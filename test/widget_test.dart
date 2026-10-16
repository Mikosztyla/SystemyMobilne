import 'package:bursa_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('aplikacja się uruchamia', (tester) async {
    await tester.pumpWidget(const BursaApp());

    expect(find.text('Bursa'), findsOneWidget);
  });
}
