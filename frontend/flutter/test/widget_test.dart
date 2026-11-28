import 'package:flutter_test/flutter_test.dart';
import 'package:eduway/main.dart';

void main() {
  testWidgets('EduWay smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EduWay());
  });
}
