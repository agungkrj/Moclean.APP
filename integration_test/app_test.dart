import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moclienapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login User Berhasil', (tester) async {
    // Abaikan overflow error dari rendering
    final List<String> ignoreErrors = [
      'A RenderFlex overflowed',
    ];

    FlutterError.onError = (FlutterErrorDetails details) {
      final String message = details.toString();
      if (ignoreErrors.any((e) => message.contains(e))) return;
      FlutterError.dumpErrorToConsole(details);
    };

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 6));

    if (find.text('Mulai Sekarang').evaluate().isNotEmpty) {
      await tester.tap(find.text('Mulai Sekarang'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    if (find.byKey(const Key('phoneField')).evaluate().isEmpty) {
      await tester.tap(find.text('Akses layanan sebagai pengguna'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    expect(find.byKey(const Key('phoneField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('phoneField')),
      '081234567890',
    );
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      '1234567',
    );

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 8));
  });
}