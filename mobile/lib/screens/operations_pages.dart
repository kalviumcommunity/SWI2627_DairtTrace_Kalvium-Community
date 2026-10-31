part of '../app_shell.dart';

String _shortId(String id) =>
    id.length > 8 ? id.substring(0, 8).toUpperCase() : id;
String _measure(Object? n, [String unit = '']) =>
    n is num ? '${n.toStringAsFixed(1)}$unit' : 'Not recorded';
void _open(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

class OperationsPage extends StatefulWidget {
  const OperationsPage({
    super.key,
    required this.module,
    this.embedded = false,
    this.service,
  });
  final String module;
  final bool embedded;
  final OperationsService? service;
  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  late final OperationsService service = widget.service ?? OperationsService();
  late Stream<List<OperationalRecord>> stream;
  String query = '', filter = 'All';
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  String get path => widget.module == 'Batches'
      ? 'batches'
      : widget.module == 'Disputes'
      ? 'disputes'
      : 'collections';
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    stream = service.watch(path);
  }

  @override
  Widget build(BuildContext context) {
    final body = StreamBuilder<List<OperationalRecord>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _LoadError(onRetry: () => setState(_reload));
        }
        if (!snapshot.hasData) return const _LoadingCard();
        final all = snapshot.data!;
        var records = all
            .where(
              (r) =>
                  '${r.id} ${r.text('farmerName')} ${r.text('description')} ${r.text('dayKey')}'
                      .toLowerCase()
                      .contains(query),
            )
            .toList();
        final quality =
            widget.module == 'Quality Tests' ||
            widget.module == 'Notifications';
        if (quality) {
          records = records
              .where(
                (r) =>
                    r.text('qualityStatus') ==
                        (widget.module == 'Notifications'
                            ? 'ALERT'
                            : r.text('qualityStatus')) &&
                    r.text('qualityStatus', 'UNKNOWN') != 'UNKNOWN',
              )
              .toList();
        }
        if (filter != 'All') {
          records = records
              .where(
                (r) => r.text(quality ? 'qualityStatus' : 'status') == filter,
              )
              .toList();
        }
        final reporting = ['Reports', 'Reconciliation'].contains(widget.module);
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            if (widget.embedded)
              _PageHeader(
                title: widget.module,
                subtitle: 'Trace every collection, from source to batch',
                icon: Icons.inventory_2_outlined,
              ),
            if (reporting)
              ..._report(all)
            else ...[
              TextField(
                decoration: _searchDecoration('Search by name or ID'),
                onChanged: (v) =>
                    setState(() => query = v.trim().toLowerCase()),
              ),
              const SizedBox(height: 12),
              if ([
                'Batches',
                'Disputes',
                'Quality Tests',
              ].contains(widget.module))
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                              'All',
                              ...widget.module == 'Batches'
                                  ? ['PENDING', 'PASSED', 'FAILED']
                                  : widget.module == 'Disputes'
                                  ? [
                                      'OPEN',
                                      'UNDER_REVIEW',
                                      'RESOLVED',
                                      'REJECTED',
                                    ]
                                  : ['ACCEPTED', 'ALERT'],
                            ]
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(s.replaceAll('_', ' ')),
                                  selected: filter == s,
                                  onSelected: (_) => setState(() => filter = s),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              const SizedBox(height: 12),
              if (widget.module == 'Batches')
                FilledButton.icon(
                  onPressed: () => _open(context, const BatchBuilderPage()),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Batch'),
                ),
              if (widget.module == 'Disputes')
                const Text(
                  'Open a collection to report a quantity or quality issue.',
                  style: TextStyle(color: _mutedText),
                ),
              if (widget.module == 'Notifications')
                const Text(
                  'Quality alerts requiring attention',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              if (records.isEmpty)
                const _EmptyCard(
                  icon: Icons.inbox_outlined,
                  title: 'No matching records',
                  message: 'New records will appear here as you work.',
                ),
              ...records.map((r) => _recordTile(r, quality)),
            ],
          ],
        );
      },
    );
    return widget.embedded
        ? body
        : Scaffold(
            appBar: AppBar(title: Text(widget.module)),
            body: body,
          );
  }

  Widget _recordTile(OperationalRecord r, bool quality) {
    final collection = path == 'collections';
    final status = r.text(collection ? 'qualityStatus' : 'status', 'UNKNOWN');
    return Card(
      margin: const EdgeInsets.only(top: 10),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE3F5EB),
          child: Icon(
            collection
                ? Icons.local_drink_outlined
                : path == 'batches'
                ? Icons.inventory_2_outlined
                : Icons.report_outlined,
            color: _green,
          ),
        ),
        title: Text(
          collection
              ? r.text('farmerName')
              : '${path == 'batches' ? 'BT' : 'DIS'}-${_shortId(r.id)}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          collection
              ? '${r.number('quantityLitres').toStringAsFixed(1)} L · ${_formatDate(r.date)}\n${quality ? 'Fat ${_measure(r.data['fat'], '%')} · SNF ${_measure(r.data['snf'], '%')}' : _shortId(r.id)}'
              : path == 'batches'
              ? '${(r.data['collectionIds'] as List).length} collections · ${r.text('dayKey')}\n${r.text('session')}'
              : '${r.text('type')} · ${r.text('description')}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _QualityPill(status: status),
        onTap: () => _open(
          context,
          collection
              ? _CollectionDetailsPage(id: r.id, collection: r.data)
              : RecordDetailsPage(record: r, kind: path, service: service),
        ),
      ),
    );
  }

  List<Widget> _report(List<OperationalRecord> all) {
    final records = all
        .where((r) => r.date.year == month.year && r.date.month == month.month)
        .toList();
    final litres = records.fold<double>(
      0,
      (total, r) => total + r.number('quantityLitres'),
    );
    final totals = reconcile(records, month);
    final unknown = records.where((r) => r.text('farmerId').isEmpty).length;
    final passed = records
        .where((r) => r.text('qualityStatus') == 'ACCEPTED')
        .length;
    final alerts = records
        .where((r) => r.text('qualityStatus') == 'ALERT')
        .length;
    final values = List<double>.filled(
      DateTime(month.year, month.month + 1, 0).day,
      0,
    );
    for (final r in records) {
      values[r.date.day - 1] += r.number('quantityLitres');
    }
    return [
      Row(
        children: [
          IconButton(
            tooltip: 'Previous month',
            onPressed: () =>
                setState(() => month = DateTime(month.year, month.month - 1)),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              '${_monthName(month.month)} ${month.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            tooltip: 'Next month',
            onPressed:
                month.isBefore(
                  DateTime(DateTime.now().year, DateTime.now().month),
                )
                ? () => setState(
                    () => month = DateTime(month.year, month.month + 1),
                  )
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      _SummaryTile(
        label: 'Total Milk Collected',
        value: '${litres.toStringAsFixed(1)} L',
        icon: Icons.local_drink_outlined,
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _SummaryTile(
              label: 'Collections',
              value: '${records.length}',
              icon: Icons.receipt_long_outlined,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryTile(
              label: 'Farmers',
              value: '${totals.length}',
              icon: Icons.people_outline,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (widget.module == 'Reports') ...[
        const Text(
          'Daily collection · litres',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: CustomPaint(
            painter: _MilkChart(values),
            child: const SizedBox.expand(),
          ),
        ),
        Text(
          '1 ${_monthName(month.month)}                                     ${values.length} ${_monthName(month.month)}',
          style: const TextStyle(color: _mutedText, fontSize: 11),
        ),
        const SizedBox(height: 20),
        _DetailRow(label: 'Quality accepted', value: '$passed'),
        _DetailRow(label: 'Quality alerts', value: '$alerts'),
        _DetailRow(
          label: 'Quality unknown',
          value: '${records.length - passed - alerts}',
        ),
      ],
      const SizedBox(height: 12),
      const Text(
        'Farmer totals',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        'Quantity-weighted quality averages. Pricing is not configured; no payable amounts are calculated.',
        style: TextStyle(color: _mutedText, fontSize: 12),
      ),
      if (unknown > 0)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '$unknown legacy records need farmer mapping. They are included in overall volume but excluded from farmer totals.',
            style: TextStyle(color: Colors.orange.shade900),
          ),
        ),
      ...totals.map(
        (t) => Card(
          child: ListTile(
            title: Text(t.name),
            subtitle: Text(
              '${t.count} collections · ${t.alerts} alerts\nFat ${_measure(t.averageFat, '%')} · SNF ${_measure(t.averageSnf, '%')}',
            ),
            trailing: Text(
              '${t.litres.toStringAsFixed(1)} L',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        icon: const Icon(Icons.copy_outlined),
        label: const Text('Copy report as CSV'),
        onPressed: records.isEmpty
            ? null
            : () async {
                await Clipboard.setData(
                  ClipboardData(text: collectionCsv(records)),
                );
                if (mounted) {
                  UserFeedback.showSuccess(
                    context,
                    message:
                        'CSV report copied. Paste into a spreadsheet or file.',
                  );
                }
              },
      ),
    ];
  }
}

class _QualityPill extends StatelessWidget {
  const _QualityPill({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final color = ['ALERT', 'FAILED', 'REJECTED'].contains(status)
        ? Colors.red.shade700
        : ['PENDING', 'OPEN', 'UNDER_REVIEW'].contains(status)
        ? Colors.orange.shade800
        : status == 'UNKNOWN'
        ? _mutedText
        : _green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MilkChart extends CustomPainter {
  _MilkChart(this.values);
  final List<double> values;
  @override
  void paint(Canvas canvas, Size size) {
    final max = values.fold<double>(1, (a, b) => a > b ? a : b);
    final paint = Paint()..color = _green;
    for (var i = 0; i < values.length; i++) {
      final width = size.width / values.length;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * width + 2,
            size.height - values[i] / max * (size.height - 12),
            width - 4,
            values[i] / max * (size.height - 12),
          ),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MilkChart old) => true;
}

class BatchBuilderPage extends StatefulWidget {
  const BatchBuilderPage({super.key, this.service});
  final OperationsService? service;
  @override
  State<BatchBuilderPage> createState() => _BatchBuilderPageState();
}

class _BatchBuilderPageState extends State<BatchBuilderPage> {
  late final service = widget.service ?? OperationsService();
  late final records = service.watch('collections');
  final selected = <String>{};
  bool saving = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create Batch')),
    body: StreamBuilder<List<OperationalRecord>>(
      stream: records,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _LoadError();
        if (!snapshot.hasData) return const _LoadingCard();
        final available = snapshot.data!
            .where(
              (r) => r.data['batchId'] == null && r.text('farmerId').isNotEmpty,
            )
            .toList();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Select up to 8 collections from the same centre, date and session. Quality alerts remain visible in the batch.',
              style: TextStyle(color: _mutedText),
            ),
            const SizedBox(height: 16),
            if (available.isEmpty)
              const _EmptyCard(
                icon: Icons.inventory_2_outlined,
                title: 'No eligible collections',
                message: 'Record a collection for a registered farmer first.',
              ),
            if (available.isEmpty)
              FilledButton.icon(
                onPressed: () => _open(context, const NewCollectionPage()),
                icon: const Icon(Icons.add),
                label: const Text('Record a collection'),
              ),
            ...available.map(
              (r) => CheckboxListTile(
                value: selected.contains(r.id),
                onChanged: saving
                    ? null
                    : (checked) => setState(() {
                        if (checked == true) {
                          selected.add(r.id);
                        } else {
                          selected.remove(r.id);
                        }
                      }),
                title: Text(r.text('farmerName')),
                subtitle: Text(
                  '${r.number('quantityLitres')} L · ${r.text('dayKey')} · ${r.text('session')}\n${r.text('centerName')} · ${r.text('qualityStatus')}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: saving || selected.isEmpty
                  ? null
                  : () async {
                      setState(() => saving = true);
                      try {
                        await service.createBatch(selected.toList());
                        if (context.mounted) {
                          UserFeedback.showSuccess(
                            context,
                            message: 'Batch created.',
                          );
                          Navigator.pop(context);
                        }
                      } catch (error) {
                        if (context.mounted) {
                          UserFeedback.showError(
                            context,
                            message: error is StateError
                                ? error.message
                                : error is ArgumentError
                                ? '${error.message}'
                                : 'Could not create batch. Retry after checking access.',
                          );
                        }
                      } finally {
                        if (mounted) setState(() => saving = false);
                      }
                    },
              child: Text(
                saving ? 'Creating…' : 'Create Batch (${selected.length})',
              ),
            ),
          ],
        );
      },
    ),
  );
}

class RecordDetailsPage extends StatefulWidget {
  const RecordDetailsPage({
    super.key,
    required this.record,
    required this.kind,
    required this.service,
  });
  final OperationalRecord record;
  final String kind;
  final OperationsService service;
  @override
  State<RecordDetailsPage> createState() => _RecordDetailsPageState();
}

class _RecordDetailsPageState extends State<RecordDetailsPage> {
  late final stream = widget.service.watch(widget.kind);
  bool saving = false;
  Future<void> _update(OperationalRecord r, String status) async {
    final notes = await _askText(
      context,
      widget.kind == 'batches'
          ? 'Quality test notes'
          : 'Review / resolution notes',
      min: 3,
    );
    if (notes == null || !mounted) return;
    setState(() => saving = true);
    try {
      if (widget.kind == 'batches') {
        await widget.service.recordBatchResult(r.id, status, notes);
      } else {
        await widget.service.resolveDispute(r.id, status, notes);
      }
      if (mounted) {
        UserFeedback.showSuccess(
          context,
          message: '${status.replaceAll('_', ' ')} recorded.',
        );
      }
    } catch (_) {
      if (mounted) {
        UserFeedback.showError(
          context,
          message: 'Could not update. Refresh and check your access.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.kind == 'batches' ? 'Batch Details' : 'Dispute Details',
      ),
    ),
    body: StreamBuilder<List<OperationalRecord>>(
      stream: stream,
      builder: (context, s) {
        if (s.hasError) return const _LoadError();
        if (!s.hasData) return const _LoadingCard();
        final matches = s.data!.where((r) => r.id == widget.record.id);
        if (matches.isEmpty) {
          return const Center(child: Text('Record unavailable.'));
        }
        final r = matches.first;
        final batch = widget.kind == 'batches';
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${batch ? 'BT' : 'DIS'}-${_shortId(r.id)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: _QualityPill(status: r.text('status')),
            ),
            const SizedBox(height: 20),
            if (batch) ...[
              _DetailRow(label: 'Collection date', value: r.text('dayKey')),
              _DetailRow(label: 'Session', value: r.text('session')),
              if (r.text('status') == 'FAILED')
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Investigate all source collections. A failed batch does not establish which farmer caused the issue.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const Text(
                'Source collections',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              _BatchSources(record: r, service: widget.service),
              if (r.text('testNotes').isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(r.text('testNotes')),
                Text(
                  'Tested by ${r.text('testedBy')}',
                  style: const TextStyle(fontSize: 11, color: _mutedText),
                ),
              ],
              if (r.text('status') == 'PENDING') ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: saving ? null : () => _update(r, 'PASSED'),
                  child: const Text('Record passed result'),
                ),
                OutlinedButton(
                  onPressed: saving ? null : () => _update(r, 'FAILED'),
                  child: const Text('Record failed result'),
                ),
              ],
            ] else ...[
              _DetailRow(label: 'Issue type', value: r.text('type')),
              Text(r.text('description')),
              const SizedBox(height: 20),
              _SourceCollection(
                id: r.text('collectionId'),
                service: widget.service,
              ),
              if (r.text('resolution').isNotEmpty)
                _DetailRow(label: 'Review notes', value: r.text('resolution')),
              if (['OPEN', 'UNDER_REVIEW'].contains(r.text('status'))) ...[
                if (r.text('status') == 'OPEN')
                  OutlinedButton(
                    onPressed: saving ? null : () => _update(r, 'UNDER_REVIEW'),
                    child: const Text('Start review'),
                  ),
                FilledButton(
                  onPressed: saving ? null : () => _update(r, 'RESOLVED'),
                  child: const Text('Resolve with notes'),
                ),
                TextButton(
                  onPressed: saving ? null : () => _update(r, 'REJECTED'),
                  child: const Text('Reject with notes'),
                ),
              ],
            ],
          ],
        );
      },
    ),
  );
}

class _BatchSources extends StatelessWidget {
  const _BatchSources({required this.record, required this.service});
  final OperationalRecord record;
  final OperationsService service;
  @override
  Widget build(BuildContext context) => StreamBuilder<List<OperationalRecord>>(
    stream: service.watch('collections'),
    builder: (context, s) {
      if (s.hasError) return const _LoadError();
      if (!s.hasData) return const _LoadingCard();
      final ids = List<String>.from(record.data['collectionIds'] as List);
      final sources = s.data!.where((r) => ids.contains(r.id)).toList();
      return Column(
        children: [
          _DetailRow(
            label: 'Total quantity',
            value:
                '${sources.fold<double>(0, (total, r) => total + r.number('quantityLitres')).toStringAsFixed(1)} L',
          ),
          ...sources.map(
            (r) => ListTile(
              title: Text(r.text('farmerName')),
              subtitle: Text(
                '${r.number('quantityLitres')} L · ${_shortId(r.id)}',
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
  );
}

class _SourceCollection extends StatelessWidget {
  const _SourceCollection({required this.id, required this.service});
  final String id;
  final OperationsService service;
  @override
  Widget build(BuildContext context) =>
      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: service.db.collection('collections').doc(id).get(),
        builder: (context, s) {
          if (s.hasError) return const _LoadError();
          if (!s.hasData) return const _LoadingCard();
          if (!s.data!.exists) {
            return const Text('Source collection is unavailable.');
          }
          return OutlinedButton.icon(
            onPressed: () => _open(
              context,
              _CollectionDetailsPage(id: id, collection: s.data!.data()!),
            ),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('View source collection'),
          );
        },
      );
}

Future<String?> _askText(
  BuildContext context,
  String title, {
  int min = 3,
}) async {
  return showDialog<String>(
    context: context,
    builder: (_) => _NotesDialog(title: title, min: min),
  );
}

class _NotesDialog extends StatefulWidget {
  const _NotesDialog({required this.title, required this.min});
  final String title;
  final int min;
  @override
  State<_NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<_NotesDialog> {
  final controller = TextEditingController();
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Form(
      key: form,
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        maxLength: 1000,
        decoration: const InputDecoration(labelText: 'Notes'),
        validator: (v) => (v?.trim().length ?? 0) < widget.min
            ? 'Enter at least ${widget.min} characters.'
            : null,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (form.currentState!.validate()) {
            Navigator.pop(context, controller.text.trim());
          }
        },
        child: const Text('Save'),
      ),
    ],
  );
}
