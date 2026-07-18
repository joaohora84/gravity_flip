import 'package:flutter_test/flutter_test.dart';

import 'package:gravity_flip/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GravityFlipApp());
  });
}
