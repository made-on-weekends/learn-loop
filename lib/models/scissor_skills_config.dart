enum ScissorLineType { straight, curved, zigzag, shapeOutlines, cutAndPaste }

extension ScissorLineTypeExtension on ScissorLineType {
  String get label {
    switch (this) {
      case ScissorLineType.straight:
        return 'Straight Cutting Lines';
      case ScissorLineType.curved:
        return 'Curved & Wavy Cutting Lines';
      case ScissorLineType.zigzag:
        return 'Zigzag Cutting Lines';
      case ScissorLineType.shapeOutlines:
        return 'Shape Cutting Outlines';
      case ScissorLineType.cutAndPaste:
        return 'Cut & Paste Matching Activity';
    }
  }

  String get description {
    switch (this) {
      case ScissorLineType.straight:
        return 'Practice snip and cut precision along straight horizontal guidelines.';
      case ScissorLineType.curved:
        return 'Control scissor direction along smooth curved and wavy guidelines.';
      case ScissorLineType.zigzag:
        return 'Turn and pivot scissors sharply along zigzag angle guidelines.';
      case ScissorLineType.shapeOutlines:
        return 'Cut out complete geometric shapes along dashed cutting borders.';
      case ScissorLineType.cutAndPaste:
        return 'Snip out bottom number cards and paste them into matching target boxes.';
    }
  }
}

class ScissorSkillsConfig {
  ScissorLineType lineType;
  int lineCount;
  bool showScissorIcons;
  int seed;

  ScissorSkillsConfig({
    this.lineType = ScissorLineType.straight,
    this.lineCount = 4,
    this.showScissorIcons = true,
    int? seed,
  }) : seed = seed ?? 63914;

  void applyPreset(ScissorLineType type) {
    lineType = type;
    switch (type) {
      case ScissorLineType.straight:
        lineCount = 5;
        break;
      case ScissorLineType.curved:
        lineCount = 4;
        break;
      case ScissorLineType.zigzag:
        lineCount = 4;
        break;
      case ScissorLineType.shapeOutlines:
        lineCount = 4; // 4 shapes per page
        break;
      case ScissorLineType.cutAndPaste:
        lineCount = 4; // 4 matching pairs
        break;
    }
  }
}
