import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/models/focus_attention_config.dart';
import 'package:learn_loop/screens/focus_attention_screen.dart';
import 'package:learn_loop/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4 Focus & Visual Attention Engine Tests', () {
    test('FocusAttentionConfig applies activity presets correctly', () {
      final config = FocusAttentionConfig();

      config.applyActivityPreset(FocusActivityType.findAndCircle);
      expect(config.activityType, equals(FocusActivityType.findAndCircle));
      expect(config.targetItem, equals('star'));

      config.applyActivityPreset(FocusActivityType.targetSearch);
      expect(config.activityType, equals(FocusActivityType.targetSearch));
      expect(config.targetItem, equals('B'));

      config.applyActivityPreset(FocusActivityType.oddOneOut);
      expect(config.activityType, equals(FocusActivityType.oddOneOut));

      config.applyActivityPreset(FocusActivityType.visualSearchGrid);
      expect(config.activityType, equals(FocusActivityType.visualSearchGrid));

      config.applyActivityPreset(FocusActivityType.findNObjects);
      expect(config.activityType, equals(FocusActivityType.findNObjects));
    });

    test(
      'PdfService.generateFocusAttention generates valid PDF for all FocusActivityType modes',
      () async {
        final global = GlobalConfig(title: "Focus Test");

        for (final mode in FocusActivityType.values) {
          final config = FocusAttentionConfig(seed: 12345)
            ..applyActivityPreset(mode);
          final bytes = await PdfService.generateFocusAttention(global, config);
          expect(bytes, isNotEmpty, reason: 'Failed for mode: ${mode.name}');
        }
      },
    );

    testWidgets('FocusAttentionScreen renders editor controls and builds PDF', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: FocusAttentionScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Focus & Visual Attention"), findsWidgets);
      expect(find.text("Activity Mode"), findsOneWidget);
      expect(find.text("Target Item (e.g. star, B, 5, apple)"), findsOneWidget);
      expect(find.text("New Random Grid Mix"), findsOneWidget);
    });
  });
}
