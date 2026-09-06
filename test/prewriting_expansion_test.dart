import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/models/prewriting_config.dart';
import 'package:learn_loop/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3 Pre-Writing & Pencil Control Engine Tests', () {
    test(
      'PrewritingConfig progression levels set expected pattern and corridor settings',
      () {
        final config = PrewritingConfig();

        config.applyProgressionLevel(1);
        expect(config.pattern, equals(LinePattern.straight));

        config.applyProgressionLevel(3);
        expect(config.pattern, equals(LinePattern.curve));

        config.applyProgressionLevel(5);
        expect(config.pattern, equals(LinePattern.loop));

        config.applyProgressionLevel(7);
        expect(config.pattern, equals(LinePattern.corridor));
        expect(config.corridorWidth, equals(CorridorWidthPreset.wide));
        expect(config.showCorridorBoundaries, isTrue);

        config.applyProgressionLevel(8);
        expect(config.pattern, equals(LinePattern.corridor));
        expect(config.corridorWidth, equals(CorridorWidthPreset.narrow));
      },
    );

    test(
      'PdfService.generatePrewriting generates valid PDF for all LinePattern options',
      () async {
        final global = GlobalConfig(title: "Pre-Writing Test");

        for (final pattern in LinePattern.values) {
          final config = PrewritingConfig(
            pattern: pattern,
            lineCount: 4,
            strokeWidth: 2.0,
            isDotted: true,
            showCorridorBoundaries: true,
          );

          final bytes = await PdfService.generatePrewriting(global, config);
          expect(
            bytes,
            isNotEmpty,
            reason: 'Failed for pattern: ${pattern.name}',
          );
        }
      },
    );

    test(
      'PdfService.generatePrewriting generates valid PDF for all ContextPair options',
      () async {
        final global = GlobalConfig(title: "Context Anchor Test");

        for (final pair in ContextPair.values) {
          final config = PrewritingConfig(
            pattern: LinePattern.wave,
            contextPair: pair,
            lineCount: 5,
          );

          final bytes = await PdfService.generatePrewriting(global, config);
          expect(
            bytes,
            isNotEmpty,
            reason: 'Failed for context pair: ${pair.name}',
          );
        }
      },
    );
  });
}
