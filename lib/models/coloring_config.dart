enum ColoringLineThickness { thin, medium, thick }

extension ColoringLineThicknessExtension on ColoringLineThickness {
  String get label {
    switch (this) {
      case ColoringLineThickness.thin:
        return 'Thin (1.2 pt)';
      case ColoringLineThickness.medium:
        return 'Medium (2.0 pt)';
      case ColoringLineThickness.thick:
        return 'Thick Contour (3.2 pt)';
    }
  }

  double get widthPt {
    switch (this) {
      case ColoringLineThickness.thin:
        return 1.2;
      case ColoringLineThickness.medium:
        return 2.0;
      case ColoringLineThickness.thick:
        return 3.2;
    }
  }
}

class ColoringConfig {
  String assetId;
  ColoringLineThickness lineThickness;
  bool showWordTracing;
  bool showDecorativeBorder;
  bool showColoringPrompts;
  int? seed;

  ColoringConfig({
    this.assetId = 'animal_apple_bear',
    this.lineThickness = ColoringLineThickness.thick,
    this.showWordTracing = true,
    this.showDecorativeBorder = true,
    this.showColoringPrompts = false,
    this.seed,
  });
}
