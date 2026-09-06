import 'package:flutter/material.dart';
import '../models/handwriting_line_style.dart';

class LineStyleSelector extends StatefulWidget {
  final HandwritingLineStyle selectedStyle;
  final ValueChanged<HandwritingLineStyle> onStyleSelected;

  const LineStyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleSelected,
  });

  @override
  State<LineStyleSelector> createState() => _LineStyleSelectorState();
}

class _LineStyleSelectorState extends State<LineStyleSelector> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDef = widget.selectedStyle.definition;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant,
          width: _isExpanded ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Style Summary Header (Tap to Expand / Collapse)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.format_line_spacing,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedDef.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              selectedDef.hasMiddleGuide
                                  ? (selectedDef.hasSeparator
                                        ? "3-line system with midline guide & descender space"
                                        : "3-line continuous system with midline guide")
                                  : (selectedDef.hasSeparator
                                        ? "2-line headline & baseline with descender space"
                                        : "2-line simple headline & baseline"),
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.65,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        icon: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                        ),
                        label: Text(
                          _isExpanded ? "Collapse" : "Change",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Large Preview for Selected Style
                  Container(
                    height: 52,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: CustomPaint(
                      painter: _ExpandedLineStylePainter(
                        definition: selectedDef,
                        primaryColor: theme.colorScheme.primary,
                        textColor: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Visual List of All 4 Styles
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                    child: Text(
                      "Select Line Style (Large Visual Preview):",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ...HandwritingLineStyle.values.map((style) {
                    final isSelected = style == widget.selectedStyle;
                    final def = style.definition;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: InkWell(
                        onTap: () {
                          widget.onStyleSelected(style);
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.06,
                                  )
                                : theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 18,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      def.label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                                .withValues(alpha: 0.15)
                                          : theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      def.hasSeparator
                                          ? "With Descender Gap"
                                          : "Continuous Shared",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Expanded generous preview canvas
                              Container(
                                height: 56,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: _ExpandedLineStylePainter(
                                    definition: def,
                                    primaryColor: theme.colorScheme.primary,
                                    textColor: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpandedLineStylePainter extends CustomPainter {
  final HandwritingStyleDefinition definition;
  final Color primaryColor;
  final Color textColor;

  _ExpandedLineStylePainter({
    required this.definition,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color =
          const Color(0xFFEF4444) // Red Headline
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final basePaint = Paint()
      ..color =
          const Color(0xFF1E293B) // Dark Baseline
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final midPaint = Paint()
      ..color =
          const Color(0xFF3B82F6) // Blue Midline
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final sepPaint = Paint()
      ..color =
          const Color(0xFF94A3B8) // Slate Separator
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final totalHeight = size.height;

    if (definition.sharedBoundary) {
      // 2 rows sharing boundaries
      final rowHeight = totalHeight / 2.0;

      // Row 1
      const r1Top = 4.0;
      final r1Base = r1Top + rowHeight - 4.0;
      final r1Mid = (r1Top + r1Base) / 2.0;

      // Row 2 (Top line of Row 2 = Base line of Row 1)
      final r2Base = r1Base + rowHeight - 4.0;
      final r2Mid = (r1Base + r2Base) / 2.0;

      // Draw Row 1 Top line
      canvas.drawLine(const Offset(0, r1Top), Offset(width, r1Top), guidePaint);

      // Midlines if 3-line
      if (definition.hasMiddleGuide) {
        _drawDashedLine(
          canvas,
          Offset(0, r1Mid),
          Offset(width, r1Mid),
          midPaint,
          dashWidth: 4,
          dashSpace: 3,
        );
        _drawDashedLine(
          canvas,
          Offset(0, r2Mid),
          Offset(width, r2Mid),
          midPaint,
          dashWidth: 4,
          dashSpace: 3,
        );
      }

      // Shared line between Row 1 and Row 2
      canvas.drawLine(Offset(0, r1Base), Offset(width, r1Base), basePaint);

      // Row 2 Bottom line
      canvas.drawLine(Offset(0, r2Base), Offset(width, r2Base), basePaint);
    } else {
      // Separated rows with equal gaps between all lines (top, mid, base, sep)
      const marginY = 4.0;
      final band = (totalHeight - 2 * marginY) / 6.0;

      // Row 1
      final r1Top = marginY;
      final r1Mid = r1Top + band;
      final r1Base = r1Top + 2 * band;

      // Separator Line
      final sepY = r1Top + 3 * band;

      // Row 2
      final r2Top = r1Top + 4 * band;
      final r2Mid = r1Top + 5 * band;
      final r2Base = r1Top + 6 * band;

      // Draw Row 1
      canvas.drawLine(Offset(0, r1Top), Offset(width, r1Top), guidePaint);
      if (definition.hasMiddleGuide) {
        _drawDashedLine(
          canvas,
          Offset(0, r1Mid),
          Offset(width, r1Mid),
          midPaint,
          dashWidth: 4,
          dashSpace: 3,
        );
      }
      canvas.drawLine(Offset(0, r1Base), Offset(width, r1Base), basePaint);

      // Draw Separator Line (dotted line)
      _drawDashedLine(
        canvas,
        Offset(0, sepY),
        Offset(width, sepY),
        sepPaint,
        dashWidth: 3,
        dashSpace: 3,
      );

      // Draw Row 2
      canvas.drawLine(Offset(0, r2Top), Offset(width, r2Top), guidePaint);
      if (definition.hasMiddleGuide) {
        _drawDashedLine(
          canvas,
          Offset(0, r2Mid),
          Offset(width, r2Mid),
          midPaint,
          dashWidth: 4,
          dashSpace: 3,
        );
      }
      canvas.drawLine(Offset(0, r2Base), Offset(width, r2Base), basePaint);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint, {
    double dashWidth = 4,
    double dashSpace = 3,
  }) {
    final maxDistance = (p2 - p1).distance;
    final direction = (p2 - p1) / maxDistance;
    double currentDistance = 0.0;

    while (currentDistance < maxDistance) {
      final start = p1 + direction * currentDistance;
      final end =
          p1 +
          direction *
              (currentDistance + dashWidth < maxDistance
                  ? currentDistance + dashWidth
                  : maxDistance);
      canvas.drawLine(start, end, paint);
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _ExpandedLineStylePainter oldDelegate) {
    return oldDelegate.definition != definition ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.textColor != textColor;
  }
}
