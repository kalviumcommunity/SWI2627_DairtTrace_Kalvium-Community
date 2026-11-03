import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/directory_page.dart';
import 'package:mobile/services/directory_service.dart';
import 'package:mocktail/mocktail.dart';

class DirectoryMock extends Mock implements DirectoryService {}

void main() {
  testWidgets('farmer tab gets an independent centre subscription', (
    tester,
  ) async {
    final service = DirectoryMock();
    when(() => service.watchCenters()).thenAnswer(
      (_) => Stream.value(const [
        DirectoryEntry(id: 'centre', name: 'Green Valley'),
      ]),
    );
    when(() => service.watchFarmers()).thenAnswer((_) => Stream.value([]));
    await tester.pumpWidget(MaterialApp(home: DirectoryPage(service: service)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farmers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register Farmer'));
    await tester.pumpAndSettle();
    expect(find.text('Contact number'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
