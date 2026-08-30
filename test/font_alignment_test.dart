import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/models/handwriting_config.dart';
import 'package:learn_loop/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test handwriting PDF generation with updated font metrics', () async {
    final global = GlobalConfig();
    final config = HandwritingConfig();
    config.source = HandwritingSource.alphabetUpper;

    final pdfBytes = await PdfService.generateHandwriting(global, config);
    expect(pdfBytes, isNotEmpty);
  });
}
