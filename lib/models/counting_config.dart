enum CountingActivityType {
  countAndWrite,
  drawToMatch,
  numberTracing,
  moreVsLess,
  numberSequence,
}

enum ShapeType { random, circle, square, triangle, star, heart, tree, apple }

class CountingConfig {
  CountingActivityType activityType;
  int minNumber;
  int maxNumber;
  ShapeType shapeType;
  int questionsPerPage;
  bool compareMore; // true for circle MORE, false for circle FEWER
  int sequenceLength; // 3 to 6 numbers in sequence mode
  int? seed;

  CountingConfig({
    this.activityType = CountingActivityType.countAndWrite,
    this.minNumber = 1,
    this.maxNumber = 10,
    this.shapeType = ShapeType.random,
    this.questionsPerPage = 6,
    this.compareMore = true,
    this.sequenceLength = 5,
    this.seed,
  });
}
