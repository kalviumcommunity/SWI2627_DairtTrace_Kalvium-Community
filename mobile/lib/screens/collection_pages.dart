part of '../app_shell.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, this.service});
  final OperationsService? service;
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final service = widget.service ?? OperationsService();
  late Stream<List<OperationalRecord>> farmers = service.watch('farmers');
  late Stream<List<OperationalRecord>> centers = service.watch(
    'collectionCenters',
  );
  String query = '';
  bool showFarmers = true;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _PageHeader(
        title: 'Users',
        subtitle: 'Your dairy community',
        icon: Icons.people_outline,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Farmers'),
                    selected: showFarmers,
                    onSelected: (_) => setState(() => showFarmers = true),
                  ),
                ),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Centres'),
                    selected: !showFarmers,
                    onSelected: (_) => setState(() => showFarmers = false),
                  ),
                ),
                IconButton(
                  tooltip: 'Register farmer or centre',
                  onPressed: () => _open(context, const DirectoryPage()),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: _searchDecoration('Search name, phone or ID'),
              onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      Expanded(
        child: StreamBuilder<List<OperationalRecord>>(
          stream: showFarmers ? farmers : centers,
          builder: (context, s) {
            if (s.hasError) {
              return _LoadError(
                onRetry: () => setState(() {
                  farmers = service.watch('farmers');
                  centers = service.watch('collectionCenters');
                }),
              );
            }
            if (!s.hasData) return const _LoadingCard();
            final records =
                s.data!
                    .where(
                      (r) =>
                          '${r.id} ${r.text('name')} ${r.text('phone')} ${r.text('village')}'
                              .toLowerCase()
                              .contains(query),
                    )
                    .toList()
                  ..sort((a, b) => a.text('name').compareTo(b.text('name')));
            if (records.isEmpty) {
              return _EmptyCard(
                icon: Icons.people_outline,
                title: 'No matching ${showFarmers ? 'farmers' : 'centres'}',
                message: 'Register your community to start collecting.',
                action: 'Register',
                onAction: () => _open(context, const DirectoryPage()),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: records.length,
              itemBuilder: (context, i) {
                final r = records[i];
                return Card(
                  color: Colors.white,
                  elevation: 0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE3F5EB),
                      child: Text(
                        r.text('name', '?').substring(0, 1),
                        style: const TextStyle(color: _green),
                      ),
                    ),
                    title: Text(
                      r.text('name'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${showFarmers ? 'Farmer' : 'Centre'} · ${_shortId(r.id)}\n${r.text(showFarmers ? 'phone' : 'village')}',
                    ),
                    trailing: _QualityPill(status: r.text('status')),
                    onTap: () => _open(
                      context,
                      FarmerProfilePage(
                        record: r,
                        isFarmer: showFarmers,
                        service: service,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ],
  );
}

class FarmerProfilePage extends StatelessWidget {
  const FarmerProfilePage({
    super.key,
    required this.record,
    this.isFarmer = true,
    required this.service,
  });
  final OperationalRecord record;
  final bool isFarmer;
  final OperationsService service;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(isFarmer ? 'Farmer Details' : 'Centre Details')),
    body: StreamBuilder<List<OperationalRecord>>(
      stream: service.watch('collections'),
      builder: (context, s) {
        if (s.hasError) return const _LoadError();
        if (!s.hasData) return const _LoadingCard();
        final records = s.data!
            .where(
              (r) => r.text(isFarmer ? 'farmerId' : 'centerId') == record.id,
            )
            .toList();
        final total = FarmerTotal(record.id, record.text('name'));
        for (final r in records) {
          total.add(r);
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFFE3F5EB),
                  child: Text(
                    record.text('name', '?').substring(0, 1),
                    style: const TextStyle(fontSize: 28, color: _green),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.text('name'),
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _shortId(record.id),
                        style: const TextStyle(color: _mutedText),
                      ),
                      const SizedBox(height: 8),
                      _QualityPill(status: record.text('status')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(
              label: 'Village / address',
              value: record.text('village'),
            ),
            if (isFarmer)
              _DetailRow(label: 'Phone', value: record.text('phone')),
            if (isFarmer)
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: service.db
                    .collection('collectionCenters')
                    .doc(record.text('centerId'))
                    .get(),
                builder: (context, s) => _DetailRow(
                  label: 'Collection centre',
                  value:
                      s.data?.data()?['name'] as String? ??
                      _shortId(record.text('centerId')),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    label: 'Total collected',
                    value: '${total.litres.toStringAsFixed(1)} L',
                    icon: Icons.local_drink_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryTile(
                    label: 'Average fat',
                    value: _measure(total.averageFat, '%'),
                    icon: Icons.science_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Collection History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (records.isEmpty)
              const _EmptyCard(
                icon: Icons.history,
                title: 'No collections yet',
                message: 'Only records linked to this ID appear here.',
              ),
            ...records.map(
              (r) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('MC-${_shortId(r.id)}'),
                subtitle: Text(
                  '${r.number('quantityLitres')} L · ${_formatDate(r.date)}',
                ),
                trailing: _QualityPill(
                  status: r.text('qualityStatus', 'UNKNOWN'),
                ),
                onTap: () => _open(
                  context,
                  _CollectionDetailsPage(id: r.id, collection: r.data),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class NewCollectionPage extends StatefulWidget {
  const NewCollectionPage({super.key, this.directory, this.collectionService});
  final DirectoryService? directory;
  final CollectionService? collectionService;
  @override
  State<NewCollectionPage> createState() => _NewCollectionPageState();
}

class _NewCollectionPageState extends State<NewCollectionPage> {
  late final directory = widget.directory ?? DirectoryService();
  late final service = widget.collectionService ?? CollectionService();
  late Stream<List<DirectoryEntry>> farmers = directory.watchFarmers();
  late Stream<List<DirectoryEntry>> centers = directory.watchCenters();
  final form = GlobalKey<FormState>();
  final quantity = TextEditingController(),
      fat = TextEditingController(),
      snf = TextEditingController(),
      temperature = TextEditingController(),
      notes = TextEditingController();
  String? farmerId;
  String session = DateTime.now().hour < 12 ? 'MORNING' : 'EVENING';
  DateTime date = DateTime.now();
  bool saving = false;
  @override
  void dispose() {
    for (final c in [quantity, fat, snf, temperature, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New Collection')),
    body: StreamBuilder<List<DirectoryEntry>>(
      stream: centers,
      builder: (context, cs) => StreamBuilder<List<DirectoryEntry>>(
        stream: farmers,
        builder: (context, fs) {
          if (cs.hasError || fs.hasError) {
            return _LoadError(
              onRetry: () => setState(() {
                centers = directory.watchCenters();
                farmers = directory.watchFarmers();
              }),
            );
          }
          if (!cs.hasData || !fs.hasData) return const _LoadingCard();
          final activeCenters = cs.data!.where((c) => c.status == 'ACTIVE');
          final activeFarmers = fs.data!
              .where(
                (f) =>
                    f.status == 'ACTIVE' &&
                    activeCenters.any((c) => c.id == f.centerId),
              )
              .toList();
          if (activeFarmers.isEmpty) {
            return _EmptyCard(
              icon: Icons.person_add_outlined,
              title: 'Register a farmer first',
              message: 'A collection needs a registered farmer and an active centre.',
              action: 'Farmers & Centres',
              onAction: () => _open(context, const DirectoryPage()),
            );
          }
          final selected = activeFarmers
              .where((f) => f.id == farmerId)
              .firstOrNull;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey(activeFarmers.map((f) => f.id).join(',')),
                      initialValue: selected?.id,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Farmer',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: activeFarmers
                          .map(
                            (f) => DropdownMenuItem(
                              value: f.id,
                              child: Text(
                                '${f.name} (${_shortId(f.id)})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: saving
                          ? null
                          : (v) => setState(() => farmerId = v),
                      validator: (_) =>
                          selected == null ? 'Select an active farmer.' : null,
                    ),
                    if (selected != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Centre: ${activeCenters.firstWhere((c) => c.id == selected.centerId).name}',
                          style: const TextStyle(color: _mutedText),
                        ),
                      ),
                    const SizedBox(height: 18),
                    const Text(
                      'Date & Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                            ),
                            label: Text(_formatDate(date)),
                            onPressed: saving
                                ? null
                                : () async {
                                    final chosen = await showDatePicker(
                                      context: context,
                                      initialDate: date,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (chosen != null && mounted) {
                                      setState(
                                        () => date = DateTime(
                                          chosen.year,
                                          chosen.month,
                                          chosen.day,
                                          date.hour,
                                          date.minute,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.schedule, size: 18),
                            label: Text(
                              TimeOfDay.fromDateTime(date).format(context),
                            ),
                            onPressed: saving
                                ? null
                                : () async {
                                    final t = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(date),
                                    );
                                    if (t != null && mounted) {
                                      setState(
                                        () => date = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          t.hour,
                                          t.minute,
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: session,
                      decoration: const InputDecoration(
                        labelText: 'Collection session',
                      ),
                      items: ['MORNING', 'EVENING']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: saving
                          ? null
                          : (v) => setState(() => session = v!),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: quantity,
                      enabled: !saving,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantity (Litres)',
                        suffixText: 'L',
                      ),
                      validator: validateMilkQuantity,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Quality Parameters',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final fields = [
                          _reading(fat, 'Fat %', true),
                          _reading(snf, 'SNF %', true),
                          _reading(temperature, 'Temp °C', false),
                        ];
                        return constraints.maxWidth < 310
                            ? Column(
                                children: fields
                                    .map(
                                      (f) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: f,
                                      ),
                                    )
                                    .toList(),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: fields[0]),
                                  const SizedBox(width: 8),
                                  Expanded(child: fields[1]),
                                  const SizedBox(width: 8),
                                  Expanded(child: fields[2]),
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Demo limits: Fat ≥3% · SNF ≥8% · Temperature ≤10°C',
                      style: TextStyle(fontSize: 11, color: _mutedText),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: notes,
                      enabled: !saving,
                      maxLines: 3,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Enter notes…',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: saving
                          ? null
                          : () async {
                              if (!form.currentState!.validate() ||
                                  selected == null) {
                                return;
                              }
                              setState(() => saving = true);
                              try {
                                final quality = QualityChecker.check(
                                  fat: double.parse(fat.text.trim()),
                                  snf: double.parse(snf.text.trim()),
                                  temperature: double.parse(
                                    temperature.text.trim(),
                                  ),
                                );
                                await service.addCollection(
                                  farmerName: selected.name,
                                  quantityLitres: double.parse(
                                    quantity.text.trim(),
                                  ),
                                  fat: double.parse(fat.text.trim()),
                                  snf: double.parse(snf.text.trim()),
                                  temperature: double.parse(
                                    temperature.text.trim(),
                                  ),
                                  farmerId: selected.id,
                                  centerId: selected.centerId,
                                  session: session,
                                  occurredAt: date,
                                  notes: notes.text,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  if (quality.isAccepted) {
                                    UserFeedback.showSuccess(
                                      context,
                                      message:
                                          'Collection saved. Quality ACCEPTED.',
                                    );
                                  } else {
                                    UserFeedback.showError(
                                      context,
                                      message:
                                          'Collection saved. ALERT: ${quality.message}',
                                    );
                                  }
                                }
                              } catch (error) {
                                if (context.mounted) {
                                  UserFeedback.showError(
                                    context,
                                    message: error is StateError
                                        ? error.message
                                        : error is ArgumentError
                                        ? '${error.message}'
                                        : 'Could not save. Check your connection and access.',
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => saving = false);
                              }
                            },
                      child: Text(saving ? 'Saving…' : 'Save Collection'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
  Widget _reading(
    TextEditingController controller,
    String label,
    bool percent,
  ) => TextFormField(
    controller: controller,
    enabled: !saving,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
    ),
    validator: (v) =>
        validateQualityReading(v, label: label, percentage: percent),
  );
}
