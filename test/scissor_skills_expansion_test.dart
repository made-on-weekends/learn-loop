import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/models/scissor_skills_config.dart';
import 'package:learn_loop/screens/scissor_skills_screen.dart';
import 'package:learn_loop/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 7 Scissor Skills & Fine Motor Engine Tests', () {
    test('ScissorSkillsConfig applies activity presets correctly', () {
      final config = ScissorSkillsConfig();

      config.applyPreset(ScissorLineType.straight);
      expect(config.lineType, equals(ScissorLineType.straight));
      expect(config.lineCount, equals(5));

      config.applyPreset(ScissorLineType.curved);
      expect(config.lineType, equals(ScissorLineType.curved));

      config.applyPreset(ScissorLineType.cutAndPaste);
      expect(config.lineType, equals(ScissorLineType.cutAndPaste));
    });

    test(
      'PdfService.generateScissorSkills generates valid PDF for all ScissorLineType modes',
      () async {
        final global = GlobalConfig(title: "Scissor Test");

        for (final mode in ScissorLineType.values) {
          final config = ScissorSkillsConfig(seed: 58219)..applyPreset(mode);
          final bytes = await PdfService.generateScissorSkills(global, config);
          expect(bytes, isNotEmpty, reason: 'Failed for mode: ${mode.name}');
        }
      },
    );

    testWidgets('ScissorSkillsScreen renders editor controls and builds PDF', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ScissorSkillsScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Scissor Skills & Cutting"), findsWidgets);
      expect(find.text("Scissor Cutting Mode"), findsOneWidget);
      expect(find.text("New Random Cut & Paste Mix"), findsOneWidget);
    });
  });
}
