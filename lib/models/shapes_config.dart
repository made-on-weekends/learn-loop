enum ShapeDesign { circle, square, triangle, rectangle, star, heart }

class ShapesConfig {
  List<ShapeDesign> selectedShapes;
  bool showTracingGuides; // helper arrows/outlines
  bool showShapeNames;   // label at the bottom (solid/dotted)
  bool isDotted;

  ShapesConfig({
    List<ShapeDesign>? selectedShapes,
    this.showTracingGuides = true,
    this.showShapeNames = true,
    this.isDotted = true,
  }) : selectedShapes = selectedShapes ?? [
    ShapeDesign.circle,
    ShapeDesign.square,
    ShapeDesign.triangle,
    ShapeDesign.star,
  ];
}
