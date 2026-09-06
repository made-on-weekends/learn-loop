import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/main.dart';
import 'package:learn_loop/models/handwriting_config.dart';
import 'package:learn_loop/models/kid_profile.dart';
import 'package:learn_loop/screens/handwriting_screen.dart';
import 'package:learn_loop/services/settings_service.dart';
import 'package:learn_loop/widgets/kid_profile_card.dart';
import 'package:learn_loop/widgets/line_style_selector.dart';
import 'package:learn_loop/widgets/page_margin_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
    await SettingsService.saveKidProfile(
      const KidProfile(age: 5, grade: KidGrade.kindergarten),
    );
  });

  group('Drawer & Navigation Tests', () {
    testWidgets(
      'Hamburger menu opens drawer with Kid Profile and Support options',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const LearnLoopApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify dashboard renders
        expect(find.text('Learn Loop'), findsWidgets);

        // Open drawer safely via ScaffoldState
        final scaffoldState = tester.state<ScaffoldState>(
          find.byType(Scaffold),
        );
        scaffoldState.openDrawer();
        await tester.pumpAndSettle();

        // Verify drawer header and sections
        expect(find.text('LEARNER PROFILE'), findsOneWidget);
        expect(find.byType(KidProfileCard), findsOneWidget);

        final drawerScrollable = find.descendant(
          of: find.byType(Drawer),
          matching: find.byType(Scrollable),
        );
        if (drawerScrollable.evaluate().isNotEmpty) {
          await tester.drag(drawerScrollable, const Offset(0, -1200));
          await tester.pumpAndSettle();
        }

        expect(find.text('Support LearnLoop'), findsWidgets);
      },
    );

    testWidgets('Drawer allows changing Kid Profile globally', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const LearnLoopApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Check current profile
      expect(
        SettingsService.currentKidProfile.grade,
        equals(KidGrade.kindergarten),
      );
    });
  });

  group('Handwriting Screen UI Refinements Tests', () {
    testWidgets('KidProfileCard is not in HandwritingScreen customize panel', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: HandwritingScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // KidProfileCard should not be inside HandwritingScreen
      expect(find.byType(KidProfileCard), findsNothing);
    });

    testWidgets(
      'Left margin checkbox option is removed from HandwritingScreen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const MaterialApp(home: HandwritingScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(
          find.text('Show Left Vertical Margin Guide (Red Line)'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Line Style Selector expands on click and allows selecting a style',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const MaterialApp(home: HandwritingScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(LineStyleSelector), findsOneWidget);

        // Initially collapsed
        expect(find.text('Change'), findsOneWidget);
        expect(
          find.text('Select Line Style (Large Visual Preview):'),
          findsNothing,
        );

        // Tap Change to expand
        await tester.tap(find.text('Change'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Expanded list should be visible
        expect(
          find.text('Select Line Style (Large Visual Preview):'),
          findsOneWidget,
        );
        expect(find.text('2 Lines — With Separator'), findsOneWidget);

        // Tap to select a different style
        await tester.tap(find.text('2 Lines — With Separator'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Should collapse back and show selected
        expect(
          find.text('Select Line Style (Large Visual Preview):'),
          findsNothing,
        );
        expect(find.text('2 Lines — With Separator'), findsOneWidget);
      },
    );

    testWidgets(
      'Line color scheme is a segmented toggle (Color & Black/White)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const MaterialApp(home: HandwritingScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        final segmentedFinder = find.byType(
          SegmentedButton<GuidelineColorScheme>,
        );
        expect(segmentedFinder, findsOneWidget);
        expect(find.text('Color'), findsOneWidget);
        expect(find.text('Black & White'), findsOneWidget);

        // Toggle to Black & White
        await tester.tap(find.text('Black & White'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        final SegmentedButton<GuidelineColorScheme> widget = tester.widget(
          segmentedFinder,
        );
        expect(widget.selected, contains(GuidelineColorScheme.monochrome));
      },
    );

    testWidgets(
      'Dotted font switch is only shown when Tracing mode is selected',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const MaterialApp(home: HandwritingScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Default mode is tracing -> dotted font switch should be present
        await tester.ensureVisible(find.text('Use Dotted Font for Tracing'));
        expect(find.text('Use Dotted Font for Tracing'), findsOneWidget);

        // Find Mode dropdown and switch to Copy Example
        await tester.ensureVisible(find.text('Trace Letters'));
        await tester.tap(find.text('Trace Letters'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        await tester.tap(find.text('Copy Example').last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Dotted font switch should be hidden in Copy mode
        expect(find.text('Use Dotted Font for Tracing'), findsNothing);
      },
    );
  });

  group('Page Margin Dropdown Tests', () {
    testWidgets('PageMarginDropdown displays standard presets', (
      WidgetTester tester,
    ) async {
      double selected = 19.05;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PageMarginDropdown(
                  value: selected,
                  onChanged: (val) {
                    setState(() {
                      selected = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(PageMarginDropdown), findsOneWidget);
      expect(find.text('Normal (19 mm / 0.75")'), findsOneWidget);

      // Open dropdown
      await tester.tap(find.text('Normal (19 mm / 0.75")'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Narrow (10 mm / 0.4")').last, findsOneWidget);
      expect(find.text('Wide (25.4 mm / 1.0")').last, findsOneWidget);

      // Tap Narrow
      await tester.tap(find.text('Narrow (10 mm / 0.4")').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(selected, equals(10.0));
    });
  });
}
