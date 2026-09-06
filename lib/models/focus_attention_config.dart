enum FocusActivityType {
  findAndCircle,
  targetSearch,
  oddOneOut,
  visualSearchGrid,
  findNObjects,
}

extension FocusActivityTypeExtension on FocusActivityType {
  String get label {
    switch (this) {
      case FocusActivityType.findAndCircle:
        return 'Find & Circle Target';
      case FocusActivityType.targetSearch:
        return 'Letter / Number Scanning';
      case FocusActivityType.oddOneOut:
        return 'Odd One Out';
      case FocusActivityType.visualSearchGrid:
        return 'Visual Search Grid';
      case FocusActivityType.findNObjects:
        return 'Find N Targets';
    }
  }

  String get description {
    switch (this) {
      case FocusActivityType.findAndCircle:
        return 'Search the page and circle every matching target object.';
      case FocusActivityType.targetSearch:
        return 'Scan through rows of letters or numbers to find target characters.';
      case FocusActivityType.oddOneOut:
        return 'Identify the single different object in each row.';
      case FocusActivityType.visualSearchGrid:
        return 'Scan a dense multi-column grid for target items among distractors.';
      case FocusActivityType.findNObjects:
        return 'Find and count a specific quantity of hidden target items.';
    }
  }
}

enum FocusTargetCategory { shapes, character, illustration }

class FocusAttentionConfig {
  FocusActivityType activityType;
  FocusTargetCategory targetCategory;
  String targetItem;
  List<String> distractorItems;
  int targetCount;
  int gridRows;
  int gridCols;
  int seed;

  FocusAttentionConfig({
    this.activityType = FocusActivityType.findAndCircle,
    this.targetCategory = FocusTargetCategory.shapes,
    this.targetItem = 'star',
    List<String>? distractorItems,
    this.targetCount = 5,
    this.gridRows = 5,
    this.gridCols = 5,
    int? seed,
  }) : distractorItems =
           distractorItems ?? ['circle', 'square', 'triangle', 'heart'],
       seed = seed ?? 42918;

  void applyActivityPreset(FocusActivityType type) {
    activityType = type;
    switch (type) {
      case FocusActivityType.findAndCircle:
        targetCategory = FocusTargetCategory.shapes;
        targetItem = 'star';
        distractorItems = ['circle', 'square', 'triangle', 'heart'];
        targetCount = 6;
        gridRows = 5;
        gridCols = 5;
        break;
      case FocusActivityType.targetSearch:
        targetCategory = FocusTargetCategory.character;
        targetItem = 'B';
        distractorItems = ['P', 'R', 'D', '8', 'E'];
        targetCount = 8;
        gridRows = 6;
        gridCols = 6;
        break;
      case FocusActivityType.oddOneOut:
        targetCategory = FocusTargetCategory.shapes;
        targetItem = 'apple';
        distractorItems = ['tree'];
        targetCount = 5; // 5 rows
        gridRows = 5;
        gridCols = 4; // 4 items per row
        break;
      case FocusActivityType.visualSearchGrid:
        targetCategory = FocusTargetCategory.character;
        targetItem = '5';
        distractorItems = ['2', '3', '6', '8', '9', 'S'];
        targetCount = 10;
        gridRows = 7;
        gridCols = 7;
        break;
      case FocusActivityType.findNObjects:
        targetCategory = FocusTargetCategory.shapes;
        targetItem = 'star';
        distractorItems = ['circle', 'square', 'triangle'];
        targetCount = 5;
        gridRows = 4;
        gridCols = 5;
        break;
    }
  }
}
