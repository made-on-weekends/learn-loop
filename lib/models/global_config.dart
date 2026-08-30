class GlobalConfig {
  String title;
  bool showHeader;
  bool showNameLine;
  bool showDateLine;
  double marginMm;
  bool showRedMarginLine;

  GlobalConfig({
    this.title = "Worksheet",
    this.showHeader = true,
    this.showNameLine = true,
    this.showDateLine = true,
    this.marginMm = 19.05, // 0.75 inch default margin
    this.showRedMarginLine = true,
  });
}
