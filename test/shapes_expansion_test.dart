import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/models/shapes_config.dart';
import 'package:learn_loop/screens/shapes_screen.dart';
import 'package:learn_loop/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 6 Shapes & Visual-Motor Engine Tests', () {
    test('ShapesConfig properties and extensions work properly', () {
      final config = ShapesConfig();

      expect(config.activityMode, equals(ShapeActivityMode.tracing));
      expect(ShapeDesign.oval.label, equals('Oval'));
      expect(ShapeDesign.diamond.realWorldMatch, equals('Kite'));
    });

    test(
      'PdfService.generateShapes generates valid PDF for all ShapeActivityMode values',
      () async {
        final global = GlobalConfig(title: "Shapes Test");

        for (final mode in ShapeActivityMode.values) {
          final config = ShapesConfig(
            activityMode: mode,
            seed: 48291,
            selectedShapes: [
              ShapeDesign.circle,
              ShapeDesign.square,
              ShapeDesign.triangle,
              ShapeDesign.oval,
              ShapeDesign.diamond,
            ],
          );
          final bytes = await PdfService.generateShapes(global, config);
          expect(bytes, isNotEmpty, reason: 'Failed for mode: ${mode.name}');
        }
      },
    );

    testWidgets('ShapesScreen renders editor controls and builds PDF', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ShapesScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Shapes Learning & Visual-Motor"), findsWidgets);
      expect(find.text("Shape Learning Mode"), findsOneWidget);
      expect(find.text("Select Shapes"), findsOneWidget);
      expect(find.text("New Random Grid Mix"), findsOneWidget);
    });
  });
}
