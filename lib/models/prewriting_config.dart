enum LinePattern { straight, wave, zigzag, castle }

class PrewritingConfig {
  LinePattern pattern;
  int lineCount;
  double strokeWidth;
  bool isDotted;
  double lineSpacing;

  PrewritingConfig({
    this.pattern = LinePattern.straight,
    this.lineCount = 5,
    this.strokeWidth = 2.0,
    this.isDotted = true,
    this.lineSpacing = 50.0,
  });
}
