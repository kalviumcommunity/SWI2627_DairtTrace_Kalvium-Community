import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'services/collection_service.dart';
import 'services/operations_service.dart';
import 'services/directory_service.dart';
import 'screens/directory_page.dart';
import 'utils/quality_checker.dart';
import 'utils/user_feedback.dart';
import 'form_validators.dart';

import 'package:flutter/services.dart';

part 'screens/operations_pages.dart';
part 'screens/collection_pages.dart';

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
  const DairyTraceShell({
    super.key,
    required this.onNewCollection,
    this.collectionService,
    this.operations,
    this.auth,
  });
  final CollectionService? collectionService;
  final OperationsService? operations;
  final FirebaseAuth? auth;

  final VoidCallback onNewCollection;

  @override
  State<DairyTraceShell> createState() => _DairyTraceShellState();
}

class _DairyTraceShellState extends State<DairyTraceShell> {
  late final _collectionService =
      widget.collectionService ?? CollectionService();
  late final operations = widget.operations ?? OperationsService();
  late final auth = widget.auth ?? FirebaseAuth.instance;
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
        displayName: auth.currentUser?.displayName ?? 'Operator',
        collections: _collections,
        onRefresh: () => setState(_refreshCollections),
        onNewCollection: _openCollectionForm,
        onOpenModule: _openModule,
      ),
      UsersPage(service: operations),
      OperationsPage(module: 'Batches', embedded: true, service: operations),
      _MoreTab(onOpenModule: _openModule, auth: auth),
    ];

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: IndexedStack(index: _selectedTab, children: tabs),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: 'new-collection',
        elevation: 0,
        highlightElevation: 0,
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ['Settings', 'Help & Support', 'About'].contains(title)
            ? _InformationPage(title: title)
            : OperationsPage(module: title, service: operations),
      ),
    );
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

class _HomeTab extends StatefulWidget {
  const _HomeTab({
    required this.displayName,
    required this.collections,
    required this.onRefresh,
    required this.onNewCollection,
    required this.onOpenModule,
  });

  final String displayName;
  final Stream<QuerySnapshot<Map<String, dynamic>>> collections;
  final VoidCallback onRefresh;
  final VoidCallback onNewCollection;
  final ValueChanged<String> onOpenModule;
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  Widget build(BuildContext context) {
    final onOpenModule = widget.onOpenModule;
    final onNewCollection = widget.onNewCollection;
    final onRefresh = widget.onRefresh;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: widget.collections,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final now = month;
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
        final farmers = monthDocs
            .map((doc) => doc.data()['farmerId'] as String? ?? '')
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
                    displayName: widget.displayName,
                    onNotifications: () => onOpenModule('Notifications'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Previous month',
                        onPressed: () => setState(
                          () => month = DateTime(month.year, month.month - 1),
                        ),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          '${_monthName(month.month)} ${month.year}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next month',
                        onPressed:
                            month.isBefore(
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                              ),
                            )
                            ? () => setState(
                                () => month = DateTime(
                                  month.year,
                                  month.month + 1,
                                ),
                              )
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
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
                          label: 'Farmers Served',
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
  const _HomeHeader({required this.onNotifications, required this.displayName});
  final String displayName;

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFD9F2E6),
          child: Text(
            (displayName.isNotEmpty ? displayName[0] : 'D').toUpperCase(),
            style: const TextStyle(color: _green, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTime.now().hour < 12
                    ? 'Good morning,'
                    : DateTime.now().hour < 17
                    ? 'Good afternoon,'
                    : 'Good evening,',
                style: TextStyle(color: _mutedText, fontSize: 12),
              ),
              Text(
                displayName.isNotEmpty ? displayName : 'Operator',
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
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
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
              Text(
                suffix,
                style: const TextStyle(color: _mutedText, fontSize: 10),
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

class _MoreTab extends StatelessWidget {
  const _MoreTab({required this.onOpenModule, required this.auth});
  final FirebaseAuth auth;

  final ValueChanged<String> onOpenModule;

  static const _modules = [
    ('Quality Tests', 'Review milk quality results', Icons.science_outlined),
    (
      'Reconciliation',
      'Farmer quantity and quality totals',
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
    final email = auth.currentUser?.email ?? '';
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
                            'DairyTrace Operator',
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
                    await auth.signOut();
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to sign out. Please try again.'),
                      ),
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
                _QualityPill(
                  status: collection['qualityStatus'] as String? ?? 'UNKNOWN',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            label: 'Centre',
            value:
                collection['centerName'] as String? ??
                'Legacy record · not linked',
          ),
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
          const SizedBox(height: 16),
          _CollectionActions(id: id, collection: collection),
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

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE7EEEA)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFE3F5EB),
          child: Icon(icon, color: _green, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: _mutedText, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: _deepGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ModuleListTile extends StatelessWidget {
  const _ModuleListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFE7EEEA)),
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
        trailing: const Icon(Icons.chevron_right_rounded, color: _mutedText),
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: _deepGreen,
                fontWeight: FontWeight.w700,
              ),
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

class _InformationPage extends StatelessWidget {
  const _InformationPage({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (title == 'Settings') ...[
          _DetailRow(
            label: 'Signed in',
            value: FirebaseAuth.instance.currentUser?.email ?? '',
          ),
          const _DetailRow(label: 'Access', value: 'Your account records'),
          const _DetailRow(
            label: 'Quality thresholds',
            value: 'Demo: Fat 3% · SNF 8% · Max 10°C',
          ),
          const _DetailRow(label: 'Pricing', value: 'Not configured'),
          OutlinedButton(
            onPressed: () async {
              try {
                final email = FirebaseAuth.instance.currentUser?.email;
                if (email != null) {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                }
                if (context.mounted) {
                  UserFeedback.showInfo(
                    context,
                    message: 'Password reset instructions requested. Check your inbox.',
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  UserFeedback.showError(
                    context,
                    message: 'Unable to send reset email. Try again.',
                  );
                }
              }
            },
            child: const Text('Send password reset email'),
          ),
        ] else if (title == 'Help & Support') ...[
          const Text(
            'Your collection workflow',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            '1. Register a centre and farmer in Users.\n\n2. Tap + to record quantity and quality readings.\n\n3. Group compatible records in Batches, then record a quality result.\n\n4. Open any collection to report a dispute.\n\n5. Review monthly totals and copy reports as CSV.\n\nIf a save fails, check your connection and ask your project administrator to verify account access and deployed database rules.',
          ),
        ] else ...[
          const Text(
            'DairyTrace',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text('Trace · Trust · Together'),
          const SizedBox(height: 20),
          const Text(
            'Version 1.0.0\nMilk collection, quality monitoring and source-to-batch traceability.\n\nQuality thresholds are demonstration values. Reconciliation reports quantity and weighted quality totals; it does not calculate payments.',
          ),
        ],
      ],
    ),
  );
}

class _CollectionActions extends StatefulWidget {
  const _CollectionActions({required this.id, required this.collection});
  final String id;
  final Map<String, dynamic> collection;
  @override
  State<_CollectionActions> createState() => _CollectionActionsState();
}

class _CollectionActionsState extends State<_CollectionActions> {
  bool busy = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (widget.collection['farmerId'] is String)
        OutlinedButton.icon(
          icon: const Icon(Icons.person_outline),
          label: const Text('View Farmer'),
          onPressed: busy
              ? null
              : () async {
                  setState(() => busy = true);
                  try {
                    final service = OperationsService();
                    final doc = await service.db
                        .collection('farmers')
                        .doc(widget.collection['farmerId'] as String)
                        .get();
                    if (context.mounted && doc.exists) {
                      _open(
                        context,
                        FarmerProfilePage(
                          record: OperationalRecord(doc.id, doc.data()!),
                          service: service,
                        ),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      UserFeedback.showError(
                        context,
                        message: 'Unable to load farmer.',
                      );
                    }
                  } finally {
                    if (mounted) setState(() => busy = false);
                  }
                },
        ),
      if (widget.collection['batchId'] is String)
        OutlinedButton.icon(
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('View in Batch'),
          onPressed: busy
              ? null
              : () async {
                  setState(() => busy = true);
                  try {
                    final service = OperationsService();
                    final doc = await service.db
                        .collection('batches')
                        .doc(widget.collection['batchId'] as String)
                        .get();
                    if (context.mounted && doc.exists) {
                      _open(
                        context,
                        RecordDetailsPage(
                          record: OperationalRecord(doc.id, doc.data()!),
                          kind: 'batches',
                          service: service,
                        ),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      UserFeedback.showError(
                        context,
                        message: 'Unable to load batch.',
                      );
                    }
                  } finally {
                    if (mounted) setState(() => busy = false);
                  }
                },
        ),
      OutlinedButton.icon(
        icon: const Icon(Icons.report_outlined),
        label: Text(busy ? 'Please wait…' : 'Report an issue'),
        onPressed: busy
            ? null
            : () async {
                final type = await showDialog<String>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Issue type'),
                    children: ['Quantity', 'Quality', 'Other']
                        .map(
                          (t) => SimpleDialogOption(
                            onPressed: () => Navigator.pop(context, t),
                            child: Text(t),
                          ),
                        )
                        .toList(),
                  ),
                );
                if (type == null || !context.mounted) return;
                final notes = await _askText(
                  context,
                  'Describe the issue',
                  min: 5,
                );
                if (notes == null || !mounted) return;
                setState(() => busy = true);
                try {
                  await OperationsService().raiseDispute(
                    widget.id,
                    type,
                    notes,
                  );
                  if (context.mounted) {
                    UserFeedback.showSuccess(
                      context,
                      message: 'Dispute raised. Track it in Disputes.',
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    UserFeedback.showError(
                      context,
                      message: 'Unable to report issue. Please retry.',
                    );
                  }
                } finally {
                  if (mounted) setState(() => busy = false);
                }
              },
      ),
    ],
  );
}
