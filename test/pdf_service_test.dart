import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/models/handwriting_config.dart';
import 'package:learn_loop/models/handwriting_line_style.dart';
import 'package:learn_loop/models/counting_config.dart';
import 'package:learn_loop/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfService Handwriting Generation Tests', () {
    test('generateHandwriting does not hang and generates pages successfully', () async {
      final globalConfig = GlobalConfig(title: 'Test Title');
      final config = HandwritingConfig();
      config.source = HandwritingSource.alphabetUpper;
      config.direction = PracticeDirection.row;

      final pdfBytes = await PdfService.generateHandwriting(globalConfig, config);
      expect(pdfBytes, isNotEmpty);
    });

    test('generateHandwriting in column mode does not hang and generates pages successfully', () async {
      final globalConfig = GlobalConfig(title: 'Test Title');
      final config = HandwritingConfig();
      config.source = HandwritingSource.alphabetLower;
      config.direction = PracticeDirection.column;

      final pdfBytes = await PdfService.generateHandwriting(globalConfig, config);
      expect(pdfBytes, isNotEmpty);
    });

    test('generateHandwriting supports all Zaner-Bloser grade level presets', () async {
      final globalConfig = GlobalConfig(title: 'Grade Level Test');

      for (var grade in GradeLevel.values) {
        final config = HandwritingConfig();
        config.applyGradePreset(grade);
        config.colorScheme = GuidelineColorScheme.zanerBloser;
        config.showRedMarginLine = true;

        final pdfBytes = await PdfService.generateHandwriting(globalConfig, config);
        expect(pdfBytes, isNotEmpty);

        if (grade != GradeLevel.custom) {
          expect(config.effectiveWritingHeightPt, equals(grade.defaultWritingHeightPt));
          expect(config.effectiveMidlineFromBaselinePt, equals(grade.defaultWritingHeightPt * 0.5));
          expect(config.effectiveDescenderBufferPt, equals(grade.defaultWritingHeightPt * 0.5));
        }
      }
    });

    test('generateHandwriting generates valid PDF in monochrome ink-saver mode', () async {
      final globalConfig = GlobalConfig(title: 'Monochrome Test');
      final config = HandwritingConfig();
      config.colorScheme = GuidelineColorScheme.monochrome;
      config.showRedMarginLine = false;

      final pdfBytes = await PdfService.generateHandwriting(globalConfig, config);
      expect(pdfBytes, isNotEmpty);
    });

    test('generateHandwriting supports all 4 HandwritingLineStyle choices', () async {
      final globalConfig = GlobalConfig(title: 'Line Style Test');

      for (var style in HandwritingLineStyle.values) {
        final config = HandwritingConfig();
        config.lineStyleOverride = style;

        final pdfBytes = await PdfService.generateHandwriting(globalConfig, config);
        expect(pdfBytes, isNotEmpty);
      }
    });
  });

  group('PdfService Counting Generation Tests', () {
    test('generateCounting in countAndWrite mode generates pages successfully', () async {
      final globalConfig = GlobalConfig(title: 'Test Title');
      final config = CountingConfig(
        activityType: CountingActivityType.countAndWrite,
        minNumber: 1,
        maxNumber: 20,
      );

      final pdfBytes = await PdfService.generateCounting(globalConfig, config);
      expect(pdfBytes, isNotEmpty);
    });

    test('generateCounting in drawToMatch mode generates pages successfully', () async {
      final globalConfig = GlobalConfig(title: 'Test Title');
      final config = CountingConfig(
        activityType: CountingActivityType.drawToMatch,
        minNumber: 1,
        maxNumber: 20,
      );

      final pdfBytes = await PdfService.generateCounting(globalConfig, config);
      expect(pdfBytes, isNotEmpty);
    });
  });
}
