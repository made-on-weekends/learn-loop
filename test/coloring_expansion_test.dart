import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/coloring_config.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/registry/worksheet_registry.dart';
import 'package:learn_loop/screens/coloring_screen.dart';
import 'package:learn_loop/services/asset_catalog_service.dart';
import 'package:learn_loop/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 10 Coloring Model & Asset Catalog Tests', () {
    test('ColoringConfig default settings', () {
      final config = ColoringConfig();
      expect(config.assetId, equals('animal_apple_bear'));
      expect(config.lineThickness, equals(ColoringLineThickness.thick));
      expect(config.showWordTracing, isTrue);
      expect(config.showDecorativeBorder, isTrue);
      expect(config.showColoringPrompts, isFalse);
    });

    test('ColoringLineThicknessExtension values', () {
      expect(ColoringLineThickness.thin.widthPt, equals(1.2));
      expect(ColoringLineThickness.medium.widthPt, equals(2.0));
      expect(ColoringLineThickness.thick.widthPt, equals(3.2));
      expect(ColoringLineThickness.thick.label, contains('Thick'));
    });

    test('AssetCatalogService catalog lookup & filter', () {
      final all = AssetCatalogService.getAll();
      expect(all.length, greaterThanOrEqualTo(9));

      final animals = AssetCatalogService.getByCategory('Animal');
      expect(animals.length, greaterThanOrEqualTo(4));

      final vehicles = AssetCatalogService.getByCategory('Vehicle');
      expect(vehicles.length, greaterThanOrEqualTo(2));

      final categories = AssetCatalogService.getCategories();
      expect(categories, contains('Animal'));
      expect(categories, contains('Vehicle'));

      final searched = AssetCatalogService.search('rocket');
      expect(searched.length, equals(1));
      expect(searched.first.id, equals('vehicle_air_rocket'));
    });
  });

  group('Phase 10 Coloring PDF Engine Tests', () {
    final globalConfig = GlobalConfig(title: 'Coloring Test');

    test(
      'PdfService.generateColoring generates valid PDF for all built-in assets',
      () async {
        final assets = AssetCatalogService.getAll();

        for (final asset in assets) {
          final config = ColoringConfig(
            assetId: asset.id,
            lineThickness: ColoringLineThickness.thick,
            showWordTracing: true,
            showDecorativeBorder: true,
            showColoringPrompts: true,
          );

          final pdfBytes = await PdfService.generateColoring(
            globalConfig,
            config,
          );
          expect(pdfBytes, isA<Uint8List>());
          expect(pdfBytes.length, greaterThan(1000));
        }
      },
    );

    test(
      'PdfService.generateColoring handles line thickness variants',
      () async {
        for (final thickness in ColoringLineThickness.values) {
          final config = ColoringConfig(
            assetId: 'vehicle_land_car',
            lineThickness: thickness,
          );

          final pdfBytes = await PdfService.generateColoring(
            globalConfig,
            config,
          );
          expect(pdfBytes, isA<Uint8List>());
          expect(pdfBytes.length, greaterThan(1000));
        }
      },
    );
  });

  group('Phase 10 WorksheetRegistry Integration Tests', () {
    test('coloring_pages activity is registered with metadata', () {
      final activity = WorksheetRegistry.getById('coloring_pages');
      expect(activity, isNotNull);
      expect(activity!.title, contains('Coloring Pages'));
      expect(activity.tags, contains('coloring'));
      expect(activity.targetSkills, contains('creativity'));
      expect(activity.categoryIds, contains('coloring'));
      expect(WorksheetRegistry.getByCategory('coloring').map((a) => a.id), contains('coloring_pages'));
    });
  });

  group('Phase 10 ColoringScreen UI Tests', () {
    testWidgets('ColoringScreen renders editor controls and builds PDF', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ColoringScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Coloring Generator'), findsOneWidget);
      expect(find.text('Select Coloring Page'), findsOneWidget);
      expect(find.text('Line Thickness'), findsOneWidget);

      // Verify category dropdown
      final categoryDropdown = find.byKey(
        const ValueKey('coloring_category_dropdown'),
      );
      expect(categoryDropdown, findsOneWidget);

      // Verify asset dropdown
      final assetDropdown = find.byKey(
        const ValueKey('coloring_asset_dropdown'),
      );
      expect(assetDropdown, findsOneWidget);

      // Verify switches
      expect(find.byKey(const ValueKey('word_tracing_switch')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('decorative_border_switch')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('coloring_prompts_switch')),
        findsOneWidget,
      );

      // Toggle a switch
      await tester.ensureVisible(
        find.byKey(const ValueKey('coloring_prompts_switch')),
      );
      await tester.tap(find.byKey(const ValueKey('coloring_prompts_switch')));
      await tester.pumpAndSettle();
    });
  });
}
