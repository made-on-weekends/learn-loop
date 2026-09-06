import 'kid_profile.dart';
import 'handwriting_line_style.dart';
import '../services/handwriting_defaults_resolver.dart';

enum HandwritingSource {
  alphabetUpper,
  alphabetLower,
  alphabetBoth,
  numbers,
  caseMatching,
  alphabetSequence,
  beginningSounds,
  cvcWords,
  sightWords,
  customText,
}

enum PracticeMode { tracing, copy }

enum PracticeDirection { row, column }

enum GradeLevel { kindergarten, grade1, grade2, grade3, custom }

enum GuidelineColorScheme { zanerBloser, monochrome }

extension GradeLevelExtension on GradeLevel {
  String get label {
    switch (this) {
      case GradeLevel.kindergarten:
        return "Kindergarten (Ages 4–6) • 1.00\" Line";
      case GradeLevel.grade1:
        return "Grade 1 (Ages 6–7) • 5/8\" (0.625\") Line";
      case GradeLevel.grade2:
        return "Grade 2 (Ages 7–8) • 1/2\" (0.50\") Line";
      case GradeLevel.grade3:
        return "Grade 3 (Ages 8–9) • 3/8\" (0.375\") Line";
      case GradeLevel.custom:
        return "Custom Size";
    }
  }

  double get writingHeightInches {
    switch (this) {
      case GradeLevel.kindergarten:
        return 1.00;
      case GradeLevel.grade1:
        return 0.625;
      case GradeLevel.grade2:
        return 0.50;
      case GradeLevel.grade3:
        return 0.375;
      case GradeLevel.custom:
        return 0.50;
    }
  }

  double get defaultWritingHeightPt => writingHeightInches * 72.0;

  KidGrade toKidGrade() {
    switch (this) {
      case GradeLevel.kindergarten:
        return KidGrade.kindergarten;
      case GradeLevel.grade1:
        return KidGrade.grade1;
      case GradeLevel.grade2:
        return KidGrade.grade2;
      case GradeLevel.grade3:
        return KidGrade.grade3Plus;
      case GradeLevel.custom:
        return KidGrade.kindergarten;
    }
  }
}

class HandwritingConfig {
  HandwritingSource source;
  int numberStart;
  int numberEnd;
  String alphabetStart;
  String alphabetEnd;
  String customText;
  PracticeMode mode;
  PracticeDirection direction;
  bool dottedFont;
  bool cvcMissingVowel;
  int? seed;

  // Grade level preset & guidelines config
  GradeLevel gradeLevel;
  GuidelineColorScheme colorScheme;
  bool showTopLine;
  bool showMidLine;
  bool showBaseLine;
  bool showBottomLine;
  bool showRedMarginLine;

  double fontSize;

  // Overrides for unified profile system
  HandwritingLineStyle? lineStyleOverride;
  double? rowHeightMmOverride;

  // Conversion constant: 1 mm = 72 / 25.4 pt
  static const double mmToPt = 72.0 / 25.4;
  // Visual cap height ratio for PrintClearly/PrintDashed is 0.65
  static const double fontCapHeightRatio = 0.65;
  static const double fontAscentRatio = 0.65;
  // Font baseline upward offset ratio to align bottom of glyphs with baseline
  static const double fontBaselineOffsetRatio = 0.045;

  HandwritingConfig({
    this.source = HandwritingSource.alphabetUpper,
    this.numberStart = 1,
    this.numberEnd = 10,
    this.alphabetStart = "A",
    this.alphabetEnd = "Z",
    this.customText = "HELLO\nWORLD",
    this.mode = PracticeMode.tracing,
    this.direction = PracticeDirection.row,
    this.dottedFont = true,
    this.cvcMissingVowel = false,
    this.seed,
    this.gradeLevel = GradeLevel.kindergarten,
    this.colorScheme = GuidelineColorScheme.zanerBloser,
    this.showTopLine = true,
    this.showMidLine = true,
    this.showBaseLine = true,
    this.showBottomLine = false,
    this.showRedMarginLine = true,
    this.lineStyleOverride,
    this.rowHeightMmOverride,
    double? fontSize,
  }) : fontSize = fontSize ?? GradeLevel.kindergarten.defaultWritingHeightPt;

  // Canonical resolvers
  HandwritingLineStyle getEffectiveLineStyle(KidProfile kidProfile) {
    if (lineStyleOverride != null) {
      return lineStyleOverride!;
    }
    return HandwritingDefaultsResolver.resolve(
      kidProfile: kidProfile,
    ).lineStyle;
  }

  double getEffectiveRowHeightMm(KidProfile kidProfile) {
    if (rowHeightMmOverride != null) {
      return rowHeightMmOverride!;
    }
    return HandwritingDefaultsResolver.resolve(
      kidProfile: kidProfile,
    ).rowHeightMm;
  }

  double getEffectiveRowHeightPt(KidProfile kidProfile) {
    return getEffectiveRowHeightMm(kidProfile) * mmToPt;
  }

  // Row height is split into equal guideline bands: writing area (2/4 = 0.5) and descender/separator space (2/4 = 0.5)
  double getEffectiveWritingHeightPt(KidProfile kidProfile) {
    return getEffectiveRowHeightPt(kidProfile) * 0.5;
  }

  double getEffectiveDescenderBufferPt(KidProfile kidProfile) {
    return getEffectiveRowHeightPt(kidProfile) * 0.5;
  }

  double getEffectiveFontSizePt(KidProfile kidProfile) {
    return getEffectiveWritingHeightPt(kidProfile) / fontCapHeightRatio;
  }

  double getEffectiveMidlineFromBaselinePt(KidProfile kidProfile) {
    return getEffectiveWritingHeightPt(kidProfile) * 0.5;
  }

  // Backward compatibility getters for legacy code/tests
  void applyGradePreset(GradeLevel grade) {
    gradeLevel = grade;
    if (grade != GradeLevel.custom) {
      final kidGrade = grade.toKidGrade();
      final defaults = HandwritingDefaultsResolver.resolve(grade: kidGrade);
      lineStyleOverride = defaults.lineStyle;
      rowHeightMmOverride = defaults.rowHeightMm;
      fontSize = grade.defaultWritingHeightPt;
    }
  }

  double get effectiveWritingHeightPt => gradeLevel == GradeLevel.custom
      ? fontSize
      : gradeLevel.defaultWritingHeightPt;

  double get effectiveFontSizePt =>
      effectiveWritingHeightPt / fontCapHeightRatio;

  double get effectiveMidlineFromBaselinePt => effectiveWritingHeightPt * 0.5;

  double get effectiveDescenderBufferPt => effectiveWritingHeightPt * 0.5;

  double get effectiveTotalRowHeightPt =>
      effectiveWritingHeightPt + effectiveDescenderBufferPt;

  void resetOverrides() {
    lineStyleOverride = null;
    rowHeightMmOverride = null;
  }
}
