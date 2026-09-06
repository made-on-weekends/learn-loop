import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/models/math_config.dart';
import 'package:learn_loop/models/counting_config.dart';
import 'package:learn_loop/services/pdf_service.dart';
import 'package:learn_loop/screens/math_screen.dart';
import 'package:learn_loop/screens/counting_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MathConfig & CountingConfig Models', () {
    test('MathConfig default values and modifications', () {
      final config = MathConfig();
      expect(config.activityMode, MathActivityMode.standardEquations);
      expect(config.operation, MathOperation.addition);
      expect(config.format, MathFormat.vertical);
      expect(config.minNumber, 1);
      expect(config.maxNumber, 10);
      expect(config.missingTerm, false);

      config.activityMode = MathActivityMode.numberLine;
      config.missingTerm = true;
      config.seed = 12345;
      expect(config.activityMode, MathActivityMode.numberLine);
      expect(config.missingTerm, true);
      expect(config.seed, 12345);
    });

    test('CountingConfig default values and modifications', () {
      final config = CountingConfig();
      expect(config.activityType, CountingActivityType.countAndWrite);
      expect(config.minNumber, 1);
      expect(config.maxNumber, 10);
      expect(config.compareMore, true);
      expect(config.sequenceLength, 5);

      config.activityType = CountingActivityType.numberSequence;
      config.sequenceLength = 4;
      config.compareMore = false;
      config.seed = 999;
      expect(config.activityType, CountingActivityType.numberSequence);
      expect(config.sequenceLength, 4);
      expect(config.compareMore, false);
      expect(config.seed, 999);
    });
  });

  group('PdfService Math Generation', () {
    final global = GlobalConfig(title: "Test Math");

    test('generateMath - Standard Equations (Vertical & Horizontal)', () async {
      final config = MathConfig(
        activityMode: MathActivityMode.standardEquations,
        format: MathFormat.vertical,
        questionsCount: 6,
      );
      final pdfBytes = await PdfService.generateMath(global, config);
      expect(pdfBytes, isA<Uint8List>());
      expect(pdfBytes.length, greaterThan(0));

      config.format = MathFormat.horizontal;
      config.missingTerm = true;
      final pdfBytesHoriz = await PdfService.generateMath(global, config);
      expect(pdfBytesHoriz.length, greaterThan(0));
    });

    test('generateMath - Number Line', () async {
      final config = MathConfig(
        activityMode: MathActivityMode.numberLine,
        operation: MathOperation.addition,
        minNumber: 1,
        maxNumber: 10,
        questionsCount: 4,
      );
      final pdfBytes = await PdfService.generateMath(global, config);
      expect(pdfBytes.length, greaterThan(0));
    });

    test('generateMath - Ten Frame', () async {
      final config = MathConfig(
        activityMode: MathActivityMode.tenFrame,
        operation: MathOperation.subtraction,
        minNumber: 1,
        maxNumber: 10,
        questionsCount: 4,
      );
      final pdfBytes = await PdfService.generateMath(global, config);
      expect(pdfBytes.length, greaterThan(0));
    });

    test('generateMath - Number Bonds', () async {
      final config = MathConfig(
        activityMode: MathActivityMode.numberBonds,
        missingTerm: true,
        questionsCount: 4,
      );
      final pdfBytes = await PdfService.generateMath(global, config);
      expect(pdfBytes.length, greaterThan(0));
    });

    test('generateMath - Seed Determinism', () async {
      final config1 = MathConfig(seed: 424242, questionsCount: 8);
      final config2 = MathConfig(seed: 424242, questionsCount: 8);

      final pdf1 = await PdfService.generateMath(global, config1);
      final pdf2 = await PdfService.generateMath(global, config2);
      expect(pdf1.length, greaterThan(0));
      expect(pdf2.length, greaterThan(0));
      expect((pdf1.length - pdf2.length).abs(), lessThan(50));
    });
  });

  group('PdfService Counting Generation', () {
    final global = GlobalConfig(title: "Test Counting");

    test('generateCounting - Count and Write & Draw to Match', () async {
      final config = CountingConfig(
        activityType: CountingActivityType.countAndWrite,
        questionsPerPage: 4,
      );
      final pdfBytes1 = await PdfService.generateCounting(global, config);
      expect(pdfBytes1.length, greaterThan(0));

      config.activityType = CountingActivityType.drawToMatch;
      final pdfBytes2 = await PdfService.generateCounting(global, config);
      expect(pdfBytes2.length, greaterThan(0));
    });

    test('generateCounting - Number Tracing', () async {
      final config = CountingConfig(
        activityType: CountingActivityType.numberTracing,
        minNumber: 1,
        maxNumber: 5,
        questionsPerPage: 5,
      );
      final pdfBytes = await PdfService.generateCounting(global, config);
      expect(pdfBytes.length, greaterThan(0));
    });

    test('generateCounting - More vs Less', () async {
      final config = CountingConfig(
        activityType: CountingActivityType.moreVsLess,
        compareMore: true,
        questionsPerPage: 4,
      );
      final pdfBytes = await PdfService.generateCounting(global, config);
      expect(pdfBytes.length, greaterThan(0));
    });

    test('generateCounting - Number Sequence', () async {
      final config = CountingConfig(
        activityType: CountingActivityType.numberSequence,
        sequenceLength: 4,
        questionsPerPage: 4,
      );
      final pdfBytes = await PdfService.generateCounting(global, config);
      expect(pdfBytes.length, greaterThan(0));
    });

    test('generateCounting - Seed Determinism', () async {
      final config1 = CountingConfig(seed: 7777, questionsPerPage: 6);
      final config2 = CountingConfig(seed: 7777, questionsPerPage: 6);

      final pdf1 = await PdfService.generateCounting(global, config1);
      final pdf2 = await PdfService.generateCounting(global, config2);
      expect(pdf1.length, greaterThan(0));
      expect(pdf2.length, greaterThan(0));
      expect((pdf1.length - pdf2.length).abs(), lessThan(50));
    });
  });

  group('MathScreen & CountingScreen Widget Tests', () {
    testWidgets('MathScreen renders and responds to mode changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MathScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Addition & Subtraction"), findsWidgets);
      expect(find.text("Worksheet Style"), findsOneWidget);

      // Select Number Line mode
      final dropdown = find.byType(DropdownButtonFormField<MathActivityMode>);
      expect(dropdown, findsOneWidget);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final numberLineItem = find.text("Number Line Jump Guides").last;
      await tester.tap(numberLineItem);
      await tester.pumpAndSettle();

      expect(find.text("Number Line Math"), findsWidgets);
    });

    testWidgets(
      'CountingScreen renders and responds to activity type changes',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: CountingScreen()));
        await tester.pumpAndSettle();

        expect(find.text("Numbers & Counting"), findsWidgets);
        expect(find.text("Worksheet Activity"), findsOneWidget);

        // Select Number Tracing mode
        final dropdown = find.byType(
          DropdownButtonFormField<CountingActivityType>,
        );
        expect(dropdown, findsOneWidget);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        final tracingItem = find.text("Number Tracing 1-20").last;
        await tester.tap(tracingItem);
        await tester.pumpAndSettle();

        expect(find.text("Number Tracing Practice"), findsWidgets);
      },
    );
  });
}
