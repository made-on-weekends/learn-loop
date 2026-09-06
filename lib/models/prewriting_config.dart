enum LinePattern {
  straight,
  wave,
  zigzag,
  castle,
  curve,
  loop,
  spiral,
  mixedStrokes,
  corridor,
}

enum ContextPair {
  circleToStar,
  beeToFlower,
  carToGarage,
  rocketToPlanet,
  fishToOcean,
  rabbitToCarrot,
}

extension ContextPairExtension on ContextPair {
  String get label {
    switch (this) {
      case ContextPair.circleToStar:
        return 'Circle ➔ Star';
      case ContextPair.beeToFlower:
        return 'Bee ➔ Flower';
      case ContextPair.carToGarage:
        return 'Car ➔ Garage';
      case ContextPair.rocketToPlanet:
        return 'Rocket ➔ Planet';
      case ContextPair.fishToOcean:
        return 'Fish ➔ Ocean';
      case ContextPair.rabbitToCarrot:
        return 'Rabbit ➔ Carrot';
    }
  }

  String get startEmoji {
    switch (this) {
      case ContextPair.circleToStar:
        return '●';
      case ContextPair.beeToFlower:
        return '🐝';
      case ContextPair.carToGarage:
        return '🚗';
      case ContextPair.rocketToPlanet:
        return '🚀';
      case ContextPair.fishToOcean:
        return '🐟';
      case ContextPair.rabbitToCarrot:
        return '🐇';
    }
  }

  String get endEmoji {
    switch (this) {
      case ContextPair.circleToStar:
        return '★';
      case ContextPair.beeToFlower:
        return '🌸';
      case ContextPair.carToGarage:
        return '🏠';
      case ContextPair.rocketToPlanet:
        return '🪐';
      case ContextPair.fishToOcean:
        return '🌊';
      case ContextPair.rabbitToCarrot:
        return '🥕';
    }
  }
}

enum CorridorWidthPreset { wide, medium, narrow }

extension CorridorWidthPresetExtension on CorridorWidthPreset {
  String get label {
    switch (this) {
      case CorridorWidthPreset.wide:
        return 'Beginner Wide (32 pt)';
      case CorridorWidthPreset.medium:
        return 'Developing Medium (22 pt)';
      case CorridorWidthPreset.narrow:
        return 'Advanced Narrow (14 pt)';
    }
  }

  double get widthPt {
    switch (this) {
      case CorridorWidthPreset.wide:
        return 32.0;
      case CorridorWidthPreset.medium:
        return 22.0;
      case CorridorWidthPreset.narrow:
        return 14.0;
    }
  }
}

class PrewritingConfig {
  LinePattern pattern;
  int lineCount;
  double strokeWidth;
  bool isDotted;
  double lineSpacing;
  ContextPair contextPair;
  CorridorWidthPreset corridorWidth;
  bool showCorridorBoundaries;
  int progressionLevel; // 1 to 12

  PrewritingConfig({
    this.pattern = LinePattern.straight,
    this.lineCount = 5,
    this.strokeWidth = 2.0,
    this.isDotted = true,
    this.lineSpacing = 50.0,
    this.contextPair = ContextPair.circleToStar,
    this.corridorWidth = CorridorWidthPreset.wide,
    this.showCorridorBoundaries = false,
    this.progressionLevel = 1,
  });

  void applyProgressionLevel(int level) {
    progressionLevel = level.clamp(1, 12);
    switch (progressionLevel) {
      case 1:
        pattern = LinePattern.straight;
        isDotted = true;
        showCorridorBoundaries = false;
        break;
      case 2:
        pattern = LinePattern.straight;
        isDotted = true;
        showCorridorBoundaries = false;
        break;
      case 3:
        pattern = LinePattern.curve;
        isDotted = true;
        showCorridorBoundaries = false;
        break;
      case 4:
        pattern = LinePattern.zigzag;
        isDotted = true;
        showCorridorBoundaries = false;
        break;
      case 5:
        pattern = LinePattern.loop;
        isDotted = true;
        showCorridorBoundaries = false;
        break;
      case 6:
        pattern = LinePattern.mixedStrokes;
        isDotted = true;
        showCorridorBoundaries = false;
        break;
      case 7:
        pattern = LinePattern.corridor;
        corridorWidth = CorridorWidthPreset.wide;
        showCorridorBoundaries = true;
        isDotted = true;
        break;
      case 8:
        pattern = LinePattern.corridor;
        corridorWidth = CorridorWidthPreset.narrow;
        showCorridorBoundaries = true;
        isDotted = true;
        break;
      default:
        pattern = LinePattern.mixedStrokes;
        isDotted = true;
        break;
    }
  }
}
