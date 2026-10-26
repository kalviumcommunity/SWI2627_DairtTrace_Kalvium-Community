import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/screens/directory_page.dart';
import 'package:mobile/services/directory_service.dart';

class MockDirectory extends Mock implements DirectoryService {}

void main() {
  late MockDirectory service;
  setUp(() {
    service = MockDirectory();
    when(() => service.watchCenters()).thenAnswer((_) => Stream.value([]));
    when(() => service.watchFarmers()).thenAnswer((_) => Stream.value([]));
  });

  testWidgets(
    'centre load failure keeps Add Centre visible and retry recovers',
    (tester) async {
      when(() => service.watchCenters()).thenAnswer(
        (_) => Stream.error(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(home: DirectoryPage(service: service)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Add Centre'), findsOneWidget);
      expect(find.textContaining('Your account cannot access'), findsOneWidget);
      when(() => service.watchCenters()).thenAnswer((_) => Stream.value([]));
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No centres yet.'), findsOneWidget);
    },
  );

  testWidgets('validates centre fields then saves and shows success', (
    tester,
  ) async {
    when(() => service.addCenter(name: 'Rampur Centre', village: 'Rampur'))
        .thenAnswer((_) async => 'center-1');
    await tester.pumpWidget(MaterialApp(home: DirectoryPage(service: service)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Centre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter village/address.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Rampur Centre');
    await tester.enterText(find.byType(TextFormField).at(1), 'Rampur');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Collection centre created.'), findsOneWidget);
    verify(() => service.addCenter(name: 'Rampur Centre', village: 'Rampur'))
        .called(1);
  });

  testWidgets('searches by village and opens centre details', (tester) async {
    when(() => service.watchCenters()).thenAnswer(
      (_) => Stream.value([
        const DirectoryEntry(
          id: 'center-1',
          name: 'Main Centre',
          village: 'Rampur',
        ),
        const DirectoryEntry(
          id: 'center-2',
          name: 'East Centre',
          village: 'Pune',
        ),
      ]),
    );
    await tester.pumpWidget(MaterialApp(home: DirectoryPage(service: service)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'RAMPUR');
    await tester.pumpAndSettle();
    expect(find.text('East Centre'), findsNothing);
    await tester.tap(find.text('Main Centre'));
    await tester.pumpAndSettle();
    expect(find.text('Centre ID'), findsOneWidget);
    expect(find.text('center-1'), findsOneWidget);
    expect(find.text('Status: ACTIVE'), findsOneWidget);
  });

  testWidgets('failed save preserves entered centre details', (tester) async {
    when(
      () => service.addCenter(
        name: any(named: 'name'),
        village: any(named: 'village'),
      ),
    ).thenThrow(
      FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
    );
    await tester.pumpWidget(MaterialApp(home: DirectoryPage(service: service)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Centre'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Rampur Centre');
    await tester.enterText(find.byType(TextFormField).at(1), 'Rampur');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text('You do not have permission to register this record.'),
      findsOneWidget,
    );
    expect(find.text('Rampur Centre'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
