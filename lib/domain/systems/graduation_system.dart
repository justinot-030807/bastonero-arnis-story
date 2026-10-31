// lib/domain/systems/graduation_system.dart
// Pure Dart graduation and alumni system for student advancement and legacy.

import '../models/alumni.dart';
import '../models/camp.dart';
import '../models/student.dart';

class GraduationCandidate {
  final Student student;
  final String reason; // 'Nakatapos ng Grade 12' or 'Edad 18+ (Bukas / Adult)'
  final String bestSpecialty;
  final int trainerSkill;
  final int monthlySponsorshipEstimate;

  const GraduationCandidate({
    required this.student,
    required this.reason,
    required this.bestSpecialty,
    required this.trainerSkill,
    required this.monthlySponsorshipEstimate,
  });
}

class SchoolYearEvaluationResult {
  final List<Student> promotedStudents;
  final List<Student> retainedStudents;
  final List<GraduationCandidate> graduationCandidates;

  const SchoolYearEvaluationResult({
    required this.promotedStudents,
    required this.retainedStudents,
    required this.graduationCandidates,
  });
}

class GraduationSystem {
  /// Evaluates which students can graduate at this point in time.
  static List<GraduationCandidate> checkGraduationCandidates(Camp camp) {
    final candidates = <GraduationCandidate>[];

    for (final s in camp.students) {
      if (s.status != StudentStatus.aktibo && s.status != StudentStatus.injured) {
        continue;
      }

      bool isGraduationReady = false;
      String reason = '';

      if (s.grade >= 12 && s.gradePercent >= 75.0) {
        isGraduationReady = true;
        reason = 'Nakatapos ng Grade 12 (Senior High School)';
      } else if (s.age >= 18) {
        isGraduationReady = true;
        reason = 'Sumapit sa edad 18 (Bukas / Adult Division)';
      }

      if (isGraduationReady) {
        // Calculate best stat
        String specialty = 'lakas';
        double highest = s.lakas;
        if (s.bilis > highest) {
          highest = s.bilis;
          specialty = 'bilis';
        }
        if (s.diskarte > highest) {
          highest = s.diskarte;
          specialty = 'diskarte';
        }
        if (s.salag > highest) {
          highest = s.salag;
          specialty = 'salag';
        }

        final trainerSkill = (highest / 40.0).clamp(1, 5).toInt();
        final sponsorshipEstimate = 100 + (s.titles.length * 150);

        candidates.add(GraduationCandidate(
          student: s,
          reason: reason,
          bestSpecialty: specialty,
          trainerSkill: trainerSkill,
          monthlySponsorshipEstimate: sponsorshipEstimate,
        ));
      }
    }

    return candidates;
  }

  /// Processes end-of-school-year progression (in March, Month 3 Week 4).
  /// Promotes passing students to the next grade and identifies graduation candidates.
  static SchoolYearEvaluationResult processSchoolYearEnd({
    required Camp camp,
    required int year,
  }) {
    final promoted = <Student>[];
    final retained = <Student>[];

    for (final s in camp.students) {
      if (s.status != StudentStatus.aktibo && s.status != StudentStatus.injured) {
        continue;
      }

      // Age increment
      s.age += 1;

      // Grade progression if in school
      if (s.grade > 0 && s.grade < 12) {
        if (s.gradePercent >= 75.0) {
          s.grade += 1;
          promoted.add(s);
        } else {
          retained.add(s);
        }
      }
    }

    final gradCandidates = checkGraduationCandidates(camp);

    return SchoolYearEvaluationResult(
      promotedStudents: promoted,
      retainedStudents: retained,
      graduationCandidates: gradCandidates,
    );
  }

  /// Executes graduation for a student, removing them from active student roster
  /// and assigning them to their selected Alumni role.
  static Alumnus graduate({
    required Camp camp,
    required Student student,
    required AlumniRole role,
    required int year,
    required int month,
  }) {
    final alumnus = camp.graduateStudent(
      student: student,
      role: role,
      year: year,
      month: month,
    );
    return alumnus;
  }
}
