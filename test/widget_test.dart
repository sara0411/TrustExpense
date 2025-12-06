import 'package:flutter_test/flutter_test.dart';
import 'package:trust_expense/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TrustExpenseApp());

    // Verify that app loads with welcome message
    expect(find.text('Welcome to TrustExpense'), findsOneWidget);
    expect(find.text('Capture Receipt'), findsOneWidget);
  });
}
