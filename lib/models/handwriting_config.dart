enum HandwritingSource { alphabetUpper, alphabetLower, numbers, customText }
enum PracticeMode { tracing, copy }
enum PracticeDirection { row, column }

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
  
  // Guidelines config
  bool showTopLine;
  bool showMidLine;
  bool showBaseLine;
  bool showBottomLine;
  
  double fontSize;

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
    this.showTopLine = true,
    this.showMidLine = true,
    this.showBaseLine = true,
    this.showBottomLine = true,
    this.fontSize = 36.0,
  });
}
