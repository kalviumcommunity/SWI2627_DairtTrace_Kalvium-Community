import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'services/collection_service.dart';

const _green = Color(0xFF00866A);
const _deepGreen = Color(0xFF183C32);
const _pageBackground = Color(0xFFF5F9F7);
const _mutedText = Color(0xFF71867D);

class DairyTraceSplashScreen extends StatelessWidget {
  const DairyTraceSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF7),
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -85,
            child: _SplashCircle(size: 270, color: const Color(0xFFDDF2E5)),
          ),
          Positioned(
            bottom: -130,
            left: -85,
            child: _SplashCircle(size: 300, color: const Color(0xFFE6F4E9)),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(34),
                      boxShadow: [
                        BoxShadow(
                          color: _deepGreen.withValues(alpha: 0.08),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: _green,
                      size: 62,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'DairyTrace',
                    style: TextStyle(
                      color: _deepGreen,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Trace · Trust · Together',
                    style: TextStyle(
                      color: _mutedText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashCircle extends StatelessWidget {
  const _SplashCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class DairyTraceShell extends StatefulWidget {
  const DairyTraceShell({super.key, required this.onNewCollection});

  final VoidCallback onNewCollection;

  @override
  State<DairyTraceShell> createState() => _DairyTraceShellState();
}

class _DairyTraceShellState extends State<DairyTraceShell> {
  final _collectionService = CollectionService();
  late Stream<QuerySnapshot<Map<String, dynamic>>> _collections;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _refreshCollections();
  }

  void _refreshCollections() {
    _collections = _collectionService.watchDocuments();
  }

  void _openCollectionForm() {
    widget.onNewCollection();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _HomeTab(
        collections: _collections,
        onRefresh: () => setState(_refreshCollections),
        onNewCollection: _openCollectionForm,
        onOpenModule: _openModule,
      ),
      _FarmersTab(collections: _collections),
      _BatchesTab(onNewCollection: _openCollectionForm),
      _MoreTab(onOpenModule: _openModule),
    ];

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: IndexedStack(index: _selectedTab, children: tabs),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: 'new-collection',
        tooltip: 'New collection',
        onPressed: _openCollectionForm,
        backgroundColor: _green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
                selected: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0),
              ),
              _NavItem(
                icon: Icons.people_outline_rounded,
                selectedIcon: Icons.people_rounded,
                label: 'Users',
                selected: _selectedTab == 1,
                onTap: () => setState(() => _selectedTab = 1),
              ),
              const SizedBox(width: 48),
              _NavItem(
                icon: Icons.inventory_2_outlined,
                selectedIcon: Icons.inventory_2_rounded,
                label: 'Batches',
                selected: _selectedTab == 2,
                onTap: () => setState(() => _selectedTab = 2),
              ),
              _NavItem(
                icon: Icons.more_horiz_rounded,
                selectedIcon: Icons.more_horiz_rounded,
                label: 'More',
                selected: _selectedTab == 3,
                onTap: () => setState(() => _selectedTab = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openModule(String title) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => _ModulePage(title: title)));
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _green : _mutedText;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? selectedIcon : icon, size: 21, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.collections,
    required this.onRefresh,
    required this.onNewCollection,
    required this.onOpenModule,
  });

  final Stream<QuerySnapshot<Map<String, dynamic>>> collections;
  final VoidCallback onRefresh;
  final VoidCallback onNewCollection;
  final ValueChanged<String> onOpenModule;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: collections,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final now = DateTime.now();
        final monthDocs = docs.where((doc) {
          final timestamp = doc.data()['collectionDate'] as Timestamp?;
          if (timestamp == null) return false;
          final date = timestamp.toDate().toLocal();
          return date.year == now.year && date.month == now.month;
        }).toList();
        final totalLitres = monthDocs.fold<double>(
          0,
          (total, doc) =>
              total + ((doc.data()['quantityLitres'] as num?)?.toDouble() ?? 0),
        );
        final farmers = docs
            .map((doc) => doc.data()['farmerName'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .length;
        final qualityTests = monthDocs.where((doc) {
          final data = doc.data();
          return data['fat'] != null ||
              data['snf'] != null ||
              data['temperature'] != null;
        }).length;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _HomeHeader(
                    onNotifications: () => onOpenModule('Notifications'),
                  ),
                  const SizedBox(height: 20),
                  _MonthSelector(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: 'Total Collections',
                          value: _metricValue(snapshot, '${monthDocs.length}'),
                          suffix: 'records',
                          icon: Icons.water_drop_rounded,
                          color: const Color(0xFFDCF6E9),
                          iconColor: _green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          label: 'Milk Collected',
                          value: _metricValue(
                            snapshot,
                            totalLitres.toStringAsFixed(1),
                          ),
                          suffix: 'litres',
                          icon: Icons.local_drink_rounded,
                          color: const Color(0xFFE9F1FF),
                          iconColor: const Color(0xFF4779CE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: 'Active Farmers',
                          value: _metricValue(snapshot, '$farmers'),
                          suffix: 'farmers',
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xFFFFF1DF),
                          iconColor: const Color(0xFFE8983F),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          label: 'Quality Tests',
                          value: _metricValue(snapshot, '$qualityTests'),
                          suffix: 'recorded',
                          icon: Icons.verified_rounded,
                          color: const Color(0xFFF0EAFE),
                          iconColor: const Color(0xFF8A65CC),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionHeading(
                    title: 'Recent Activity',
                    action: 'View all',
                    onAction: () => onOpenModule('Collections'),
                  ),
                  const SizedBox(height: 10),
                  if (snapshot.hasError)
                    _LoadError(onRetry: onRefresh)
                  else if (snapshot.connectionState == ConnectionState.waiting)
                    const _LoadingCard()
                  else if (docs.isEmpty)
                    _EmptyCard(
                      icon: Icons.water_drop_outlined,
                      title: 'No collections yet',
                      message: 'Your latest milk collection records will appear here.',
                      action: 'Record a collection',
                      onAction: onNewCollection,
                    )
                  else
                    ...docs.take(4).map((doc) {
                      final data = doc.data();
                      final timestamp = data['collectionDate'] as Timestamp?;
                      return _ActivityTile(
                        title: data['farmerName'] as String? ?? 'Farmer',
                        subtitle: timestamp == null
                            ? 'Collection date pending'
                            : _formatDate(timestamp.toDate()),
                        trailing:
                            '${((data['quantityLitres'] as num?) ?? 0).toStringAsFixed(1)} L',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => _CollectionDetailsPage(
                              id: doc.id,
                              collection: data,
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 22),
                  _SectionHeading(
                    title: 'Quick access',
                    action: null,
                    onAction: null,
                  ),
                  const SizedBox(height: 10),
                  _QuickAccessGrid(onOpenModule: onOpenModule),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _metricValue(
  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  String value,
) {
  if (snapshot.hasError) return '--';
  if (snapshot.connectionState == ConnectionState.waiting) return '...';
  return value;
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onNotifications});

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final displayName = FirebaseAuth.instance.currentUser?.displayName
        ?.trim()
        .split(' ')
        .first;
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFD9F2E6),
          child: Text(
            (displayName?.isNotEmpty == true ? displayName![0] : 'D')
                .toUpperCase(),
            style: const TextStyle(color: _green, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good morning,',
                style: TextStyle(color: _mutedText, fontSize: 12),
              ),
              Text(
                displayName?.isNotEmpty == true ? displayName! : 'Admin',
                style: const TextStyle(
                  color: _deepGreen,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotifications,
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_none_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _deepGreen,
          ),
        ),
      ],
    );
  }
}

class _MonthSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EEEA)),
      ),
      child: const Row(
        children: [
          Icon(Icons.calendar_month_outlined, color: _green, size: 18),
          SizedBox(width: 8),
          Text('This Month', style: TextStyle(fontWeight: FontWeight.w600)),
          Spacer(),
          Icon(Icons.keyboard_arrow_down_rounded, color: _mutedText),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  final String label;
  final String value;
  final String suffix;
  final IconData icon;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE7EEEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _mutedText, fontSize: 11),
          ),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _deepGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  suffix,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _mutedText, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _deepGreen,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: _green,
              padding: EdgeInsets.zero,
            ),
            child: Text(action!),
          ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE7EEEA)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 17,
                  backgroundColor: Color(0xFFE3F5EB),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: _green,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _deepGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(color: _mutedText, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Text(
                  trailing,
                  style: const TextStyle(
                    color: _deepGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.onOpenModule});

  final ValueChanged<String> onOpenModule;

  static const _items = [
    ('Quality Tests', Icons.science_outlined, Color(0xFFEFE8FF)),
    (
      'Reconciliation',
      Icons.account_balance_wallet_outlined,
      Color(0xFFFFEFDB),
    ),
    ('Disputes', Icons.report_gmailerrorred_outlined, Color(0xFFFFE6E6)),
    ('Reports', Icons.bar_chart_rounded, Color(0xFFE4F0FF)),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.65,
      children: _items
          .map(
            (item) => InkWell(
              onTap: () => onOpenModule(item.$1),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE7EEEA)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: item.$3,
                      child: Icon(item.$2, size: 17, color: _deepGreen),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.$1,
                        style: const TextStyle(
                          color: _deepGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FarmersTab extends StatefulWidget {
  const _FarmersTab({required this.collections});

  final Stream<QuerySnapshot<Map<String, dynamic>>> collections;

  @override
  State<_FarmersTab> createState() => _FarmersTabState();
}

class _FarmersTabState extends State<_FarmersTab> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: widget.collections,
      builder: (context, snapshot) {
        final farmerTotals = <String, double>{};
        for (final doc in snapshot.data?.docs ?? []) {
          final data = doc.data();
          final name = data['farmerName'] as String? ?? '';
          if (name.isNotEmpty) {
            farmerTotals.update(
              name,
              (total) =>
                  total + ((data['quantityLitres'] as num?)?.toDouble() ?? 0),
              ifAbsent: () => (data['quantityLitres'] as num?)?.toDouble() ?? 0,
            );
          }
        }
        final farmers =
            farmerTotals.entries
                .where((entry) => entry.key.toLowerCase().contains(_search))
                .toList()
              ..sort((a, b) => a.key.compareTo(b.key));

        return Column(
          children: [
            _PageHeader(
              title: 'Farmers',
              subtitle: '${farmerTotals.length} registered farmers',
              icon: Icons.people_alt_outlined,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                onChanged: (value) =>
                    setState(() => _search = value.trim().toLowerCase()),
                decoration: _searchDecoration('Search by name or phone'),
              ),
            ),
            Expanded(
              child: snapshot.hasError
                  ? const _LoadError()
                  : snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : farmers.isEmpty
                  ? _EmptyCard(
                      icon: Icons.people_outline_rounded,
                      title: _search.isEmpty
                          ? 'No farmers yet'
                          : 'No matching farmers',
                      message: _search.isEmpty
                          ? 'Farmers will be listed here after their first collection is recorded.'
                          : 'Try a different search term.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: farmers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 9),
                      itemBuilder: (context, index) {
                        final farmer = farmers[index];
                        return _FarmerCard(
                          name: farmer.key,
                          totalLitres: farmer.value,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => _FarmerDetailsPage(
                                name: farmer.key,
                                totalLitres: farmer.value,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FarmerCard extends StatelessWidget {
  const _FarmerCard({
    required this.name,
    required this.totalLitres,
    required this.onTap,
  });

  final String name;
  final double totalLitres;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFE7EEEA)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE3F5EB),
          child: Text(
            name.isEmpty ? '?' : name[0].toUpperCase(),
            style: const TextStyle(color: _green, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: _deepGreen,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${totalLitres.toStringAsFixed(1)} L total recorded',
          style: const TextStyle(color: _mutedText, fontSize: 11),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: _mutedText),
      ),
    );
  }
}

class _FarmerDetailsPage extends StatelessWidget {
  const _FarmerDetailsPage({required this.name, required this.totalLitres});

  final String name;
  final double totalLitres;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(title: const Text('Farmer Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE7EEEA)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFE3F5EB),
                  child: Text(
                    name.isEmpty ? '?' : name[0].toUpperCase(),
                    style: const TextStyle(
                      color: _green,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    color: _deepGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Farmer', style: TextStyle(color: _mutedText)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            label: 'Total milk collected',
            value: '${totalLitres.toStringAsFixed(1)} L',
          ),
          const _DetailRow(label: 'Account status', value: 'Active'),
          const SizedBox(height: 14),
          const Text(
            'Collection history',
            style: TextStyle(
              color: _deepGreen,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const _EmptyCard(
            icon: Icons.history_rounded,
            title: 'Collection history',
            message:
                'Individual collection history is available in Collections.',
          ),
        ],
      ),
    );
  }
}

class _BatchesTab extends StatelessWidget {
  const _BatchesTab({required this.onNewCollection});

  final VoidCallback onNewCollection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _PageHeader(
          title: 'Batch tracking',
          subtitle: 'Follow milk from collection to processing',
          icon: Icons.inventory_2_outlined,
        ),
        Expanded(
          child: _EmptyCard(
            icon: Icons.inventory_2_outlined,
            title: 'No batches yet',
            message: 'Batch records will appear here once collections are grouped for processing.',
            action: 'Create a collection',
            onAction: onNewCollection,
          ),
        ),
      ],
    );
  }
}

class _MoreTab extends StatelessWidget {
  const _MoreTab({required this.onOpenModule});

  final ValueChanged<String> onOpenModule;

  static const _modules = [
    ('Quality Tests', 'Review milk quality results', Icons.science_outlined),
    (
      'Reconciliation',
      'Collection totals and farmer payouts',
      Icons.account_balance_wallet_outlined,
    ),
    ('Disputes', 'Track and resolve reported issues', Icons.gavel_rounded),
    ('Reports', 'Collection and quality summaries', Icons.bar_chart_rounded),
    ('Notifications', 'Stay up to date', Icons.notifications_none_rounded),
    ('Settings', 'Account and app preferences', Icons.settings_outlined),
    ('Help & Support', 'Get help with DairyTrace', Icons.help_outline_rounded),
    ('About', 'Learn about DairyTrace', Icons.info_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return Column(
      children: [
        const _PageHeader(
          title: 'More',
          subtitle: 'Tools and account settings',
          icon: Icons.grid_view_rounded,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE7EEEA)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFE3F5EB),
                      child: Icon(Icons.person_outline, color: _green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DairyTrace Admin',
                            style: TextStyle(
                              color: _deepGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ..._modules.map(
                (module) => _ModuleListTile(
                  title: module.$1,
                  subtitle: module.$2,
                  icon: module.$3,
                  onTap: () => onOpenModule(module.$1),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Unable to sign out: $error')),
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD34F4F),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: Color(0xFFF2CCCC)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModulePage extends StatelessWidget {
  const _ModulePage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final data =
        _moduleContent[title] ??
        const _ModuleContent(
          icon: Icons.info_outline_rounded,
          description: 'DairyTrace',
          items: [],
        );

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(title: Text(title), backgroundColor: _pageBackground),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE7EEEA)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE3F5EB),
                  child: Icon(data.icon, color: _green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.description,
                    style: const TextStyle(
                      color: _deepGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (title == 'Reports')
            const _ReportsSummary()
          else if (title == 'Reconciliation')
            const _ReconciliationSummary()
          else if (title == 'Quality Tests')
            const _QualitySummary()
          else if (title == 'Collections')
            const _CollectionsSummary()
          else
            ...data.items.map(
              (item) => _ModuleListTile(
                title: item.$1,
                subtitle: item.$2,
                icon: item.$3,
                trailing: item.$4,
              ),
            ),
        ],
      ),
    );
  }
}

class _ModuleContent {
  const _ModuleContent({
    required this.icon,
    required this.description,
    required this.items,
  });

  final IconData icon;
  final String description;
  final List<(String, String, IconData, String?)> items;
}

const _moduleContent = <String, _ModuleContent>{
  'Quality Tests': _ModuleContent(
    icon: Icons.science_outlined,
    description: 'Monitor milk quality and test results.',
    items: [
      (
        'No test records',
        'Quality test history will show here.',
        Icons.biotech_outlined,
        null,
      ),
    ],
  ),
  'Reconciliation': _ModuleContent(
    icon: Icons.account_balance_wallet_outlined,
    description: 'Review collection totals and farmer payouts.',
    items: [
      (
        'Current period',
        'No payout records available yet.',
        Icons.receipt_long_outlined,
        null,
      ),
    ],
  ),
  'Disputes': _ModuleContent(
    icon: Icons.gavel_rounded,
    description: 'Review and resolve collection disputes.',
    items: [
      (
        'No open disputes',
        'New dispute reports will appear here.',
        Icons.check_circle_outline,
        'Resolved',
      ),
    ],
  ),
  'Reports': _ModuleContent(
    icon: Icons.bar_chart_rounded,
    description: 'View collection and quality summaries.',
    items: [],
  ),
  'Notifications': _ModuleContent(
    icon: Icons.notifications_none_rounded,
    description: 'Updates about DairyTrace activity.',
    items: [
      (
        'You are all caught up',
        'New notifications will appear here.',
        Icons.done_all_rounded,
        null,
      ),
    ],
  ),
  'Settings': _ModuleContent(
    icon: Icons.settings_outlined,
    description: 'Manage your DairyTrace account.',
    items: [
      (
        'Account',
        'Signed in with your Firebase account.',
        Icons.person_outline,
        null,
      ),
      (
        'Privacy',
        'Your collection records are protected.',
        Icons.lock_outline,
        null,
      ),
      ('App version', 'DairyTrace mobile', Icons.phone_android_outlined, null),
    ],
  ),
  'Help & Support': _ModuleContent(
    icon: Icons.help_outline_rounded,
    description: 'Support for your dairy collection workflow.',
    items: [
      (
        'Need help?',
        'Contact your DairyTrace administrator.',
        Icons.support_agent,
        null,
      ),
    ],
  ),
  'About': _ModuleContent(
    icon: Icons.info_outline_rounded,
    description: 'DairyTrace helps cooperatives manage transparent milk collection and traceability.',
    items: [
      (
        'DairyTrace',
        'Trace · Trust · Together',
        Icons.water_drop_outlined,
        null,
      ),
    ],
  ),
};

class _CollectionsSummary extends StatelessWidget {
  const _CollectionsSummary();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: CollectionService().watchDocuments(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _LoadError();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard();
        }
        if (snapshot.data?.docs.isEmpty ?? true) {
          return const _EmptyCard(
            icon: Icons.water_drop_outlined,
            title: 'No collections yet',
            message: 'Record a collection to start building your history.',
          );
        }
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final item = doc.data();
            return _ActivityTile(
              title: item['farmerName'] as String? ?? 'Farmer',
              subtitle: 'Milk collection',
              trailing:
                  '${((item['quantityLitres'] as num?) ?? 0).toStringAsFixed(1)} L',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      _CollectionDetailsPage(id: doc.id, collection: item),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CollectionDetailsPage extends StatelessWidget {
  const _CollectionDetailsPage({required this.id, required this.collection});

  final String id;
  final Map<String, dynamic> collection;

  @override
  Widget build(BuildContext context) {
    final date = collection['collectionDate'] as Timestamp?;
    final quantity = (collection['quantityLitres'] as num?) ?? 0;
    final fat = collection['fat'] as num?;
    final snf = collection['snf'] as num?;
    final temperature = collection['temperature'] as num?;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: const Text('Collection Details'),
        backgroundColor: _pageBackground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0xFFE7EEEA)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 23,
                  backgroundColor: Color(0xFFE3F5EB),
                  child: Icon(Icons.water_drop_rounded, color: _green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        id.length > 12 ? id.substring(0, 12) : id,
                        style: const TextStyle(
                          color: _deepGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        date == null
                            ? 'Date pending'
                            : _formatDate(date.toDate()),
                        style: const TextStyle(color: _mutedText, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const _StatusPill(text: 'Recorded'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            label: 'Farmer',
            value: collection['farmerName'] as String? ?? 'Unknown',
          ),
          _DetailRow(
            label: 'Collection session',
            value: collection['session'] as String? ?? 'Not specified',
          ),
          _DetailRow(
            label: 'Quantity',
            value: '${quantity.toStringAsFixed(1)} L',
          ),
          const SizedBox(height: 12),
          const Text(
            'Quality parameters',
            style: TextStyle(
              color: _deepGreen,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _DetailRow(
            label: 'Fat',
            value: fat == null ? 'Not recorded' : '${fat.toStringAsFixed(1)}%',
          ),
          _DetailRow(
            label: 'SNF',
            value: snf == null ? 'Not recorded' : '${snf.toStringAsFixed(1)}%',
          ),
          _DetailRow(
            label: 'Temperature',
            value: temperature == null
                ? 'Not recorded'
                : '${temperature.toStringAsFixed(1)} °C',
          ),
          if ((collection['notes'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            const Text(
              'Notes',
              style: TextStyle(
                color: _deepGreen,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Collection note',
              value: collection['notes'] as String,
            ),
          ],
        ],
      ),
    );
  }
}

class _QualitySummary extends StatelessWidget {
  const _QualitySummary();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: CollectionService().watchDocuments(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _LoadError();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard();
        }
        final tested = (snapshot.data?.docs ?? []).where((doc) {
          final data = doc.data();
          return data['fat'] != null ||
              data['snf'] != null ||
              data['temperature'] != null;
        }).toList();
        return Column(
          children: [
            _SummaryTile(
              label: 'Quality tests',
              value: '${tested.length}',
              icon: Icons.science_outlined,
            ),
            const SizedBox(height: 10),
            if (tested.isEmpty)
              const _EmptyCard(
                icon: Icons.verified_outlined,
                title: 'No test records',
                message: 'Quality results will appear here when available.',
              )
            else
              ...tested.map((doc) {
                final data = doc.data();
                final parameters = <String>[
                  if (data['fat'] != null)
                    'Fat ${(data['fat'] as num).toStringAsFixed(1)}%',
                  if (data['snf'] != null)
                    'SNF ${(data['snf'] as num).toStringAsFixed(1)}%',
                  if (data['temperature'] != null)
                    '${(data['temperature'] as num).toStringAsFixed(1)} °C',
                ].join(' · ');
                return _ActivityTile(
                  title: data['farmerName'] as String? ?? 'Farmer',
                  subtitle: parameters,
                  trailing: 'Recorded',
                );
              }),
          ],
        );
      },
    );
  }
}

class _ReconciliationSummary extends StatelessWidget {
  const _ReconciliationSummary();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SummaryTile(
          label: 'Pending payouts',
          value: '0',
          icon: Icons.payments_outlined,
        ),
        SizedBox(height: 10),
        _EmptyCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'No reconciliation records',
          message: 'Collection and payout summaries will be listed here.',
        ),
      ],
    );
  }
}

class _ReportsSummary extends StatelessWidget {
  const _ReportsSummary();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: CollectionService().watchDocuments(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _LoadError();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard();
        }
        final docs = snapshot.data?.docs ?? [];
        final litres = docs.fold<double>(
          0,
          (total, doc) =>
              total + ((doc.data()['quantityLitres'] as num?)?.toDouble() ?? 0),
        );
        final today = DateTime.now();
        final firstDay = DateTime(
          today.year,
          today.month,
          today.day,
        ).subtract(const Duration(days: 6));
        final dailyLitres = List<double>.filled(7, 0);
        for (final doc in docs) {
          final timestamp = doc.data()['collectionDate'] as Timestamp?;
          if (timestamp == null) continue;
          final date = timestamp.toDate().toLocal();
          final day = DateTime(
            date.year,
            date.month,
            date.day,
          ).difference(firstDay).inDays;
          if (day >= 0 && day < dailyLitres.length) {
            dailyLitres[day] +=
                (doc.data()['quantityLitres'] as num?)?.toDouble() ?? 0;
          }
        }
        final maxDailyLitres = dailyLitres.fold<double>(
          1,
          (max, value) => value > max ? value : max,
        );
        return Column(
          children: [
            _SummaryTile(
              label: 'Total milk collected',
              value: '${litres.toStringAsFixed(1)} L',
              icon: Icons.water_drop_outlined,
            ),
            const SizedBox(height: 10),
            _SummaryTile(
              label: 'Collection records',
              value: '${docs.length}',
              icon: Icons.receipt_long_outlined,
            ),
            const SizedBox(height: 10),
            _WeeklyCollectionChart(
              values: dailyLitres,
              maximum: maxDailyLitres,
            ),
          ],
        );
      },
    );
  }
}

class _WeeklyCollectionChart extends StatelessWidget {
  const _WeeklyCollectionChart({required this.values, required this.maximum});

  final List<double> values;
  final double maximum;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE7EEEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily collection · last 7 days',
            style: TextStyle(
              color: _deepGreen,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 128,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List<Widget>.generate(values.length, (index) {
                final day = today.subtract(
                  Duration(days: values.length - index - 1),
                );
                final barHeight = (values[index] / maximum * 88)
                    .clamp(4.0, 88.0)
                    .toDouble();
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        values[index] == 0
                            ? ''
                            : values[index].toStringAsFixed(0),
                        style: const TextStyle(color: _mutedText, fontSize: 9),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: barHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == values.length - 1
                              ? _green
                              : const Color(0xFFBDEBD4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${day.day}/${day.month}',
                        style: const TextStyle(color: _mutedText, fontSize: 9),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE7EEEA)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE3F5EB),
            child: Icon(icon, color: _green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _deepGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: _green, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ModuleListTile extends StatelessWidget {
  const _ModuleListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE7EEEA)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEAF5EF),
          child: Icon(icon, color: _green, size: 19),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: _deepGreen,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: _mutedText, fontSize: 10),
        ),
        trailing: trailing == null
            ? const Icon(Icons.chevron_right_rounded, color: _mutedText)
            : _StatusPill(text: trailing!),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F7EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _green,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _deepGreen,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: _mutedText, fontSize: 11),
                ),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: _green, size: 20),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE7EEEA)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: _green),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              color: _deepGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _mutedText, fontSize: 11),
          ),
          if (action != null) ...[
            const SizedBox(height: 10),
            FilledButton.tonal(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _EmptyCard(
      icon: Icons.cloud_off_outlined,
      title: 'Unable to load records',
      message: 'Check your connection or account access, then try again.',
      action: onRetry == null ? null : 'Try again',
      onAction: onRetry,
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE7EEEA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: _mutedText)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _deepGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _searchDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 12, color: _mutedText),
    prefixIcon: const Icon(Icons.search_rounded, color: _mutedText, size: 20),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFFE7EEEA)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFFE7EEEA)),
    ),
  );
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')} '
      '${_monthName(local.month)} ${local.year}';
}

String _monthName(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month - 1];
