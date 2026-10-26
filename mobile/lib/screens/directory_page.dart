import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../services/directory_service.dart';

class DirectoryPage extends StatefulWidget {
  const DirectoryPage({super.key, this.service});
  final DirectoryService? service;
  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  late final DirectoryService _service = widget.service ?? DirectoryService();
  late Stream<List<DirectoryEntry>> _centers = _service.watchCenters();
  late Stream<List<DirectoryEntry>> _farmers = _service.watchFarmers();
  String _search = '';

  void _retry(bool farmer) => setState(() {
    if (farmer) {
      _farmers = _service.watchFarmers();
    } else {
      _centers = _service.watchCenters();
    }
  });

  Future<void> _add(bool farmer, List<DirectoryEntry> centers) async {
    if (farmer && centers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an active collection centre first.')),
      );
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RegistrationDialog(
        service: _service,
        farmer: farmer,
        centers: centers,
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            farmer ? 'Farmer registered.' : 'Collection centre created.',
          ),
        ),
      );
      _retry(farmer);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    initialIndex: 1,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Farmers & Centres'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Farmers'),
            Tab(text: 'Centres'),
          ],
        ),
      ),
      body: TabBarView(children: [_farmerTab(), _centerTab()]),
    ),
  );

  Widget _centerTab() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Collection Centres',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Register the places where farmers deliver their milk.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _add(false, const []),
              icon: const Icon(Icons.add),
              label: const Text('Add Centre'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search centres',
                hintText: 'Name, village or centre ID',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) =>
                  setState(() => _search = value.trim().toLowerCase()),
            ),
          ],
        ),
      ),
      Expanded(
        child: StreamBuilder<List<DirectoryEntry>>(
          stream: _centers,
          builder: (context, snapshot) {
            if (snapshot.hasError) return _failure(snapshot.error, false);
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snapshot.data!;
            if (all.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No centres yet. Tap Add Centre to register your first collection location.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final matches = all
                .where(
                  (entry) => '${entry.name} ${entry.village} ${entry.id}'
                      .toLowerCase()
                      .contains(_search),
                )
                .toList();
            if (matches.isEmpty) {
              return const Center(
                child: Text('No matching centres. Try another search.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final center = matches[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.store_outlined),
                    title: Text(center.name),
                    subtitle: Text(
                      '${center.village}\n${center.status} · ID: ${center.id}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _details(center),
                  ),
                );
              },
            );
          },
        ),
      ),
    ],
  );

  void _details(DirectoryEntry center) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(center.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Centre ID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SelectableText(center.id),
            const SizedBox(height: 16),
            const Text(
              'Village / address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(center.village),
            const SizedBox(height: 16),
            Text('Status: ${center.status}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Widget _failure(Object? error, bool farmer) {
    final denied =
        error is FirebaseException && error.code == 'permission-denied';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(denied ? Icons.lock_outline : Icons.cloud_off, size: 40),
            const SizedBox(height: 12),
            Text(
              denied
                  ? 'Your account cannot access these records. Contact your administrator.'
                  : 'Unable to load records. Check your connection and retry.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _retry(farmer),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _farmerTab() => StreamBuilder<List<DirectoryEntry>>(
    stream: _centers,
    builder: (context, centersSnapshot) {
      final centers = (centersSnapshot.data ?? [])
          .where((entry) => entry.status == 'ACTIVE')
          .toList();
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: centersSnapshot.hasData
                  ? () => _add(true, centers)
                  : null,
              icon: const Icon(Icons.add),
              label: const Text('Register Farmer'),
            ),
          ),
          if (centersSnapshot.hasError)
            TextButton(
              onPressed: () => _retry(false),
              child: const Text('Centres unavailable. Retry loading centres.'),
            ),
          Expanded(
            child: StreamBuilder<List<DirectoryEntry>>(
              stream: _farmers,
              builder: (context, snapshot) {
                if (snapshot.hasError) return _failure(snapshot.error, true);
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final farmers = snapshot.data!;
                if (farmers.isEmpty) {
                  return const Center(
                    child: Text('No farmers yet. Register your first farmer.'),
                  );
                }
                return ListView.builder(
                  itemCount: farmers.length,
                  itemBuilder: (context, index) {
                    final farmer = farmers[index];
                    final matching = centers.where(
                      (entry) => entry.id == farmer.centerId,
                    );
                    return ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(farmer.name),
                      subtitle: Text(
                        'ID: ${farmer.id}\nCentre: ${matching.isEmpty ? farmer.centerId : matching.first.name}',
                      ),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

class _RegistrationDialog extends StatefulWidget {
  const _RegistrationDialog({
    required this.service,
    required this.farmer,
    required this.centers,
  });
  final DirectoryService service;
  final bool farmer;
  final List<DirectoryEntry> centers;
  @override
  State<_RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<_RegistrationDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _village = TextEditingController();
  final _phone = TextEditingController();
  String? _centerId;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _village.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.farmer) {
        await widget.service.addFarmer(
          name: _name.text,
          village: _village.text,
          phone: _phone.text,
          centerId: _centerId!,
        );
      } else {
        await widget.service.addCenter(
          name: _name.text,
          village: _village.text,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on FirebaseException catch (error) {
      if (mounted) {
        setState(
          () => _error = error.code == 'permission-denied'
              ? 'You do not have permission to register this record.'
              : 'Could not save. Check your connection and try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Could not save. Check the details and selected centre.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: Text(widget.farmer ? 'Register Farmer' : 'Add Collection Centre'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                enabled: !_saving,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => (value?.trim().length ?? 0) < 2
                    ? 'Enter at least 2 characters.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _village,
                enabled: !_saving,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Village / address',
                ),
                validator: (value) => (value?.trim().length ?? 0) < 2
                    ? 'Enter village/address.'
                    : null,
              ),
              if (widget.farmer) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  enabled: !_saving,
                  keyboardType: TextInputType.phone,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    labelText: 'Contact number',
                  ),
                  validator: (value) =>
                      RegExp(r'^\+?[0-9][0-9 -]{5,18}[0-9]$')
                          .hasMatch(value?.trim() ?? '')
                      ? null
                      : 'Enter a valid contact number.',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _centerId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Collection centre',
                  ),
                  items: widget.centers
                      .map(
                        (center) => DropdownMenuItem(
                          value: center.id,
                          child: Text(
                            '${center.name} · ${center.id}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _centerId = value),
                  validator: (value) =>
                      value == null ? 'Select a centre.' : null,
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (_saving)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('Saving… Waiting for confirmation.'),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving…' : 'Save'),
        ),
      ],
    ),
  );
}
