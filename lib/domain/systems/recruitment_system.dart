// lib/domain/systems/recruitment_system.dart
// Pure Dart recruitment system for walk-ins, scouting, and candidate generation.

import '../models/camp.dart';
import '../models/student.dart';
import '../rng.dart';

class RecruitmentCandidate {
  final Student student;
  final int fee; // 0 for normal walk-ins, 500 for scholarship candidates
  final int potentialStars; // 1..5 stars for preview
  final bool isScholarship;

  const RecruitmentCandidate({
    required this.student,
    required this.fee,
    required this.potentialStars,
    this.isScholarship = false,
  });
}

class RecruitmentSystem {
  static const List<String> availableTraits = [
    'Masipag',
    'Tamad',
    'Matalino',
    'Palaban',
    'Kabado',
    'Maliksi',
    'Matibay',
    'Pasaway',
  ];

  static const List<String> defaultMaleFirstNames = [
    'Bayani', 'Danilo', 'Andres', 'Crisanto', 'Juan', 'Emilio', 'Mateo', 'Lito',
    'Renato', 'Dodong', 'Nonoy', 'Cardo', 'Benjie', 'Kanor', 'Bong', 'Jessie',
  ];

  static const List<String> defaultFemaleFirstNames = [
    'Ligaya', 'Mutya', 'Tala', 'Marilou', 'Luningning', 'Jasmin', 'Rochelle',
    'Dalisay', 'Amihan', 'Perla', 'Mayumi', 'Kristine', 'Elena', 'Rowena',
  ];

  static const List<String> defaultLastNames = [
    'Dalisay', 'Santos', 'Reyes', 'Dela Cruz', 'Bautista', 'Mendoza', 'Alcantara',
    'Villanueva', 'Dimagiba', 'Magtanggol', 'Silang', 'Batungbakal', 'Guinto',
  ];

  static const List<String> defaultNicknames = [
    'Kidlat', 'Agila', 'Tigre', 'Balisong', 'Hagupit', 'Bato', 'Buwaya',
    'Gintong Kamay', 'Mabilis', 'Talas', 'Bagsik', 'Kampilan', 'Laban',
  ];

  /// Calculates walk-in probability for the month tick:
  /// Chance = 10% + 5% per Tarpaulin + fame / 200 (capped at 80%).
  static double calculateWalkInChance({
    required int fame,
    required int tarpaulinCount,
  }) {
    final base = 0.10 + (tarpaulinCount * 0.05) + (fame / 2000.0);
    return base.clamp(0.10, 0.80);
  }

  /// Checks if the camp has space for a new student.
  static bool hasCapacity(Camp camp) {
    final activeCount = camp.students
        .where((s) => s.status == StudentStatus.aktibo || s.status == StudentStatus.injured)
        .length;
    return activeCount < camp.maxStudents;
  }

  /// Generates a procedural candidate with names, grade, 2 distinct traits, and potential.
  static RecruitmentCandidate generateCandidate({
    required GameRng rng,
    required int year,
    bool isScholarship = false,
    List<String>? maleFirstNames,
    List<String>? femaleFirstNames,
    List<String>? lastNames,
    List<String>? nicknames,
  }) {
    final mNames = (maleFirstNames != null && maleFirstNames.isNotEmpty)
        ? maleFirstNames
        : defaultMaleFirstNames;
    final fNames = (femaleFirstNames != null && femaleFirstNames.isNotEmpty)
        ? femaleFirstNames
        : defaultFemaleFirstNames;
    final lNames = (lastNames != null && lastNames.isNotEmpty) ? lastNames : defaultLastNames;
    final nNames = (nicknames != null && nicknames.isNotEmpty) ? nicknames : defaultNicknames;

    final isMale = rng.nextBool();
    final gender = isMale ? 'Lalaki' : 'Babae';
    final firstName = isMale ? mNames[rng.nextInt(mNames.length)] : fNames[rng.nextInt(fNames.length)];
    final lastName = lNames[rng.nextInt(lNames.length)];
    final nickname = nNames[rng.nextInt(nNames.length)];

    // Grade 4 to Grade 10 at recruitment
    final grade = rng.nextInt(7) + 4; // 4..10
    final age = grade + 6; // e.g. Grade 4 = 10 yrs old, Grade 10 = 16 yrs old

    // Potential: standard 0.70..1.25, scholarship 1.15..1.45
    double potential = isScholarship
        ? 1.15 + (rng.nextDouble() * 0.30)
        : 0.70 + (rng.nextDouble() * 0.55);
    potential = (potential * 100).round() / 100.0;

    // Convert potential to stars (1..5)
    // 0.70..0.85 = 1 star, 0.86..1.00 = 2 stars, 1.01..1.15 = 3 stars, 1.16..1.30 = 4 stars, 1.31+ = 5 stars
    int stars = 1;
    if (potential >= 1.30) {
      stars = 5;
    } else if (potential >= 1.15) {
      stars = 4;
    } else if (potential >= 1.00) {
      stars = 3;
    } else if (potential >= 0.85) {
      stars = 2;
    }

    // Pick 2 distinct traits
    final traitPool = List<String>.from(availableTraits);
    final trait1Index = rng.nextInt(traitPool.length);
    final trait1 = traitPool.removeAt(trait1Index);
    final trait2 = traitPool[rng.nextInt(traitPool.length)];

    // Initial stats scaled slightly by grade
    final baseStat = 10.0 + (grade * 1.2);
    final lakas = baseStat + (rng.nextDouble() * 4.0);
    final bilis = baseStat + (rng.nextDouble() * 4.0);
    final diskarte = baseStat + (rng.nextDouble() * 4.0);
    final salag = baseStat + (rng.nextDouble() * 4.0);

    final look = StudentLook(
      bodyTypeId: isMale ? 'body_a' : 'body_b',
      skinIndex: rng.nextInt(3),
      hairIndex: rng.nextInt(4),
      hairColorIndex: rng.nextInt(3),
      outfitColorIndex: rng.nextInt(4),
      headbandColorIndex: rng.nextInt(4),
    );

    final uniqueId = 'std_${year}_${DateTime.now().microsecondsSinceEpoch % 1000000}_${rng.nextInt(1000)}';

    final student = Student(
      id: uniqueId,
      name: '$firstName $lastName',
      nickname: nickname,
      age: age,
      gender: gender,
      grade: grade,
      gradePercent: 78.0 + (rng.nextDouble() * 15.0),
      lakas: (lakas * 10).round() / 10.0,
      bilis: (bilis * 10).round() / 10.0,
      diskarte: (diskarte * 10).round() / 10.0,
      salag: (salag * 10).round() / 10.0,
      fatigue: 0.0,
      morale: 80.0,
      style: ArnisStyle.values[rng.nextInt(ArnisStyle.values.length)],
      traits: [trait1, trait2],
      tuition: 50,
      potential: potential,
      look: look,
    );

    return RecruitmentCandidate(
      student: student,
      fee: isScholarship ? 500 : 0,
      potentialStars: stars,
      isScholarship: isScholarship,
    );
  }

  /// Enrolls candidate into the camp after verifying fee and capacity.
  static bool enrollCandidate({
    required Camp camp,
    required RecruitmentCandidate candidate,
  }) {
    if (!hasCapacity(camp)) return false;
    if (camp.money < candidate.fee) return false;

    camp.money -= candidate.fee;
    camp.students.add(candidate.student);
    return true;
  }
}
