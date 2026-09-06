enum KidGrade {
  playgroup,
  preschool,
  nursery,
  kindergarten,
  homeschool,
  grade1,
  grade2,
  grade3Plus,
}

extension KidGradeExtension on KidGrade {
  String get label {
    switch (this) {
      case KidGrade.playgroup:
        return "Playgroup / PG";
      case KidGrade.preschool:
        return "Preschool";
      case KidGrade.nursery:
        return "Nursery";
      case KidGrade.kindergarten:
        return "Kindergarten / KG";
      case KidGrade.homeschool:
        return "Homeschool";
      case KidGrade.grade1:
        return "Grade 1";
      case KidGrade.grade2:
        return "Grade 2";
      case KidGrade.grade3Plus:
        return "Grade 3+";
    }
  }

  String get shortName {
    switch (this) {
      case KidGrade.playgroup:
        return "Playgroup";
      case KidGrade.preschool:
        return "Preschool";
      case KidGrade.nursery:
        return "Nursery";
      case KidGrade.kindergarten:
        return "Kindergarten";
      case KidGrade.homeschool:
        return "Homeschool";
      case KidGrade.grade1:
        return "Grade 1";
      case KidGrade.grade2:
        return "Grade 2";
      case KidGrade.grade3Plus:
        return "Grade 3+";
    }
  }

  int get typicalAge {
    switch (this) {
      case KidGrade.playgroup:
        return 3;
      case KidGrade.preschool:
        return 3;
      case KidGrade.nursery:
        return 4;
      case KidGrade.kindergarten:
        return 5;
      case KidGrade.homeschool:
        return 5;
      case KidGrade.grade1:
        return 6;
      case KidGrade.grade2:
        return 7;
      case KidGrade.grade3Plus:
        return 8;
    }
  }
}

class KidProfile {
  final int age;
  final KidGrade grade;

  const KidProfile({this.age = 4, this.grade = KidGrade.nursery});

  KidProfile copyWith({int? age, KidGrade? grade}) {
    return KidProfile(age: age ?? this.age, grade: grade ?? this.grade);
  }

  Map<String, dynamic> toJson() {
    return {'age': age, 'grade': grade.name};
  }

  factory KidProfile.fromJson(Map<String, dynamic> json) {
    final age = json['age'] is int ? json['age'] as int : 4;
    final gradeName = json['grade'] as String?;
    final grade = KidGrade.values.firstWhere(
      (e) => e.name == gradeName,
      orElse: () => KidGrade.nursery,
    );
    return KidProfile(age: age, grade: grade);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KidProfile &&
          runtimeType == other.runtimeType &&
          age == other.age &&
          grade == other.grade;

  @override
  int get hashCode => age.hashCode ^ grade.hashCode;
}
