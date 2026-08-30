enum HandwritingLineStyle {
  twoLine,
  twoLineSeparated,
  threeLine,
  threeLineSeparated,
}

class HandwritingStyleDefinition {
  final HandwritingLineStyle id;
  final String label;
  final String rawValue;
  final int lineCount; // 2 or 3
  final bool hasMiddleGuide;
  final bool hasSeparator;
  final bool sharedBoundary;

  const HandwritingStyleDefinition({
    required this.id,
    required this.label,
    required this.rawValue,
    required this.lineCount,
    required this.hasMiddleGuide,
    required this.hasSeparator,
    required this.sharedBoundary,
  });
}

extension HandwritingLineStyleExtension on HandwritingLineStyle {
  String get rawValue {
    switch (this) {
      case HandwritingLineStyle.twoLine:
        return 'two-line';
      case HandwritingLineStyle.twoLineSeparated:
        return 'two-line-separated';
      case HandwritingLineStyle.threeLine:
        return 'three-line';
      case HandwritingLineStyle.threeLineSeparated:
        return 'three-line-separated';
    }
  }

  String get label {
    switch (this) {
      case HandwritingLineStyle.twoLine:
        return '2 Lines — No Separator';
      case HandwritingLineStyle.twoLineSeparated:
        return '2 Lines — With Separator';
      case HandwritingLineStyle.threeLine:
        return '3 Lines — No Separator';
      case HandwritingLineStyle.threeLineSeparated:
        return '3 Lines — With Separator';
    }
  }

  HandwritingStyleDefinition get definition {
    switch (this) {
      case HandwritingLineStyle.twoLine:
        return const HandwritingStyleDefinition(
          id: HandwritingLineStyle.twoLine,
          label: '2 Lines — No Separator',
          rawValue: 'two-line',
          lineCount: 2,
          hasMiddleGuide: false,
          hasSeparator: false,
          sharedBoundary: true,
        );
      case HandwritingLineStyle.twoLineSeparated:
        return const HandwritingStyleDefinition(
          id: HandwritingLineStyle.twoLineSeparated,
          label: '2 Lines — With Separator',
          rawValue: 'two-line-separated',
          lineCount: 2,
          hasMiddleGuide: false,
          hasSeparator: true,
          sharedBoundary: false,
        );
      case HandwritingLineStyle.threeLine:
        return const HandwritingStyleDefinition(
          id: HandwritingLineStyle.threeLine,
          label: '3 Lines — No Separator',
          rawValue: 'three-line',
          lineCount: 3,
          hasMiddleGuide: true,
          hasSeparator: false,
          sharedBoundary: true,
        );
      case HandwritingLineStyle.threeLineSeparated:
        return const HandwritingStyleDefinition(
          id: HandwritingLineStyle.threeLineSeparated,
          label: '3 Lines — With Separator',
          rawValue: 'three-line-separated',
          lineCount: 3,
          hasMiddleGuide: true,
          hasSeparator: true,
          sharedBoundary: false,
        );
    }
  }

  static HandwritingLineStyle fromRawValue(String value) {
    switch (value) {
      case 'two-line':
        return HandwritingLineStyle.twoLine;
      case 'two-line-separated':
        return HandwritingLineStyle.twoLineSeparated;
      case 'three-line':
        return HandwritingLineStyle.threeLine;
      case 'three-line-separated':
      default:
        return HandwritingLineStyle.threeLineSeparated;
    }
  }
}
