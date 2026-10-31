// test/events_recruitment_graduation_test.dart
// Unit tests for EventSystem, RecruitmentSystem, and GraduationSystem (Phase 6).

import 'package:flutter_test/flutter_test.dart';
import 'package:bastonero_arnis_story/domain/models/alumni.dart';
import 'package:bastonero_arnis_story/domain/models/camp.dart';
import 'package:bastonero_arnis_story/domain/models/equipment.dart';
import 'package:bastonero_arnis_story/domain/models/event.dart';
import 'package:bastonero_arnis_story/domain/models/student.dart';
import 'package:bastonero_arnis_story/domain/rng.dart';
import 'package:bastonero_arnis_story/domain/systems/event_system.dart';
import 'package:bastonero_arnis_story/domain/systems/graduation_system.dart';
import 'package:bastonero_arnis_story/domain/systems/recruitment_system.dart';

void main() {
  group('EventSystem - Triggering & Effects', () {
    late List<GameEvent> sampleEvents;
    late Camp testCamp;
    late EventSystem eventSystem;

    setUp(() {
      sampleEvents = [
        const GameEvent(
          id: 'pasko',
          title: 'Pasko sa Bakuran',
          tag: 'positive',
          text: 'Pasko sa bakuran!',
          triggerMonth: 12,
          effects: {'moraleGain': 15, 'moneyGain': 500},
        ),
        const GameEvent(
          id: 'bagyo',
          title: 'Malakas na Bagyo',
          tag: 'negative',
          text: 'Bumuhos ang bagyo!',
          triggerMonth: 7,
          effects: {'trainingBlocked': true, 'costBase': 400},
        ),
        const GameEvent(
          id: 'alumni_returns',
          title: 'Pagbabalik ng Alumnus',
          tag: 'positive',
          text: 'Bumalik ang dati mong kampeon.',
          condition: 'has_alumni',
          effects: {'moneyGain': 800, 'moraleGain': 10},
        ),
        const GameEvent(
          id: 'magulang_reklamo',
          title: 'Magulang na Nagrereklamo',
          tag: 'negative',
          text: 'Nag-aalala ang magulang.',
          condition: 'has_failing_student',
          effects: {'gradeWarning': true},
        ),
        const GameEvent(
          id: 'taho_treat',
          title: 'Mainit na Taho',
          tag: 'positive',
          text: 'Masarap na meryenda!',
          effects: {'moraleGain': 8, 'fatigueRelief': 15},
        ),
      ];

      testCamp = Camp(name: 'Subok Camp', money: 1000);
      eventSystem = EventSystem(events: sampleEvents);
    });

    test('Pasko triggers automatically in December Week 4', () {
      final rng = GameRng(42);
      final ev = eventSystem.rollWeeklyEvent(
        camp: testCamp,
        month: 12,
        week: 4,
        rng: rng,
        cooldowns: {},
      );

      expect(ev, isNotNull);
      expect(ev!.id, 'pasko');
    });

    test('Cooldown prevents event from triggering again prematurely', () {
      final rng = GameRng(42);
      final ev = eventSystem.rollWeeklyEvent(
        camp: testCamp,
        month: 12,
        week: 4,
        rng: rng,
        cooldowns: {'pasko': 5},
      );

      expect(ev?.id, isNot('pasko'));
    });

    test('Conditional event has_alumni triggers only if camp has alumni', () {
      final alumnusEvent = sampleEvents.firstWhere((e) => e.id == 'alumni_returns');

      // Without alumni -> cannot trigger
      expect(eventSystem.canTrigger(alumnusEvent, testCamp, 6, 2, {}), isFalse);

      // Add alumnus -> can trigger
      testCamp.alumni.add(Alumnus(
        id: 'alm_1',
        studentId: 'std_1',
        name: 'Bayani Alumnus',
        graduatedYear: 1,
        graduatedMonth: 3,
        lakas: 50,
        bilis: 40,
        diskarte: 45,
        salag: 35,
      ));

      expect(eventSystem.canTrigger(alumnusEvent, testCamp, 6, 2, {}), isTrue);
    });

    test('Conditional event has_failing_student triggers only when a student is below 75%', () {
      final complaintEvent = sampleEvents.firstWhere((e) => e.id == 'magulang_reklamo');

      // All default starter students have passing grades (85%+)
      expect(eventSystem.canTrigger(complaintEvent, testCamp, 6, 2, {}), isFalse);

      // Make one student fail
      testCamp.students.first.gradePercent = 70.0;
      expect(eventSystem.canTrigger(complaintEvent, testCamp, 6, 2, {}), isTrue);
    });

    test('Applying event effects updates camp money, fame, morale, and fatigue', () {
      final rng = GameRng(42);
      final tahoEvent = sampleEvents.firstWhere((e) => e.id == 'taho_treat');
      final student = testCamp.students.first;
      student.morale = 60.0;
      student.fatigue = 50.0;

      final res = eventSystem.applyEventEffects(
        event: tahoEvent,
        camp: testCamp,
        rng: rng,
      );

      expect(res.moraleDelta, 8.0);
      expect(res.fatigueDelta, -15.0);
      expect(student.morale, 68.0);
      expect(student.fatigue, 35.0);
    });
  });

  group('RecruitmentSystem - Walk-ins & Capacity', () {
    late Camp camp;

    setUp(() {
      camp = Camp(name: 'Recruit Camp', money: 1000, floors: 1);
    });

    test('Walk-in chance formula scales with tarpaulins and fame', () {
      final baseChance = RecruitmentSystem.calculateWalkInChance(fame: 0, tarpaulinCount: 0);
      expect(baseChance, closeTo(0.10, 0.001));

      // 2 Tarpaulins (+10%) and 400 fame (+20%) = 40%
      final boostedChance = RecruitmentSystem.calculateWalkInChance(fame: 400, tarpaulinCount: 2);
      expect(boostedChance, closeTo(0.40, 0.001));
    });

    test('Capacity limits enrollment up to max students', () {
      // 1 floor = 8 students max
      expect(camp.maxStudents, 8);
      expect(camp.students.length, 3); // 3 starters
      expect(RecruitmentSystem.hasCapacity(camp), isTrue);

      final rng = GameRng(101);
      while (camp.students.length < 8) {
        final cand = RecruitmentSystem.generateCandidate(rng: rng, year: 1);
        final enrolled = RecruitmentSystem.enrollCandidate(camp: camp, candidate: cand);
        expect(enrolled, isTrue);
      }

      expect(camp.students.length, 8);
      expect(RecruitmentSystem.hasCapacity(camp), isFalse);

      // Attempting to enroll 9th student fails
      final extraCand = RecruitmentSystem.generateCandidate(rng: rng, year: 1);
      final failed = RecruitmentSystem.enrollCandidate(camp: camp, candidate: extraCand);
      expect(failed, isFalse);
    });

    test('Placing benches (bangko) and sparring mats (banig) increases capacity', () {
      expect(camp.maxStudents, 8);

      camp.placements.add(PlacedEquipment(
        instanceId: 'inst_1',
        equipmentId: 'bangko',
        floor: 1,
        tileX: 0,
      ));
      camp.placements.add(PlacedEquipment(
        instanceId: 'inst_2',
        equipmentId: 'banig',
        floor: 1,
        tileX: 2,
      ));

      // 4 + (1 * 4) + (2 * 2) = 12
      expect(camp.maxStudents, 12);
    });

    test('Candidate generation produces valid names, traits, and potential stars', () {
      final rng = GameRng(99);
      final normalCandidate = RecruitmentSystem.generateCandidate(
        rng: rng,
        year: 1,
        isScholarship: false,
      );

      expect(normalCandidate.student.name, isNotEmpty);
      expect(normalCandidate.student.traits.length, 2);
      expect(normalCandidate.fee, 0);
      expect(normalCandidate.potentialStars, inInclusiveRange(1, 5));

      final scholarCandidate = RecruitmentSystem.generateCandidate(
        rng: rng,
        year: 1,
        isScholarship: true,
      );
      expect(scholarCandidate.fee, 500);
      expect(scholarCandidate.student.potential, greaterThanOrEqualTo(1.15));
      expect(scholarCandidate.potentialStars, inInclusiveRange(4, 5));
    });
  });

  group('GraduationSystem - Promotion, Graduation, and Alumni', () {
    late Camp camp;

    setUp(() {
      camp = Camp(name: 'Grad Camp', money: 2000, floors: 1);
    });

    test('Students with Grade 12 or Age 18+ are eligible to graduate', () {
      final seniorStudent = Student(
        id: 'std_grad_1',
        name: 'Lorenzo Senior',
        grade: 12,
        gradePercent: 88.0,
        age: 18,
        lakas: 60.0,
        bilis: 45.0,
        diskarte: 40.0,
        salag: 35.0,
        titles: ['Kampyon ng Inter-Purok', 'Kampyon ng Intrams'],
      );
      camp.students.add(seniorStudent);

      final candidates = GraduationSystem.checkGraduationCandidates(camp);
      expect(candidates.length, 1);
      expect(candidates.first.student.id, 'std_grad_1');
      expect(candidates.first.bestSpecialty, 'lakas');
      // 100 base + 2 * 150 = 400
      expect(candidates.first.monthlySponsorshipEstimate, 400);
    });

    test('Graduating as Trainer adds Guro with matching specialty and salary to Camp', () {
      final student = Student(
        id: 'std_grad_trainer',
        name: 'Andres Kidlat',
        grade: 12,
        gradePercent: 85.0,
        age: 18,
        lakas: 30.0,
        bilis: 85.0, // Best stat is Bilis
        diskarte: 40.0,
        salag: 30.0,
      );
      camp.students.add(student);

      final alumnus = GraduationSystem.graduate(
        camp: camp,
        student: student,
        role: AlumniRole.trainer,
        year: 2,
        month: 3,
      );

      expect(alumnus.role, AlumniRole.trainer);
      expect(student.status, StudentStatus.graduated);
      expect(camp.alumni.length, 1);

      // Verify added Trainer
      expect(camp.trainers.length, 1);
      final newTrainer = camp.trainers.first;
      expect(newTrainer.name, contains('Andres Kidlat'));
      expect(newTrainer.specialty, 'bilis');
      expect(newTrainer.skill, greaterThanOrEqualTo(2));
    });

    test('Graduating as Sponsor increases camp monthly alumni sponsorships', () {
      final student = Student(
        id: 'std_grad_sponsor',
        name: 'Cardo Dalisay',
        grade: 12,
        gradePercent: 82.0,
        age: 18,
        lakas: 50.0,
        bilis: 50.0,
        diskarte: 50.0,
        salag: 50.0,
        titles: ['Inter-Purok Kampeon', 'Inter-Barangay Kampeon'],
      );
      camp.students.add(student);

      final alumnus = GraduationSystem.graduate(
        camp: camp,
        student: student,
        role: AlumniRole.sponsor,
        year: 2,
        month: 3,
      );

      expect(alumnus.role, AlumniRole.sponsor);
      // 100 + (2 * 150) = 400
      expect(alumnus.monthlySponsorship, 400);
      expect(camp.monthlyAlumniSponsorships, 400);
    });

    test('Graduating as Hall of Fame grants permanent fame bonus', () {
      final initialFame = camp.fame;
      final student = Student(
        id: 'std_grad_hof',
        name: 'Mutya Silang',
        grade: 12,
        gradePercent: 92.0,
        age: 18,
        lakas: 70.0,
        bilis: 65.0,
        diskarte: 60.0,
        salag: 55.0,
      );
      camp.students.add(student);

      GraduationSystem.graduate(
        camp: camp,
        student: student,
        role: AlumniRole.hallOfFame,
        year: 2,
        month: 3,
      );

      expect(camp.fame, initialFame + 50);
    });

    test('End of School Year evaluation promotes passing students and ages all students', () {
      final std1 = camp.students[0]; // Grade 5
      std1.gradePercent = 85.0;
      final initialAge = std1.age;

      final result = GraduationSystem.processSchoolYearEnd(camp: camp, year: 1);

      expect(std1.age, initialAge + 1);
      expect(std1.grade, 6); // Promoted to Grade 6
      expect(result.promotedStudents.contains(std1), isTrue);
    });
  });
}
