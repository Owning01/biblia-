import 'package:flutter_test/flutter_test.dart';
import 'package:biblia/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BibliaApp());
    expect(find.text('Biblia'), findsOneWidget);
  });
}
