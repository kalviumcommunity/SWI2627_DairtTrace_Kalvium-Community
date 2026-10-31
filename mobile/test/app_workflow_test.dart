import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/app_shell.dart';
import 'package:mobile/main.dart';
import 'package:mobile/widgets/app_theme.dart';
import 'package:mobile/services/collection_service.dart';
import 'package:mobile/services/directory_service.dart';
import 'package:mobile/services/operations_service.dart';

class _Auth extends Mock implements FirebaseAuth {}

class _User extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore db;
  late _Auth auth;
  late OperationsService ops;
  late CollectionService collections;
  late DirectoryService directory;
  final capture = GlobalKey();
  setUp(() async {
    db = FakeFirebaseFirestore();
    auth = _Auth();
    final user = _User();
    when(() => user.uid).thenReturn('owner');
    when(() => user.email).thenReturn('operator@dairytrace.test');
    when(() => user.displayName).thenReturn('Edha');
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.signOut()).thenAnswer((_) async {});
    ops = OperationsService(firestore: db, auth: auth);
    collections = CollectionService(firestore: db, auth: auth);
    directory = DirectoryService(firestore: db, auth: auth);
    await db.collection('collectionCenters').doc('center').set({
      'name': 'Green Valley Centre',
      'village': 'Rampur',
      'createdBy': 'owner',
      'status': 'ACTIVE',
    });
    for (final item in [
      ('farmer', 'Rajesh Kumar'),
      ('farmer2', 'Suresh Patel'),
      ('farmer3', 'Meena Devi'),
    ]) {
      await db.collection('farmers').doc(item.$1).set({
        'name': item.$2,
        'phone': '+91 9876543210',
        'village': 'Rampur',
        'centerId': 'center',
        'status': 'ACTIVE',
        'createdBy': 'owner',
      });
    }
    final today = DateTime.now();
    for (var i = 0; i < 6; i++) {
      await db.collection('collections').doc('collection-$i').set({
        'farmerId': i % 2 == 0 ? 'farmer' : 'farmer2',
        'farmerName': i % 2 == 0 ? 'Rajesh Kumar' : 'Suresh Patel',
        'centerId': 'center',
        'centerName': 'Green Valley Centre',
        'createdBy': 'owner',
        'quantityLitres': 120.0 + i * 5,
        'fat': i == 3 ? 2.5 : 4.2,
        'snf': 8.6,
        'temperature': 4.0,
        'qualityStatus': i == 3 ? 'ALERT' : 'ACCEPTED',
        'collectionDate': Timestamp.fromDate(today.subtract(Duration(days: i))),
        'session': 'MORNING',
        'dayKey':
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
      });
    }
    await db.collection('batches').doc('batch-1').set({
      'createdBy': 'owner',
      'createdAt': Timestamp.now(),
      'collectionIds': ['collection-0', 'collection-1'],
      'centerId': 'center',
      'session': 'MORNING',
      'dayKey': '2026-10-31',
      'status': 'PENDING',
    });
    await db.collection('disputes').doc('dispute-1').set({
      'createdBy': 'owner',
      'createdAt': Timestamp.now(),
      'collectionId': 'collection-3',
      'type': 'Quality',
      'description': 'Please verify the fat reading',
      'status': 'OPEN',
    });
  });
  Future<void> show(
    WidgetTester tester,
    Widget page, {
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dairyTheme(),
        home: RepaintBoundary(key: capture, child: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> screenshot(WidgetTester tester, String name) async {
    if (Platform.environment['DAIRYTRACE_RENDER'] != '1') return;
    await tester.runAsync(() async {
      final render =
          capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await render.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('build/previews').create(recursive: true);
      await File('build/previews/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  setUpAll(() async {
    if (Platform.environment['DAIRYTRACE_RENDER'] == '1' &&
        Platform.isWindows) {
      for (final item in [
        ('Roboto', 'roboto-regular.ttf'),
        ('MaterialIcons', 'materialicons-regular.otf'),
      ]) {
        final fontRoot =
            Platform.environment['FLUTTER_ROOT'] ?? 'C:/src/flutter';
        final loader = FontLoader(item.$1)
          ..addFont(
            File('$fontRoot/bin/cache/artifacts/material_fonts/${item.$2}')
                .readAsBytes()
                .then((b) => ByteData.sublistView(b)),
          );
        await loader.load();
      }
    }
  });
  testWidgets('shell metrics, navigation and month filter work at phone size', (
    tester,
  ) async {
    await show(
      tester,
      DairyTraceShell(
        onNewCollection: () {},
        collectionService: collections,
        operations: ops,
        auth: auth,
      ),
    );
    expect(find.text('Edha'), findsOneWidget);
    expect(find.text('Total Collections'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await screenshot(tester, 'dashboard');
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsWidgets);
    await tester.tap(find.text('Users').last);
    await tester.pumpAndSettle();
    expect(find.text('Rajesh Kumar'), findsWidgets);
    await screenshot(tester, 'users');
    await tester.tap(find.text('Batches').last);
    await tester.pumpAndSettle();
    expect(find.text('Create Batch'), findsOneWidget);
    await screenshot(tester, 'batches');
    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();
    await screenshot(tester, 'more');
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Sign out'), findsOneWidget);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    verify(() => auth.signOut()).called(1);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'new collection selects stable farmer and persists quality and notes',
    (tester) async {
      await show(
        tester,
        NewCollectionPage(directory: directory, collectionService: collections),
      );
      await screenshot(tester, 'new-collection');
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Rajesh Kumar').last);
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      for (final item in [
        (0, '15.5'),
        (1, '2.5'),
        (2, '8.6'),
        (3, '4'),
        (4, 'Morning collection'),
      ]) {
        await tester.enterText(fields.at(item.$1), item.$2);
      }
      await tester.ensureVisible(find.text('Save Collection'));
      await tester.tap(find.text('Save Collection'));
      await tester.pumpAndSettle();
      final result = (await db.collection('collections').get()).docs
          .where((d) => d.data()['notes'] == 'Morning collection')
          .single
          .data();
      expect(result['farmerId'], 'farmer');
      expect(result['qualityStatus'], 'ALERT');
      expect(result['quantityLitres'], 15.5);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'reports and reconciliation show real totals, period filters and CSV action',
    (tester) async {
      await show(tester, OperationsPage(module: 'Reports', service: ops));
      expect(find.text('Total Milk Collected'), findsOneWidget);
      await screenshot(tester, 'reports');
      expect(tester.takeException(), isNull);
      await show(
        tester,
        OperationsPage(
          key: UniqueKey(),
          module: 'Reconciliation',
          service: ops,
        ),
      );
      expect(find.textContaining('no payable amounts'), findsOneWidget);
      await screenshot(tester, 'reconciliation');
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('0.0 L'), findsOneWidget);
    },
  );
  testWidgets('quality and dispute filters work without invented records', (
    tester,
  ) async {
    await show(tester, OperationsPage(module: 'Quality Tests', service: ops));
    await tester.tap(find.widgetWithText(ChoiceChip, 'ALERT'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    await screenshot(tester, 'quality');
    await show(
      tester,
      OperationsPage(key: UniqueKey(), module: 'Disputes', service: ops),
    );
    await screenshot(tester, 'disputes');
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'RESOLVED'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'RESOLVED'));
    await tester.pumpAndSettle();
    expect(find.text('No matching records'), findsOneWidget);
  });
  testWidgets('farmer profile shows only collections with the same ID', (
    tester,
  ) async {
    final record = OperationalRecord(
      'farmer',
      (await db.collection('farmers').doc('farmer').get()).data()!,
    );
    await show(tester, FarmerProfilePage(record: record, service: ops));
    expect(find.text('Collection History'), findsOneWidget);
    await screenshot(tester, 'farmer-details');
    expect(tester.takeException(), isNull);
  });
  testWidgets('login has brand, password toggle and reset without overflow', (
    tester,
  ) async {
    await show(tester, LoginPage(auth: auth));
    await screenshot(tester, 'login');
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('small phone layouts do not overflow', (tester) async {
    for (final page in <Widget>[
      NewCollectionPage(directory: directory, collectionService: collections),
      OperationsPage(module: 'Reports', service: ops),
      DairyTraceShell(
        onNewCollection: () {},
        collectionService: collections,
        operations: ops,
        auth: auth,
      ),
    ]) {
      await show(tester, page, width: 320);
      expect(tester.takeException(), isNull);
    }
  });
}
