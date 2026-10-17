import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/ui/widgets/error_view.dart';

void main() {
  testWidgets('shows the message and calls onRetry when Coba Lagi is tapped',
      (tester) async {
    var retryCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'Tidak dapat terhubung ke internet.',
            onRetry: () => retryCount++,
          ),
        ),
      ),
    );

    expect(find.text('Tidak dapat terhubung ke internet.'), findsOneWidget);

    await tester.tap(find.text('Coba Lagi'));

    expect(retryCount, 1);
  });
}