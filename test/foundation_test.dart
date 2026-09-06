import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/registry/worksheet_registry.dart';
import 'package:learn_loop/services/random_seed_service.dart';
import 'package:learn_loop/services/asset_catalog_service.dart';
import 'package:learn_loop/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorksheetRegistry Foundation Tests', () {
    test('WorksheetRegistry returns all built-in activities', () {
      final activities = WorksheetRegistry.getAll();
      expect(activities.length, greaterThanOrEqualTo(5));
    });

    test(
      'WorksheetRegistry retrieves activities by developmental category',
      () {
        final mathActivities = WorksheetRegistry.getByCategory('early_math');
        expect(mathActivities.length, greaterThanOrEqualTo(2));
        expect(mathActivities.any((a) => a.id == 'numbers_counting'), isTrue);
        expect(
          mathActivities.any((a) => a.id == 'addition_subtraction'),
          isTrue,
        );
      },
    );

    test('WorksheetRegistry performs search by title and tags', () {
      final handwritingResults = WorksheetRegistry.search('handwriting');
      expect(handwritingResults.length, equals(1));
      expect(handwritingResults.first.id, equals('handwriting_practice'));

      final shapeResults = WorksheetRegistry.search('star');
      expect(shapeResults.any((a) => a.id == 'shapes_tracing'), isTrue);
    });

    test('WorksheetRegistry retrieves activities by age', () {
      final toddlerActivities = WorksheetRegistry.getForAge(2);
      expect(toddlerActivities.any((a) => a.id == 'prewriting_lines'), isTrue);
    });
  });

  group('RandomSeedService Tests', () {
    test('RandomSeedService is deterministic when given identical seed', () {
      final rng1 = RandomSeedService.fromSeed(42918);
      final rng2 = RandomSeedService.fromSeed(42918);

      final val1 = List.generate(5, (_) => rng1.inRange(1, 100));
      final val2 = List.generate(5, (_) => rng2.inRange(1, 100));

      expect(val1, equals(val2));
    });

    test('RandomSeedService picks items and shuffles predictably', () {
      final rng = RandomSeedService.fromSeed(12345);
      final items = ['A', 'B', 'C', 'D'];
      final picked = rng.pickOne(items);
      expect(items.contains(picked), isTrue);

      final shuffled = rng.shuffle(items);
      expect(shuffled.length, equals(4));
    });
  });

  group('AssetCatalogService Tests', () {
    test('AssetCatalogService returns all enabled assets', () {
      final assets = AssetCatalogService.getAll();
      expect(assets.isNotEmpty, isTrue);
    });

    test('AssetCatalogService filters assets by category', () {
      final animals = AssetCatalogService.getByCategory('Animal');
      expect(animals.every((a) => a.category == 'Animal'), isTrue);
    });

    test('AssetCatalogService searches assets by keyword', () {
      final results = AssetCatalogService.search('rocket');
      expect(results.any((a) => a.slug == 'space-rocket'), isTrue);
    });
  });

  group('SettingsService Recents & Favorites Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('SettingsService persists recents and favorites', () async {
      await SettingsService.init();

      final seedItem = SavedWorksheetSeed(
        activityId: 'numbers_counting',
        title: 'Numbers & Counting',
        seed: 9999,
        timestamp: DateTime.now(),
      );

      await SettingsService.addRecentWorksheet(seedItem);
      expect(SettingsService.recentsNotifier.value.length, equals(1));
      expect(SettingsService.recentsNotifier.value.first.seed, equals(9999));

      await SettingsService.toggleFavorite(seedItem);
      expect(SettingsService.isFavorite('numbers_counting', 9999), isTrue);
    });
  });
}
