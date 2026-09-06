import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/models/thinking_logic_config.dart';
import 'package:learn_loop/screens/thinking_logic_screen.dart';
import 'package:learn_loop/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 5 Thinking & Logic Engine Tests', () {
    test('ThinkingLogicConfig generates patterns correctly', () {
      const pool = ['star', 'circle', 'square'];

      final ab = PatternType.ab.generateSequence(pool, 4);
      expect(ab, equals(['star', 'circle', 'star', 'circle']));

      final aab = PatternType.aab.generateSequence(pool, 4);
      expect(aab, equals(['star', 'star', 'circle', 'star']));

      final abc = PatternType.abc.generateSequence(pool, 4);
      expect(abc, equals(['star', 'circle', 'square', 'star']));
    });

    test(
      'PdfService.generateThinkingLogic generates valid PDF for all ThinkingLogicType modes',
      () async {
        final global = GlobalConfig(title: "Logic Test");

        for (final mode in ThinkingLogicType.values) {
          final config = ThinkingLogicConfig(seed: 98765)..applyPreset(mode);
          final bytes = await PdfService.generateThinkingLogic(global, config);
          expect(bytes, isNotEmpty, reason: 'Failed for mode: ${mode.name}');
        }
      },
    );

    testWidgets('ThinkingLogicScreen renders editor controls and builds PDF', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ThinkingLogicScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Thinking & Logic Practice"), findsWidgets);
      expect(find.text("Activity Mode"), findsOneWidget);
      expect(find.text("Pattern Sequence Structure"), findsOneWidget);
      expect(find.text("New Random Logic Mix"), findsOneWidget);
    });
  });
}
