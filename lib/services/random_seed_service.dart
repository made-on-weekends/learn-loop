import 'dart:math' as math;

class RandomSeedService {
  final math.Random _random;
  final int seed;

  RandomSeedService([int? seed])
    : seed = seed ?? DateTime.now().microsecondsSinceEpoch,
      _random = math.Random(seed ?? DateTime.now().microsecondsSinceEpoch);

  factory RandomSeedService.fromSeed(int seed) {
    return RandomSeedService(seed);
  }

  int nextInt(int max) {
    return _random.nextInt(max);
  }

  int inRange(int min, int max) {
    if (min >= max) return min;
    return min + _random.nextInt(max - min + 1);
  }

  bool nextBool() {
    return _random.nextBool();
  }

  double nextDouble() {
    return _random.nextDouble();
  }

  T pickOne<T>(List<T> items) {
    if (items.isEmpty) {
      throw ArgumentError('Cannot pick from an empty list');
    }
    return items[_random.nextInt(items.length)];
  }

  List<T> shuffle<T>(List<T> items) {
    final list = List<T>.from(items);
    list.shuffle(_random);
    return list;
  }

  static int generateNewSeed() {
    return math.Random().nextInt(0x7FFFFFFF);
  }
}
