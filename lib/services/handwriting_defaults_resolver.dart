import '../models/kid_profile.dart';
import '../models/handwriting_line_style.dart';

class HandwritingDefaults {
  final HandwritingLineStyle lineStyle;
  final double rowHeightMm;

  const HandwritingDefaults({
    required this.lineStyle,
    required this.rowHeightMm,
  });
}

class HandwritingDefaultsResolver {
  static const HandwritingDefaults fallbackDefaults = HandwritingDefaults(
    lineStyle: HandwritingLineStyle.threeLine,
    rowHeightMm: 14.0,
  );

  static HandwritingDefaults resolve({
    KidProfile? kidProfile,
    KidGrade? grade,
    int? age,
  }) {
    final effectiveGrade = grade ?? kidProfile?.grade;
    final effectiveAge = age ?? kidProfile?.age;

    // 1. Grade-based resolution (Primary)
    if (effectiveGrade != null) {
      switch (effectiveGrade) {
        case KidGrade.playgroup:
          return const HandwritingDefaults(
            lineStyle: HandwritingLineStyle.twoLineSeparated,
            rowHeightMm: 20.0,
          );
        case KidGrade.preschool:
          return const HandwritingDefaults(
            lineStyle: HandwritingLineStyle.twoLineSeparated,
            rowHeightMm: 18.0,
          );
        case KidGrade.nursery:
          return const HandwritingDefaults(
            lineStyle: HandwritingLineStyle.threeLineSeparated,
            rowHeightMm: 17.0,
          );
        case KidGrade.kindergarten:
          return const HandwritingDefaults(
            lineStyle: HandwritingLineStyle.threeLine,
            rowHeightMm: 14.0,
          );
        case KidGrade.homeschool:
          return const HandwritingDefaults(
            lineStyle: HandwritingLineStyle.threeLine,
            rowHeightMm: 14.0,
          );
        case KidGrade.grade1:
          return const HandwritingDefaults(
            lineStyle: HandwritingLineStyle.threeLine,
            rowHeightMm: 12.0,
          );
        case KidGrade.grade2:
          return const HandwritingDefaults(
            lineStyle: HandwritingLineStyle.threeLine,
            rowHeightMm: 10.5,
          );
        case KidGrade.grade3Plus:
          return const HandwritingDefaults(
            lineStyle: HandwritingLineStyle.threeLine,
            rowHeightMm: 9.0,
          );
      }
    }

    // 2. Age-based resolution (Secondary)
    if (effectiveAge != null) {
      if (effectiveAge <= 3) {
        return const HandwritingDefaults(
          lineStyle: HandwritingLineStyle.twoLineSeparated,
          rowHeightMm: 20.0,
        );
      } else if (effectiveAge == 4) {
        return const HandwritingDefaults(
          lineStyle: HandwritingLineStyle.threeLineSeparated,
          rowHeightMm: 17.0,
        );
      } else if (effectiveAge == 5) {
        return const HandwritingDefaults(
          lineStyle: HandwritingLineStyle.threeLine,
          rowHeightMm: 14.0,
        );
      } else if (effectiveAge == 6) {
        return const HandwritingDefaults(
          lineStyle: HandwritingLineStyle.threeLine,
          rowHeightMm: 12.0,
        );
      } else if (effectiveAge == 7) {
        return const HandwritingDefaults(
          lineStyle: HandwritingLineStyle.threeLine,
          rowHeightMm: 10.5,
        );
      } else {
        return const HandwritingDefaults(
          lineStyle: HandwritingLineStyle.threeLine,
          rowHeightMm: 9.0,
        );
      }
    }

    // 3. Application fallback
    return fallbackDefaults;
  }
}
