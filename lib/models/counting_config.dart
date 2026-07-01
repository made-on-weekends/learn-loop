enum CountingActivityType { countAndWrite, drawToMatch }
enum ShapeType { random, circle, square, triangle, star, heart, tree, apple }

class CountingConfig {
  CountingActivityType activityType;
  int minNumber;
  int maxNumber;
  ShapeType shapeType;
  int questionsPerPage;

  CountingConfig({
    this.activityType = CountingActivityType.countAndWrite,
    this.minNumber = 1,
    this.maxNumber = 10,
    this.shapeType = ShapeType.random,
    this.questionsPerPage = 6,
  });
}
