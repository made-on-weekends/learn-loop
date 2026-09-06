enum DrawingActivityMode { finishSymmetry, stepByStep, storyPrompt, dotToDot }

extension DrawingActivityModeExtension on DrawingActivityMode {
  String get label {
    switch (this) {
      case DrawingActivityMode.finishSymmetry:
        return 'Finish the Drawing (Grid Symmetry)';
      case DrawingActivityMode.stepByStep:
        return 'Step-by-Step Drawing Guide';
      case DrawingActivityMode.storyPrompt:
        return 'Draw & Write Story Prompt';
      case DrawingActivityMode.dotToDot:
        return 'Dot-to-Dot Number Connect';
    }
  }
}

class DrawingConfig {
  DrawingActivityMode activityMode;
  int gridSize;
  String symmetryShape;
  String stepSubject;
  String storyPromptText;
  int dotCount;
  String dotShape;
  int? seed;

  DrawingConfig({
    this.activityMode = DrawingActivityMode.finishSymmetry,
    this.gridSize = 8,
    this.symmetryShape = 'house',
    this.stepSubject = 'cat',
    this.storyPromptText =
        "Draw your favorite animal and write a story about it:",
    this.dotCount = 15,
    this.dotShape = 'star',
    this.seed,
  });
}
