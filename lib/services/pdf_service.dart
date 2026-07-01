import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/global_config.dart';
import '../models/handwriting_config.dart';
import '../models/counting_config.dart';
import '../models/math_config.dart';
import '../models/prewriting_config.dart';
import '../models/shapes_config.dart';

class PdfService {
  // Constants for conversion
  static const double mmToPt = 72.0 / 25.4;

  // Renders the standard header on each A4 page
  static pw.Widget _buildHeader(GlobalConfig global, pw.Font textFont, String sheetTitle) {
    if (!global.showHeader) {
      return pw.SizedBox.shrink();
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              global.title.isNotEmpty ? global.title : sheetTitle,
              style: pw.TextStyle(
                font: textFont,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (global.showNameLine)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      "Name: ______________________",
                      style: pw.TextStyle(font: textFont, fontSize: 11),
                    ),
                  ),
                if (global.showDateLine)
                  pw.Text(
                    "Date: _________________",
                    style: pw.TextStyle(font: textFont, fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1.0, color: PdfColors.grey300),
        pw.SizedBox(height: 12),
      ],
    );
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

    return {
      'regular': regular,
      'dashed': dashed,
      'bold': bold,
    };
  }

  // Helper: generates handwriting items based on settings
  static List<String> _generateHandwritingItems(HandwritingConfig config) {
    switch (config.source) {
      case HandwritingSource.alphabetUpper:
        int startCode = config.alphabetStart.isEmpty ? 65 : config.alphabetStart.toUpperCase().codeUnitAt(0);
        int endCode = config.alphabetEnd.isEmpty ? 90 : config.alphabetEnd.toUpperCase().codeUnitAt(0);
        if (startCode < 65 || startCode > 90) startCode = 65;
        if (endCode < 65 || endCode > 90) endCode = 90;
        if (startCode > endCode) {
          int temp = startCode;
          startCode = endCode;
          endCode = temp;
        }
        return List.generate(endCode - startCode + 1, (index) => String.fromCharCode(startCode + index));
      case HandwritingSource.alphabetLower:
        int startCode = config.alphabetStart.isEmpty ? 97 : config.alphabetStart.toLowerCase().codeUnitAt(0);
        int endCode = config.alphabetEnd.isEmpty ? 122 : config.alphabetEnd.toLowerCase().codeUnitAt(0);
        if (startCode < 97 || startCode > 122) startCode = 97;
        if (endCode < 97 || endCode > 122) endCode = 122;
        if (startCode > endCode) {
          int temp = startCode;
          startCode = endCode;
          endCode = temp;
        }
        return List.generate(endCode - startCode + 1, (index) => String.fromCharCode(startCode + index));
      case HandwritingSource.numbers:
        int start = config.numberStart;
        int end = config.numberEnd;
        if (start > end) {
          int temp = start;
          start = end;
          end = temp;
        }
        return List.generate(end - start + 1, (index) => (start + index).toString());
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
    HandwritingConfig config,
  ) async {
    final pdf = pw.Document();
    final fonts = await _loadFonts();
    final pw.Font solidFont = fonts['regular']!;
    final pw.Font dottedFont = fonts['dashed']!;
    final pw.Font boldFont = fonts['bold']!;

    final double margin = global.marginMm * mmToPt;
    final List<String> items = _generateHandwritingItems(config);
    if (items.isEmpty) return pdf.save();

    final double rowHeight = config.fontSize * 2.2;
    final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
    final double printableHeight = PdfPageFormat.a4.height - 2 * margin - (global.showHeader ? 50 : 0);
    int rowsPerPage = (printableHeight / rowHeight).floor();
    if (rowsPerPage < 1) rowsPerPage = 1;

    final dummyContext = pw.Context(document: pdf.document);
    final PdfFont pdfSolid = solidFont.getFont(dummyContext);
    final PdfFont pdfDotted = dottedFont.getFont(dummyContext);
    final PdfFont measureFont = config.dottedFont ? pdfDotted : pdfSolid;

    if (config.direction == PracticeDirection.row) {
      int itemIndex = 0;

      while (itemIndex < items.length) {
        final List<String> pageItems = [];
        for (int r = 0; r < rowsPerPage && itemIndex < items.length; r++) {
          pageItems.add(items[itemIndex]);
          itemIndex++;
        }

        // Calculate dynamic column sizing
        double maxItemWidth = 0.0;
        for (var item in pageItems) {
          double w = measureFont.stringMetrics(item).size.x * config.fontSize;
          if (w > maxItemWidth) maxItemWidth = w;
        }

        double cellPadding = config.fontSize * 0.8;
        double cellWidth = math.max(maxItemWidth + cellPadding, config.fontSize * 1.8);
        int colsCount = (printableWidth / cellWidth).floor();
        if (colsCount < 1) colsCount = 1;
        cellWidth = printableWidth / colsCount;

        final double capturedCellWidth = cellWidth;
        final int capturedColsCount = colsCount;
        final List<String> capturedPageItems = List.from(pageItems);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(margin),
            build: (context) {
              final PdfFont localSolid = solidFont.getFont(context);
              final PdfFont localDotted = dottedFont.getFont(context);
              final PdfFont localMeasureFont = config.dottedFont ? localDotted : localSolid;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(global, boldFont, "Handwriting Practice"),
                  pw.Column(
                    children: List.generate(capturedPageItems.length, (rIndex) {
                      final String item = capturedPageItems[rIndex];
                      return pw.Row(
                        children: List.generate(capturedColsCount, (cIndex) {
                          bool isEmpty = false;
                          PdfFont font = localMeasureFont;

                          if (config.mode == PracticeMode.copy) {
                            if (cIndex == 0) {
                              isEmpty = false;
                              font = localSolid;
                            } else {
                              isEmpty = true;
                            }
                          } else {
                            isEmpty = false;
                            font = localDotted;
                          }

                          return pw.CustomPaint(
                            size: PdfPoint(capturedCellWidth, rowHeight),
                            painter: (canvas, size) {
                              _drawHandwritingCell(
                                canvas,
                                size,
                                item,
                                font,
                                config.fontSize,
                                isEmpty,
                                config,
                              );
                            },
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
      }
    } else {
      // Column mode
      int itemIndex = 0;

      while (itemIndex < items.length) {
        // Calculate width and cols count
        double maxItemWidth = 0.0;
        int maxCols = (printableWidth / (config.fontSize * 1.8)).floor();
        if (maxCols < 1) maxCols = 1;

        int tempIdx = itemIndex;
        final List<String> scanItems = [];
        for (int c = 0; c < maxCols && tempIdx < items.length; c++) {
          scanItems.add(items[tempIdx]);
          tempIdx++;
        }

        for (var item in scanItems) {
          double w = measureFont.stringMetrics(item).size.x * config.fontSize;
          if (w > maxItemWidth) maxItemWidth = w;
        }

        double cellPadding = config.fontSize * 0.8;
        double cellWidth = math.max(maxItemWidth + cellPadding, config.fontSize * 1.8);
        int colsCount = (printableWidth / cellWidth).floor();
        if (colsCount < 1) colsCount = 1;
        cellWidth = printableWidth / colsCount;

        final List<String> pageItems = [];
        for (int c = 0; c < colsCount && itemIndex < items.length; c++) {
          pageItems.add(items[itemIndex]);
          itemIndex++;
        }

        final double capturedCellWidth = cellWidth;
        final List<String> capturedPageItems = List.from(pageItems);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(margin),
            build: (context) {
              final PdfFont localSolid = solidFont.getFont(context);
              final PdfFont localDotted = dottedFont.getFont(context);
              final PdfFont localMeasureFont = config.dottedFont ? localDotted : localSolid;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(global, boldFont, "Handwriting Practice"),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: List.generate(capturedPageItems.length, (cIndex) {
                      final String item = capturedPageItems[cIndex];
                      return pw.Column(
                        children: List.generate(rowsPerPage, (rIndex) {
                          bool isEmpty = false;
                          PdfFont font = localMeasureFont;

                          if (config.mode == PracticeMode.copy) {
                            if (rIndex == 0) {
                              isEmpty = false;
                              font = localSolid;
                            } else {
                              isEmpty = true;
                            }
                          } else {
                            isEmpty = false;
                            font = localDotted;
                          }

                          return pw.CustomPaint(
                            size: PdfPoint(capturedCellWidth, rowHeight),
                            painter: (canvas, size) {
                              _drawHandwritingCell(
                                canvas,
                                size,
                                item,
                                font,
                                config.fontSize,
                                isEmpty,
                                config,
                              );
                            },
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
      }
    }

    return pdf.save();
  }

  // Draw handwriting lines + text
  static void _drawHandwritingCell(
    PdfGraphics canvas,
    PdfPoint size,
    String text,
    PdfFont font,
    double fontSize,
    bool isEmpty,
    HandwritingConfig config,
  ) {
    final double width = size.x;
    final double height = size.y;

    final double baselineY = height * 0.32;
    final double topLineY = baselineY + fontSize * 0.72;
    final double midLineY = baselineY + fontSize * 0.38;
    final double bottomLineY = baselineY - fontSize * 0.22;

    canvas.saveContext();

    if (config.showTopLine) {
      canvas.setStrokeColor(PdfColors.grey500);
      canvas.setLineWidth(0.5);
      canvas.drawLine(0, topLineY, width, topLineY);
      canvas.strokePath();
    }

    if (config.showMidLine) {
      canvas.setStrokeColor(PdfColors.grey400);
      canvas.setLineWidth(0.5);
      canvas.setLineDashPattern([3, 3], 0);
      canvas.drawLine(0, midLineY, width, midLineY);
      canvas.strokePath();
      canvas.setLineDashPattern([], 0);
    }

    if (config.showBaseLine) {
      canvas.setStrokeColor(PdfColors.grey700);
      canvas.setLineWidth(0.8);
      canvas.drawLine(0, baselineY, width, baselineY);
      canvas.strokePath();
    }

    if (config.showBottomLine) {
      canvas.setStrokeColor(PdfColors.grey500);
      canvas.setLineWidth(0.5);
      canvas.drawLine(0, bottomLineY, width, bottomLineY);
      canvas.strokePath();
    }

    canvas.setStrokeColor(PdfColors.grey300);
    canvas.setLineWidth(0.5);
    canvas.drawLine(width, 0, width, height);
    canvas.strokePath();

    canvas.restoreContext();

    if (!isEmpty && text.isNotEmpty) {
      canvas.saveContext();
      final double textWidth = font.stringMetrics(text).size.x * fontSize;
      final double startX = (width - textWidth) / 2;
      canvas.setFillColor(PdfColors.black);
      canvas.drawString(
        font,
        fontSize,
        text,
        startX,
        baselineY,
      );
      canvas.restoreContext();
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

    final rand = math.Random();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(margin),
        build: (context) {
          final PdfFont pdfSolid = solidFont.getFont(context);

          final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
          final double printableHeight = PdfPageFormat.a4.height - 2 * margin - (global.showHeader ? 50 : 0);

          final int questions = config.questionsPerPage;
          final int rows = (questions / 2).ceil();
          final double rowHeight = printableHeight / rows;
          final double colWidth = printableWidth / 2;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                global,
                boldFont,
                config.activityType == CountingActivityType.countAndWrite
                    ? "Count and Write"
                    : "Draw to Match",
              ),
              pw.Column(
                children: List.generate(rows, (rIndex) {
                  return pw.Row(
                    children: List.generate(2, (cIndex) {
                      final int qIdx = rIndex * 2 + cIndex;
                      if (qIdx >= questions) return pw.SizedBox(width: colWidth, height: rowHeight);

                      final int targetNum = config.minNumber + rand.nextInt(config.maxNumber - config.minNumber + 1);
                      ShapeType shape = config.shapeType;
                      if (shape == ShapeType.random) {
                        final shapes = ShapeType.values.where((e) => e != ShapeType.random).toList();
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

    final double dividerX = width * 0.7;
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
      final double fontSize = height * 0.45;
      final double textWidth = font.stringMetrics(text).size.x * fontSize;
      final double textHeight = font.stringMetrics(text).size.y * fontSize;
      
      final double startX = (dividerX - textWidth) / 2;
      final double startY = (height - textHeight * 0.5) / 2;

      canvas.setFillColor(PdfColors.black);
      canvas.drawString(
        font,
        fontSize,
        text,
        startX,
        startY,
      );
      canvas.restoreContext();

      canvas.saveContext();
      final String instruction = "Draw $count shapes below:";
      final double textW = font.stringMetrics(instruction).size.x * 8.0;
      canvas.setFillColor(PdfColors.grey600);
      canvas.drawString(
        font,
        8.0,
        instruction,
        (dividerX - textW) / 2,
        4.0,
      );
      canvas.restoreContext();

      final double boxW = width - dividerX - 16.0;
      final double boxH = height - 16.0;
      final double bx = dividerX + 8.0;
      final double by = 8.0;

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey500);
      canvas.setLineWidth(1.0);
      canvas.setLineDashPattern([3, 3], 0);
      canvas.drawRect(bx, by, boxW, boxH);
      canvas.strokePath();
      canvas.restoreContext();
    }
  }

  // Draw simple vector shapes
  static void _drawShape(PdfGraphics canvas, ShapeType type, double cx, double cy, double s) {
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
      cx - s * 0.5, cy + s * 0.52,
      cx - s * 0.6, cy - s * 0.08,
      cx, bottomY,
    );
    canvas.curveTo(
      cx + s * 0.6, cy - s * 0.08,
      cx + s * 0.5, cy + s * 0.52,
      cx, topY,
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
    canvas.curveTo(cx - 2, cy + r * 0.6 + 6, cx + 4, cy + r * 0.6 + 8, cx + 6, cy + r * 0.6 + 10);
    canvas.setLineWidth(1.5);
    canvas.strokePath();
    canvas.restoreContext();

    canvas.moveTo(cx + 3, cy + r * 0.6 + 4);
    canvas.curveTo(cx + 6, cy + r * 0.6 + 8, cx + 12, cy + r * 0.6 + 8, cx + 10, cy + r * 0.6 + 3);
    canvas.curveTo(cx + 7, cy + r * 0.6 + 1, cx + 4, cy + r * 0.6 + 2, cx + 3, cy + r * 0.6 + 4);
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
    final pw.Font solidFont = fonts['regular']!;
    final pw.Font boldFont = fonts['bold']!;

    final double margin = global.marginMm * mmToPt;

    final rand = math.Random();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(margin),
        build: (context) {
          final PdfFont pdfSolid = solidFont.getFont(context);

          final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
          final double printableHeight = PdfPageFormat.a4.height - 2 * margin - (global.showHeader ? 50 : 0);

          final int cols = config.columnsCount;
          final int questions = config.questionsCount;
          final int rows = (questions / cols).ceil();
          final double rowHeight = printableHeight / rows;
          final double colWidth = printableWidth / cols;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(global, boldFont, "Math Practice"),
              pw.Column(
                children: List.generate(rows, (rIndex) {
                  return pw.Row(
                    children: List.generate(cols, (cIndex) {
                      final int qIdx = rIndex * cols + cIndex;
                      if (qIdx >= questions) return pw.SizedBox(width: colWidth, height: rowHeight);

                      int num1 = config.minNumber + rand.nextInt(config.maxNumber - config.minNumber + 1);
                      int num2 = config.minNumber + rand.nextInt(config.maxNumber - config.minNumber + 1);

                      MathOperation op = config.operation;
                      if (op == MathOperation.mixed) {
                        op = rand.nextBool() ? MathOperation.addition : MathOperation.subtraction;
                      }

                      if (op == MathOperation.subtraction && num2 > num1) {
                        int temp = num1;
                        num1 = num2;
                        num2 = temp;
                      }

                      return pw.Container(
                        width: colWidth,
                        height: rowHeight,
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.CustomPaint(
                          size: PdfPoint(colWidth - 16, rowHeight - 16),
                          painter: (canvas, size) {
                            _drawMathQuestion(
                              canvas,
                              size,
                              num1,
                              num2,
                              op,
                              config,
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

      _drawCenteredText(canvas, num1.toString(), font, fontSize, equationX, startY + textSpacing);
      _drawCenteredText(canvas, "$opStr   $num2", font, fontSize, equationX, startY);

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.black);
      canvas.setLineWidth(1.5);
      canvas.drawLine(equationX - 25.0, startY - 8.0, equationX + 25.0, startY - 8.0);
      canvas.strokePath();
      canvas.restoreContext();

      final double boxSize = height * 0.18;
      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey800);
      canvas.setLineWidth(1.5);
      canvas.drawRect(equationX - boxSize / 2, startY - 14.0 - boxSize, boxSize, boxSize);
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
        canvas.drawString(
          font,
          6.5,
          label,
          workX + (workW - wLabel) / 2,
          11.0,
        );
        canvas.restoreContext();
      }
    } else {
      final double equationY = height * 0.6;
      final double fontSize = height * 0.22;
      final String problemText = "$num1 $opStr $num2 = ";

      canvas.saveContext();
      canvas.setFillColor(PdfColors.black);
      canvas.drawString(
        font,
        fontSize,
        problemText,
        15.0,
        equationY,
      );
      canvas.restoreContext();

      final double textW = font.stringMetrics(problemText).size.x * fontSize;
      final double boxSize = height * 0.25;
      final double bx = 15.0 + textW + 5.0;
      final double by = equationY - 4.0;

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey800);
      canvas.setLineWidth(1.5);
      canvas.drawRect(bx, by, boxSize, boxSize);
      canvas.strokePath();
      canvas.restoreContext();

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
        canvas.drawString(
          font,
          7.0,
          label,
          rx + 6.0,
          ry + rh - 10.0,
        );
        canvas.restoreContext();
      }
    }
  }

  static void _drawCenteredText(
    PdfGraphics canvas,
    String text,
    PdfFont font,
    double size,
    double cx,
    double cy,
  ) {
    canvas.saveContext();
    final double textWidth = font.stringMetrics(text).size.x * size;
    canvas.setFillColor(PdfColors.black);
    canvas.drawString(
      font,
      size,
      text,
      cx - textWidth / 2,
      cy,
    );
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
          final double printableHeight = PdfPageFormat.a4.height - 2 * margin - (global.showHeader ? 50 : 0);

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

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey800);
      canvas.setLineWidth(1.5);
      canvas.setFillColor(PdfColors.white);
      canvas.drawEllipse(startX - 8, y, 6, 6);
      canvas.strokePath();
      canvas.restoreContext();

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey800);
      canvas.setLineWidth(1.0);
      _pathStar(canvas, endX + 8, y, 8.0);
      canvas.strokePath();
      canvas.restoreContext();

      canvas.saveContext();
      canvas.setStrokeColor(PdfColors.grey700);
      canvas.setLineWidth(config.strokeWidth);

      if (config.isDotted) {
        canvas.setLineDashPattern([3, 3], 0);
      }

      switch (config.pattern) {
        case LinePattern.straight:
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
              midX - segmentW / 4, y + amplitude * direction,
              midX + segmentW / 4, y + amplitude * direction,
              nextX, y,
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
    final pw.Font dashedFont = fonts['dashed']!;
    final pw.Font boldFont = fonts['bold']!;

    final double margin = global.marginMm * mmToPt;
    final List<ShapeDesign> shapes = config.selectedShapes;
    if (shapes.isEmpty) return pdf.save();

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
            final PdfFont pdfSolid = solidFont.getFont(context);
            final PdfFont pdfDashed = dashedFont.getFont(context);

            final double printableWidth = PdfPageFormat.a4.width - 2 * margin;
            final double printableHeight = PdfPageFormat.a4.height - 2 * margin - (global.showHeader ? 50 : 0);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(global, boldFont, "Shapes Learning & Tracing"),
                pw.Expanded(
                  child: pw.GridView(
                    crossAxisCount: 2,
                    childAspectRatio: printableWidth / (printableHeight * 0.95),
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    children: List.generate(pageShapes.length, (index) {
                      final ShapeDesign shape = pageShapes[index];
                      return pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300, width: 1.0),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        ),
                        child: pw.CustomPaint(
                          painter: (canvas, size) {
                            _drawShapeTraceCard(
                              canvas,
                              size,
                              shape,
                              config,
                              pdfSolid,
                              pdfDashed,
                            );
                          },
                        ),
                      );
                    }),
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

  // Draw card containing shape + label
  static void _drawShapeTraceCard(
    PdfGraphics canvas,
    PdfPoint size,
    ShapeDesign shape,
    ShapesConfig config,
    PdfFont solidFont,
    PdfFont dashedFont,
  ) {
    final double width = size.x;
    final double height = size.y;

    final String shapeName = shape.name[0].toUpperCase() + shape.name.substring(1);
    final double nameFontSize = height * 0.12;

    canvas.saveContext();
    final double textWidth = solidFont.stringMetrics(shapeName).size.x * nameFontSize;
    canvas.setFillColor(PdfColors.black);
    canvas.drawString(
      solidFont,
      nameFontSize,
      shapeName,
      (width - textWidth) / 2,
      height - nameFontSize * 1.3,
    );
    canvas.restoreContext();

    final double cx = width / 2;
    final double cy = height * 0.45;
    final double shapeSize = math.min(width * 0.52, height * 0.48);

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
        canvas.drawRect(cx - shapeSize / 2, cy - shapeSize / 2, shapeSize, shapeSize);
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
        canvas.drawRect(cx - shapeSize / 1.5, cy - shapeSize / 2.2, shapeSize * 1.33, shapeSize * 0.9);
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
        default:
          break;
      }
      canvas.restoreContext();
    }

    if (config.showShapeNames) {
      canvas.saveContext();
      final double copyFontSize = height * 0.1;
      final double copyTextW = dashedFont.stringMetrics(shapeName).size.x * copyFontSize;
      canvas.setFillColor(PdfColors.black);
      canvas.drawString(
        dashedFont,
        copyFontSize,
        shapeName,
        (width - copyTextW) / 2,
        copyFontSize * 0.8,
      );
      canvas.restoreContext();
    }
  }

  // Pure trig-based arrow drawing without coordinate transformations
  static void _drawArrow(PdfGraphics canvas, double x, double y, double angleRad) {
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
}
