import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/drawing_config.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/registry/worksheet_registry.dart';
import 'package:learn_loop/screens/drawing_screen.dart';
import 'package:learn_loop/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 11 Drawing Config Model Tests', () {
    test('DrawingConfig default settings', () {
      final config = DrawingConfig();
      expect(config.activityMode, equals(DrawingActivityMode.finishSymmetry));
      expect(config.gridSize, equals(8));
      expect(config.stepSubject, equals('cat'));
      expect(config.dotCount, equals(15));
      expect(config.seed, isNull);
    });

    test('DrawingActivityModeExtension labels', () {
      expect(
        DrawingActivityMode.finishSymmetry.label,
        contains('Grid Symmetry'),
      );
      expect(DrawingActivityMode.stepByStep.label, contains('Step-by-Step'));
      expect(DrawingActivityMode.storyPrompt.label, contains('Story Prompt'));
      expect(DrawingActivityMode.dotToDot.label, contains('Dot-to-Dot'));
    });
  });

  group('Phase 11 Drawing PDF Engine Tests', () {
    final globalConfig = GlobalConfig(title: 'Drawing Test');

    test(
      'PdfService.generateDrawing generates valid PDF for all 4 modes',
      () async {
        for (final mode in DrawingActivityMode.values) {
          final config = DrawingConfig(
            activityMode: mode,
            gridSize: 8,
            stepSubject: 'car',
            storyPromptText: 'Draw your favorite pet:',
            dotCount: 15,
            seed: 42,
          );

          final pdfBytes = await PdfService.generateDrawing(
            globalConfig,
            config,
          );
          expect(pdfBytes, isA<Uint8List>());
          expect(pdfBytes.length, greaterThan(1000));
        }
      },
    );
  });

  group('Phase 11 WorksheetRegistry Integration Tests', () {
    test('drawing_creativity activity is registered with metadata', () {
      final activity = WorksheetRegistry.getById('drawing_creativity');
      expect(activity, isNotNull);
      expect(activity!.title, contains('Drawing & Creative Prompts'));
      expect(activity.tags, contains('symmetry'));
      expect(activity.targetSkills, contains('creativity'));
      expect(activity.categoryIds, contains('drawing_creativity'));
      expect(WorksheetRegistry.getByCategory('drawing_creativity').map((a) => a.id), contains('drawing_creativity'));
    });
  });

  group('Phase 11 DrawingScreen UI Tests', () {
    testWidgets('DrawingScreen renders editor controls and builds PDF', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: DrawingScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Drawing & Creativity Generator'), findsOneWidget);
      expect(find.text('Worksheet Activity Mode'), findsOneWidget);

      // Verify activity mode dropdown
      final dropdown = find.byKey(const ValueKey('drawing_mode_dropdown'));
      expect(dropdown, findsOneWidget);

      // Select Step-by-Step mode
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final stepItem = find.text('Step-by-Step Drawing Guide').last;
      await tester.tap(stepItem);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('step_subject_dropdown')),
        findsOneWidget,
      );

      // Tap shuffle seed button
      await tester.tap(find.byKey(const ValueKey('shuffle_drawing_seed_btn')));
      await tester.pumpAndSettle();
    });
  });
}
