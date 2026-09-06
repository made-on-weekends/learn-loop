import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/main.dart';
import 'package:learn_loop/screens/category_screen.dart';
import 'package:learn_loop/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 2 Navigation Redesign Tests', () {
    testWidgets(
      'HomeScreen renders header, search button, tabs, and goal cards',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const LearnLoopApp());
        await tester.pumpAndSettle();

        expect(find.text("Learn Loop"), findsOneWidget);
        expect(find.text("Early Childhood Worksheet Platform"), findsOneWidget);
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);

        // Verify Tabs
        expect(find.text("Learning Goals"), findsOneWidget);
        expect(find.text("All Worksheets"), findsOneWidget);
        expect(find.text("Favorites & Recent"), findsOneWidget);

        // Verify Goal Cards
        expect(find.text("Pencil Control & Pre-Writing"), findsOneWidget);
        expect(find.text("Early Math"), findsOneWidget);
        expect(find.text("Early Literacy"), findsOneWidget);
      },
    );

    testWidgets('Tapping a goal card navigates to CategoryScreen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();

      final goalCard = find.text("Early Math");
      expect(goalCard, findsOneWidget);
      await tester.tap(goalCard, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(CategoryScreen), findsOneWidget);
      expect(find.textContaining("AVAILABLE WORKSHEETS"), findsOneWidget);
      expect(find.text("Numbers & Counting"), findsOneWidget);
      expect(find.text("Addition & Subtraction"), findsOneWidget);
    });

    testWidgets(
      'Drawer opens and lists Developmental Goals and KidProfileCard',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
        await tester.pumpAndSettle();

        final menuButton = find.byIcon(Icons.menu_rounded);
        expect(menuButton, findsOneWidget);
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        expect(find.text("LEARNER PROFILE"), findsOneWidget);
        expect(find.text("DEVELOPMENTAL GOALS"), findsWidgets);
        expect(find.text("Pencil Control & Pre-Writing"), findsWidgets);
      },
    );
  });
}
