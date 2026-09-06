import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/global_config.dart';
import '../models/handwriting_config.dart';
import '../models/handwriting_line_style.dart';
import '../models/kid_profile.dart';
import '../models/counting_config.dart';
import '../models/math_config.dart';
import '../models/prewriting_config.dart';
import '../models/shapes_config.dart';
import '../models/focus_attention_config.dart';
import '../models/thinking_logic_config.dart';
import '../models/scissor_skills_config.dart';
import '../models/coloring_config.dart';
import '../models/drawing_config.dart';
import 'asset_catalog_service.dart';
import 'random_seed_service.dart';
import 'settings_service.dart';

class PdfService {
  // Constants for conversion
  static const double mmToPt = 72.0 / 25.4;

  // Renders the standard header on each A4 page
  static pw.Widget _buildHeader(
    GlobalConfig global,
    pw.Font textFont,
    String sheetTitle,
  ) {
    if (!global.showHeader) {
      return pw.SizedBox.shrink();
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Row 1: Title (styled clean using Helvetica Bold to avoid broken tracing fonts)
        pw.Text(
          global.title.isNotEmpty ? global.title : sheetTitle,
          style: pw.TextStyle(
            font: pw.Font.helveticaBold(),
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        // Row 2: Name (left) and Date (right)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (global.showNameLine)
              pw.Text(
                "Name: ______________________",
                style: pw.TextStyle(font: pw.Font.helvetica(), fontSize: 10),
              )
            else
              pw.SizedBox.shrink(),
            if (global.showDateLine)
              pw.Text(
                "Date: _________________",
                style: pw.TextStyle(font: pw.Font.helvetica(), fontSize: 10),
              )
            else
              pw.SizedBox.shrink(),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(thickness: 1.0, color: PdfColors.grey300),
        pw.SizedBox(height: 8),
      ],
    );
  }

  // Helper to get character advance width, falling back to TTF/CFF hmtx table when stringMetrics returns 0
  static double _charAdvance(PdfFont font, String char) {
    final metrics = font.stringMetrics(char);
    if (metrics.size.x > 0) return metrics.size.x;
    if (font is PdfTtfFont) {
      final code = char.codeUnitAt(0);
      final gid = font.font.charToGlyphIndexMap[code];
      if (gid != null) {
        final hmtxOffset = font.font.tableOffsets['hmtx'];
        final unitsPerEm = font.font.unitsPerEm;
        final numOfLong = font.font.numOfLongHorMetrics;
        if (hmtxOffset != null && unitsPerEm > 0) {
          final bytes = font.font.bytes;
          final adv = gid < numOfLong
              ? bytes.getUint16(hmtxOffset + gid * 4)
              : bytes.getUint16(hmtxOffset + (numOfLong - 1) * 4);
          return adv / unitsPerEm;
        }
      }
    }
    return 0.5;
  }

  // Helper to measure string width using actual character advances
  static double _measureText(PdfFont font, double fontSize, String text) {
    final metrics = font.stringMetrics(text);
    if (metrics.size.x > 0) return metrics.size.x * fontSize;
    double total = 0.0;
    for (int i = 0; i < text.length; i++) {
      total += _charAdvance(font, text[i]) * fontSize;
    }
    return total;
  }

  // Helper to draw text character by character to prevent custom TTF font glyph overlap
  static void _drawText(
    PdfGraphics canvas,
    PdfFont font,
    double fontSize,
    String text,
    double x,
    double y,
  ) {
    double currentX = x;
    for (int i = 0; i < text.length; i++) {
      final String char = text[i];
      canvas.drawString(font, fontSize, char, currentX, y);
      currentX += _charAdvance(font, char) * fontSize;
    }
  }

  // Load custom fonts with safe fallback
  static Future<Map<String, pw.Font>> _loadFonts() async {
    pw.Font regular;
    pw.Font dashed;
    pw.Font bold;

    try {
      final regData = await rootBundle.load('assets/fonts/PrintClearly.otf');
      regular = pw.Font.ttf(regData);
    } catch (_) {
      regular = pw.Font.helvetica();
    }

    try {
      final dashData = await rootBundle.load('assets/fonts/PrintDashed.otf');
      dashed = pw.Font.ttf(dashData);
    } catch (_) {
      dashed = pw.Font.helvetica();
    }

    try {
      final boldData = await rootBundle.load('assets/fonts/PrintBold.otf');
      bold = pw.Font.ttf(boldData);
    } catch (_) {
      bold = pw.Font.helveticaBold();
    }

    return {'regular': regular, 'dashed': dashed, 'bold': bold};
  }

  // Helper: generates handwriting items based on settings
  static List<String> _generateHandwritingItems(HandwritingConfig config) {
    switch (config.source) {
      case HandwritingSource.alphabetUpper:
        int startCode = config.alphabetStart.isEmpty
            ? 65
            : config.alphabetStart.toUpperCase().codeUnitAt(0);
        int endCode = config.alphabetEnd.isEmpty
            ? 90
            : config.alphabetEnd.toUpperCase().codeUnitAt(0);
        if (startCode < 65 || startCode > 90) startCode = 65;
        if (endCode < 65 || endCode > 90) endCode = 90;
        if (startCode > endCode) {
          int temp = startCode;
          startCode = endCode;
          endCode = temp;
        }
        return List.generate(
          endCode - startCode + 1,
          (index) => String.fromCharCode(startCode + index),
        );
      case HandwritingSource.alphabetLower:
        int startCode = config.alphabetStart.isEmpty
            ? 97
            : config.alphabetStart.toLowerCase().codeUnitAt(0);
        int endCode = config.alphabetEnd.isEmpty
            ? 122
            : config.alphabetEnd.toLowerCase().codeUnitAt(0);
        if (startCode < 97 || startCode > 122) startCode = 97;
        if (endCode < 97 || endCode > 122) endCode = 122;
        if (startCode > endCode) {
          int temp = startCode;
          startCode = endCode;
          endCode = temp;
        }
        return List.generate(
          endCode - startCode + 1,
          (index) => String.fromCharCode(startCode + index),
        );
      case HandwritingSource.alphabetBoth:
        int startCode = config.alphabetStart.isEmpty
            ? 65
            : config.alphabetStart.toUpperCase().codeUnitAt(0);
        int endCode = config.alphabetEnd.isEmpty
            ? 90
            : config.alphabetEnd.toUpperCase().codeUnitAt(0);
        if (startCode < 65 || startCode > 90) startCode = 65;
        if (endCode < 65 || endCode > 90) endCode = 90;
        if (startCode > endCode) {
          int temp = startCode;
          startCode = endCode;
          endCode = temp;
        }
        return List.generate(endCode - startCode + 1, (index) {
          final char = String.fromCharCode(startCode + index);
          return "$char ${char.toLowerCase()}";
        });
      case HandwritingSource.numbers:
        int start = config.numberStart;
        int end = config.numberEnd;
        if (start > end) {
          int temp = start;
          start = end;
          end = temp;
        }
        return List.generate(
          end - start + 1,
          (index) => (start + index).toString(),
        );
      case HandwritingSource.cvcWords:
        final words = [
          "CAT",
          "DOG",
          "BUS",
          "SUN",
          "BED",
          "PIG",
          "FOX",
          "BAT",
          "HAT",
          "PEN",
          "CUP",
          "BOX",
        ];
        if (config.cvcMissingVowel) {
          return words.map((w) => "${w[0]}  _  ${w[2]}").toList();
        }
        return words;
      case HandwritingSource.sightWords:
        return [
          "THE",
          "AND",
          "YOU",
          "THAT",
          "WAS",
          "FOR",
          "ON",
          "ARE",
          "AS",
          "WITH",
          "HIS",
          "THEY",
          "AT",
          "BE",
          "THIS",
          "FROM",
          "HAVE",
          "OR",
          "BY",
          "ONE",
        ];
      case HandwritingSource.caseMatching:
      case HandwritingSource.alphabetSequence:
      case HandwritingSource.beginningSounds:
        return ["LITERACY_ACTIVITY"];
      case HandwritingSource.customText:
        if (config.customText.trim().isEmpty) {
          return ["ABC"];
        }
        return config.customText
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    }
  }

  // ==========================================
  // 1. HANDWRITING PRACTICE GENERATOR
  // ==========================================
  static Future<Uint8List> generateHandwriting(
    GlobalConfig global,
    HandwritingConfig config, {
    KidProfile? kidProfile,
  }) async {
    final profile = kidProfile ?? SettingsService.currentKidProfile;
    final styleDef = config.getEffectiveLineStyle(profile).definition;

    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final pw.Font solidFont = fonts['regular']!;
    final pw.Font dottedFont = fonts['dashed']!;
    final pw.Font boldFont = fonts['bold']!;

    final double margin = global.marginMm * mmToPt;

    if (config.source == HandwritingSource.caseMatching ||
        config.source == HandwritingSource.alphabetSequence ||
        config.source == HandwritingSource.beginningSounds) {
      String headerTitle = "Handwriting Practice";
      if (config.source == HandwritingSource.caseMatching) {
        headerTitle = "Match Uppercase to Lowercase Letters";
      } else if (config.source == HandwritingSource.alphabetSequence) {
        headerTitle = "Fill in Missing Letters";
      } else if (config.source == HandwritingSource.beginningSounds) {
        headerTitle = "Circle the Beginning Sound";
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(margin),
          build: (context) {
            final rand = config.seed != null
                ? math.Random(config.seed)
                : math.Random();
            final PdfFont pdfSolid = solidFont.getFont(context);
            final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
            final double headerHeight = global.showHeader ? 75.0 : 0.0;
            final double printableHeight =
                PdfPageFormat.a4.height - 2 * margin - headerHeight - 16.0;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(global, boldFont, headerTitle),
                if (global.showHeader) pw.SizedBox(height: 8),
                pw.Container(
                  width: printableWidth,
                  height: printableHeight,
                  child: pw.CustomPaint(
                    size: PdfPoint(printableWidth, printableHeight),
                    painter: (canvas, size) {
                      if (config.source == HandwritingSource.caseMatching) {
                        _drawCaseMatchingPage(canvas, size, rand, pdfSolid);
                      } else if (config.source ==
                          HandwritingSource.alphabetSequence) {
                        _drawAlphabetSequencePage(canvas, size, rand, pdfSolid);
                      } else if (config.source ==
                          HandwritingSource.beginningSounds) {
                        _drawBeginningSoundsPage(canvas, size, rand, pdfSolid);
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );

      return pdf.save();
    }

    final List<String> items = _generateHandwritingItems(config);
    if (items.isEmpty) return pdf.save();

    final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
    final double headerHeight = global.showHeader ? 75.0 : 0.0;
    final double printableHeight =
        PdfPageFormat.a4.height - 2 * margin - headerHeight - 20.0;

    final double fontSize = config.getEffectiveFontSizePt(profile);
    final double rowHeight = config.getEffectiveRowHeightPt(profile);

    final dummyContext = pw.Context(document: pdf.document);
    final PdfFont pdfSolid = solidFont.getFont(dummyContext);
    final PdfFont pdfDotted = dottedFont.getFont(dummyContext);
    final PdfFont pdfTrace = config.dottedFont ? pdfDotted : pdfSolid;
    final PdfFont measureFont = config.mode == PracticeMode.tracing
        ? pdfTrace
        : pdfSolid;

    int rowsPerPage = (printableHeight / rowHeight).floor();
    if (rowsPerPage < 1) rowsPerPage = 1;

    // Calculate global dynamic column sizing parameters across all items to ensure page-to-page consistency
    double globalMaxItemWidth = 0.0;
    for (var item in items) {
      double w = measureFont.stringMetrics(item).size.x * fontSize;
      if (w > globalMaxItemWidth) globalMaxItemWidth = w;
    }
    double globalCellPadding = fontSize * 0.8;
    double globalCellWidth = math.max(
      globalMaxItemWidth + globalCellPadding,
      fontSize * 1.8,
    );
    int globalColsCount = (printableWidth / globalCellWidth).floor();
    if (globalColsCount < 1) globalColsCount = 1;
    globalCellWidth = printableWidth / globalColsCount;

    if (config.direction == PracticeDirection.row) {
      int itemIndex = 0;

      while (itemIndex < items.length) {
        final List<String> pageItems = [];
        for (int r = 0; r < rowsPerPage && itemIndex < items.length; r++) {
          pageItems.add(items[itemIndex]);
          itemIndex++;
        }

        final double capturedCellWidth = globalCellWidth;
        final int capturedColsCount = globalColsCount;
        final List<String> capturedPageItems = List.from(pageItems);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(margin),
            build: (context) {
              final PdfFont localSolid = solidFont.getFont(context);
              final PdfFont localDotted = config.dottedFont
                  ? dottedFont.getFont(context)
                  : localSolid;
              final double fullRowWidth = capturedCellWidth * capturedColsCount;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(global, boldFont, "Handwriting Practice"),
                  if (global.showHeader) pw.SizedBox(height: 8),
                  pw.Column(
                    children: List.generate(capturedPageItems.length, (rIndex) {
                      final String item = capturedPageItems[rIndex];
                      return pw.CustomPaint(
                        size: PdfPoint(fullRowWidth, rowHeight),
                        painter: (canvas, size) {
                          _drawHandwritingRow(
                            canvas,
                            size,
                            item,
                            localSolid,
                            localDotted,
                            fontSize,
                            capturedColsCount,
                            capturedCellWidth,
                            config,
                            global,
                            styleDef,
                            isLastRow: rIndex == capturedPageItems.length - 1,
                          );
                        },
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        );
      }
    } else {
      // Column mode
      int itemIndex = 0;

      while (itemIndex < items.length) {
        final List<String> pageItems = [];
        for (int c = 0; c < globalColsCount && itemIndex < items.length; c++) {
          pageItems.add(items[itemIndex]);
          itemIndex++;
        }

        final double capturedCellWidth = globalCellWidth;
        final List<String> capturedPageItems = List.from(pageItems);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(margin),
            build: (context) {
              final PdfFont localSolid = solidFont.getFont(context);
              final PdfFont localDotted = config.dottedFont
                  ? dottedFont.getFont(context)
                  : localSolid;

              final double fullRowWidth =
                  capturedCellWidth * capturedPageItems.length;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(global, boldFont, "Handwriting Practice"),
                  if (global.showHeader) pw.SizedBox(height: 8),
                  pw.Column(
                    children: List.generate(rowsPerPage, (rIndex) {
                      return pw.CustomPaint(
                        size: PdfPoint(fullRowWidth, rowHeight),
                        painter: (canvas, size) {
                          _drawHandwritingColumnRow(
                            canvas,
                            size,
                            capturedPageItems,
                            localSolid,
                            localDotted,
                            fontSize,
                            capturedCellWidth,
                            rIndex,
                            config,
                            global,
                            styleDef,
                            isLastRow: rIndex == rowsPerPage - 1,
                          );
                        },
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    return pdf.save();
  }

  // Early Literacy Drawing Helpers
  static void _drawCaseMatchingPage(
    PdfGraphics canvas,
    PdfPoint size,
    math.Random rand,
    PdfFont font,
  ) {
    const double instructionsFontSize = 14.0;
    const double letterFontSize = 26.0;
    const int pairCount = 6;

    _drawText(
      canvas,
      font,
      instructionsFontSize,
      "Draw a line from each uppercase letter to its matching lowercase letter.",
      0,
      size.y - instructionsFontSize - 10,
    );

    final List<int> letterIndices = List.generate(26, (i) => i);
    letterIndices.shuffle(rand);
    final selectedIndices = letterIndices.take(pairCount).toList();

    final upperLetters = selectedIndices
        .map((i) => String.fromCharCode(65 + i))
        .toList();
    final lowerIndices = List<int>.from(selectedIndices)..shuffle(rand);
    final lowerLetters = lowerIndices
        .map((i) => String.fromCharCode(97 + i))
        .toList();

    final double contentHeight = size.y - 40.0;
    final double rowStep = contentHeight / pairCount;
    final double leftColX = size.x * 0.20;
    final double rightColX = size.x * 0.80;

    for (int i = 0; i < pairCount; i++) {
      final double y = size.y - 50.0 - (i * rowStep) - rowStep / 2;

      final upperChar = upperLetters[i];
      final double upperW =
          font.stringMetrics(upperChar).size.x * letterFontSize;

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey400);
      canvas.setLineWidth(1.0);
      canvas.drawRect(leftColX - 25, y - 20, 50, 40);
      canvas.strokePath();
      canvas.restoreContext();

      _drawText(
        canvas,
        font,
        letterFontSize,
        upperChar,
        leftColX - upperW / 2,
        y - letterFontSize * 0.35,
      );

      canvas.saveContext();
      canvas.setFillColor(PdfColors.black);
      canvas.drawEllipse(leftColX + 35, y, 4, 4);
      canvas.fillPath();
      canvas.restoreContext();

      final lowerChar = lowerLetters[i];
      final double lowerW =
          font.stringMetrics(lowerChar).size.x * letterFontSize;

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey400);
      canvas.setLineWidth(1.0);
      canvas.drawRect(rightColX - 25, y - 20, 50, 40);
      canvas.strokePath();
      canvas.restoreContext();

      _drawText(
        canvas,
        font,
        letterFontSize,
        lowerChar,
        rightColX - lowerW / 2,
        y - letterFontSize * 0.35,
      );

      canvas.saveContext();
      canvas.setFillColor(PdfColors.black);
      canvas.drawEllipse(rightColX - 35, y, 4, 4);
      canvas.fillPath();
      canvas.restoreContext();
    }
  }

  static void _drawAlphabetSequencePage(
    PdfGraphics canvas,
    PdfPoint size,
    math.Random rand,
    PdfFont font,
  ) {
    const double instructionsFontSize = 14.0;
    const double letterFontSize = 24.0;
    const int rowCount = 5;
    const int itemsPerRow = 5;

    _drawText(
      canvas,
      font,
      instructionsFontSize,
      "Fill in the missing letters in each sequence.",
      0,
      size.y - instructionsFontSize - 10,
    );

    final double contentHeight = size.y - 40.0;
    final double rowStep = contentHeight / rowCount;

    for (int r = 0; r < rowCount; r++) {
      final double rowY = size.y - 50.0 - (r * rowStep) - rowStep / 2;
      final int startCode = 65 + rand.nextInt(22);

      final List<int> positions = List.generate(itemsPerRow, (i) => i);
      positions.shuffle(rand);
      final Set<int> missingIndices = {positions[0], positions[1]};

      const double boxSize = 54.0;
      const double boxGap = 16.0;
      final double totalW = itemsPerRow * boxSize + (itemsPerRow - 1) * boxGap;
      final double startX = (size.x - totalW) / 2;

      for (int i = 0; i < itemsPerRow; i++) {
        final double boxX = startX + i * (boxSize + boxGap);
        final String char = String.fromCharCode(startCode + i);
        final bool isMissing = missingIndices.contains(i);

        canvas.saveContext();
        if (isMissing) {
          canvas.setStrokeColor(PdfColors.black);
          canvas.setLineWidth(1.5);
          canvas.drawRect(boxX, rowY - boxSize / 2, boxSize, boxSize);
          canvas.strokePath();

          canvas.setStrokeColor(PdfColors.grey400);
          canvas.setLineWidth(0.8);
          canvas.setLineDashPattern([3, 3]);
          canvas.moveTo(boxX + 6, rowY);
          canvas.lineTo(boxX + boxSize - 6, rowY);
          canvas.strokePath();
        } else {
          canvas.setStrokeColor(PdfColors.grey400);
          canvas.setLineWidth(1.0);
          canvas.drawRect(boxX, rowY - boxSize / 2, boxSize, boxSize);
          canvas.strokePath();

          final double strW = font.stringMetrics(char).size.x * letterFontSize;
          _drawText(
            canvas,
            font,
            letterFontSize,
            char,
            boxX + (boxSize - strW) / 2,
            rowY - letterFontSize * 0.35,
          );
        }
        canvas.restoreContext();

        if (i < itemsPerRow - 1) {
          canvas.saveContext();
          canvas.setStrokeColor(PdfColors.grey500);
          canvas.setLineWidth(1.2);
          final double arrowStartX = boxX + boxSize + 3;
          final double arrowEndX = arrowStartX + boxGap - 6;
          canvas.moveTo(arrowStartX, rowY);
          canvas.lineTo(arrowEndX, rowY);
          canvas.lineTo(arrowEndX - 4, rowY + 3);
          canvas.moveTo(arrowEndX, rowY);
          canvas.lineTo(arrowEndX - 4, rowY - 3);
          canvas.strokePath();
          canvas.restoreContext();
        }
      }
    }
  }

  static void _drawBeginningSoundsPage(
    PdfGraphics canvas,
    PdfPoint size,
    math.Random rand,
    PdfFont font,
  ) {
    const double instructionsFontSize = 14.0;
    const double letterFontSize = 24.0;
    const int rowCount = 5;

    _drawText(
      canvas,
      font,
      instructionsFontSize,
      "Look at each picture and circle its beginning sound.",
      0,
      size.y - instructionsFontSize - 10,
    );

    final List<Map<String, dynamic>> itemsPool = [
      {'letter': 'A', 'shape': ShapeType.apple},
      {'letter': 'T', 'shape': ShapeType.tree},
      {'letter': 'S', 'shape': ShapeType.star},
      {'letter': 'H', 'shape': ShapeType.heart},
      {'letter': 'C', 'shape': ShapeType.circle},
      {'letter': 'S', 'shape': ShapeType.square},
      {'letter': 'T', 'shape': ShapeType.triangle},
    ];
    itemsPool.shuffle(rand);
    final selectedPool = itemsPool.take(rowCount).toList();

    final double contentHeight = size.y - 40.0;
    final double rowStep = contentHeight / rowCount;

    for (int r = 0; r < rowCount; r++) {
      final double rowY = size.y - 50.0 - (r * rowStep) - rowStep / 2;
      final item = selectedPool[r];
      final String correctLetter = item['letter'] as String;
      final ShapeType shape = item['shape'] as ShapeType;

      final double pictureX = size.x * 0.22;
      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey300);
      canvas.setLineWidth(1.0);
      canvas.drawRect(pictureX - 45, rowY - 35, 90, 70);
      canvas.strokePath();
      canvas.restoreContext();

      _drawShape(canvas, shape, pictureX, rowY, 48.0);

      final List<String> options = [correctLetter];
      while (options.length < 3) {
        final String randomLetter = String.fromCharCode(65 + rand.nextInt(26));
        if (!options.contains(randomLetter)) {
          options.add(randomLetter);
        }
      }
      options.shuffle(rand);

      const double circleRadius = 24.0;
      const double optionGap = 65.0;
      final double optionsStartX = size.x * 0.52;

      for (int i = 0; i < options.length; i++) {
        final double circleX = optionsStartX + i * optionGap;
        final String optChar = options[i];

        canvas.saveContext();
        canvas.setStrokeColor(PdfColors.black);
        canvas.setLineWidth(1.2);
        canvas.drawEllipse(circleX, rowY, circleRadius, circleRadius);
        canvas.strokePath();
        canvas.restoreContext();

        final double strW = font.stringMetrics(optChar).size.x * letterFontSize;
        _drawText(
          canvas,
          font,
          letterFontSize,
          optChar,
          circleX - strW / 2,
          rowY - letterFontSize * 0.35,
        );
      }
    }
  }

  // Draw a full-width handwriting row with guidelines spanning entire row width (row-direction mode).
  static void _drawHandwritingRow(
    PdfGraphics canvas,
    PdfPoint size,
    String text,
    PdfFont solidFont,
    PdfFont dottedFont,
    double fontSize,
    int colsCount,
    double cellWidth,
    HandwritingConfig config,
    GlobalConfig global,
    HandwritingStyleDefinition styleDef, {
    bool isLastRow = false,
  }) {
    final double width = size.x;
    final double height = size.y;

    final double descenderBuffer = height * 0.5;
    final double writingHeight = height * 0.5;
    final double midlineFromBaseline = writingHeight * 0.5;

    final double baselineY = descenderBuffer;
    final double midLineY = baselineY + midlineFromBaseline;
    final double topLineY = baselineY + writingHeight;
    final double separatorY = descenderBuffer * 0.5;
    final double bottomLineY = 0.0;

    final bool isZanerBloser =
        config.colorScheme == GuidelineColorScheme.zanerBloser;
    final PdfColor redColor = isZanerBloser
        ? PdfColor.fromHex('#E53935')
        : PdfColors.grey500;
    final PdfColor blueColor = isZanerBloser
        ? PdfColor.fromHex('#1E88E5')
        : PdfColors.grey400;
    final PdfColor blackColor = isZanerBloser
        ? PdfColor.fromHex('#1A1A1A')
        : PdfColors.grey700;

    canvas.saveContext();

    // 1. Left Vertical Margin Red Line (0.75" margin guide at left margin boundary)
    if (global.showRedMarginLine && config.showRedMarginLine) {
      canvas.setStrokeColor(redColor);
      canvas.setLineWidth(1.0);
      canvas.drawLine(0, 0, 0, height);
      canvas.strokePath();
    }

    // 2. Horizontal Guidelines
    // Line 1: Headline (Top Line) - Solid Red Line
    if (config.showTopLine) {
      canvas.setStrokeColor(redColor);
      canvas.setLineWidth(0.7);
      canvas.drawLine(0, topLineY, width, topLineY);
      canvas.strokePath();
    }

    // Line 2: Midline (Center) - Dashed/Dotted Blue Line (only for 3-line styles)
    if (styleDef.hasMiddleGuide && config.showMidLine) {
      canvas.setStrokeColor(blueColor);
      canvas.setLineWidth(0.6);
      canvas.setLineDashPattern([3, 3], 0);
      canvas.drawLine(0, midLineY, width, midLineY);
      canvas.strokePath();
      canvas.setLineDashPattern([], 0);
    }

    // Line 3: Baseline (Bottom) - Thick Solid Black Line
    if (config.showBaseLine) {
      canvas.setStrokeColor(blackColor);
      canvas.setLineWidth(1.2);
      canvas.drawLine(0, baselineY, width, baselineY);
      canvas.strokePath();
    }

    // Separator line centered in descender gap (equal gap above baseline and below next headline)
    canvas.setStrokeColor(PdfColors.grey500);
    canvas.setLineWidth(0.8);
    canvas.setLineDashPattern([4, 3], 0);
    canvas.drawLine(0, separatorY, width, separatorY);
    canvas.strokePath();
    canvas.setLineDashPattern([], 0);

    if (config.showBottomLine && isLastRow) {
      canvas.setStrokeColor(
        isZanerBloser ? PdfColor.fromHex('#E53935') : PdfColors.grey500,
      );
      canvas.setLineWidth(0.7);
      canvas.drawLine(0, bottomLineY, width, bottomLineY);
      canvas.strokePath();
    }

    canvas.restoreContext();

    // 3. Draw text at each cell position
    for (int cIndex = 0; cIndex < colsCount; cIndex++) {
      bool isEmpty = false;
      PdfFont font;

      if (config.mode == PracticeMode.copy) {
        if (cIndex == 0) {
          isEmpty = false;
          font = solidFont;
        } else {
          isEmpty = true;
          font = dottedFont;
        }
      } else {
        isEmpty = false;
        font = dottedFont;
      }

      if (!isEmpty && text.isNotEmpty) {
        canvas.saveContext();
        // Dynamically compute font size based on actual writing height and visual cap height ratio
        final double capHeightRatio = HandwritingConfig.fontCapHeightRatio;
        final double rowFontSize = writingHeight / capHeightRatio;
        final double fontWidth = font.stringMetrics(text).size.x;
        double effectiveFontSize = rowFontSize;

        // Auto-scale font size only for longer custom text phrases if text width exceeds cell width
        if (text.length > 2) {
          final double maxAllowedWidth = cellWidth - 4.0;
          if (fontWidth * effectiveFontSize > maxAllowedWidth &&
              fontWidth > 0) {
            effectiveFontSize = maxAllowedWidth / fontWidth;
          }
        }

        final double textWidth = fontWidth * effectiveFontSize;
        final double cellStartX = cIndex * cellWidth;
        final double startX = cellStartX + (cellWidth - textWidth) / 2;
        final double drawY =
            baselineY +
            (HandwritingConfig.fontBaselineOffsetRatio * effectiveFontSize);
        canvas.setFillColor(PdfColors.black);
        _drawText(canvas, font, effectiveFontSize, text, startX, drawY);
        canvas.restoreContext();
      }
    }
  }

  // Draw a full-width handwriting row for column-direction mode.
  static void _drawHandwritingColumnRow(
    PdfGraphics canvas,
    PdfPoint size,
    List<String> columnItems,
    PdfFont solidFont,
    PdfFont dottedFont,
    double fontSize,
    double cellWidth,
    int rIndex,
    HandwritingConfig config,
    GlobalConfig global,
    HandwritingStyleDefinition styleDef, {
    bool isLastRow = false,
  }) {
    final double width = size.x;
    final double height = size.y;

    final double descenderBuffer = height * 0.5;
    final double writingHeight = height * 0.5;
    final double midlineFromBaseline = writingHeight * 0.5;

    final double baselineY = descenderBuffer;
    final double midLineY = baselineY + midlineFromBaseline;
    final double topLineY = baselineY + writingHeight;
    final double separatorY = descenderBuffer * 0.5;
    final double bottomLineY = 0.0;

    final bool isZanerBloser =
        config.colorScheme == GuidelineColorScheme.zanerBloser;
    final PdfColor redColor = isZanerBloser
        ? PdfColor.fromHex('#E53935')
        : PdfColors.grey500;
    final PdfColor blueColor = isZanerBloser
        ? PdfColor.fromHex('#1E88E5')
        : PdfColors.grey400;
    final PdfColor blackColor = isZanerBloser
        ? PdfColor.fromHex('#1A1A1A')
        : PdfColors.grey700;

    canvas.saveContext();

    // 1. Left Vertical Margin Red Line
    if (global.showRedMarginLine && config.showRedMarginLine) {
      canvas.setStrokeColor(redColor);
      canvas.setLineWidth(1.0);
      canvas.drawLine(0, 0, 0, height);
      canvas.strokePath();
    }

    // 2. Horizontal Guidelines
    if (config.showTopLine) {
      canvas.setStrokeColor(redColor);
      canvas.setLineWidth(0.7);
      canvas.drawLine(0, topLineY, width, topLineY);
      canvas.strokePath();
    }

    if (styleDef.hasMiddleGuide && config.showMidLine) {
      canvas.setStrokeColor(blueColor);
      canvas.setLineWidth(0.6);
      canvas.setLineDashPattern([3, 3], 0);
      canvas.drawLine(0, midLineY, width, midLineY);
      canvas.strokePath();
      canvas.setLineDashPattern([], 0);
    }

    if (config.showBaseLine) {
      canvas.setStrokeColor(blackColor);
      canvas.setLineWidth(1.2);
      canvas.drawLine(0, baselineY, width, baselineY);
      canvas.strokePath();
    }

    // Separator line centered in descender gap (equal gap above baseline and below next headline)
    canvas.setStrokeColor(PdfColors.grey500);
    canvas.setLineWidth(0.8);
    canvas.setLineDashPattern([4, 3], 0);
    canvas.drawLine(0, separatorY, width, separatorY);
    canvas.strokePath();
    canvas.setLineDashPattern([], 0);

    if (config.showBottomLine && isLastRow) {
      canvas.setStrokeColor(
        isZanerBloser ? PdfColor.fromHex('#E53935') : PdfColors.grey500,
      );
      canvas.setLineWidth(0.7);
      canvas.drawLine(0, bottomLineY, width, bottomLineY);
      canvas.strokePath();
    }

    canvas.restoreContext();

    // 3. Draw text at each column position
    for (int cIndex = 0; cIndex < columnItems.length; cIndex++) {
      final String item = columnItems[cIndex];
      bool isEmpty = false;
      PdfFont font;

      if (config.mode == PracticeMode.copy) {
        if (rIndex == 0) {
          isEmpty = false;
          font = solidFont;
        } else {
          isEmpty = true;
          font = dottedFont;
        }
      } else {
        isEmpty = false;
        font = dottedFont;
      }

      if (!isEmpty && item.isNotEmpty) {
        canvas.saveContext();
        // Dynamically compute font size based on actual writing height and visual cap height ratio
        final double capHeightRatio = HandwritingConfig.fontCapHeightRatio;
        final double rowFontSize = writingHeight / capHeightRatio;
        final double fontWidth = font.stringMetrics(item).size.x;
        double effectiveFontSize = rowFontSize;

        // Auto-scale font size only for longer custom text phrases if text width exceeds cell width
        if (item.length > 2) {
          final double maxAllowedWidth = cellWidth - 4.0;
          if (fontWidth * effectiveFontSize > maxAllowedWidth &&
              fontWidth > 0) {
            effectiveFontSize = maxAllowedWidth / fontWidth;
          }
        }

        final double textWidth = fontWidth * effectiveFontSize;
        final double cellStartX = cIndex * cellWidth;
        final double startX = cellStartX + (cellWidth - textWidth) / 2;
        final double drawY =
            baselineY +
            (HandwritingConfig.fontBaselineOffsetRatio * effectiveFontSize);
        canvas.setFillColor(PdfColors.black);
        _drawText(canvas, font, effectiveFontSize, item, startX, drawY);
        canvas.restoreContext();
      }
    }
  }

  // ==========================================
  // 2. NUMBERS AND COUNTING GENERATOR
  // ==========================================
  static Future<Uint8List> generateCounting(
    GlobalConfig global,
    CountingConfig config,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final pw.Font solidFont = fonts['regular']!;
    final pw.Font boldFont = fonts['bold']!;
    final double margin = global.marginMm * mmToPt;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(margin),
        build: (context) {
          final rand = config.seed != null
              ? math.Random(config.seed)
              : math.Random();
          final PdfFont pdfSolid = solidFont.getFont(context);

          final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
          final double headerHeight = global.showHeader ? 75.0 : 0.0;
          final double printableHeight =
              PdfPageFormat.a4.height - 2 * margin - headerHeight - 12.0;

          String titleStr;
          switch (config.activityType) {
            case CountingActivityType.countAndWrite:
              titleStr = "Count and Write";
              break;
            case CountingActivityType.drawToMatch:
              titleStr = "Draw to Match";
              break;
            case CountingActivityType.numberTracing:
              titleStr = "Number Tracing Practice";
              break;
            case CountingActivityType.moreVsLess:
              titleStr = config.compareMore
                  ? "Circle the Group with MORE"
                  : "Circle the Group with FEWER";
              break;
            case CountingActivityType.numberSequence:
              titleStr = "Fill in Missing Numbers";
              break;
          }

          if (config.activityType == CountingActivityType.numberTracing) {
            final List<int> numbersToTrace = [];
            final int minN = math.max(1, config.minNumber);
            final int maxN = math.max(minN, config.maxNumber);
            for (
              int i = minN;
              i <= maxN && numbersToTrace.length < config.questionsPerPage;
              i++
            ) {
              numbersToTrace.add(i);
            }
            if (numbersToTrace.isEmpty) numbersToTrace.add(1);

            final int rows = numbersToTrace.length;
            final double rowHeight = printableHeight / rows;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(global, boldFont, titleStr),
                pw.Column(
                  children: List.generate(rows, (rIndex) {
                    final int numVal = numbersToTrace[rIndex];
                    return pw.Container(
                      width: printableWidth,
                      height: rowHeight,
                      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
                      child: pw.CustomPaint(
                        size: PdfPoint(printableWidth, rowHeight - 8),
                        painter: (canvas, size) {
                          _drawNumberTracingRow(canvas, size, numVal, pdfSolid);
                        },
                      ),
                    );
                  }),
                ),
              ],
            );
          } else if (config.activityType ==
              CountingActivityType.numberSequence) {
            final int questions = math.max(2, config.questionsPerPage);
            final double rowHeight = printableHeight / questions;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(global, boldFont, titleStr),
                pw.Column(
                  children: List.generate(questions, (qIdx) {
                    final int seqLen = config.sequenceLength.clamp(3, 6);
                    final int rangeSpan = config.maxNumber - config.minNumber;
                    final int startVal =
                        config.minNumber +
                        (rangeSpan > seqLen
                            ? rand.nextInt(rangeSpan - seqLen + 1)
                            : 0);

                    return pw.Container(
                      width: printableWidth,
                      height: rowHeight,
                      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
                      child: pw.CustomPaint(
                        size: PdfPoint(printableWidth, rowHeight - 8),
                        painter: (canvas, size) {
                          _drawSequenceQuestion(
                            canvas,
                            size,
                            startVal,
                            seqLen,
                            rand,
                            pdfSolid,
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            );
          } else if (config.activityType == CountingActivityType.moreVsLess) {
            final int questions = config.questionsPerPage;
            final int rows = (questions / 2).ceil();
            final double rowHeight = printableHeight / rows;
            final double colWidth = printableWidth / 2;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(global, boldFont, titleStr),
                pw.Column(
                  children: List.generate(rows, (rIndex) {
                    return pw.Row(
                      children: List.generate(2, (cIndex) {
                        final int qIdx = rIndex * 2 + cIndex;
                        if (qIdx >= questions) {
                          return pw.SizedBox(
                            width: colWidth,
                            height: rowHeight,
                          );
                        }

                        int countA =
                            config.minNumber +
                            rand.nextInt(
                              config.maxNumber - config.minNumber + 1,
                            );
                        int countB =
                            config.minNumber +
                            rand.nextInt(
                              config.maxNumber - config.minNumber + 1,
                            );
                        if (countA == countB) {
                          countB = countA < config.maxNumber
                              ? countA + 1
                              : countA - 1;
                        }

                        ShapeType shape = config.shapeType;
                        if (shape == ShapeType.random) {
                          final shapes = ShapeType.values
                              .where((e) => e != ShapeType.random)
                              .toList();
                          shape = shapes[rand.nextInt(shapes.length)];
                        }

                        return pw.Container(
                          width: colWidth,
                          height: rowHeight,
                          padding: const pw.EdgeInsets.all(6.0),
                          child: pw.CustomPaint(
                            size: PdfPoint(colWidth - 12, rowHeight - 12),
                            painter: (canvas, size) {
                              _drawMoreVsLessQuestion(
                                canvas,
                                size,
                                countA,
                                countB,
                                shape,
                                pdfSolid,
                              );
                            },
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ],
            );
          } else {
            final int questions = config.questionsPerPage;
            final int rows = (questions / 2).ceil();
            final double rowHeight = printableHeight / rows;
            final double colWidth = printableWidth / 2;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(global, boldFont, titleStr),
                pw.Column(
                  children: List.generate(rows, (rIndex) {
                    return pw.Row(
                      children: List.generate(2, (cIndex) {
                        final int qIdx = rIndex * 2 + cIndex;
                        if (qIdx >= questions) {
                          return pw.SizedBox(
                            width: colWidth,
                            height: rowHeight,
                          );
                        }

                        final int targetNum =
                            config.minNumber +
                            rand.nextInt(
                              config.maxNumber - config.minNumber + 1,
                            );
                        ShapeType shape = config.shapeType;
                        if (shape == ShapeType.random) {
                          final shapes = ShapeType.values
                              .where((e) => e != ShapeType.random)
                              .toList();
                          shape = shapes[rand.nextInt(shapes.length)];
                        }

                        return pw.Container(
                          width: colWidth,
                          height: rowHeight,
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.CustomPaint(
                            size: PdfPoint(colWidth - 16, rowHeight - 16),
                            painter: (canvas, size) {
                              _drawCountingQuestion(
                                canvas,
                                size,
                                targetNum,
                                shape,
                                config.activityType,
                                pdfSolid,
                              );
                            },
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ],
            );
          }
        },
      ),
    );

    return pdf.save();
  }

  // Draw counting exercise
  static void _drawCountingQuestion(
    PdfGraphics canvas,
    PdfPoint size,
    int count,
    ShapeType shape,
    CountingActivityType activityType,
    PdfFont font,
  ) {
    final double width = size.x;
    final double height = size.y;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey400);
    canvas.setLineWidth(1.0);
    canvas.drawRect(0, 0, width, height);
    canvas.strokePath();

    final double dividerX = activityType == CountingActivityType.countAndWrite
        ? width * 0.7
        : width * 0.5;
    canvas.setLineDashPattern([2, 2], 0);
    canvas.drawLine(dividerX, 0, dividerX, height);
    canvas.strokePath();
    canvas.restoreContext();

    if (activityType == CountingActivityType.countAndWrite) {
      final double areaW = dividerX;
      final double areaH = height;

      int gridCols = (math.sqrt(count)).ceil();
      int gridRows = (count / gridCols).ceil();

      double stepX = areaW / (gridCols + 1);
      double stepY = areaH / (gridRows + 1);
      double shapeSize = math.min(stepX * 0.7, stepY * 0.7);

      int drawn = 0;
      for (int r = 0; r < gridRows; r++) {
        for (int c = 0; c < gridCols; c++) {
          if (drawn >= count) break;
          double cx = stepX * (c + 1);
          double cy = stepY * (r + 1);
          _drawShape(canvas, shape, cx, cy, shapeSize);
          drawn++;
        }
      }

      final double boxSize = 40.0;
      final double bx = dividerX + (width - dividerX - boxSize) / 2;
      final double by = (height - boxSize) / 2;

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey800);
      canvas.setLineWidth(1.5);
      canvas.drawRect(bx, by, boxSize, boxSize);
      canvas.strokePath();
      canvas.restoreContext();
    } else {
      canvas.saveContext();
      final String text = count.toString();
      const double leftPad = 10.0;
      const double rightPad = 10.0;
      final double availableW = dividerX - leftPad - rightPad;
      double fontSize = height * 0.45;
      double textWidth = font.stringMetrics(text).size.x * fontSize;
      if (textWidth > availableW) {
        fontSize = fontSize * availableW / textWidth;
        textWidth = availableW;
      }
      final double startX = leftPad + (availableW - textWidth) / 2;
      final double startY =
          height / 2 - (font.ascent * fontSize + font.descent * fontSize) / 2;

      canvas.setFillColor(PdfColors.black);
      _drawText(canvas, font, fontSize, text, startX, startY);
      canvas.restoreContext();

      final double bx = dividerX + 8.0;
      final double by = 8.0;
      final double boxW = width - dividerX - 16.0;
      final double boxH = height - 16.0;

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey500);
      canvas.setLineWidth(1.0);
      canvas.setLineDashPattern([3, 3], 0);
      canvas.drawRect(bx, by, boxW, boxH);
      canvas.strokePath();
      canvas.restoreContext();
    }
  }

  static void _drawNumberTracingRow(
    PdfGraphics canvas,
    PdfPoint size,
    int number,
    PdfFont font,
  ) {
    final double width = size.x;
    final double height = size.y;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey300);
    canvas.setLineWidth(1.0);
    canvas.drawRect(0, 0, width, height);
    canvas.strokePath();
    canvas.restoreContext();

    // Left display cell (20% width)
    final double leftW = width * 0.22;
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey400);
    canvas.setLineWidth(1.0);
    canvas.drawLine(leftW, 0, leftW, height);
    canvas.strokePath();

    final String numStr = number.toString();
    final double mainFontSize = height * 0.55;
    final double strW = font.stringMetrics(numStr).size.x * mainFontSize;
    canvas.setFillColor(PdfColors.black);
    _drawText(
      canvas,
      font,
      mainFontSize,
      numStr,
      (leftW - strW) / 2,
      (height - mainFontSize * 0.7) / 2,
    );

    // Green start dot
    canvas.setFillColor(PdfColors.green700);
    canvas.drawEllipse(
      (leftW - strW) / 2 - 4.0,
      (height + mainFontSize * 0.4) / 2,
      2.5,
      2.5,
    );
    canvas.fillPath();
    canvas.restoreContext();

    // Right tracing guidelines area
    final double rightW = width - leftW;
    final double topY = height * 0.8;
    final double midY = height * 0.5;
    final double botY = height * 0.2;

    canvas.saveContext();
    // Top guideline
    canvas.setStrokeColor(PdfColors.blue300);
    canvas.setLineWidth(0.8);
    canvas.drawLine(leftW, topY, width, topY);
    canvas.strokePath();

    // Bottom baseline
    canvas.setStrokeColor(PdfColors.blue700);
    canvas.setLineWidth(1.2);
    canvas.drawLine(leftW, botY, width, botY);
    canvas.strokePath();

    // Dashed centerline
    canvas.setStrokeColor(PdfColors.blue400);
    canvas.setLineWidth(0.8);
    canvas.setLineDashPattern([3, 3], 0);
    canvas.drawLine(leftW, midY, width, midY);
    canvas.strokePath();
    canvas.restoreContext();

    // Draw 4 dotted tracing numbers across the right area
    final double traceFontSize = (topY - botY) * 0.9;
    final int traceCount = 4;
    final double stepX = rightW / traceCount;
    for (int i = 0; i < traceCount; i++) {
      final double tx = leftW + i * stepX + (stepX - strW) / 2;
      canvas.saveContext();
      canvas.setFillColor(PdfColors.grey400);
      _drawText(canvas, font, traceFontSize, numStr, tx, botY + 2.0);
      canvas.restoreContext();
    }
  }

  static void _drawSequenceQuestion(
    PdfGraphics canvas,
    PdfPoint size,
    int startVal,
    int length,
    math.Random rand,
    PdfFont font,
  ) {
    final double width = size.x;
    final double height = size.y;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey300);
    canvas.setLineWidth(0.8);
    canvas.drawRect(0, 0, width, height);
    canvas.strokePath();
    canvas.restoreContext();

    final int blankIdx1 = rand.nextInt(length);
    int blankIdx2 = -1;
    if (length >= 5 && rand.nextBool()) {
      blankIdx2 = (blankIdx1 + 2) % length;
    }

    final double boxSize = math.min(
      height * 0.65,
      (width - 40.0) / (length * 1.4),
    );
    final double spacing = (width - 30.0 - (length * boxSize)) / (length + 1);

    for (int i = 0; i < length; i++) {
      final double bx = 15.0 + spacing + i * (boxSize + spacing);
      final double by = (height - boxSize) / 2;
      final int val = startVal + i;
      final bool isBlank = i == blankIdx1 || i == blankIdx2;

      canvas.saveContext();
      if (isBlank) {
        canvas.setStrokeColor(PdfColors.grey700);
        canvas.setLineWidth(1.2);
        canvas.setLineDashPattern([3, 3], 0);
        canvas.drawRect(bx, by, boxSize, boxSize);
        canvas.strokePath();
      } else {
        canvas.setStrokeColor(PdfColors.black);
        canvas.setLineWidth(1.5);
        canvas.drawRect(bx, by, boxSize, boxSize);
        canvas.strokePath();

        final String valStr = val.toString();
        final double fontSize = boxSize * 0.55;
        final double strW = font.stringMetrics(valStr).size.x * fontSize;
        canvas.setFillColor(PdfColors.black);
        _drawText(
          canvas,
          font,
          fontSize,
          valStr,
          bx + (boxSize - strW) / 2,
          by + (boxSize - fontSize * 0.7) / 2,
        );
      }
      canvas.restoreContext();

      if (i < length - 1) {
        // Arrow between boxes
        final double arrowX = bx + boxSize + spacing * 0.2;
        final double arrowY = height / 2;
        canvas.saveContext();
        canvas.setStrokeColor(PdfColors.grey600);
        canvas.setLineWidth(1.2);
        canvas.drawLine(arrowX, arrowY, arrowX + spacing * 0.6, arrowY);
        canvas.strokePath();
        canvas.setFillColor(PdfColors.grey600);
        canvas.moveTo(arrowX + spacing * 0.6, arrowY);
        canvas.lineTo(arrowX + spacing * 0.4, arrowY + 3.0);
        canvas.lineTo(arrowX + spacing * 0.4, arrowY - 3.0);
        canvas.closePath();
        canvas.fillPath();
        canvas.restoreContext();
      }
    }
  }

  static void _drawMoreVsLessQuestion(
    PdfGraphics canvas,
    PdfPoint size,
    int countA,
    int countB,
    ShapeType shape,
    PdfFont font,
  ) {
    final double width = size.x;
    final double height = size.y;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey400);
    canvas.setLineWidth(1.0);
    canvas.drawRect(0, 0, width, height);
    canvas.strokePath();

    final double halfW = width / 2;
    canvas.setLineDashPattern([2, 2], 0);
    canvas.drawLine(halfW, 0, halfW, height);
    canvas.strokePath();
    canvas.restoreContext();

    // Box A (Left)
    _drawShapeGridInBox(canvas, 0, 0, halfW, height * 0.75, countA, shape);
    // Box B (Right)
    _drawShapeGridInBox(canvas, halfW, 0, halfW, height * 0.75, countB, shape);

    // Selection circles underneath each box
    final double circleR = 8.0;
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey700);
    canvas.setLineWidth(1.2);

    canvas.drawEllipse(halfW / 2, height * 0.15, circleR, circleR);
    canvas.strokePath();

    canvas.drawEllipse(halfW + halfW / 2, height * 0.15, circleR, circleR);
    canvas.strokePath();
    canvas.restoreContext();
  }

  static void _drawShapeGridInBox(
    PdfGraphics canvas,
    double x,
    double y,
    double w,
    double h,
    int count,
    ShapeType shape,
  ) {
    int cols = (math.sqrt(count)).ceil();
    int rows = (count / cols).ceil();
    double stepX = w / (cols + 1);
    double stepY = h / (rows + 1);
    double shapeSize = math.min(stepX * 0.65, stepY * 0.65);

    int drawn = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (drawn >= count) break;
        double cx = x + stepX * (c + 1);
        double cy = y + stepY * (r + 1);
        _drawShape(canvas, shape, cx, cy, shapeSize);
        drawn++;
      }
    }
  }

  // Draw simple vector shapes
  static void _drawShape(
    PdfGraphics canvas,
    ShapeType type,
    double cx,
    double cy,
    double s,
  ) {
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.black);
    canvas.setLineWidth(1.2);
    canvas.setFillColor(PdfColors.white);

    final double r = s / 2.0;

    switch (type) {
      case ShapeType.circle:
        canvas.drawEllipse(cx, cy, r, r);
        canvas.strokePath();
        break;
      case ShapeType.square:
        canvas.drawRect(cx - r, cy - r, s, s);
        canvas.strokePath();
        break;
      case ShapeType.triangle:
        canvas.moveTo(cx, cy + r);
        canvas.lineTo(cx - r, cy - r);
        canvas.lineTo(cx + r, cy - r);
        canvas.closePath();
        canvas.strokePath();
        break;
      case ShapeType.star:
        _pathStar(canvas, cx, cy, r);
        canvas.strokePath();
        break;
      case ShapeType.heart:
        _pathHeart(canvas, cx, cy, s);
        canvas.strokePath();
        break;
      case ShapeType.tree:
        _pathTree(canvas, cx, cy, s);
        break;
      case ShapeType.apple:
        _pathApple(canvas, cx, cy, s);
        break;
      default:
        canvas.drawEllipse(cx, cy, r, r);
        canvas.strokePath();
        break;
    }
    canvas.restoreContext();
  }

  static void _pathStar(PdfGraphics canvas, double cx, double cy, double r) {
    final double innerR = r * 0.4;
    const int points = 5;
    const double step = math.pi / points;
    double angle = -math.pi / 2;

    canvas.moveTo(cx + r * math.cos(angle), cy + r * math.sin(angle));
    for (int i = 0; i < points * 2; i++) {
      angle += step;
      double currR = (i % 2 == 0) ? innerR : r;
      canvas.lineTo(cx + currR * math.cos(angle), cy + currR * math.sin(angle));
    }
    canvas.closePath();
  }

  static void _pathHeart(PdfGraphics canvas, double cx, double cy, double s) {
    final double topY = cy + s * 0.22;
    final double bottomY = cy - s * 0.42;

    canvas.moveTo(cx, topY);
    canvas.curveTo(
      cx - s * 0.5,
      cy + s * 0.52,
      cx - s * 0.6,
      cy - s * 0.08,
      cx,
      bottomY,
    );
    canvas.curveTo(
      cx + s * 0.6,
      cy - s * 0.08,
      cx + s * 0.5,
      cy + s * 0.52,
      cx,
      topY,
    );
    canvas.closePath();
  }

  static void _pathTree(PdfGraphics canvas, double cx, double cy, double s) {
    canvas.drawRect(cx - s * 0.08, cy - s * 0.45, s * 0.16, s * 0.22);
    canvas.setFillColor(PdfColors.white);
    canvas.strokePath();

    canvas.moveTo(cx - s * 0.35, cy - s * 0.23);
    canvas.lineTo(cx + s * 0.35, cy - s * 0.23);
    canvas.lineTo(cx, cy + s * 0.02);
    canvas.closePath();
    canvas.strokePath();

    canvas.moveTo(cx - s * 0.28, cy - s * 0.05);
    canvas.lineTo(cx + s * 0.28, cy - s * 0.05);
    canvas.lineTo(cx, cy + s * 0.18);
    canvas.closePath();
    canvas.strokePath();

    canvas.moveTo(cx - s * 0.2, cy + s * 0.1);
    canvas.lineTo(cx + s * 0.2, cy + s * 0.1);
    canvas.lineTo(cx, cy + s * 0.38);
    canvas.closePath();
    canvas.strokePath();
  }

  static void _pathApple(PdfGraphics canvas, double cx, double cy, double s) {
    final double r = s * 0.35;
    canvas.drawEllipse(cx - r * 0.28, cy - r * 0.08, r, r * 0.95);
    canvas.strokePath();
    canvas.drawEllipse(cx + r * 0.28, cy - r * 0.08, r, r * 0.95);
    canvas.strokePath();

    canvas.saveContext();
    canvas.moveTo(cx, cy + r * 0.6);
    canvas.curveTo(
      cx - 2,
      cy + r * 0.6 + 6,
      cx + 4,
      cy + r * 0.6 + 8,
      cx + 6,
      cy + r * 0.6 + 10,
    );
    canvas.setLineWidth(1.5);
    canvas.strokePath();
    canvas.restoreContext();

    canvas.moveTo(cx + 3, cy + r * 0.6 + 4);
    canvas.curveTo(
      cx + 6,
      cy + r * 0.6 + 8,
      cx + 12,
      cy + r * 0.6 + 8,
      cx + 10,
      cy + r * 0.6 + 3,
    );
    canvas.curveTo(
      cx + 7,
      cy + r * 0.6 + 1,
      cx + 4,
      cy + r * 0.6 + 2,
      cx + 3,
      cy + r * 0.6 + 4,
    );
    canvas.closePath();
    canvas.strokePath();
  }

  // ==========================================
  // 3. ADDITION & SUBTRACTION GENERATOR
  // ==========================================
  static Future<Uint8List> generateMath(
    GlobalConfig global,
    MathConfig config,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final pw.Font boldFont = fonts['bold']!;
    final pw.Font solidFont = fonts['regular']!;
    final double margin = global.marginMm * mmToPt;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(margin),
        build: (context) {
          final rand = config.seed != null
              ? math.Random(config.seed)
              : math.Random();
          final PdfFont pdfSolid = solidFont.getFont(context);

          final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
          final double headerHeight = global.showHeader ? 75.0 : 0.0;
          final double printableHeight =
              PdfPageFormat.a4.height - 2 * margin - headerHeight - 12.0;

          String titleStr = "Math Practice";
          if (config.activityMode == MathActivityMode.numberLine) {
            titleStr = "Number Line Math";
          } else if (config.activityMode == MathActivityMode.tenFrame) {
            titleStr = "Ten-Frame Math";
          } else if (config.activityMode == MathActivityMode.numberBonds) {
            titleStr = "Number Bonds Math";
          }

          final int cols =
              config.activityMode == MathActivityMode.standardEquations
              ? config.columnsCount
              : 2;
          final int questions = config.questionsCount;
          final int rows = (questions / cols).ceil();
          final double rowHeight = printableHeight / rows;
          final double colWidth = printableWidth / cols;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(global, boldFont, titleStr),
              pw.Column(
                children: List.generate(rows, (rIndex) {
                  return pw.Row(
                    children: List.generate(cols, (cIndex) {
                      final int qIdx = rIndex * cols + cIndex;
                      if (qIdx >= questions) {
                        return pw.SizedBox(width: colWidth, height: rowHeight);
                      }

                      int num1 =
                          config.minNumber +
                          rand.nextInt(config.maxNumber - config.minNumber + 1);
                      int num2 =
                          config.minNumber +
                          rand.nextInt(config.maxNumber - config.minNumber + 1);

                      MathOperation op = config.operation;
                      if (op == MathOperation.mixed) {
                        op = rand.nextBool()
                            ? MathOperation.addition
                            : MathOperation.subtraction;
                      }

                      if (op == MathOperation.subtraction && num2 > num1) {
                        int temp = num1;
                        num1 = num2;
                        num2 = temp;
                      }

                      return pw.Container(
                        width: colWidth,
                        height: rowHeight,
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.CustomPaint(
                          size: PdfPoint(colWidth - 12, rowHeight - 12),
                          painter: (canvas, size) {
                            if (config.activityMode ==
                                MathActivityMode.numberLine) {
                              _drawNumberLineQuestion(
                                canvas,
                                size,
                                num1,
                                num2,
                                op,
                                config,
                                pdfSolid,
                              );
                            } else if (config.activityMode ==
                                MathActivityMode.tenFrame) {
                              _drawTenFrameQuestion(
                                canvas,
                                size,
                                num1,
                                num2,
                                op,
                                config,
                                pdfSolid,
                              );
                            } else if (config.activityMode ==
                                MathActivityMode.numberBonds) {
                              _drawNumberBondQuestion(
                                canvas,
                                size,
                                num1,
                                num2,
                                op,
                                config,
                                pdfSolid,
                              );
                            } else {
                              _drawMathQuestion(
                                canvas,
                                size,
                                num1,
                                num2,
                                op,
                                config,
                                pdfSolid,
                              );
                            }
                          },
                        ),
                      );
                    }),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Draw arithmetic problem
  static void _drawMathQuestion(
    PdfGraphics canvas,
    PdfPoint size,
    int num1,
    int num2,
    MathOperation op,
    MathConfig config,
    PdfFont font,
  ) {
    final double width = size.x;
    final double height = size.y;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey300);
    canvas.setLineWidth(0.8);
    canvas.drawRect(0, 0, width, height);
    canvas.strokePath();
    canvas.restoreContext();

    final String opStr = op == MathOperation.addition ? "+" : "-";

    if (config.format == MathFormat.vertical) {
      final double equationX = width * 0.3;
      final double startY = height * 0.45;
      final double textSpacing = height * 0.16;
      final double fontSize = height * 0.2;

      final String n1Str = config.missingTerm ? "___" : num1.toString();
      final String n2Str = num2.toString();

      final double n1W = font.stringMetrics(n1Str).size.x * fontSize;
      final double n2W = font.stringMetrics(n2Str).size.x * fontSize;

      final double alignX = equationX + 12.0;

      canvas.saveContext();
      canvas.setFillColor(PdfColors.black);

      canvas.drawString(
        font,
        fontSize,
        n1Str,
        alignX - n1W,
        startY + textSpacing,
      );
      canvas.drawString(font, fontSize, n2Str, alignX - n2W, startY);

      final double opX = alignX - math.max(n1W, n2W) - 18.0;
      canvas.drawString(font, fontSize, opStr, opX, startY);
      canvas.restoreContext();

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.black);
      canvas.setLineWidth(1.5);
      canvas.drawLine(
        equationX - 25.0,
        startY - 8.0,
        equationX + 25.0,
        startY - 8.0,
      );
      canvas.strokePath();
      canvas.restoreContext();

      final double boxSize = height * 0.18;
      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey800);
      canvas.setLineWidth(1.5);
      canvas.drawRect(
        equationX - boxSize,
        startY - 14.0 - boxSize,
        boxSize * 2,
        boxSize,
      );
      canvas.strokePath();
      canvas.restoreContext();

      if (config.drawWorkspace) {
        final double workX = width * 0.55;
        final double workW = width * 0.42;
        final double workH = height - 16.0;

        canvas.saveContext();
        canvas.setStrokeColor(PdfColors.grey400);
        canvas.setLineWidth(0.8);
        canvas.setLineDashPattern([2, 2], 0);
        canvas.drawRect(workX, 8.0, workW, workH);
        canvas.strokePath();
        canvas.restoreContext();

        canvas.saveContext();
        canvas.setFillColor(PdfColors.grey500);
        final String label = "Counting space";
        final double wLabel = font.stringMetrics(label).size.x * 6.5;
        canvas.drawString(font, 6.5, label, workX + (workW - wLabel) / 2, 11.0);
        canvas.restoreContext();
      }
    } else {
      double fontSize = height * 0.22;
      if (fontSize > 28.0) {
        fontSize = 28.0;
      }

      String problemText;
      if (config.missingTerm) {
        problemText =
            "$num1 $opStr ___ = ${op == MathOperation.addition ? num1 + num2 : num1 - num2}";
      } else {
        problemText = "$num1 $opStr $num2 = ";
      }

      double textW = font.stringMetrics(problemText).size.x * fontSize;
      double boxSize = fontSize * 1.25;
      double boxWidth = boxSize * 2;

      final double maxAvailable = width - 40.0;
      if (textW + boxWidth > maxAvailable) {
        final double scale = maxAvailable / (textW + boxWidth);
        fontSize = fontSize * scale;
        textW = font.stringMetrics(problemText).size.x * fontSize;
        boxSize = fontSize * 1.25;
        boxWidth = boxSize * 2;
      }

      final double bx = 15.0 + textW + 5.0;

      final double workspaceTop = config.drawWorkspace
          ? (6.0 + height * 0.42)
          : 6.0;
      final double remainingSpace = height - 6.0 - workspaceTop;
      final double by = workspaceTop + (remainingSpace - boxSize) / 2;
      final double equationY = by + (boxSize - fontSize * 0.7) / 2;

      canvas.saveContext();
      canvas.setFillColor(PdfColors.black);
      canvas.drawString(font, fontSize, problemText, 15.0, equationY);
      canvas.restoreContext();

      if (!config.missingTerm) {
        canvas.saveContext();
        canvas.setStrokeColor(PdfColors.grey800);
        canvas.setLineWidth(1.5);
        canvas.drawRect(bx, by, boxWidth, boxSize);
        canvas.strokePath();
        canvas.restoreContext();
      }

      if (config.drawWorkspace) {
        final double rx = 10.0;
        final double ry = 6.0;
        final double rw = width - 20.0;
        final double rh = height * 0.42;

        canvas.saveContext();
        canvas.setStrokeColor(PdfColors.grey400);
        canvas.setLineWidth(0.8);
        canvas.setLineDashPattern([2, 2], 0);
        canvas.drawRect(rx, ry, rw, rh);
        canvas.strokePath();
        canvas.restoreContext();

        canvas.saveContext();
        canvas.setFillColor(PdfColors.grey500);
        final String label = "Draw counting sticks here";
        canvas.drawString(font, 7.0, label, rx + 6.0, ry + rh - 10.0);
        canvas.restoreContext();
      }
    }
  }

  static void _drawNumberLineQuestion(
    PdfGraphics canvas,
    PdfPoint size,
    int num1,
    int num2,
    MathOperation op,
    MathConfig config,
    PdfFont font,
  ) {
    final double width = size.x;
    final double height = size.y;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey300);
    canvas.setLineWidth(0.8);
    canvas.drawRect(0, 0, width, height);
    canvas.strokePath();
    canvas.restoreContext();

    // Equation string on top
    final String opStr = op == MathOperation.addition ? "+" : "-";
    final String eqText = config.missingTerm
        ? "$num1 $opStr ___ = ${op == MathOperation.addition ? num1 + num2 : num1 - num2}"
        : "$num1 $opStr $num2 = [   ]";
    final double fontSize = math.min(16.0, height * 0.18);
    canvas.saveContext();
    canvas.setFillColor(PdfColors.black);
    _drawText(canvas, font, fontSize, eqText, 12.0, height - fontSize * 1.4);
    canvas.restoreContext();

    // Number line underneath equation
    final int startVal = 0;
    final int endVal = math.max(10, math.max(config.maxNumber, num1 + num2));
    final double paddingX = 20.0;
    final double lineY = height * 0.32;
    final double lineW = width - paddingX * 2;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.black);
    canvas.setLineWidth(1.2);
    canvas.drawLine(paddingX, lineY, paddingX + lineW, lineY);
    canvas.strokePath();

    final int totalTicks = endVal - startVal + 1;
    final double stepX = totalTicks > 1 ? lineW / (totalTicks - 1) : lineW;

    for (int i = 0; i < totalTicks; i++) {
      final int val = startVal + i;
      final double tx = paddingX + i * stepX;

      canvas.drawLine(tx, lineY - 3.0, tx, lineY + 3.0);
      canvas.strokePath();

      final String valStr = val.toString();
      final double fontSz = 8.0;
      final double strW = font.stringMetrics(valStr).size.x * fontSz;
      canvas.setFillColor(PdfColors.black);
      _drawText(canvas, font, fontSz, valStr, tx - strW / 2, lineY - 12.0);
    }
    canvas.restoreContext();

    // Hop arc guide
    final int targetVal = op == MathOperation.addition
        ? num1 + num2
        : num1 - num2;
    final double startX = paddingX + num1 * stepX;
    final double endX = paddingX + targetVal * stepX;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.blue700);
    canvas.setLineWidth(1.2);
    canvas.setLineDashPattern([2, 2], 0);

    final double arcHeight = height * 0.28;
    final double topY = lineY + arcHeight;

    canvas.moveTo(startX, lineY + 3.0);
    canvas.curveTo(startX, topY, endX, topY, endX, lineY + 3.0);
    canvas.strokePath();

    canvas.setLineDashPattern([], 0);
    canvas.setFillColor(PdfColors.blue700);
    canvas.moveTo(endX, lineY + 3.0);
    if (op == MathOperation.addition) {
      canvas.lineTo(endX - 3.5, lineY + 8.0);
      canvas.lineTo(endX + 2.0, lineY + 7.0);
    } else {
      canvas.lineTo(endX + 3.5, lineY + 8.0);
      canvas.lineTo(endX - 2.0, lineY + 7.0);
    }
    canvas.closePath();
    canvas.fillPath();
    canvas.restoreContext();
  }

  static void _drawTenFrameQuestion(
    PdfGraphics canvas,
    PdfPoint size,
    int num1,
    int num2,
    MathOperation op,
    MathConfig config,
    PdfFont font,
  ) {
    final double width = size.x;
    final double height = size.y;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey300);
    canvas.setLineWidth(0.8);
    canvas.drawRect(0, 0, width, height);
    canvas.strokePath();
    canvas.restoreContext();

    final String opStr = op == MathOperation.addition ? "+" : "-";
    final String eqText = config.missingTerm
        ? "$num1 $opStr ___ = ${op == MathOperation.addition ? num1 + num2 : num1 - num2}"
        : "$num1 $opStr $num2 = [   ]";
    final double fontSize = math.min(16.0, height * 0.18);
    canvas.saveContext();
    canvas.setFillColor(PdfColors.black);
    _drawText(canvas, font, fontSize, eqText, 12.0, height - fontSize * 1.4);
    canvas.restoreContext();

    // 10-frame box (2x5 grid)
    final double frameW = math.min(width - 24.0, 140.0);
    final double frameH = math.min(height * 0.55, 55.0);
    final double frameX = (width - frameW) / 2;
    final double frameY = 10.0;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.black);
    canvas.setLineWidth(1.2);
    canvas.drawRect(frameX, frameY, frameW, frameH);
    canvas.strokePath();

    canvas.drawLine(
      frameX,
      frameY + frameH / 2,
      frameX + frameW,
      frameY + frameH / 2,
    );
    canvas.strokePath();

    final double colW = frameW / 5;
    for (int c = 1; c < 5; c++) {
      canvas.drawLine(
        frameX + c * colW,
        frameY,
        frameX + c * colW,
        frameY + frameH,
      );
      canvas.strokePath();
    }

    final double dotR = math.min(colW, frameH / 2) * 0.32;
    final int filledCount = op == MathOperation.addition ? num1 : num1;
    final int secCount = num2;

    int drawn = 0;
    for (int row = 1; row >= 0; row--) {
      for (int col = 0; col < 5; col++) {
        final double cx = frameX + col * colW + colW / 2;
        final double cy = frameY + row * (frameH / 2) + (frameH / 4);

        if (drawn < filledCount) {
          canvas.setFillColor(PdfColors.black);
          canvas.drawEllipse(cx, cy, dotR, dotR);
          canvas.fillPath();
          drawn++;
        } else if (drawn < filledCount + secCount) {
          if (op == MathOperation.addition) {
            canvas.setStrokeColor(PdfColors.grey700);
            canvas.setLineWidth(1.2);
            canvas.drawEllipse(cx, cy, dotR, dotR);
            canvas.strokePath();
          } else {
            canvas.setFillColor(PdfColors.black);
            canvas.drawEllipse(cx, cy, dotR, dotR);
            canvas.fillPath();

            canvas.setStrokeColor(PdfColors.red);
            canvas.setLineWidth(1.5);
            canvas.drawLine(cx - dotR, cy - dotR, cx + dotR, cy + dotR);
            canvas.drawLine(cx - dotR, cy + dotR, cx + dotR, cy - dotR);
            canvas.strokePath();
          }
          drawn++;
        }
      }
    }
    canvas.restoreContext();
  }

  static void _drawNumberBondQuestion(
    PdfGraphics canvas,
    PdfPoint size,
    int num1,
    int num2,
    MathOperation op,
    MathConfig config,
    PdfFont font,
  ) {
    final double width = size.x;
    final double height = size.y;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey300);
    canvas.setLineWidth(0.8);
    canvas.drawRect(0, 0, width, height);
    canvas.strokePath();
    canvas.restoreContext();

    final double r = math.min(width, height) * 0.16;

    final double wholeX = width / 2;
    final double wholeY = height * 0.72;

    final double part1X = width * 0.3;
    final double part1Y = height * 0.28;

    final double part2X = width * 0.7;
    final double part2Y = height * 0.28;

    final int wholeVal = op == MathOperation.addition ? num1 + num2 : num1;
    final int p1Val = op == MathOperation.addition ? num1 : num2;
    final int p2Val = op == MathOperation.addition ? num2 : num1 - num2;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey800);
    canvas.setLineWidth(1.5);
    canvas.drawLine(wholeX, wholeY - r, part1X, part1Y + r);
    canvas.drawLine(wholeX, wholeY - r, part2X, part2Y + r);
    canvas.strokePath();
    canvas.restoreContext();

    final bool missingPart = config.missingTerm;
    _drawBondCircle(
      canvas,
      font,
      wholeX,
      wholeY,
      r,
      missingPart ? wholeVal : null,
    );
    _drawBondCircle(canvas, font, part1X, part1Y, r, p1Val);
    _drawBondCircle(
      canvas,
      font,
      part2X,
      part2Y,
      r,
      missingPart ? null : p2Val,
    );
  }

  static void _drawBondCircle(
    PdfGraphics canvas,
    PdfFont font,
    double cx,
    double cy,
    double r,
    int? value,
  ) {
    canvas.saveContext();
    canvas.setFillColor(PdfColors.white);
    canvas.setStrokeColor(PdfColors.black);
    canvas.setLineWidth(1.5);
    canvas.drawEllipse(cx, cy, r, r);
    canvas.fillPath();
    canvas.drawEllipse(cx, cy, r, r);
    canvas.strokePath();

    if (value != null) {
      final String text = value.toString();
      final double fontSize = r * 1.1;
      final double strW = font.stringMetrics(text).size.x * fontSize;
      canvas.setFillColor(PdfColors.black);
      _drawText(
        canvas,
        font,
        fontSize,
        text,
        cx - strW / 2,
        cy - fontSize * 0.35,
      );
    } else {
      canvas.setStrokeColor(PdfColors.grey600);
      canvas.setLineWidth(1.0);
      canvas.drawLine(cx - r * 0.4, cy - r * 0.2, cx + r * 0.4, cy - r * 0.2);
      canvas.strokePath();
    }
    canvas.restoreContext();
  }

  // ==========================================
  // 4. PRE-WRITING LINES GENERATOR
  // ==========================================
  static Future<Uint8List> generatePrewriting(
    GlobalConfig global,
    PrewritingConfig config,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final pw.Font boldFont = fonts['bold']!;

    final double margin = global.marginMm * mmToPt;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(margin),
        build: (context) {
          final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
          final double headerHeight = global.showHeader ? 75.0 : 0.0;
          final double printableHeight =
              PdfPageFormat.a4.height - 2 * margin - headerHeight - 12.0;

          final int lines = config.lineCount;
          final double spacing = printableHeight / (lines + 1);

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(global, boldFont, "Pre-Writing Lines Tracing"),
              pw.Container(
                width: printableWidth,
                height: printableHeight,
                child: pw.CustomPaint(
                  size: PdfPoint(printableWidth, printableHeight),
                  painter: (canvas, size) {
                    _drawPrewritingLines(canvas, size, lines, spacing, config);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static void _drawContextStartAnchor(
    PdfGraphics canvas,
    double x,
    double y,
    ContextPair pair,
  ) {
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey800);
    canvas.setLineWidth(1.2);
    canvas.setFillColor(PdfColors.white);
    switch (pair) {
      case ContextPair.circleToStar:
        canvas.drawEllipse(x, y, 6, 6);
        canvas.strokePath();
        break;
      case ContextPair.beeToFlower:
        canvas.drawEllipse(x, y, 7, 4);
        canvas.drawEllipse(x, y + 4, 3, 2);
        canvas.strokePath();
        break;
      case ContextPair.carToGarage:
        canvas.drawRect(x - 6, y - 3, 12, 6);
        canvas.drawRect(x - 4, y + 3, 8, 4);
        canvas.drawEllipse(x - 3, y - 4, 2, 2);
        canvas.drawEllipse(x + 3, y - 4, 2, 2);
        canvas.strokePath();
        break;
      case ContextPair.rocketToPlanet:
        canvas.moveTo(x, y + 8);
        canvas.lineTo(x - 4, y - 4);
        canvas.lineTo(x + 4, y - 4);
        canvas.closePath();
        canvas.strokePath();
        break;
      case ContextPair.fishToOcean:
        canvas.drawEllipse(x, y, 6, 4);
        canvas.moveTo(x - 6, y);
        canvas.lineTo(x - 9, y + 3);
        canvas.lineTo(x - 9, y - 3);
        canvas.closePath();
        canvas.strokePath();
        break;
      case ContextPair.rabbitToCarrot:
        canvas.drawEllipse(x, y - 2, 5, 4);
        canvas.drawEllipse(x - 2, y + 4, 2, 4);
        canvas.drawEllipse(x + 2, y + 4, 2, 4);
        canvas.strokePath();
        break;
    }
    canvas.restoreContext();
  }

  static void _drawContextEndAnchor(
    PdfGraphics canvas,
    double x,
    double y,
    ContextPair pair,
  ) {
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey800);
    canvas.setLineWidth(1.2);
    canvas.setFillColor(PdfColors.white);
    switch (pair) {
      case ContextPair.circleToStar:
        _pathStar(canvas, x, y, 8.0);
        canvas.strokePath();
        break;
      case ContextPair.beeToFlower:
        canvas.drawEllipse(x, y, 3, 3);
        for (int p = 0; p < 5; p++) {
          final angle = p * (2 * math.pi / 5);
          canvas.drawEllipse(
            x + 5 * math.cos(angle),
            y + 5 * math.sin(angle),
            3,
            3,
          );
        }
        canvas.strokePath();
        break;
      case ContextPair.carToGarage:
        canvas.drawRect(x - 7, y - 5, 14, 8);
        canvas.moveTo(x - 8, y + 3);
        canvas.lineTo(x, y + 8);
        canvas.lineTo(x + 8, y + 3);
        canvas.closePath();
        canvas.strokePath();
        break;
      case ContextPair.rocketToPlanet:
        canvas.drawEllipse(x, y, 6, 6);
        canvas.drawEllipse(x, y, 10, 3);
        canvas.strokePath();
        break;
      case ContextPair.fishToOcean:
        canvas.moveTo(x - 7, y);
        canvas.curveTo(x - 3, y + 4, x - 1, y + 4, x, y);
        canvas.curveTo(x + 1, y + 4, x + 3, y + 4, x + 7, y);
        canvas.strokePath();
        break;
      case ContextPair.rabbitToCarrot:
        canvas.moveTo(x, y - 6);
        canvas.lineTo(x - 4, y + 3);
        canvas.lineTo(x + 4, y + 3);
        canvas.closePath();
        canvas.moveTo(x, y + 3);
        canvas.lineTo(x, y + 7);
        canvas.strokePath();
        break;
    }
    canvas.restoreContext();
  }

  // Draw tracing line patterns
  static void _drawPrewritingLines(
    PdfGraphics canvas,
    PdfPoint size,
    int lineCount,
    double spacing,
    PrewritingConfig config,
  ) {
    final double startX = 25.0;
    final double endX = size.x - 25.0;
    final double width = endX - startX;

    for (int i = 0; i < lineCount; i++) {
      final double y = size.y - spacing * (i + 1);

      // Start Anchor
      _drawContextStartAnchor(canvas, startX - 10, y, config.contextPair);

      // End Anchor
      _drawContextEndAnchor(canvas, endX + 10, y, config.contextPair);

      // Corridor Wall Boundaries (if enabled or corridor pattern)
      if (config.showCorridorBoundaries ||
          config.pattern == LinePattern.corridor) {
        final double halfW = config.corridorWidth.widthPt / 2.0;
        canvas.saveContext();
        canvas.setStrokeColor(PdfColors.grey400);
        canvas.setLineWidth(1.0);
        canvas.setLineDashPattern([], 0);
        canvas.drawLine(startX, y + halfW, endX, y + halfW);
        canvas.drawLine(startX, y - halfW, endX, y - halfW);
        canvas.strokePath();
        canvas.restoreContext();
      }

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey700);
      canvas.setLineWidth(config.strokeWidth);

      if (config.isDotted) {
        canvas.setLineDashPattern([3, 3], 0);
      }

      switch (config.pattern) {
        case LinePattern.straight:
        case LinePattern.corridor:
          canvas.drawLine(startX, y, endX, y);
          canvas.strokePath();
          break;
        case LinePattern.wave:
          final int segments = 12;
          final double segmentW = width / segments;
          final double amplitude = 15.0;

          canvas.moveTo(startX, y);
          for (int s = 0; s < segments; s++) {
            double currentX = startX + s * segmentW;
            double nextX = currentX + segmentW;
            double midX = currentX + segmentW / 2;
            double direction = (s % 2 == 0) ? 1.0 : -1.0;

            canvas.curveTo(
              midX - segmentW / 4,
              y + amplitude * direction,
              midX + segmentW / 4,
              y + amplitude * direction,
              nextX,
              y,
            );
          }
          canvas.strokePath();
          break;
        case LinePattern.zigzag:
          final int peaks = 10;
          final double step = width / (peaks * 2);
          final double amp = 15.0;

          canvas.moveTo(startX, y);
          for (int p = 0; p < peaks * 2; p++) {
            double nx = startX + (p + 1) * step;
            double ny = (p % 2 == 0) ? y + amp : y - amp;
            canvas.lineTo(nx, ny);
          }
          canvas.strokePath();
          break;
        case LinePattern.castle:
          final int periods = 8;
          final double stepW = width / (periods * 4);
          final double amp = 14.0;

          canvas.moveTo(startX, y);
          double currX = startX;
          for (int p = 0; p < periods; p++) {
            canvas.lineTo(currX, y + amp);
            currX += stepW;
            canvas.lineTo(currX, y + amp);
            canvas.lineTo(currX, y);
            currX += stepW;
            canvas.lineTo(currX, y);
            canvas.lineTo(currX, y - amp);
            currX += stepW;
            canvas.lineTo(currX, y - amp);
            canvas.lineTo(currX, y);
            currX += stepW;
            canvas.lineTo(currX, y);
          }
          canvas.strokePath();
          break;
        case LinePattern.curve:
          final int arches = 8;
          final double archW = width / arches;
          final double amp = 16.0;

          canvas.moveTo(startX, y);
          for (int a = 0; a < arches; a++) {
            double cx = startX + a * archW;
            double nx = cx + archW;
            double mx = cx + archW / 2;
            canvas.curveTo(
              mx - archW / 4,
              y + amp,
              mx + archW / 4,
              y + amp,
              nx,
              y,
            );
          }
          canvas.strokePath();
          break;
        case LinePattern.loop:
          final int loops = 7;
          final double loopW = width / loops;
          final double amp = 16.0;

          canvas.moveTo(startX, y);
          for (int l = 0; l < loops; l++) {
            double cx = startX + l * loopW;
            double nx = cx + loopW;
            canvas.curveTo(
              cx + loopW * 0.7,
              y + amp * 1.3,
              nx - loopW * 0.2,
              y + amp * 1.3,
              nx,
              y,
            );
          }
          canvas.strokePath();
          break;
        case LinePattern.spiral:
          final int coils = 8;
          final double coilW = width / coils;
          final double amp = 14.0;

          canvas.moveTo(startX, y);
          for (int c = 0; c < coils; c++) {
            double cx = startX + c * coilW;
            double nx = cx + coilW;
            canvas.curveTo(
              cx + coilW * 0.4,
              y + amp,
              nx - coilW * 0.2,
              y + amp,
              nx,
              y,
            );
            canvas.curveTo(
              nx + coilW * 0.1,
              y - amp * 0.5,
              cx + coilW * 0.8,
              y - amp * 0.5,
              nx,
              y,
            );
          }
          canvas.strokePath();
          break;
        case LinePattern.mixedStrokes:
          final double segW = width / 3;
          // Segment 1: straight
          canvas.moveTo(startX, y);
          canvas.lineTo(startX + segW, y);
          // Segment 2: wave
          final int waveSegs = 4;
          final double wStep = segW / waveSegs;
          double cx = startX + segW;
          for (int w = 0; w < waveSegs; w++) {
            double nx = cx + wStep;
            double mx = cx + wStep / 2;
            double dir = (w % 2 == 0) ? 1.0 : -1.0;
            canvas.curveTo(
              mx - wStep / 4,
              y + 12 * dir,
              mx + wStep / 4,
              y + 12 * dir,
              nx,
              y,
            );
            cx = nx;
          }
          // Segment 3: zigzag
          final int zPeaks = 4;
          final double zStep = segW / (zPeaks * 2);
          for (int z = 0; z < zPeaks * 2; z++) {
            double nx = cx + zStep;
            double ny = (z % 2 == 0) ? y + 12 : y - 12;
            canvas.lineTo(nx, ny);
            cx = nx;
          }
          canvas.strokePath();
          break;
      }
      canvas.restoreContext();
    }
  }

  // ==========================================
  // 5. SHAPES TRACING GENERATOR
  // ==========================================
  static Future<Uint8List> generateShapes(
    GlobalConfig global,
    ShapesConfig config,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final pw.Font solidFont = fonts['regular']!;
    final pw.Font boldFont = fonts['bold']!;

    final double margin = global.marginMm * mmToPt;
    final List<ShapeDesign> shapes = config.selectedShapes;
    if (shapes.isEmpty) return pdf.save();

    final pdfRegFont = solidFont.getFont(pw.Context(document: pdf.document));
    final rng = RandomSeedService.fromSeed(config.seed);

    if (config.activityMode == ShapeActivityMode.tracing) {
      final int shapesPerPage = 4;
      int shapeIndex = 0;

      while (shapeIndex < shapes.length) {
        final List<ShapeDesign> pageShapes = [];
        for (int i = 0; i < shapesPerPage && shapeIndex < shapes.length; i++) {
          pageShapes.add(shapes[shapeIndex]);
          shapeIndex++;
        }

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(margin),
            build: (context) {
              final List<pw.Widget> rows = [];
              for (int i = 0; i < pageShapes.length; i += 2) {
                final rowChildren = <pw.Widget>[];
                rowChildren.add(
                  pw.Expanded(
                    child: _buildShapeCard(pageShapes[i], config, solidFont),
                  ),
                );
                if (i + 1 < pageShapes.length) {
                  rowChildren.add(pw.SizedBox(width: 15));
                  rowChildren.add(
                    pw.Expanded(
                      child: _buildShapeCard(
                        pageShapes[i + 1],
                        config,
                        solidFont,
                      ),
                    ),
                  );
                } else {
                  rowChildren.add(pw.SizedBox(width: 15));
                  rowChildren.add(pw.Expanded(child: pw.SizedBox()));
                }
                rows.add(pw.Expanded(child: pw.Row(children: rowChildren)));
                if (i + 2 < pageShapes.length) {
                  rows.add(pw.SizedBox(height: 15));
                }
              }

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(global, boldFont, "Shapes Learning & Tracing"),
                  pw.Expanded(child: pw.Column(children: rows)),
                ],
              );
            },
          ),
        );
      }
    } else if (config.activityMode == ShapeActivityMode.halfDrawSymmetry) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(margin),
          build: (context) {
            final List<pw.Widget> rows = [];
            final displayShapes = shapes.take(4).toList();
            for (int i = 0; i < displayShapes.length; i += 2) {
              final rowChildren = <pw.Widget>[];
              rowChildren.add(
                pw.Expanded(
                  child: _buildSymmetryCard(displayShapes[i], config),
                ),
              );
              if (i + 1 < displayShapes.length) {
                rowChildren.add(pw.SizedBox(width: 15));
                rowChildren.add(
                  pw.Expanded(
                    child: _buildSymmetryCard(displayShapes[i + 1], config),
                  ),
                );
              } else {
                rowChildren.add(pw.SizedBox(width: 15));
                rowChildren.add(pw.Expanded(child: pw.SizedBox()));
              }
              rows.add(pw.Expanded(child: pw.Row(children: rowChildren)));
              if (i + 2 < displayShapes.length) {
                rows.add(pw.SizedBox(height: 15));
              }
            }

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(
                  global,
                  boldFont,
                  "Shape Symmetry & Half-Draw Completion",
                ),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600, width: 1.2),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                    color: PdfColors.grey100,
                  ),
                  child: pw.Text(
                    "Complete the other half of each shape across the dashed line of symmetry!",
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Expanded(child: pw.Column(children: rows)),
              ],
            );
          },
        ),
      );
    } else if (config.activityMode == ShapeActivityMode.identification) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(margin),
          build: (context) {
            final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
            final double headerHeight = global.showHeader ? 75.0 : 0.0;
            final double instructionHeight = 45.0;
            final double printableHeight =
                PdfPageFormat.a4.height -
                2 * margin -
                headerHeight -
                instructionHeight -
                16.0;

            final target = config.targetShape;
            final String instructionText =
                "Shape Search: Find and circle all ${target.label} shapes on this page!";

            final gridRows = 5;
            final gridCols = 5;
            final totalCells = gridRows * gridCols;
            final List<ShapeDesign> cellShapes = [];
            for (int i = 0; i < totalCells; i++) {
              if (i % 3 == 0) {
                cellShapes.add(target);
              } else {
                cellShapes.add(rng.pickOne(shapes));
              }
            }
            rng.shuffle(cellShapes);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(global, boldFont, "Shape Identification Search"),
                pw.Container(
                  width: printableWidth,
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600, width: 1.2),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                    color: PdfColors.grey100,
                  ),
                  child: pw.Text(
                    instructionText,
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  width: printableWidth,
                  height: printableHeight,
                  child: pw.CustomPaint(
                    size: PdfPoint(printableWidth, printableHeight),
                    painter: (canvas, size) {
                      final double cellW = size.x / gridCols;
                      final double cellH = size.y / gridRows;

                      for (int r = 0; r < gridRows; r++) {
                        for (int c = 0; c < gridCols; c++) {
                          final idx = r * gridCols + c;
                          final shape = cellShapes[idx];
                          final x = c * cellW;
                          final y = size.y - (r + 1) * cellH;

                          canvas.saveContext();
                          canvas.setStrokeColor(PdfColors.grey300);
                          canvas.setLineWidth(0.8);
                          canvas.drawRect(x, y, cellW, cellH);
                          canvas.strokePath();
                          canvas.restoreContext();

                          final shapeType = _parseShapeType(shape.name);
                          if (shapeType != null) {
                            _drawShape(
                              canvas,
                              shapeType,
                              x + cellW / 2.0,
                              y + cellH / 2.0,
                              math.min(cellW, cellH) * 0.55,
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else if (config.activityMode == ShapeActivityMode.matching) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(margin),
          build: (context) {
            final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
            final double headerHeight = global.showHeader ? 75.0 : 0.0;
            final double instructionHeight = 45.0;
            final double printableHeight =
                PdfPageFormat.a4.height -
                2 * margin -
                headerHeight -
                instructionHeight -
                16.0;

            final displayShapes = shapes.take(5).toList();
            final leftShapes = displayShapes;
            final rightNames = rng.shuffle(
              displayShapes.map((s) => s.realWorldMatch).toList(),
            );

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(global, boldFont, "Shape & Object Matching"),
                pw.Container(
                  width: printableWidth,
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600, width: 1.2),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                    color: PdfColors.grey100,
                  ),
                  child: pw.Text(
                    "Draw lines connecting each shape on the left to its matching real-world object on the right!",
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  width: printableWidth,
                  height: printableHeight,
                  child: pw.CustomPaint(
                    size: PdfPoint(printableWidth, printableHeight),
                    painter: (canvas, size) {
                      final rows = leftShapes.length;
                      final double rowH = size.y / rows;
                      final double colW = 130.0;
                      final double leftX = 30.0;
                      final double rightX = size.x - 30.0 - colW;

                      for (int r = 0; r < rows; r++) {
                        final y = size.y - (r + 1) * rowH;
                        final cy = y + rowH / 2.0;

                        // Left Shape Card
                        canvas.saveContext();
                        canvas.setStrokeColor(PdfColors.grey400);
                        canvas.setLineWidth(1.0);
                        canvas.drawRect(leftX, cy - 24, colW, 48);
                        canvas.strokePath();

                        final shapeType = _parseShapeType(leftShapes[r].name);
                        if (shapeType != null) {
                          _drawShape(
                            canvas,
                            shapeType,
                            leftX + colW / 2.0,
                            cy,
                            28,
                          );
                        }
                        canvas.setFillColor(PdfColors.black);
                        canvas.drawEllipse(leftX + colW + 12, cy, 4, 4);
                        canvas.fillPath();
                        canvas.restoreContext();

                        // Right Object Card
                        canvas.saveContext();
                        canvas.setStrokeColor(PdfColors.grey400);
                        canvas.setLineWidth(1.0);
                        canvas.drawRect(rightX, cy - 24, colW, 48);
                        canvas.strokePath();

                        canvas.setFillColor(PdfColors.black);
                        final text = rightNames[r];
                        final textWidth =
                            pdfRegFont.stringMetrics(text).size.x * 14;
                        canvas.drawString(
                          pdfRegFont,
                          14,
                          text,
                          rightX + (colW - textWidth) / 2.0,
                          cy - 5,
                        );

                        canvas.setFillColor(PdfColors.black);
                        canvas.drawEllipse(rightX - 12, cy, 4, 4);
                        canvas.fillPath();
                        canvas.restoreContext();
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else if (config.activityMode == ShapeActivityMode.counting) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(margin),
          build: (context) {
            final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
            final double headerHeight = global.showHeader ? 75.0 : 0.0;
            final double instructionHeight = 45.0;
            final double printableHeight =
                PdfPageFormat.a4.height -
                2 * margin -
                headerHeight -
                instructionHeight -
                16.0;

            final gridRows = 4;
            final gridCols = 5;
            final totalCells = gridRows * gridCols;
            final List<ShapeDesign> cellShapes = [];
            for (int i = 0; i < totalCells; i++) {
              cellShapes.add(rng.pickOne(shapes));
            }

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(global, boldFont, "Shape Counting & Tally"),
                pw.Container(
                  width: printableWidth,
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600, width: 1.2),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                    color: PdfColors.grey100,
                  ),
                  child: pw.Text(
                    "Count how many of each shape appear in the grid above and record the total below!",
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  width: printableWidth,
                  height: printableHeight,
                  child: pw.CustomPaint(
                    size: PdfPoint(printableWidth, printableHeight),
                    painter: (canvas, size) {
                      final double gridH = size.y * 0.7;
                      final double cellW = size.x / gridCols;
                      final double cellH = gridH / gridRows;

                      for (int r = 0; r < gridRows; r++) {
                        for (int c = 0; c < gridCols; c++) {
                          final idx = r * gridCols + c;
                          final shape = cellShapes[idx];
                          final x = c * cellW;
                          final y = size.y - (r + 1) * cellH;

                          canvas.saveContext();
                          canvas.setStrokeColor(PdfColors.grey300);
                          canvas.setLineWidth(0.8);
                          canvas.drawRect(x, y, cellW, cellH);
                          canvas.strokePath();
                          canvas.restoreContext();

                          final shapeType = _parseShapeType(shape.name);
                          if (shapeType != null) {
                            _drawShape(
                              canvas,
                              shapeType,
                              x + cellW / 2.0,
                              y + cellH / 2.0,
                              math.min(cellW, cellH) * 0.55,
                            );
                          }
                        }
                      }

                      // Tally Box Area at Bottom
                      final double tallyY = 0.0;
                      final double tallyH = size.y * 0.25;
                      final tallyCols = shapes.take(4).toList();
                      final tallyW = size.x / tallyCols.length;

                      for (int i = 0; i < tallyCols.length; i++) {
                        final tx = i * tallyW;
                        final shape = tallyCols[i];

                        canvas.saveContext();
                        canvas.setStrokeColor(PdfColors.grey600);
                        canvas.setLineWidth(1.0);
                        canvas.drawRect(
                          tx + 4,
                          tallyY + 4,
                          tallyW - 8,
                          tallyH - 8,
                        );
                        canvas.strokePath();

                        final shapeType = _parseShapeType(shape.name);
                        if (shapeType != null) {
                          _drawShape(
                            canvas,
                            shapeType,
                            tx + tallyW / 2.0,
                            tallyY + tallyH * 0.65,
                            24,
                          );
                        }

                        // Answer Box
                        canvas.setStrokeColor(PdfColors.black);
                        canvas.setLineWidth(1.2);
                        canvas.drawRect(
                          tx + tallyW / 2.0 - 16,
                          tallyY + 12,
                          32,
                          24,
                        );
                        canvas.strokePath();
                        canvas.restoreContext();
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _buildSymmetryCard(ShapeDesign shape, ShapesConfig config) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1.0),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 14),
            child: pw.Text(
              "${shape.label} Symmetry",
              style: pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 16),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: pw.CustomPaint(
              size: const PdfPoint(120, 120),
              painter: (canvas, size) {
                _drawSymmetryShapeOnly(canvas, size, shape);
              },
            ),
          ),
          pw.SizedBox(height: 14),
        ],
      ),
    );
  }

  static void _drawSymmetryShapeOnly(
    PdfGraphics canvas,
    PdfPoint size,
    ShapeDesign shape,
  ) {
    final double cx = size.x / 2;
    final double cy = size.y / 2;
    final double shapeSize = math.min(size.x * 0.7, size.y * 0.7);

    // Dashed symmetry axis line down the middle
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey500);
    canvas.setLineWidth(1.0);
    canvas.setLineDashPattern([3, 3]);
    canvas.moveTo(cx, 10);
    canvas.lineTo(cx, size.y - 10);
    canvas.strokePath();
    canvas.restoreContext();

    // Solid Left Half & Dotted Right Half
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.black);
    canvas.setLineWidth(1.8);

    switch (shape) {
      case ShapeDesign.circle:
        canvas.drawEllipse(cx, cy, shapeSize / 2, shapeSize / 2);
        canvas.strokePath();
        break;
      case ShapeDesign.square:
        canvas.drawRect(
          cx - shapeSize / 2,
          cy - shapeSize / 2,
          shapeSize,
          shapeSize,
        );
        canvas.strokePath();
        break;
      case ShapeDesign.triangle:
        canvas.moveTo(cx, cy + shapeSize / 2);
        canvas.lineTo(cx - shapeSize / 2, cy - shapeSize / 2);
        canvas.lineTo(cx + shapeSize / 2, cy - shapeSize / 2);
        canvas.closePath();
        canvas.strokePath();
        break;
      case ShapeDesign.rectangle:
        canvas.drawRect(
          cx - shapeSize / 1.3,
          cy - shapeSize / 2.0,
          shapeSize * 1.5,
          shapeSize,
        );
        canvas.strokePath();
        break;
      case ShapeDesign.oval:
        canvas.drawEllipse(cx, cy, shapeSize / 1.4, shapeSize / 2.2);
        canvas.strokePath();
        break;
      case ShapeDesign.diamond:
        canvas.moveTo(cx, cy + shapeSize / 2);
        canvas.lineTo(cx + shapeSize / 2, cy);
        canvas.lineTo(cx, cy - shapeSize / 2);
        canvas.lineTo(cx - shapeSize / 2, cy);
        canvas.closePath();
        canvas.strokePath();
        break;
      case ShapeDesign.star:
        _pathStar(canvas, cx, cy, shapeSize / 2);
        canvas.strokePath();
        break;
      case ShapeDesign.heart:
        _pathHeart(canvas, cx, cy, shapeSize);
        canvas.strokePath();
        break;
    }
    canvas.restoreContext();
  }

  // Build a structured shape card widget with clean typography layout
  static pw.Widget _buildShapeCard(
    ShapeDesign shape,
    ShapesConfig config,
    pw.Font solidFont,
  ) {
    final String shapeName =
        shape.name[0].toUpperCase() + shape.name.substring(1);

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1.0),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 14),
            child: pw.Text(
              shapeName,
              style: pw.TextStyle(font: pw.Font.helveticaBold(), fontSize: 18),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: pw.CustomPaint(
              size: const PdfPoint(120, 120),
              painter: (canvas, size) {
                _drawShapeOnly(canvas, size, shape, config);
              },
            ),
          ),
          pw.SizedBox(height: 14),
        ],
      ),
    );
  }

  // Draw only the shape vector and tracing guides centered inside the canvas
  static void _drawShapeOnly(
    PdfGraphics canvas,
    PdfPoint size,
    ShapeDesign shape,
    ShapesConfig config,
  ) {
    final double width = size.x;
    final double height = size.y;

    final double cx = width / 2;
    final double cy = height / 2;
    final double shapeSize = math.min(width * 0.7, height * 0.7);

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey800);
    canvas.setLineWidth(1.8);
    if (config.isDotted) {
      canvas.setLineDashPattern([4, 4], 0);
    }

    switch (shape) {
      case ShapeDesign.circle:
        canvas.drawEllipse(cx, cy, shapeSize / 2, shapeSize / 2);
        canvas.strokePath();
        break;
      case ShapeDesign.square:
        canvas.drawRect(
          cx - shapeSize / 2,
          cy - shapeSize / 2,
          shapeSize,
          shapeSize,
        );
        canvas.strokePath();
        break;
      case ShapeDesign.triangle:
        canvas.moveTo(cx, cy + shapeSize / 2);
        canvas.lineTo(cx - shapeSize / 2, cy - shapeSize / 2);
        canvas.lineTo(cx + shapeSize / 2, cy - shapeSize / 2);
        canvas.closePath();
        canvas.strokePath();
        break;
      case ShapeDesign.rectangle:
        canvas.drawRect(
          cx - shapeSize / 1.3,
          cy - shapeSize / 2.0,
          shapeSize * 1.5,
          shapeSize,
        );
        canvas.strokePath();
        break;
      case ShapeDesign.oval:
        canvas.drawEllipse(cx, cy, shapeSize / 1.4, shapeSize / 2.2);
        canvas.strokePath();
        break;
      case ShapeDesign.diamond:
        canvas.moveTo(cx, cy + shapeSize / 2);
        canvas.lineTo(cx + shapeSize / 2, cy);
        canvas.lineTo(cx, cy - shapeSize / 2);
        canvas.lineTo(cx - shapeSize / 2, cy);
        canvas.closePath();
        canvas.strokePath();
        break;
      case ShapeDesign.star:
        _pathStar(canvas, cx, cy, shapeSize / 2);
        canvas.strokePath();
        break;
      case ShapeDesign.heart:
        _pathHeart(canvas, cx, cy, shapeSize);
        canvas.strokePath();
        break;
    }
    canvas.restoreContext();

    if (config.showTracingGuides) {
      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey500);
      canvas.setFillColor(PdfColors.grey500);
      canvas.setLineWidth(0.8);

      switch (shape) {
        case ShapeDesign.circle:
          double arrowX = cx;
          double arrowY = cy + shapeSize / 2;
          canvas.drawEllipse(arrowX, arrowY, 1.5, 1.5);
          canvas.fillPath();
          _drawArrow(canvas, arrowX, arrowY, 0.0);
          break;
        case ShapeDesign.square:
          double ax = cx - shapeSize / 2;
          double ay = cy + shapeSize / 2;
          canvas.drawEllipse(ax, ay, 1.5, 1.5);
          canvas.fillPath();
          _drawArrow(canvas, cx, ay, 0.0);
          break;
        case ShapeDesign.triangle:
          double ax = cx;
          double ay = cy + shapeSize / 2;
          canvas.drawEllipse(ax, ay, 1.5, 1.5);
          canvas.fillPath();
          _drawArrow(canvas, cx - shapeSize / 4, cy, -math.pi * 0.65);
          break;
        case ShapeDesign.oval:
          double arrowX = cx;
          double arrowY = cy + shapeSize / 2.2;
          canvas.drawEllipse(arrowX, arrowY, 1.5, 1.5);
          canvas.fillPath();
          _drawArrow(canvas, arrowX, arrowY, 0.0);
          break;
        case ShapeDesign.diamond:
          double ax = cx;
          double ay = cy + shapeSize / 2;
          canvas.drawEllipse(ax, ay, 1.5, 1.5);
          canvas.fillPath();
          _drawArrow(
            canvas,
            cx + shapeSize / 4,
            cy + shapeSize / 4,
            -math.pi * 0.25,
          );
          break;
        default:
          break;
      }
      canvas.restoreContext();
    }
  }

  // Pure trig-based arrow drawing without coordinate transformations
  static void _drawArrow(
    PdfGraphics canvas,
    double x,
    double y,
    double angleRad,
  ) {
    final double length = 6.0;
    final double arrowAngle = 0.85 * math.pi;

    final double x1 = x + length * math.cos(angleRad + arrowAngle);
    final double y1 = y + length * math.sin(angleRad + arrowAngle);
    final double x2 = x + length * math.cos(angleRad - arrowAngle);
    final double y2 = y + length * math.sin(angleRad - arrowAngle);

    canvas.moveTo(x, y);
    canvas.lineTo(x1, y1);
    canvas.lineTo(x2, y2);
    canvas.closePath();
    canvas.fillPath();
  }

  // ==========================================
  // 6. FOCUS & VISUAL ATTENTION GENERATOR
  // ==========================================
  static Future<Uint8List> generateFocusAttention(
    GlobalConfig global,
    FocusAttentionConfig config,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final pw.Font boldFont = fonts['bold']!;
    final pw.Font regFont = fonts['regular']!;

    final double margin = global.marginMm * mmToPt;
    final rng = RandomSeedService.fromSeed(config.seed);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(margin),
        build: (context) {
          final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
          final double headerHeight = global.showHeader ? 75.0 : 0.0;
          final double instructionHeight = 45.0;
          final double printableHeight =
              PdfPageFormat.a4.height -
              2 * margin -
              headerHeight -
              instructionHeight -
              16.0;

          final int rows = config.gridRows;
          final int cols = config.gridCols;
          final double cellW = printableWidth / cols;
          final double cellH = printableHeight / rows;
          final double itemSize = math.min(cellW, cellH) * 0.55;

          final totalCells = rows * cols;
          final List<String> cellItems = List.filled(totalCells, '');

          if (config.activityType == FocusActivityType.oddOneOut) {
            for (int r = 0; r < rows; r++) {
              final oddCol = rng.nextInt(cols);
              for (int c = 0; c < cols; c++) {
                final idx = r * cols + c;
                if (c == oddCol) {
                  cellItems[idx] = config.distractorItems.isNotEmpty
                      ? rng.pickOne(config.distractorItems)
                      : 'square';
                } else {
                  cellItems[idx] = config.targetItem;
                }
              }
            }
          } else {
            final targetIndices = <int>{};
            final maxTargets = math.min(config.targetCount, totalCells);
            while (targetIndices.length < maxTargets) {
              targetIndices.add(rng.nextInt(totalCells));
            }
            for (int i = 0; i < totalCells; i++) {
              if (targetIndices.contains(i)) {
                cellItems[i] = config.targetItem;
              } else {
                cellItems[i] = config.distractorItems.isNotEmpty
                    ? rng.pickOne(config.distractorItems)
                    : 'circle';
              }
            }
          }

          String instructionText;
          switch (config.activityType) {
            case FocusActivityType.findAndCircle:
            case FocusActivityType.findNObjects:
              instructionText =
                  "Find and circle all ${config.targetCount} target objects ('${config.targetItem.toUpperCase()}')!";
              break;
            case FocusActivityType.targetSearch:
              instructionText =
                  "Scan and circle every '${config.targetItem.toUpperCase()}' character on this page!";
              break;
            case FocusActivityType.oddOneOut:
              instructionText =
                  "Identify and circle the ODD ONE OUT in each row!";
              break;
            case FocusActivityType.visualSearchGrid:
              instructionText =
                  "Visual Search Challenge: Locate and circle all ${config.targetCount} '${config.targetItem.toUpperCase()}' items!";
              break;
          }

          final pdfRegFont = regFont.getFont(
            pw.Context(document: pdf.document),
          );

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                global,
                boldFont,
                "Focus & Visual Attention Practice",
              ),
              pw.Container(
                width: printableWidth,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey600, width: 1.2),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                  color: PdfColors.grey100,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        instructionText,
                        style: pw.TextStyle(
                          font: pw.Font.helveticaBold(),
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                width: printableWidth,
                height: printableHeight,
                child: pw.CustomPaint(
                  size: PdfPoint(printableWidth, printableHeight),
                  painter: (canvas, size) {
                    _drawFocusAttentionGrid(
                      canvas,
                      size,
                      rows,
                      cols,
                      cellItems,
                      itemSize,
                      config.targetCategory,
                      pdfRegFont,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static void _drawFocusAttentionGrid(
    PdfGraphics canvas,
    PdfPoint size,
    int rows,
    int cols,
    List<String> cellItems,
    double itemSize,
    FocusTargetCategory category,
    PdfFont pdfFont,
  ) {
    final double cellW = size.x / cols;
    final double cellH = size.y / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final idx = r * cols + c;
        if (idx >= cellItems.length) break;

        final item = cellItems[idx];
        final double x = c * cellW;
        final double y = size.y - (r + 1) * cellH;
        final double cx = x + cellW / 2.0;
        final double cy = y + cellH / 2.0;

        canvas.saveContext();
        canvas.setStrokeColor(PdfColors.grey300);
        canvas.setLineWidth(0.8);
        canvas.drawRect(x, y, cellW, cellH);
        canvas.strokePath();
        canvas.restoreContext();

        final shapeType = _parseShapeType(item);
        if (shapeType != null) {
          _drawShape(canvas, shapeType, cx, cy, itemSize);
        } else {
          canvas.saveContext();
          canvas.setFillColor(PdfColors.black);
          final fontSize = itemSize * 0.9;
          final textWidth = pdfFont.stringMetrics(item).size.x * fontSize;
          final textHeight = fontSize * 0.7;

          canvas.drawString(
            pdfFont,
            fontSize,
            item,
            cx - textWidth / 2.0,
            cy - textHeight / 2.0,
          );
          canvas.restoreContext();
        }
      }
    }
  }

  static ShapeType? _parseShapeType(String name) {
    switch (name.toLowerCase()) {
      case 'circle':
        return ShapeType.circle;
      case 'square':
        return ShapeType.square;
      case 'triangle':
        return ShapeType.triangle;
      case 'star':
        return ShapeType.star;
      case 'heart':
        return ShapeType.heart;
      case 'tree':
        return ShapeType.tree;
      case 'apple':
        return ShapeType.apple;
      default:
        return null;
    }
  }

  // ==========================================
  // 7. THINKING & LOGIC GENERATOR
  // ==========================================
  static Future<Uint8List> generateThinkingLogic(
    GlobalConfig global,
    ThinkingLogicConfig config,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final pw.Font boldFont = fonts['bold']!;
    final pw.Font regFont = fonts['regular']!;

    final double margin = global.marginMm * mmToPt;
    final rng = RandomSeedService.fromSeed(config.seed);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(margin),
        build: (context) {
          final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
          final double headerHeight = global.showHeader ? 75.0 : 0.0;
          final double instructionHeight = 45.0;
          final double printableHeight =
              PdfPageFormat.a4.height -
              2 * margin -
              headerHeight -
              instructionHeight -
              16.0;

          final pdfRegFont = regFont.getFont(
            pw.Context(document: pdf.document),
          );
          final pdfBoldFont = boldFont.getFont(
            pw.Context(document: pdf.document),
          );

          String instructionText;
          switch (config.activityType) {
            case ThinkingLogicType.patternCompletion:
              instructionText =
                  "Pattern Completion: Look at the pattern in each row and draw what comes next!";
              break;
            case ThinkingLogicType.whatComesNext:
              instructionText =
                  "What Comes Next?: Observe the logic sequence and complete the blank box.";
              break;
            case ThinkingLogicType.itemMatching:
              instructionText =
                  "Matching Challenge: Draw lines to connect matching objects from left to right!";
              break;
            case ThinkingLogicType.sameVsDifferent:
              instructionText =
                  "Same vs Different: Look at the target in the first box and circle the matching item!";
              break;
            case ThinkingLogicType.sizeOrdering:
              instructionText =
                  "Size Ordering: Circle the BIGGEST item and number items 1-3 from smallest to largest!";
              break;
          }

          final availableShapes = [
            'star',
            'circle',
            'square',
            'triangle',
            'heart',
            'tree',
            'apple',
          ];

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(global, boldFont, "Thinking & Logic Practice"),
              pw.Container(
                width: printableWidth,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey600, width: 1.2),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                  color: PdfColors.grey100,
                ),
                child: pw.Text(
                  instructionText,
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                width: printableWidth,
                height: printableHeight,
                child: pw.CustomPaint(
                  size: PdfPoint(printableWidth, printableHeight),
                  painter: (canvas, size) {
                    final int rows = config.rowCount;
                    final double rowH = size.y / rows;

                    if (config.activityType ==
                            ThinkingLogicType.patternCompletion ||
                        config.activityType ==
                            ThinkingLogicType.whatComesNext) {
                      for (int r = 0; r < rows; r++) {
                        final y = size.y - (r + 1) * rowH;
                        final picked = rng
                            .shuffle(availableShapes)
                            .sublist(0, 3);
                        final seq = config.patternType.generateSequence(
                          picked,
                          4,
                        );

                        _drawPatternRow(
                          canvas,
                          0,
                          y,
                          size.x,
                          rowH,
                          seq,
                          pdfRegFont,
                          pdfBoldFont,
                        );
                      }
                    } else if (config.activityType ==
                        ThinkingLogicType.itemMatching) {
                      final leftItems = rng
                          .shuffle(availableShapes)
                          .sublist(0, math.min(rows, availableShapes.length));
                      final rightItems = rng.shuffle(leftItems);

                      _drawMatchingRows(
                        canvas,
                        size,
                        leftItems.length,
                        leftItems,
                        rightItems,
                        pdfRegFont,
                      );
                    } else if (config.activityType ==
                        ThinkingLogicType.sameVsDifferent) {
                      for (int r = 0; r < rows; r++) {
                        final y = size.y - (r + 1) * rowH;
                        final target = rng.pickOne(availableShapes);
                        final distractors = availableShapes
                            .where((s) => s != target)
                            .toList();

                        _drawSameVsDifferentRow(
                          canvas,
                          0,
                          y,
                          size.x,
                          rowH,
                          target,
                          distractors,
                          rng,
                        );
                      }
                    } else if (config.activityType ==
                        ThinkingLogicType.sizeOrdering) {
                      for (int r = 0; r < rows; r++) {
                        final y = size.y - (r + 1) * rowH;
                        final item = rng.pickOne(availableShapes);

                        _drawSizeOrderingRow(canvas, 0, y, size.x, rowH, item);
                      }
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static void _drawPatternRow(
    PdfGraphics canvas,
    double x,
    double y,
    double w,
    double h,
    List<String> items,
    PdfFont regFont,
    PdfFont boldFont,
  ) {
    // Draw row background frame
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey300);
    canvas.setLineWidth(0.8);
    canvas.drawRect(x, y + 4, w, h - 8);
    canvas.strokePath();
    canvas.restoreContext();

    final int totalBoxes = items.length + 1; // 4 pattern items + 1 question box
    final double boxW = (w - 24) / totalBoxes;
    final double itemSize = math.min(boxW, h - 16) * 0.6;

    for (int i = 0; i < totalBoxes; i++) {
      final double bx = x + 12 + i * boxW;
      final double by = y + (h - boxW) / 2.0;

      canvas.saveContext();
      if (i == items.length) {
        // Question Box (dashed)
        canvas.setStrokeColor(PdfColors.grey700);
        canvas.setLineDashPattern([3, 3]);
        canvas.setLineWidth(1.5);
        canvas.drawRect(bx + 4, by, boxW - 8, boxW - 8);
        canvas.strokePath();

        final double cx = bx + boxW / 2.0;
        final double cy = by + (boxW - 8) / 2.0;
        canvas.setFillColor(PdfColors.grey800);
        canvas.drawString(boldFont, 18, "?", cx - 5, cy - 6);
      } else {
        // Pattern item box
        canvas.setStrokeColor(PdfColors.grey400);
        canvas.setLineWidth(1.0);
        canvas.drawRect(bx + 4, by, boxW - 8, boxW - 8);
        canvas.strokePath();

        final shapeType = _parseShapeType(items[i]);
        if (shapeType != null) {
          final double cx = bx + boxW / 2.0;
          final double cy = by + (boxW - 8) / 2.0;
          _drawShape(canvas, shapeType, cx, cy, itemSize);
        }
      }
      canvas.restoreContext();
    }
  }

  static void _drawMatchingRows(
    PdfGraphics canvas,
    PdfPoint size,
    int rows,
    List<String> leftItems,
    List<String> rightItems,
    PdfFont font,
  ) {
    final double rowH = size.y / rows;
    final double colW = 120.0;
    final double leftX = 40.0;
    final double rightX = size.x - 40.0 - colW;

    for (int r = 0; r < rows; r++) {
      final y = size.y - (r + 1) * rowH;
      final cy = y + rowH / 2.0;

      // Left item card
      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey400);
      canvas.setLineWidth(1.0);
      canvas.drawRect(leftX, cy - 24, colW, 48);
      canvas.strokePath();

      final leftShape = _parseShapeType(leftItems[r]);
      if (leftShape != null) {
        _drawShape(canvas, leftShape, leftX + colW / 2.0, cy, 26);
      }
      // Right anchor dot
      canvas.setFillColor(PdfColors.black);
      canvas.drawEllipse(leftX + colW + 12, cy, 4, 4);
      canvas.fillPath();
      canvas.restoreContext();

      // Right item card
      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey400);
      canvas.setLineWidth(1.0);
      canvas.drawRect(rightX, cy - 24, colW, 48);
      canvas.strokePath();

      final rightShape = _parseShapeType(rightItems[r]);
      if (rightShape != null) {
        _drawShape(canvas, rightShape, rightX + colW / 2.0, cy, 26);
      }
      // Left anchor dot
      canvas.setFillColor(PdfColors.black);
      canvas.drawEllipse(rightX - 12, cy, 4, 4);
      canvas.fillPath();
      canvas.restoreContext();
    }
  }

  static void _drawSameVsDifferentRow(
    PdfGraphics canvas,
    double x,
    double y,
    double w,
    double h,
    String targetItem,
    List<String> distractors,
    RandomSeedService rng,
  ) {
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey300);
    canvas.setLineWidth(0.8);
    canvas.drawRect(x, y + 4, w, h - 8);
    canvas.strokePath();
    canvas.restoreContext();

    final double boxW = (w - 24) / 5;
    final double itemSize = math.min(boxW, h - 16) * 0.6;
    final double cy = y + h / 2.0;

    // Target box (Left reference box)
    final double tx = x + 12;
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.black);
    canvas.setLineWidth(2.0);
    canvas.drawRect(tx + 4, cy - boxW / 2.0, boxW - 8, boxW - 8);
    canvas.strokePath();

    final targetShape = _parseShapeType(targetItem);
    if (targetShape != null) {
      _drawShape(canvas, targetShape, tx + boxW / 2.0, cy, itemSize);
    }
    canvas.restoreContext();

    // Separator line
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey500);
    canvas.setLineWidth(1.0);
    canvas.moveTo(tx + boxW + 4, y + 10);
    canvas.lineTo(tx + boxW + 4, y + h - 10);
    canvas.strokePath();
    canvas.restoreContext();

    // Generate 4 choice boxes where 1 matches target and 3 are distractors
    final matchIdx = rng.nextInt(4);
    for (int i = 0; i < 4; i++) {
      final double bx = tx + boxW + 12 + i * boxW;
      final String item = (i == matchIdx)
          ? targetItem
          : rng.pickOne(distractors);

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey400);
      canvas.setLineWidth(1.0);
      canvas.drawRect(bx + 4, cy - boxW / 2.0, boxW - 8, boxW - 8);
      canvas.strokePath();

      final shape = _parseShapeType(item);
      if (shape != null) {
        _drawShape(canvas, shape, bx + boxW / 2.0, cy, itemSize);
      }
      canvas.restoreContext();
    }
  }

  static void _drawSizeOrderingRow(
    PdfGraphics canvas,
    double x,
    double y,
    double w,
    double h,
    String item,
  ) {
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey300);
    canvas.setLineWidth(0.8);
    canvas.drawRect(x, y + 4, w, h - 8);
    canvas.strokePath();
    canvas.restoreContext();

    final double boxW = (w - 24) / 3;
    final double cy = y + h / 2.0;

    final scales = [0.45, 0.75, 1.1]; // Small, Medium, Large
    final shape = _parseShapeType(item);

    for (int i = 0; i < 3; i++) {
      final double bx = x + 12 + i * boxW;

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey400);
      canvas.setLineWidth(1.0);
      canvas.drawRect(bx + 6, cy - boxW / 2.0 + 4, boxW - 12, boxW - 12);
      canvas.strokePath();

      if (shape != null) {
        final double baseSize = (boxW - 12) * 0.5;
        _drawShape(canvas, shape, bx + boxW / 2.0, cy, baseSize * scales[i]);
      }
      canvas.restoreContext();
    }
  }

  // ==========================================
  // 8. SCISSOR SKILLS & FINE MOTOR GENERATOR
  // ==========================================
  static Future<Uint8List> generateScissorSkills(
    GlobalConfig global,
    ScissorSkillsConfig config,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final pw.Font boldFont = fonts['bold']!;

    final double margin = global.marginMm * mmToPt;
    final rng = RandomSeedService.fromSeed(config.seed);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(margin),
        build: (context) {
          final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
          final double headerHeight = global.showHeader ? 75.0 : 0.0;
          final double instructionHeight = 45.0;
          final double printableHeight =
              PdfPageFormat.a4.height -
              2 * margin -
              headerHeight -
              instructionHeight -
              16.0;

          final pdfBoldFont = boldFont.getFont(
            pw.Context(document: pdf.document),
          );

          String instructionText;
          switch (config.lineType) {
            case ScissorLineType.straight:
              instructionText =
                  "Scissor Practice: Cut along the straight dashed lines starting from the scissors!";
              break;
            case ScissorLineType.curved:
              instructionText =
                  "Scissor Practice: Follow the curved lines smoothly from start to finish!";
              break;
            case ScissorLineType.zigzag:
              instructionText =
                  "Scissor Practice: Pivot and turn your scissors sharply along the zigzag angles!";
              break;
            case ScissorLineType.shapeOutlines:
              instructionText =
                  "Shape Cutting: Carefully cut out each shape along the dashed cutting borders!";
              break;
            case ScissorLineType.cutAndPaste:
              instructionText =
                  "Cut & Paste Activity: Snip out the bottom number cards and paste into matching target boxes!";
              break;
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                global,
                boldFont,
                "Scissor Skills & Fine Motor Practice",
              ),
              pw.Container(
                width: printableWidth,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey600, width: 1.2),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                  color: PdfColors.grey100,
                ),
                child: pw.Text(
                  instructionText,
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                width: printableWidth,
                height: printableHeight,
                child: pw.CustomPaint(
                  size: PdfPoint(printableWidth, printableHeight),
                  painter: (canvas, size) {
                    if (config.lineType == ScissorLineType.straight ||
                        config.lineType == ScissorLineType.curved ||
                        config.lineType == ScissorLineType.zigzag) {
                      _drawScissorLanes(
                        canvas,
                        size,
                        config.lineCount,
                        config.lineType,
                        config.showScissorIcons,
                      );
                    } else if (config.lineType ==
                        ScissorLineType.shapeOutlines) {
                      _drawScissorShapeOutlines(
                        canvas,
                        size,
                        config.showScissorIcons,
                      );
                    } else if (config.lineType == ScissorLineType.cutAndPaste) {
                      _drawScissorCutAndPaste(canvas, size, pdfBoldFont, rng);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static void _drawScissorLanes(
    PdfGraphics canvas,
    PdfPoint size,
    int lineCount,
    ScissorLineType lineType,
    bool showScissorIcons,
  ) {
    final double laneH = size.y / lineCount;
    final double startX = 35.0;
    final double endX = size.x - 40.0;
    final double width = endX - startX;

    final targetShapes = [
      ShapeType.star,
      ShapeType.apple,
      ShapeType.tree,
      ShapeType.heart,
      ShapeType.circle,
    ];

    for (int i = 0; i < lineCount; i++) {
      final y = size.y - (i + 0.5) * laneH;

      // Scissor Start Icon
      if (showScissorIcons) {
        _drawScissorIcon(canvas, 16.0, y);
      }

      // Lane Guide Line
      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.black);
      canvas.setLineWidth(1.8);
      canvas.setLineDashPattern([6, 4]);

      if (lineType == ScissorLineType.straight) {
        canvas.moveTo(startX, y);
        canvas.lineTo(endX, y);
        canvas.strokePath();
      } else if (lineType == ScissorLineType.curved) {
        final int segments = 24;
        final double dx = width / segments;
        final double amplitude = 22.0;

        canvas.moveTo(startX, y);
        for (int s = 0; s <= segments; s++) {
          final px = startX + s * dx;
          final py = y + amplitude * math.sin(s * 0.45);
          canvas.lineTo(px, py);
        }
        canvas.strokePath();
      } else if (lineType == ScissorLineType.zigzag) {
        final int zigs = 8;
        final double zigW = width / zigs;
        final double zigH = 22.0;

        canvas.moveTo(startX, y);
        for (int z = 0; z < zigs; z++) {
          final zx1 = startX + (z + 0.5) * zigW;
          final zy1 = y + (z % 2 == 0 ? zigH : -zigH);
          final zx2 = startX + (z + 1) * zigW;
          final zy2 = y;
          canvas.lineTo(zx1, zy1);
          canvas.lineTo(zx2, zy2);
        }
        canvas.strokePath();
      }
      canvas.restoreContext();

      // Destination Target Anchor Shape
      final targetShape = targetShapes[i % targetShapes.length];
      _drawShape(canvas, targetShape, endX + 16.0, y, 22.0);
    }
  }

  static void _drawScissorIcon(PdfGraphics canvas, double x, double y) {
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.black);
    canvas.setFillColor(PdfColors.white);
    canvas.setLineWidth(1.2);

    canvas.moveTo(x - 6, y - 6);
    canvas.lineTo(x + 8, y + 2);
    canvas.strokePath();

    canvas.moveTo(x - 6, y + 6);
    canvas.lineTo(x + 8, y - 2);
    canvas.strokePath();

    canvas.drawEllipse(x - 9, y - 6, 3, 3);
    canvas.strokePath();

    canvas.drawEllipse(x - 9, y + 6, 3, 3);
    canvas.strokePath();

    canvas.restoreContext();
  }

  static void _drawScissorShapeOutlines(
    PdfGraphics canvas,
    PdfPoint size,
    bool showScissorIcons,
  ) {
    final double cardW = size.x / 2 - 12;
    final double cardH = size.y / 2 - 12;

    final shapes = [
      ShapeType.square,
      ShapeType.circle,
      ShapeType.triangle,
      ShapeType.star,
    ];

    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 2; c++) {
        final idx = r * 2 + c;
        final shape = shapes[idx];
        final x = c * (cardW + 24) + 6;
        final y = size.y - (r + 1) * (cardH + 24) + 12;

        final cx = x + cardW / 2.0;
        final cy = y + cardH / 2.0;
        final double shapeSize = math.min(cardW, cardH) * 0.7;

        canvas.saveContext();
        canvas.setStrokeColor(PdfColors.black);
        canvas.setLineWidth(2.0);
        canvas.setLineDashPattern([5, 4]);

        _drawShape(canvas, shape, cx, cy, shapeSize);

        if (showScissorIcons) {
          _drawScissorIcon(
            canvas,
            cx - shapeSize / 2.0 - 10,
            cy + shapeSize / 2.0,
          );
        }
        canvas.restoreContext();
      }
    }
  }

  static void _drawScissorCutAndPaste(
    PdfGraphics canvas,
    PdfPoint size,
    PdfFont boldFont,
    RandomSeedService rng,
  ) {
    final double topH = size.y * 0.6;
    final double bottomH = size.y * 0.35;

    // Top Target Pasting Area (4 Boxes)
    final double cardW = size.x / 2 - 16;
    final double cardH = topH / 2 - 16;

    final quantities = [1, 2, 3, 4];

    for (int r = 0; r < 2; r++) {
      for (int c = 0; c < 2; c++) {
        final idx = r * 2 + c;
        final qty = quantities[idx];
        final x = c * (cardW + 24) + 12;
        final y = size.y - (r + 1) * (cardH + 24);

        canvas.saveContext();
        canvas.setStrokeColor(PdfColors.grey400);
        canvas.setLineWidth(1.2);
        canvas.drawRect(x, y, cardW, cardH);
        canvas.strokePath();

        // Draw Qty items inside
        final double itemSize = 20.0;
        for (int q = 0; q < qty; q++) {
          final ix = x + 24 + (q % 2) * 36;
          final iy = y + cardH - 24 - (q ~/ 2) * 36;
          _drawShape(canvas, ShapeType.star, ix, iy, itemSize);
        }

        // Paste indicator box
        canvas.setStrokeColor(PdfColors.grey700);
        canvas.setLineWidth(1.0);
        canvas.setLineDashPattern([3, 3]);
        canvas.drawRect(x + cardW - 48, y + 12, 36, 36);
        canvas.strokePath();

        canvas.setFillColor(PdfColors.grey500);
        canvas.drawString(boldFont, 9, "PASTE HERE", x + cardW - 46, y + 26);
        canvas.restoreContext();
      }
    }

    // Divider Cut Line
    final double divY = bottomH + 12;
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.black);
    canvas.setLineWidth(1.5);
    canvas.setLineDashPattern([6, 4]);
    canvas.moveTo(35.0, divY);
    canvas.lineTo(size.x - 20.0, divY);
    canvas.strokePath();

    _drawScissorIcon(canvas, 16.0, divY);
    canvas.restoreContext();

    // Bottom Cuttable Number Cards (Shuffled)
    final shuffledNumbers = rng.shuffle([1, 2, 3, 4]);
    final double numCardW = (size.x - 40) / 4;

    for (int i = 0; i < 4; i++) {
      final nx = 20.0 + i * numCardW;
      final ny = 12.0;

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.black);
      canvas.setLineWidth(1.5);
      canvas.setLineDashPattern([4, 3]);
      canvas.drawRect(nx + 4, ny, numCardW - 8, bottomH - 20);
      canvas.strokePath();

      final text = "${shuffledNumbers[i]}";
      canvas.setFillColor(PdfColors.black);
      final cx = nx + numCardW / 2.0;
      final cy = ny + (bottomH - 20) / 2.0;
      canvas.drawString(boldFont, 24, text, cx - 7, cy - 8);
      canvas.restoreContext();
    }
  }

  // ==========================================
  // 9. COLORING PAGES GENERATOR
  // ==========================================
  static Future<Uint8List> generateColoring(
    GlobalConfig global,
    ColoringConfig config,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final pw.Font boldFont = fonts['bold']!;
    final pw.Font dashedFont = fonts['dashed']!;
    final double margin = global.marginMm * mmToPt;

    final ColoringAsset asset =
        AssetCatalogService.getById(config.assetId) ??
        AssetCatalogService.getAll().first;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(margin),
        build: (context) {
          final PdfFont pdfBoldFont = boldFont.getFont(context);
          final PdfFont pdfDashedFont = dashedFont.getFont(context);
          final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
          final double headerHeight = global.showHeader ? 75.0 : 0.0;
          final double printableHeight =
              PdfPageFormat.a4.height - 2 * margin - headerHeight - 12.0;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(global, boldFont, "${asset.title} Coloring Page"),
              if (global.showHeader) pw.SizedBox(height: 8),
              pw.Container(
                width: printableWidth,
                height: printableHeight,
                child: pw.CustomPaint(
                  size: PdfPoint(printableWidth, printableHeight),
                  painter: (canvas, size) {
                    _drawColoringPage(
                      canvas,
                      size,
                      asset,
                      config,
                      pdfBoldFont,
                      pdfDashedFont,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static void _drawColoringPage(
    PdfGraphics canvas,
    PdfPoint size,
    ColoringAsset asset,
    ColoringConfig config,
    PdfFont boldFont,
    PdfFont dashedFont,
  ) {
    if (config.showDecorativeBorder) {
      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.black);
      canvas.setLineWidth(2.5);
      canvas.drawRect(2, 2, size.x - 4, size.y - 4);
      canvas.strokePath();

      canvas.setLineWidth(1.0);
      canvas.drawRect(6, 6, size.x - 12, size.y - 12);
      canvas.strokePath();
      canvas.restoreContext();
    }

    final double strokeW = config.lineThickness.widthPt;

    double drawingAreaTop = size.y - 20.0;
    if (config.showWordTracing) {
      const double traceFontSize = 36.0;
      final String word = asset.title.toUpperCase();
      final double strW = _measureText(dashedFont, traceFontSize, word);
      final double traceX = (size.x - strW) / 2.0;
      final double traceY = size.y - 50.0;

      _drawText(canvas, dashedFont, traceFontSize, word, traceX, traceY);
      drawingAreaTop = size.y - 70.0;
    }

    double drawingAreaBottom = 20.0;
    if (config.showColoringPrompts) {
      drawingAreaBottom = 50.0;
      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey400);
      canvas.setLineWidth(1.0);
      canvas.drawRect(20, 15, size.x - 40, 28);
      canvas.strokePath();

      _drawText(
        canvas,
        boldFont,
        11.0,
        "Coloring Tip: Color inside the thick black lines! Use your favorite crayons or markers.",
        30,
        24,
      );
      canvas.restoreContext();
    }

    final double cx = size.x / 2.0;
    final double cy = (drawingAreaTop + drawingAreaBottom) / 2.0;

    _drawColoringAssetOutline(canvas, cx, cy, asset.id, strokeW);
  }

  static void _drawColoringAssetOutline(
    PdfGraphics canvas,
    double cx,
    double cy,
    String assetId,
    double strokeW,
  ) {
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.black);
    canvas.setFillColor(PdfColors.white);
    canvas.setLineWidth(strokeW);

    switch (assetId) {
      case 'animal_apple_bear':
        _drawBearOutline(canvas, cx, cy);
        break;
      case 'animal_farm_cow':
        _drawCowOutline(canvas, cx, cy);
        break;
      case 'animal_farm_duck':
        _drawDuckOutline(canvas, cx, cy);
        break;
      case 'animal_sea_dolphin':
        _drawDolphinOutline(canvas, cx, cy);
        break;
      case 'vehicle_land_car':
        _drawCarOutline(canvas, cx, cy);
        break;
      case 'vehicle_air_rocket':
        _drawRocketOutline(canvas, cx, cy);
        break;
      case 'food_fruit_apple':
        _drawAppleOutline(canvas, cx, cy);
        break;
      case 'nature_tree':
        _drawTreeOutline(canvas, cx, cy);
        break;
      case 'space_star':
        _drawStarOutline(canvas, cx, cy);
        break;
      default:
        _drawBearOutline(canvas, cx, cy);
        break;
    }
    canvas.restoreContext();
  }

  static void _drawBearOutline(PdfGraphics canvas, double cx, double cy) {
    canvas.drawEllipse(cx, cy - 60, 95, 80);
    canvas.strokePath();

    canvas.drawEllipse(cx, cy - 60, 55, 48);
    canvas.strokePath();

    canvas.drawEllipse(cx - 65, cy + 95, 26, 26);
    canvas.strokePath();
    canvas.drawEllipse(cx + 65, cy + 95, 26, 26);
    canvas.strokePath();

    canvas.drawEllipse(cx - 65, cy + 95, 14, 14);
    canvas.strokePath();
    canvas.drawEllipse(cx + 65, cy + 95, 14, 14);
    canvas.strokePath();

    canvas.drawEllipse(cx, cy + 35, 75, 68);
    canvas.strokePath();

    canvas.drawEllipse(cx, cy + 15, 36, 24);
    canvas.strokePath();

    canvas.drawEllipse(cx, cy + 24, 14, 9);
    canvas.fillPath();

    canvas.moveTo(cx, cy + 15);
    canvas.lineTo(cx, cy + 5);
    canvas.strokePath();
    canvas.moveTo(cx - 12, cy + 4);
    canvas.curveTo(cx - 6, cy - 2, cx, cy + 5, cx, cy + 5);
    canvas.curveTo(cx, cy + 5, cx + 6, cy - 2, cx + 12, cy + 4);
    canvas.strokePath();

    canvas.drawEllipse(cx - 28, cy + 52, 9, 12);
    canvas.fillPath();
    canvas.drawEllipse(cx + 28, cy + 52, 9, 12);
    canvas.fillPath();

    canvas.drawEllipse(cx - 90, cy - 40, 22, 38);
    canvas.strokePath();
    canvas.drawEllipse(cx + 90, cy - 40, 22, 38);
    canvas.strokePath();

    canvas.drawEllipse(cx - 55, cy - 135, 30, 20);
    canvas.strokePath();
    canvas.drawEllipse(cx + 55, cy - 135, 30, 20);
    canvas.strokePath();
  }

  static void _drawCowOutline(PdfGraphics canvas, double cx, double cy) {
    canvas.drawEllipse(cx, cy - 40, 120, 85);
    canvas.strokePath();

    canvas.drawEllipse(cx - 50, cy - 30, 32, 24);
    canvas.strokePath();
    canvas.drawEllipse(cx + 45, cy - 50, 40, 30);
    canvas.strokePath();
    canvas.drawEllipse(cx, cy - 80, 28, 20);
    canvas.strokePath();

    canvas.drawRect(cx - 85, cy - 155, 24, 45);
    canvas.strokePath();
    canvas.drawRect(cx - 45, cy - 155, 24, 45);
    canvas.strokePath();
    canvas.drawRect(cx + 25, cy - 155, 24, 45);
    canvas.strokePath();
    canvas.drawRect(cx + 65, cy - 155, 24, 45);
    canvas.strokePath();

    canvas.drawRect(cx - 85, cy - 155, 24, 12);
    canvas.fillPath();
    canvas.drawRect(cx - 45, cy - 155, 24, 12);
    canvas.fillPath();
    canvas.drawRect(cx + 25, cy - 155, 24, 12);
    canvas.fillPath();
    canvas.drawRect(cx + 65, cy - 155, 24, 12);
    canvas.fillPath();

    canvas.drawEllipse(cx, cy + 65, 65, 55);
    canvas.strokePath();

    canvas.moveTo(cx - 35, cy + 115);
    canvas.curveTo(cx - 45, cy + 135, cx - 60, cy + 130, cx - 50, cy + 115);
    canvas.strokePath();
    canvas.moveTo(cx + 35, cy + 115);
    canvas.curveTo(cx + 45, cy + 135, cx + 60, cy + 130, cx + 50, cy + 115);
    canvas.strokePath();

    canvas.drawEllipse(cx - 85, cy + 70, 25, 14);
    canvas.strokePath();
    canvas.drawEllipse(cx + 85, cy + 70, 25, 14);
    canvas.strokePath();

    canvas.drawEllipse(cx, cy + 40, 52, 32);
    canvas.strokePath();

    canvas.drawEllipse(cx - 18, cy + 40, 7, 10);
    canvas.fillPath();
    canvas.drawEllipse(cx + 18, cy + 40, 7, 10);
    canvas.fillPath();

    canvas.drawEllipse(cx - 28, cy + 85, 8, 11);
    canvas.fillPath();
    canvas.drawEllipse(cx + 28, cy + 85, 8, 11);
    canvas.fillPath();
  }

  static void _drawDuckOutline(PdfGraphics canvas, double cx, double cy) {
    canvas.drawEllipse(cx + 10, cy - 30, 95, 65);
    canvas.strokePath();

    canvas.moveTo(cx + 90, cy - 10);
    canvas.lineTo(cx + 135, cy + 10);
    canvas.lineTo(cx + 115, cy - 30);
    canvas.lineTo(cx + 130, cy - 45);
    canvas.lineTo(cx + 85, cy - 50);
    canvas.strokePath();

    canvas.drawEllipse(cx + 15, cy - 30, 48, 30);
    canvas.strokePath();

    canvas.drawEllipse(cx - 50, cy + 65, 52, 50);
    canvas.strokePath();

    canvas.moveTo(cx - 95, cy + 68);
    canvas.curveTo(cx - 130, cy + 75, cx - 130, cy + 50, cx - 95, cy + 52);
    canvas.closePath();
    canvas.strokePath();

    canvas.drawEllipse(cx - 65, cy + 78, 8, 11);
    canvas.fillPath();

    canvas.moveTo(cx - 120, cy - 100);
    canvas.curveTo(cx - 60, cy - 85, cx + 60, cy - 115, cx + 120, cy - 100);
    canvas.strokePath();
    canvas.moveTo(cx - 90, cy - 120);
    canvas.curveTo(cx - 30, cy - 105, cx + 30, cy - 135, cx + 90, cy - 120);
    canvas.strokePath();
  }

  static void _drawDolphinOutline(PdfGraphics canvas, double cx, double cy) {
    canvas.moveTo(cx - 140, cy - 60);
    canvas.curveTo(cx - 80, cy + 110, cx + 60, cy + 110, cx + 130, cy + 10);
    canvas.curveTo(cx + 80, cy - 60, cx - 60, cy - 90, cx - 140, cy - 60);
    canvas.strokePath();

    canvas.moveTo(cx + 130, cy + 10);
    canvas.curveTo(cx + 160, cy + 15, cx + 155, cy - 5, cx + 125, cy - 10);
    canvas.strokePath();

    canvas.moveTo(cx - 10, cy + 95);
    canvas.curveTo(cx - 20, cy + 145, cx + 25, cy + 135, cx + 30, cy + 85);
    canvas.strokePath();

    canvas.moveTo(cx + 35, cy - 10);
    canvas.curveTo(cx + 45, cy - 60, cx + 75, cy - 55, cx + 55, cy - 5);
    canvas.strokePath();

    canvas.moveTo(cx - 140, cy - 60);
    canvas.curveTo(cx - 175, cy - 30, cx - 180, cy - 70, cx - 150, cy - 75);
    canvas.curveTo(cx - 180, cy - 80, cx - 170, cy - 120, cx - 140, cy - 60);
    canvas.strokePath();

    canvas.drawEllipse(cx + 95, cy + 25, 7, 9);
    canvas.fillPath();

    canvas.moveTo(cx - 140, cy - 130);
    canvas.curveTo(cx - 70, cy - 110, cx + 70, cy - 150, cx + 140, cy - 130);
    canvas.strokePath();
  }

  static void _drawCarOutline(PdfGraphics canvas, double cx, double cy) {
    canvas.moveTo(cx - 150, cy - 40);
    canvas.lineTo(cx - 150, cy + 10);
    canvas.curveTo(cx - 140, cy + 30, cx - 100, cy + 35, cx - 80, cy + 35);
    canvas.lineTo(cx - 50, cy + 95);
    canvas.lineTo(cx + 50, cy + 95);
    canvas.lineTo(cx + 90, cy + 35);
    canvas.lineTo(cx + 140, cy + 35);
    canvas.curveTo(cx + 155, cy + 30, cx + 160, cy + 10, cx + 160, cy - 40);
    canvas.lineTo(cx - 150, cy - 40);
    canvas.strokePath();

    canvas.moveTo(cx - 72, cy + 40);
    canvas.lineTo(cx - 48, cy + 85);
    canvas.lineTo(cx - 5, cy + 85);
    canvas.lineTo(cx - 5, cy + 40);
    canvas.closePath();
    canvas.strokePath();

    canvas.moveTo(cx + 5, cy + 40);
    canvas.lineTo(cx + 5, cy + 85);
    canvas.lineTo(cx + 42, cy + 85);
    canvas.lineTo(cx + 80, cy + 40);
    canvas.closePath();
    canvas.strokePath();

    canvas.drawEllipse(cx - 85, cy - 40, 36, 36);
    canvas.strokePath();
    canvas.drawEllipse(cx - 85, cy - 40, 20, 20);
    canvas.strokePath();

    canvas.drawEllipse(cx + 85, cy - 40, 36, 36);
    canvas.strokePath();
    canvas.drawEllipse(cx + 85, cy - 40, 20, 20);
    canvas.strokePath();

    canvas.drawRect(cx + 145, cy + 5, 12, 18);
    canvas.strokePath();
    canvas.drawRect(cx - 155, cy + 5, 8, 18);
    canvas.strokePath();

    canvas.moveTo(cx - 170, cy - 78);
    canvas.lineTo(cx + 170, cy - 78);
    canvas.strokePath();
  }

  static void _drawRocketOutline(PdfGraphics canvas, double cx, double cy) {
    canvas.moveTo(cx, cy + 150);
    canvas.curveTo(cx + 65, cy + 80, cx + 60, cy - 50, cx + 55, cy - 80);
    canvas.lineTo(cx - 55, cy - 80);
    canvas.curveTo(cx - 60, cy - 50, cx - 65, cy + 80, cx, cy + 150);
    canvas.strokePath();

    canvas.moveTo(cx - 45, cy + 90);
    canvas.lineTo(cx + 45, cy + 90);
    canvas.strokePath();

    canvas.drawEllipse(cx, cy + 30, 32, 32);
    canvas.strokePath();
    canvas.drawEllipse(cx, cy + 30, 22, 22);
    canvas.strokePath();

    canvas.moveTo(cx - 58, cy - 20);
    canvas.lineTo(cx - 105, cy - 100);
    canvas.lineTo(cx - 55, cy - 80);
    canvas.strokePath();

    canvas.moveTo(cx + 58, cy - 20);
    canvas.lineTo(cx + 105, cy - 100);
    canvas.lineTo(cx + 55, cy - 80);
    canvas.strokePath();

    canvas.moveTo(cx - 40, cy - 80);
    canvas.lineTo(cx - 45, cy - 130);
    canvas.lineTo(cx - 20, cy - 100);
    canvas.lineTo(cx, cy - 150);
    canvas.lineTo(cx + 20, cy - 100);
    canvas.lineTo(cx + 45, cy - 130);
    canvas.lineTo(cx + 40, cy - 80);
    canvas.strokePath();

    _pathStar(canvas, cx - 110, cy + 100, 18);
    canvas.strokePath();
    _pathStar(canvas, cx + 115, cy + 80, 22);
    canvas.strokePath();
    _pathStar(canvas, cx - 120, cy - 40, 15);
    canvas.strokePath();
  }

  static void _drawAppleOutline(PdfGraphics canvas, double cx, double cy) {
    canvas.moveTo(cx, cy + 100);
    canvas.curveTo(cx - 120, cy + 140, cx - 150, cy - 40, cx - 60, cy - 130);
    canvas.curveTo(cx - 20, cy - 145, cx + 20, cy - 145, cx + 60, cy - 130);
    canvas.curveTo(cx + 150, cy - 40, cx + 120, cy + 140, cx, cy + 100);
    canvas.strokePath();

    canvas.moveTo(cx, cy + 95);
    canvas.curveTo(cx - 5, cy + 130, cx + 15, cy + 160, cx + 25, cy + 165);
    canvas.curveTo(cx + 20, cy + 165, cx + 5, cy + 135, cx - 5, cy + 95);
    canvas.strokePath();

    canvas.moveTo(cx + 10, cy + 130);
    canvas.curveTo(cx + 40, cy + 165, cx + 80, cy + 160, cx + 75, cy + 130);
    canvas.curveTo(cx + 45, cy + 115, cx + 20, cy + 120, cx + 10, cy + 130);
    canvas.strokePath();
    canvas.moveTo(cx + 10, cy + 130);
    canvas.lineTo(cx + 75, cy + 130);
    canvas.strokePath();

    canvas.moveTo(cx - 75, cy + 60);
    canvas.curveTo(cx - 100, cy + 20, cx - 95, cy - 40, cx - 70, cy - 70);
    canvas.strokePath();
  }

  static void _drawTreeOutline(PdfGraphics canvas, double cx, double cy) {
    canvas.moveTo(cx - 35, cy - 150);
    canvas.lineTo(cx - 30, cy - 10);
    canvas.lineTo(cx + 30, cy - 10);
    canvas.lineTo(cx + 35, cy - 150);
    canvas.strokePath();

    canvas.moveTo(cx - 10, cy - 130);
    canvas.lineTo(cx - 12, cy - 50);
    canvas.strokePath();
    canvas.moveTo(cx + 12, cy - 110);
    canvas.lineTo(cx + 10, cy - 30);
    canvas.strokePath();

    canvas.drawEllipse(cx - 75, cy + 30, 65, 65);
    canvas.strokePath();
    canvas.drawEllipse(cx + 75, cy + 30, 65, 65);
    canvas.strokePath();
    canvas.drawEllipse(cx - 50, cy + 95, 60, 60);
    canvas.strokePath();
    canvas.drawEllipse(cx + 50, cy + 95, 60, 60);
    canvas.strokePath();
    canvas.drawEllipse(cx, cy + 125, 70, 70);
    canvas.strokePath();

    canvas.moveTo(cx - 120, cy - 150);
    canvas.lineTo(cx - 110, cy - 130);
    canvas.lineTo(cx - 100, cy - 150);
    canvas.lineTo(cx - 90, cy - 130);
    canvas.lineTo(cx - 80, cy - 150);
    canvas.strokePath();

    canvas.moveTo(cx + 80, cy - 150);
    canvas.lineTo(cx + 90, cy - 130);
    canvas.lineTo(cx + 100, cy - 150);
    canvas.lineTo(cx + 110, cy - 130);
    canvas.lineTo(cx + 120, cy - 150);
    canvas.strokePath();
  }

  static void _drawStarOutline(PdfGraphics canvas, double cx, double cy) {
    _pathStar(canvas, cx, cy + 10, 140);
    canvas.strokePath();

    canvas.drawEllipse(cx - 35, cy + 25, 11, 16);
    canvas.fillPath();
    canvas.drawEllipse(cx + 35, cy + 25, 11, 16);
    canvas.fillPath();

    canvas.moveTo(cx - 25, cy - 15);
    canvas.curveTo(cx - 12, cy - 35, cx + 12, cy - 35, cx + 25, cy - 15);
    canvas.strokePath();

    _pathStar(canvas, cx - 145, cy + 120, 22);
    canvas.strokePath();
    _pathStar(canvas, cx + 150, cy + 110, 26);
    canvas.strokePath();
    _pathStar(canvas, cx - 140, cy - 100, 18);
    canvas.strokePath();
    _pathStar(canvas, cx + 145, cy - 110, 24);
    canvas.strokePath();
  }

  // ==========================================
  // 10. DRAWING & CREATIVITY GENERATOR
  // ==========================================
  static Future<Uint8List> generateDrawing(
    GlobalConfig global,
    DrawingConfig config,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final pw.Font boldFont = fonts['bold']!;
    final pw.Font solidFont = fonts['regular']!;
    final pw.Font dashedFont = fonts['dashed']!;
    final double margin = global.marginMm * mmToPt;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(margin),
        build: (context) {
          final PdfFont pdfBoldFont = boldFont.getFont(context);
          final PdfFont pdfSolidFont = solidFont.getFont(context);
          final PdfFont pdfDashedFont = dashedFont.getFont(context);
          final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
          final double headerHeight = global.showHeader ? 75.0 : 0.0;
          final double printableHeight =
              PdfPageFormat.a4.height - 2 * margin - headerHeight - 12.0;

          String titleText = "Drawing & Creativity Practice";
          if (config.activityMode == DrawingActivityMode.finishSymmetry) {
            titleText = "Finish the Drawing (Grid Symmetry)";
          } else if (config.activityMode == DrawingActivityMode.stepByStep) {
            titleText = "Step-by-Step Drawing Guide";
          } else if (config.activityMode == DrawingActivityMode.storyPrompt) {
            titleText = "Draw & Write Story Prompt";
          } else if (config.activityMode == DrawingActivityMode.dotToDot) {
            titleText = "Dot-to-Dot Number Connect";
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(global, boldFont, titleText),
              if (global.showHeader) pw.SizedBox(height: 8),
              pw.Container(
                width: printableWidth,
                height: printableHeight,
                child: pw.CustomPaint(
                  size: PdfPoint(printableWidth, printableHeight),
                  painter: (canvas, size) {
                    if (config.activityMode ==
                        DrawingActivityMode.finishSymmetry) {
                      _drawFinishSymmetryPage(
                        canvas,
                        size,
                        config,
                        pdfSolidFont,
                      );
                    } else if (config.activityMode ==
                        DrawingActivityMode.stepByStep) {
                      _drawStepByStepPage(
                        canvas,
                        size,
                        config,
                        pdfSolidFont,
                        pdfBoldFont,
                      );
                    } else if (config.activityMode ==
                        DrawingActivityMode.storyPrompt) {
                      _drawStoryPromptPage(
                        canvas,
                        size,
                        config,
                        pdfSolidFont,
                        pdfBoldFont,
                        pdfDashedFont,
                      );
                    } else if (config.activityMode ==
                        DrawingActivityMode.dotToDot) {
                      _drawDotToDotPage(
                        canvas,
                        size,
                        config,
                        pdfSolidFont,
                        pdfBoldFont,
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static void _drawFinishSymmetryPage(
    PdfGraphics canvas,
    PdfPoint size,
    DrawingConfig config,
    PdfFont font,
  ) {
    _drawText(
      canvas,
      font,
      13.0,
      "Complete the picture by drawing the matching right side on the grid.",
      0,
      size.y - 20,
    );

    final int gridN = config.gridSize;
    final double gridW = 340.0;
    final double gridH = 340.0;
    final double cellW = gridW / gridN;
    final double cellH = gridH / gridN;

    final double startX = (size.x - gridW) / 2.0;
    final double startY = (size.y - gridH) / 2.0 - 20.0;
    final double midX = startX + gridW / 2.0;

    // Draw Grid Lines
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey300);
    canvas.setLineWidth(0.8);

    for (int i = 0; i <= gridN; i++) {
      final x = startX + i * cellW;
      canvas.moveTo(x, startY);
      canvas.lineTo(x, startY + gridH);
      canvas.strokePath();

      final y = startY + i * cellH;
      canvas.moveTo(startX, y);
      canvas.lineTo(startX + gridW, y);
      canvas.strokePath();
    }
    canvas.restoreContext();

    // Mirror Axis
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey700);
    canvas.setLineWidth(1.8);
    canvas.setLineDashPattern([4, 4]);
    canvas.moveTo(midX, startY - 10);
    canvas.lineTo(midX, startY + gridH + 10);
    canvas.strokePath();
    canvas.restoreContext();

    // Draw Left Half Template (e.g. House/Robot)
    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.black);
    canvas.setLineWidth(2.2);

    // Left Roof
    canvas.moveTo(midX, startY + gridH - cellH * 1.5);
    canvas.lineTo(startX + cellW * 1.5, startY + gridH - cellH * 3.5);
    canvas.lineTo(startX + cellW * 1.5, startY + cellH * 1.5);
    canvas.lineTo(midX, startY + cellH * 1.5);
    canvas.strokePath();

    // Left Window
    canvas.drawRect(
      startX + cellW * 2.5,
      startY + cellH * 4.0,
      cellW * 1.5,
      cellH * 1.5,
    );
    canvas.strokePath();
    canvas.restoreContext();

    // Draw Right Side Guide Dots for Children
    canvas.saveContext();
    canvas.setFillColor(PdfColors.grey500);
    for (int r = 1; r < gridN; r++) {
      for (int c = (gridN ~/ 2) + 1; c < gridN; c++) {
        final dotX = startX + c * cellW;
        final dotY = startY + r * cellH;
        canvas.drawEllipse(dotX, dotY, 2.5, 2.5);
        canvas.fillPath();
      }
    }
    canvas.restoreContext();
  }

  static void _drawStepByStepPage(
    PdfGraphics canvas,
    PdfPoint size,
    DrawingConfig config,
    PdfFont font,
    PdfFont boldFont,
  ) {
    _drawText(
      canvas,
      font,
      13.0,
      "Follow the 4 steps to draw a ${config.stepSubject.toUpperCase()} below!",
      0,
      size.y - 20,
    );

    const int steps = 4;
    final double boxW = (size.x - 30) / steps;
    const double boxH = 110.0;
    final double topY = size.y - 145.0;

    for (int i = 0; i < steps; i++) {
      final x = i * (boxW + 10);

      // Step Box Container
      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey400);
      canvas.setLineWidth(1.2);
      canvas.drawRect(x, topY, boxW, boxH);
      canvas.strokePath();

      // Step Label
      canvas.setFillColor(PdfColors.black);
      canvas.drawString(boldFont, 10, "Step ${i + 1}", x + 8, topY + boxH - 15);
      canvas.restoreContext();

      // Progressive Drawing Content inside step box
      final cx = x + boxW / 2.0;
      final cy = topY + boxH / 2.0 - 5.0;

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.black);
      canvas.setLineWidth(1.5);

      if (i >= 0) {
        // Step 1: Head circle
        canvas.drawEllipse(cx, cy + 10, 20, 20);
        canvas.strokePath();
      }
      if (i >= 1) {
        // Step 2: Ears & Body
        canvas.moveTo(cx - 15, cy + 25);
        canvas.lineTo(cx - 22, cy + 40);
        canvas.lineTo(cx - 8, cy + 28);
        canvas.strokePath();

        canvas.moveTo(cx + 15, cy + 25);
        canvas.lineTo(cx + 22, cy + 40);
        canvas.lineTo(cx + 8, cy + 28);
        canvas.strokePath();

        canvas.drawEllipse(cx, cy - 20, 25, 18);
        canvas.strokePath();
      }
      if (i >= 2) {
        // Step 3: Face details
        canvas.drawEllipse(cx - 7, cy + 14, 2, 3);
        canvas.fillPath();
        canvas.drawEllipse(cx + 7, cy + 14, 2, 3);
        canvas.fillPath();
        canvas.drawEllipse(cx, cy + 5, 4, 3);
        canvas.strokePath();
      }
      if (i >= 3) {
        // Step 4: Tail & Whiskers
        canvas.moveTo(cx - 20, cy + 5);
        canvas.lineTo(cx - 35, cy + 8);
        canvas.moveTo(cx + 20, cy + 5);
        canvas.lineTo(cx + 35, cy + 8);
        canvas.strokePath();

        canvas.moveTo(cx + 20, cy - 25);
        canvas.curveTo(cx + 40, cy - 10, cx + 40, cy - 40, cx + 25, cy - 35);
        canvas.strokePath();
      }
      canvas.restoreContext();
    }

    // Large Bottom Practice Box
    final double bottomY = 15.0;
    final double practiceH = topY - bottomY - 15.0;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.black);
    canvas.setLineWidth(1.8);
    canvas.drawRect(0, bottomY, size.x, practiceH);
    canvas.strokePath();

    canvas.setFillColor(PdfColors.grey600);
    canvas.drawString(
      boldFont,
      12,
      "Draw Your ${config.stepSubject.toUpperCase()} Here!",
      15,
      bottomY + practiceH - 22,
    );
    canvas.restoreContext();
  }

  static void _drawStoryPromptPage(
    PdfGraphics canvas,
    PdfPoint size,
    DrawingConfig config,
    PdfFont font,
    PdfFont boldFont,
    PdfFont dashedFont,
  ) {
    // Top Prompt Box
    final double promptH = 50.0;
    final double promptY = size.y - promptH;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.grey500);
    canvas.setLineWidth(1.2);
    canvas.setFillColor(PdfColors.grey100);
    canvas.drawRect(0, promptY, size.x, promptH);
    canvas.fillAndStrokePath();

    canvas.setFillColor(PdfColors.black);
    canvas.drawString(boldFont, 13, config.storyPromptText, 14, promptY + 20);
    canvas.restoreContext();

    // Drawing Canvas Box
    final double drawH = size.y * 0.50;
    final double drawY = promptY - drawH - 15.0;

    canvas.saveContext();
    canvas.setStrokeColor(PdfColors.black);
    canvas.setLineWidth(1.8);
    canvas.drawRect(0, drawY, size.x, drawH);
    canvas.strokePath();

    canvas.setFillColor(PdfColors.grey500);
    canvas.drawString(
      boldFont,
      11,
      "DRAW YOUR PICTURE",
      14,
      drawY + drawH - 20,
    );
    canvas.restoreContext();

    // Handwriting Guidelines for Writing Story Below
    final double linesStartY = drawY - 25.0;
    const double rowH = 35.0;
    const int storyRows = 4;

    for (int r = 0; r < storyRows; r++) {
      final y = linesStartY - r * (rowH + 12.0);

      canvas.saveContext();
      // Baseline
      canvas.setStrokeColor(PdfColors.black);
      canvas.setLineWidth(1.0);
      canvas.moveTo(0, y);
      canvas.lineTo(size.x, y);
      canvas.strokePath();

      // Midline (dashed)
      canvas.setStrokeColor(PdfColors.blueGrey);
      canvas.setLineWidth(0.8);
      canvas.setLineDashPattern([3, 3]);
      canvas.moveTo(0, y + rowH * 0.5);
      canvas.lineTo(size.x, y + rowH * 0.5);
      canvas.strokePath();

      // Top line
      canvas.setStrokeColor(PdfColors.grey400);
      canvas.setLineWidth(0.8);
      canvas.moveTo(0, y + rowH);
      canvas.lineTo(size.x, y + rowH);
      canvas.strokePath();

      canvas.restoreContext();
    }
  }

  static void _drawDotToDotPage(
    PdfGraphics canvas,
    PdfPoint size,
    DrawingConfig config,
    PdfFont font,
    PdfFont boldFont,
  ) {
    _drawText(
      canvas,
      font,
      13.0,
      "Connect the dots in order from 1 to ${config.dotCount} to reveal the picture!",
      0,
      size.y - 20,
    );

    final int dotsCount = config.dotCount;
    final List<PdfPoint> dotPoints = [];
    final double cx = size.x / 2.0;
    final double cy = size.y / 2.0 - 20.0;
    final double r = 160.0;

    for (int i = 0; i < dotsCount; i++) {
      final double angle = (2 * math.pi * i / dotsCount) - (math.pi / 2);
      final double px = cx + r * math.cos(angle);
      final double py = cy + r * math.sin(angle);
      dotPoints.add(PdfPoint(px, py));
    }

    // Draw Dots and Numbers
    for (int i = 0; i < dotsCount; i++) {
      final pt = dotPoints[i];
      final int number = i + 1;

      canvas.saveContext();
      // Dot
      canvas.setFillColor(PdfColors.black);
      canvas.drawEllipse(pt.x, pt.y, 4.0, 4.0);
      canvas.fillPath();

      // Label number slightly offset outward
      final double angle = (2 * math.pi * i / dotsCount) - (math.pi / 2);
      final double labelX = pt.x + 14 * math.cos(angle) - 4;
      final double labelY = pt.y + 14 * math.sin(angle) - 4;

      canvas.drawString(boldFont, 12, "$number", labelX, labelY);
      canvas.restoreContext();

      // Start Badge on Dot 1
      if (number == 1) {
        canvas.saveContext();
        canvas.setFillColor(PdfColors.green700);
        canvas.drawString(boldFont, 10, "START (1)", pt.x - 22, pt.y + 12);
        canvas.restoreContext();
      }
    }
  }
}
