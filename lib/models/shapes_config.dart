enum ShapeDesign {
  circle,
  square,
  triangle,
  rectangle,
  oval,
  diamond,
  star,
  heart,
}

extension ShapeDesignExtension on ShapeDesign {
  String get label {
    switch (this) {
      case ShapeDesign.circle:
        return 'Circle';
      case ShapeDesign.square:
        return 'Square';
      case ShapeDesign.triangle:
        return 'Triangle';
      case ShapeDesign.rectangle:
        return 'Rectangle';
      case ShapeDesign.oval:
        return 'Oval';
      case ShapeDesign.diamond:
        return 'Diamond';
      case ShapeDesign.star:
        return 'Star';
      case ShapeDesign.heart:
        return 'Heart';
    }
  }

  String get realWorldMatch {
    switch (this) {
      case ShapeDesign.circle:
        return 'Clock';
      case ShapeDesign.square:
        return 'Window';
      case ShapeDesign.triangle:
        return 'Pizza Slice';
      case ShapeDesign.rectangle:
        return 'Door';
      case ShapeDesign.oval:
        return 'Egg';
      case ShapeDesign.diamond:
        return 'Kite';
      case ShapeDesign.star:
        return 'Starfish';
      case ShapeDesign.heart:
        return 'Cookie';
    }
  }
}

enum ShapeActivityMode {
  tracing,
  identification,
  matching,
  counting,
  halfDrawSymmetry,
}

extension ShapeActivityModeExtension on ShapeActivityMode {
  String get label {
    switch (this) {
      case ShapeActivityMode.tracing:
        return 'Shape Tracing & Direction Guides';
      case ShapeActivityMode.identification:
        return 'Shape Identification Search';
      case ShapeActivityMode.matching:
        return 'Shape & Object Matching';
      case ShapeActivityMode.counting:
        return 'Shape Counting & Tally';
      case ShapeActivityMode.halfDrawSymmetry:
        return 'Symmetry & Half-Draw Completion';
    }
  }

  String get description {
    switch (this) {
      case ShapeActivityMode.tracing:
        return 'Trace shape outlines with start dots and directional stroke arrows.';
      case ShapeActivityMode.identification:
        return 'Find and circle target geometric shapes among distractors.';
      case ShapeActivityMode.matching:
        return 'Connect shapes to real-world objects and name labels.';
      case ShapeActivityMode.counting:
        return 'Count how many of each shape appear and record the total.';
      case ShapeActivityMode.halfDrawSymmetry:
        return 'Complete the missing mirror half of symmetrical shapes across the axis line.';
    }
  }
}

class ShapesConfig {
  ShapeActivityMode activityMode;
  List<ShapeDesign> selectedShapes;
  ShapeDesign targetShape;
  bool showTracingGuides;
  bool showShapeNames;
  bool isDotted;
  int seed;

  ShapesConfig({
    this.activityMode = ShapeActivityMode.tracing,
    List<ShapeDesign>? selectedShapes,
    this.targetShape = ShapeDesign.triangle,
    this.showTracingGuides = true,
    this.showShapeNames = true,
    this.isDotted = true,
    int? seed,
  }) : selectedShapes =
           selectedShapes ??
           [
             ShapeDesign.circle,
             ShapeDesign.square,
             ShapeDesign.triangle,
             ShapeDesign.star,
           ],
       seed = seed ?? 74219;
}
