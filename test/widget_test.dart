import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/main.dart';

void main() {
  testWidgets('App dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LearnLoopApp());
    await tester.pumpAndSettle();

    // Verify that our app shows the dashboard title and developmental goals.
    expect(find.text('Learn Loop'), findsOneWidget);
    expect(find.text('Early Childhood Worksheet Platform'), findsOneWidget);
    expect(find.text('Pencil Control & Pre-Writing'), findsOneWidget);
    expect(find.text('Drawing & Creativity'), findsOneWidget);
    expect(find.text('Coloring Pages'), findsOneWidget);
  });
}
