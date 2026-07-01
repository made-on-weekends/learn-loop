enum MathOperation { addition, subtraction, mixed }
enum MathFormat { horizontal, vertical }

class MathConfig {
  MathOperation operation;
  MathFormat format;
  int minNumber;
  int maxNumber;
  int columnsCount; // 1 or 2
  int questionsCount;
  bool drawWorkspace;

  MathConfig({
    this.operation = MathOperation.addition,
    this.format = MathFormat.vertical,
    this.minNumber = 1,
    this.maxNumber = 10,
    this.columnsCount = 2,
    this.questionsCount = 10,
    this.drawWorkspace = true,
  });
}
