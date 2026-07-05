import 'package:flutter_test/flutter_test.dart';
import 'package:poneglyph/app.dart';

void main() {
  testWidgets('App should build without error', (WidgetTester tester) async {
    await tester.pumpWidget(const PoneglyphApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(PoneglyphApp), findsOneWidget);
  });
}
