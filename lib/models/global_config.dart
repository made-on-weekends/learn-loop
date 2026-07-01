class GlobalConfig {
  String title;
  bool showHeader;
  bool showNameLine;
  bool showDateLine;
  double marginMm;

  GlobalConfig({
    this.title = "Worksheet",
    this.showHeader = true,
    this.showNameLine = true,
    this.showDateLine = true,
    this.marginMm = 15.0,
  });
}
