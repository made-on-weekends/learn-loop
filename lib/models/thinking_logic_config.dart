enum ThinkingLogicType {
  patternCompletion,
  whatComesNext,
  itemMatching,
  sameVsDifferent,
  sizeOrdering,
}

extension ThinkingLogicTypeExtension on ThinkingLogicType {
  String get label {
    switch (this) {
      case ThinkingLogicType.patternCompletion:
        return 'Pattern Completion (AB, AAB, ABC)';
      case ThinkingLogicType.whatComesNext:
        return 'What Comes Next?';
      case ThinkingLogicType.itemMatching:
        return 'Two-Column Matching';
      case ThinkingLogicType.sameVsDifferent:
        return 'Same vs. Different';
      case ThinkingLogicType.sizeOrdering:
        return 'Size Ordering & Comparison';
    }
  }

  String get description {
    switch (this) {
      case ThinkingLogicType.patternCompletion:
        return 'Identify repeating patterns and draw or circle the missing element.';
      case ThinkingLogicType.whatComesNext:
        return 'Observe row sequence progression and predict the next item.';
      case ThinkingLogicType.itemMatching:
        return 'Draw lines connecting matching items between left and right columns.';
      case ThinkingLogicType.sameVsDifferent:
        return 'Compare items in each row to find the matching or different object.';
      case ThinkingLogicType.sizeOrdering:
        return 'Compare item sizes and arrange from smallest to largest or circle target size.';
    }
  }
}

enum PatternType { ab, aab, abb, abc, aabb }

extension PatternTypeExtension on PatternType {
  String get label {
    switch (this) {
      case PatternType.ab:
        return 'AB Pattern (Star, Circle, Star, Circle...)';
      case PatternType.aab:
        return 'AAB Pattern (Star, Star, Circle...)';
      case PatternType.abb:
        return 'ABB Pattern (Star, Circle, Circle...)';
      case PatternType.abc:
        return 'ABC Pattern (Star, Circle, Square...)';
      case PatternType.aabb:
        return 'AABB Pattern (Star, Star, Circle, Circle...)';
    }
  }

  List<String> generateSequence(List<String> pool, int length) {
    if (pool.isEmpty) return List.filled(length, 'star');
    final String a = pool[0];
    final String b = pool.length > 1 ? pool[1] : pool[0];
    final String c = pool.length > 2 ? pool[2] : pool[0];

    final result = <String>[];
    while (result.length < length) {
      switch (this) {
        case PatternType.ab:
          result.addAll([a, b]);
          break;
        case PatternType.aab:
          result.addAll([a, a, b]);
          break;
        case PatternType.abb:
          result.addAll([a, b, b]);
          break;
        case PatternType.abc:
          result.addAll([a, b, c]);
          break;
        case PatternType.aabb:
          result.addAll([a, a, b, b]);
          break;
      }
    }
    return result.sublist(0, length);
  }
}

enum MatchingTheme { shapes, shadowMatch, animalBabyMatch, habitatMatch }

class ThinkingLogicConfig {
  ThinkingLogicType activityType;
  PatternType patternType;
  MatchingTheme matchingTheme;
  int rowCount;
  int seed;

  ThinkingLogicConfig({
    this.activityType = ThinkingLogicType.patternCompletion,
    this.patternType = PatternType.ab,
    this.matchingTheme = MatchingTheme.shapes,
    this.rowCount = 5,
    int? seed,
  }) : seed = seed ?? 58392;

  void applyPreset(ThinkingLogicType type) {
    activityType = type;
    switch (type) {
      case ThinkingLogicType.patternCompletion:
        patternType = PatternType.ab;
        rowCount = 5;
        break;
      case ThinkingLogicType.whatComesNext:
        patternType = PatternType.abc;
        rowCount = 5;
        break;
      case ThinkingLogicType.itemMatching:
        matchingTheme = MatchingTheme.shapes;
        rowCount = 5;
        break;
      case ThinkingLogicType.sameVsDifferent:
        rowCount = 5;
        break;
      case ThinkingLogicType.sizeOrdering:
        rowCount = 4;
        break;
    }
  }
}
