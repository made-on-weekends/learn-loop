import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/models/handwriting_config.dart';
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
  });
}
