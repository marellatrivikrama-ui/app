import 'package:flutter_test/flutter_test.dart';
import 'package:aayurvani_app/main.dart';

void main() {
  testWidgets('renders the Aayurvani auth screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AayurvaniApp());

    expect(find.text('AAYURVANI'), findsOneWidget);
    expect(find.text('Enter App'), findsOneWidget);
  });
}
