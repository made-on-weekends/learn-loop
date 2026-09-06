import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/global_config.dart';
import 'package:learn_loop/models/handwriting_config.dart';
import 'package:learn_loop/models/kid_profile.dart';
import 'package:learn_loop/registry/worksheet_registry.dart';
import 'package:learn_loop/screens/handwriting_screen.dart';
import 'package:learn_loop/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Early Literacy Expansion Model Tests', () {
    test('HandwritingConfig default literacy settings', () {
      final config = HandwritingConfig();
      expect(config.source, equals(HandwritingSource.alphabetUpper));
      expect(config.cvcMissingVowel, isFalse);
      expect(config.seed, isNull);
    });

    test('HandwritingConfig custom literacy sources', () {
      final config = HandwritingConfig(
        source: HandwritingSource.caseMatching,
        cvcMissingVowel: true,
        seed: 42,
      );
      expect(config.source, equals(HandwritingSource.caseMatching));
      expect(config.cvcMissingVowel, isTrue);
      expect(config.seed, equals(42));
    });
  });

  group('Early Literacy PDF Generation Tests', () {
    final globalConfig = GlobalConfig(title: 'Literacy Test');
    final kidProfile = KidProfile(grade: KidGrade.kindergarten);

    test('Generates PDF for Alphabet Both (Uppercase & Lowercase)', () async {
      final config = HandwritingConfig(
        source: HandwritingSource.alphabetBoth,
        alphabetStart: 'A',
        alphabetEnd: 'D',
      );
      final pdfBytes = await PdfService.generateHandwriting(
        globalConfig,
        config,
        kidProfile: kidProfile,
      );
      expect(pdfBytes, isA<Uint8List>());
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('Generates PDF for Case Matching', () async {
      final config = HandwritingConfig(
        source: HandwritingSource.caseMatching,
        seed: 12345,
      );
      final pdfBytes = await PdfService.generateHandwriting(
        globalConfig,
        config,
        kidProfile: kidProfile,
      );
      expect(pdfBytes, isA<Uint8List>());
      expect(pdfBytes.length, greaterThan(1000));
    });

    test(
      'Generates PDF for Alphabet Sequence (Fill in Missing Letters)',
      () async {
        final config = HandwritingConfig(
          source: HandwritingSource.alphabetSequence,
          seed: 54321,
        );
        final pdfBytes = await PdfService.generateHandwriting(
          globalConfig,
          config,
          kidProfile: kidProfile,
        );
        expect(pdfBytes, isA<Uint8List>());
        expect(pdfBytes.length, greaterThan(1000));
      },
    );

    test('Generates PDF for Circle Beginning Sounds', () async {
      final config = HandwritingConfig(
        source: HandwritingSource.beginningSounds,
        seed: 99999,
      );
      final pdfBytes = await PdfService.generateHandwriting(
        globalConfig,
        config,
        kidProfile: kidProfile,
      );
      expect(pdfBytes, isA<Uint8List>());
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('Generates PDF for CVC Words (Standard and Missing Vowel)', () async {
      final configStandard = HandwritingConfig(
        source: HandwritingSource.cvcWords,
        cvcMissingVowel: false,
      );
      final pdfStandard = await PdfService.generateHandwriting(
        globalConfig,
        configStandard,
        kidProfile: kidProfile,
      );
      expect(pdfStandard, isA<Uint8List>());
      expect(pdfStandard.length, greaterThan(1000));

      final configMissing = HandwritingConfig(
        source: HandwritingSource.cvcWords,
        cvcMissingVowel: true,
      );
      final pdfMissing = await PdfService.generateHandwriting(
        globalConfig,
        configMissing,
        kidProfile: kidProfile,
      );
      expect(pdfMissing, isA<Uint8List>());
      expect(pdfMissing.length, greaterThan(1000));
    });

    test('Generates PDF for Sight Words', () async {
      final config = HandwritingConfig(source: HandwritingSource.sightWords);
      final pdfBytes = await PdfService.generateHandwriting(
        globalConfig,
        config,
        kidProfile: kidProfile,
      );
      expect(pdfBytes, isA<Uint8List>());
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('Deterministic PDF structure with matching seed', () async {
      final config1 = HandwritingConfig(
        source: HandwritingSource.caseMatching,
        seed: 777,
      );
      final config2 = HandwritingConfig(
        source: HandwritingSource.caseMatching,
        seed: 777,
      );

      final pdf1 = await PdfService.generateHandwriting(
        globalConfig,
        config1,
        kidProfile: kidProfile,
      );
      final pdf2 = await PdfService.generateHandwriting(
        globalConfig,
        config2,
        kidProfile: kidProfile,
      );

      expect(pdf1.length, equals(pdf2.length));
    });
  });

  group('WorksheetRegistry Early Literacy Metadata Tests', () {
    test(
      'Handwriting & Early Literacy activity registered with rich tags and skills',
      () {
        final activity = WorksheetRegistry.getById('handwriting_practice');
        expect(activity, isNotNull);
        expect(activity!.title, contains('Handwriting & Early Literacy'));
        expect(activity.tags, contains('cvc'));
        expect(activity.tags, contains('sight words'));
        expect(activity.targetSkills, contains('phonemic_awareness'));
      },
    );
  });

  group('HandwritingScreen UI Tests', () {
    testWidgets(
      'Renders HandwritingScreen with early literacy dropdown items',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: HandwritingScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Handwriting Generator'), findsOneWidget);
        expect(find.text('Generate Source'), findsOneWidget);

        // Open Generate Source dropdown
        final dropdown = find.byType(
          DropdownButtonFormField<HandwritingSource>,
        );
        expect(dropdown, findsOneWidget);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        expect(find.text('Both Upper & Lowercase (Aa Bb)'), findsWidgets);
        expect(find.text('Match Uppercase to Lowercase'), findsWidgets);
        expect(find.text('Fill in Missing Letters'), findsWidgets);
        expect(find.text('Circle Beginning Sound'), findsWidgets);
        expect(find.text('CVC Words (3-Letter Words)'), findsWidgets);
        expect(find.text('Early Sight Words'), findsWidgets);

        // Select CVC Words
        await tester.tap(
          find.text('CVC Words (3-Letter Words)').first,
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        // Check missing vowel switch visible
        expect(
          find.byKey(const ValueKey('cvc_missing_vowel_switch')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('shuffle_literacy_seed_btn')),
          findsOneWidget,
        );

        // Tap missing vowel switch
        await tester.tap(
          find.byKey(const ValueKey('cvc_missing_vowel_switch')),
        );
        await tester.pumpAndSettle();

        // Tap shuffle seed button
        await tester.tap(
          find.byKey(const ValueKey('shuffle_literacy_seed_btn')),
        );
        await tester.pumpAndSettle();
      },
    );
  });
}
