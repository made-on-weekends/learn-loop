import 'package:flutter_test/flutter_test.dart';
import 'package:learn_loop/models/handwriting_config.dart';
import 'package:learn_loop/models/handwriting_line_style.dart';
import 'package:learn_loop/models/kid_profile.dart';
import 'package:learn_loop/services/handwriting_defaults_resolver.dart';
import 'package:learn_loop/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HandwritingDefaultsResolver Tests', () {
    test('resolves correct defaults for all Grade levels', () {
      final pg = HandwritingDefaultsResolver.resolve(grade: KidGrade.playgroup);
      expect(pg.lineStyle, equals(HandwritingLineStyle.twoLineSeparated));
      expect(pg.rowHeightMm, equals(20.0));

      final ps = HandwritingDefaultsResolver.resolve(grade: KidGrade.preschool);
      expect(ps.lineStyle, equals(HandwritingLineStyle.twoLineSeparated));
      expect(ps.rowHeightMm, equals(18.0));

      final nursery = HandwritingDefaultsResolver.resolve(grade: KidGrade.nursery);
      expect(nursery.lineStyle, equals(HandwritingLineStyle.threeLineSeparated));
      expect(nursery.rowHeightMm, equals(17.0));

      final kg = HandwritingDefaultsResolver.resolve(grade: KidGrade.kindergarten);
      expect(kg.lineStyle, equals(HandwritingLineStyle.threeLine));
      expect(kg.rowHeightMm, equals(14.0));

      final hs = HandwritingDefaultsResolver.resolve(grade: KidGrade.homeschool);
      expect(hs.lineStyle, equals(HandwritingLineStyle.threeLine));
      expect(hs.rowHeightMm, equals(14.0));

      final g1 = HandwritingDefaultsResolver.resolve(grade: KidGrade.grade1);
      expect(g1.lineStyle, equals(HandwritingLineStyle.threeLine));
      expect(g1.rowHeightMm, equals(12.0));

      final g2 = HandwritingDefaultsResolver.resolve(grade: KidGrade.grade2);
      expect(g2.lineStyle, equals(HandwritingLineStyle.threeLine));
      expect(g2.rowHeightMm, equals(10.5));

      final g3 = HandwritingDefaultsResolver.resolve(grade: KidGrade.grade3Plus);
      expect(g3.lineStyle, equals(HandwritingLineStyle.threeLine));
      expect(g3.rowHeightMm, equals(9.0));
    });

    test('resolves correct defaults for Age when Grade is unspecified', () {
      final age3 = HandwritingDefaultsResolver.resolve(age: 3);
      expect(age3.lineStyle, equals(HandwritingLineStyle.twoLineSeparated));
      expect(age3.rowHeightMm, equals(20.0));

      final age4 = HandwritingDefaultsResolver.resolve(age: 4);
      expect(age4.lineStyle, equals(HandwritingLineStyle.threeLineSeparated));
      expect(age4.rowHeightMm, equals(17.0));

      final age5 = HandwritingDefaultsResolver.resolve(age: 5);
      expect(age5.lineStyle, equals(HandwritingLineStyle.threeLine));
      expect(age5.rowHeightMm, equals(14.0));

      final age6 = HandwritingDefaultsResolver.resolve(age: 6);
      expect(age6.lineStyle, equals(HandwritingLineStyle.threeLine));
      expect(age6.rowHeightMm, equals(12.0));
    });

    test('Grade takes precedence over Age', () {
      // Age 3 alone would resolve twoLineSeparated (20mm), but Grade 1 overrides to threeLine (12mm)
      final resolved = HandwritingDefaultsResolver.resolve(
        grade: KidGrade.grade1,
        age: 3,
      );
      expect(resolved.lineStyle, equals(HandwritingLineStyle.threeLine));
      expect(resolved.rowHeightMm, equals(12.0));
    });
  });

  group('HandwritingConfig Override Tests', () {
    test('worksheet with no override uses global kid profile defaults', () {
      final profile = const KidProfile(age: 4, grade: KidGrade.nursery);
      final config = HandwritingConfig();

      expect(config.getEffectiveLineStyle(profile), equals(HandwritingLineStyle.threeLineSeparated));
      expect(config.getEffectiveRowHeightMm(profile), equals(17.0));
    });

    test('explicit worksheet override overrides global profile defaults', () {
      final profile = const KidProfile(age: 4, grade: KidGrade.nursery);
      final config = HandwritingConfig();

      config.lineStyleOverride = HandwritingLineStyle.twoLine;
      config.rowHeightMmOverride = 22.5;

      expect(config.getEffectiveLineStyle(profile), equals(HandwritingLineStyle.twoLine));
      expect(config.getEffectiveRowHeightMm(profile), equals(22.5));
    });

    test('resetOverrides removes explicit overrides back to global profile defaults', () {
      final profile = const KidProfile(age: 5, grade: KidGrade.kindergarten);
      final config = HandwritingConfig();

      config.lineStyleOverride = HandwritingLineStyle.twoLineSeparated;
      config.rowHeightMmOverride = 25.0;

      config.resetOverrides();

      expect(config.lineStyleOverride, isNull);
      expect(config.rowHeightMmOverride, isNull);
      expect(config.getEffectiveLineStyle(profile), equals(HandwritingLineStyle.threeLine));
      expect(config.getEffectiveRowHeightMm(profile), equals(14.0));
    });
  });

  group('KidProfile Persistence Tests', () {
    test('SettingsService saves and loads KidProfile', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();

      final profile = const KidProfile(age: 6, grade: KidGrade.grade1);
      await SettingsService.saveKidProfile(profile);

      expect(SettingsService.currentKidProfile, equals(profile));

      final jsonStr = SharedPreferences.setMockInitialValues;
      expect(jsonStr, isNotNull);
    });
  });
}
