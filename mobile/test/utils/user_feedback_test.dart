
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/user_feedback.dart';

void main() {
  group('UserFeedback SnackBars', () {
    testWidgets('shows a success message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => UserFeedback.showSuccess(
                  context,
                  message: 'Collection saved successfully.',
                ),
                child: const Text('Show success'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show success'));
      await tester.pump();

      expect(find.text('Collection saved successfully.'), findsOneWidget);
    });

    testWidgets('shows an error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => UserFeedback.showError(
                  context,
                  message: 'Unable to save collection.',
                ),
                child: const Text('Show error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show error'));
      await tester.pump();

      expect(find.text('Unable to save collection.'), findsOneWidget);
    });

    testWidgets('shows an informational message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => UserFeedback.showInfo(
                  context,
                  message: 'Please wait.',
                ),
                child: const Text('Show info'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show info'));
      await tester.pump();

      expect(find.text('Please wait.'), findsOneWidget);
    });
  });

  group('UserFeedback confirmation dialog', () {
    testWidgets('returns true when the user confirms', (tester) async {
      bool? confirmed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  confirmed = await UserFeedback.confirm(
                    context,
                    title: 'Delete collection?',
                    message: 'This action cannot be undone.',
                    confirmText: 'Delete',
                    destructive: true,
                  );
                },
                child: const Text('Open dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete collection?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('returns false when the user cancels', (tester) async {
      bool? confirmed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  confirmed = await UserFeedback.confirm(
                    context,
                    title: 'Delete collection?',
                    message: 'This action cannot be undone.',
                  );
                },
                child: const Text('Open dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
    });
  });
}
