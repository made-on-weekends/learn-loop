enum MathOperation { addition, subtraction, mixed }

enum MathFormat { horizontal, vertical }

enum MathActivityMode { standardEquations, numberLine, tenFrame, numberBonds }

class MathConfig {
  MathActivityMode activityMode;
  MathOperation operation;
  MathFormat format;
  int minNumber;
  int maxNumber;
  int columnsCount; // 1 or 2
  int questionsCount;
  bool drawWorkspace;
  bool missingTerm;
  int? seed;

  MathConfig({
    this.activityMode = MathActivityMode.standardEquations,
    this.operation = MathOperation.addition,
    this.format = MathFormat.vertical,
    this.minNumber = 1,
    this.maxNumber = 10,
    this.columnsCount = 2,
    this.questionsCount = 10,
    this.drawWorkspace = true,
    this.missingTerm = false,
    this.seed,
  });
}
