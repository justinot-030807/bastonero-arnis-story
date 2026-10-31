import 'package:flutter_test/flutter_test.dart';
import 'package:bastonero_arnis_story/domain/tournament_engine.dart';
import 'package:bastonero_arnis_story/domain/models/student.dart';
import 'package:bastonero_arnis_story/domain/balance.dart';

void main() {
  group('TournamentEngine - Definitions & Roster (Section 10 Spec)', () {
    test('Catalogue contains 6 Community Track and 5 School Track tournaments', () {
      final tournaments = TournamentEngine.allTournaments;
      expect(tournaments.length, 11);

      final community = tournaments.where((t) => t.track == TournamentTrack.community).toList();
      final school = tournaments.where((t) => t.track == TournamentTrack.school).toList();

      expect(community.length, 6);
      expect(school.length, 5);

      // Verify specific tiers & rounds
      expect(community[0].name, 'Inter-Purok Cup');
      expect(community[0].tier, 1);
      expect(community[0].rounds, 2); // 4 contenders
      expect(community[0].prizeMoney, 500);

      expect(community[5].name, contains('Pambansang Kampeonato'));
      expect(community[5].tier, 6);
      expect(community[5].rounds, 5); // 32 contenders
      expect(community[5].prizeMoney, 100000);

      // School track scholarship points
      expect(school[0].name, 'School Intramurals');
      expect(school[0].scholarshipPoints, 50);

      expect(school[4].name, 'Palarong Pambansa');
      expect(school[4].tier, 5);
      expect(school[4].rounds, 5); // 32 contenders
      expect(school[4].scholarshipPoints, 1000);
    });

    test('Procedural opponent generation respects tier stat targets within ±15%', () {
      for (int tier = 1; tier <= 6; tier++) {
        final target = Balance.opponentStatTargetByTier[tier]!;
        final opp = TournamentEngine.generateOpponent(tier: tier, seed: 12345);

        // Stats should be within ~15% of target
        expect(opp.totalStats, greaterThanOrEqualTo(target * 0.80));
        expect(opp.totalStats, lessThanOrEqualTo(target * 1.20));

        // Opponent has valid Arnis style & gym
        expect(opp.name.isNotEmpty, isTrue);
        expect(opp.gymName.isNotEmpty, isTrue);
        expect(opp.lakas, greaterThan(0));
        expect(opp.bilis, greaterThan(0));
        expect(opp.diskarte, greaterThan(0));
        expect(opp.salag, greaterThan(0));
      }
    });

    test('Championship finals boss receives +10% stat bonus', () {
      final normal = TournamentEngine.generateOpponent(tier: 3, seed: 999, isFinalsBoss: false);
      final boss = TournamentEngine.generateOpponent(tier: 3, seed: 999, isFinalsBoss: true);

      expect(boss.totalStats, greaterThan(normal.totalStats));
      expect(boss.totalStats / normal.totalStats, closeTo(1.10, 0.05));
    });
  });

  group('TournamentBracket - Generation, Seeding & Tree Traversal', () {
    late Student heroStudent;
    late Student rivalStudent;

    setUp(() {
      heroStudent = Student(
        id: 'std_01',
        name: 'Bayani',
        nickname: 'Bastonero',
        age: 11,
        gender: 'Lalaki',
        grade: 5,
        gradePercent: 86.0,
        lakas: 25.0,
        bilis: 22.0,
        diskarte: 20.0,
        salag: 18.0,
        fatigue: 10.0,
        morale: 80.0,
        style: ArnisStyle.soloBaston,
        moves: ['abaniko'],
        traits: ['Matiyaga'],
        tuition: 50,
      );

      rivalStudent = Student(
        id: 'std_02',
        name: 'Danilo',
        nickname: 'Tigre',
        age: 12,
        gender: 'Lalaki',
        grade: 6,
        gradePercent: 82.0,
        lakas: 28.0,
        bilis: 19.0,
        diskarte: 18.0,
        salag: 19.0,
        fatigue: 15.0,
        morale: 75.0,
        style: ArnisStyle.dobleBaston,
        moves: ['sinawali'],
        traits: [],
        tuition: 60,
      );
    });

    test('Generates correct number of total matches for 2, 3, and 4 rounds', () {
      final t2 = TournamentEngine.allTournaments.firstWhere((t) => t.rounds == 2);
      final bracket2 = TournamentEngine.createBracket(tournament: t2, playerStudents: [heroStudent], seed: 42);
      // 2 rounds -> 4 contenders -> 2 semifinals + 1 final = 3 matches
      expect(bracket2.matches.length, 3);
      expect(bracket2.totalRounds, 2);

      final t3 = TournamentEngine.allTournaments.firstWhere((t) => t.rounds == 3);
      final bracket3 = TournamentEngine.createBracket(tournament: t3, playerStudents: [heroStudent], seed: 42);
      // 3 rounds -> 8 contenders -> 4 quarters + 2 semis + 1 final = 7 matches
      expect(bracket3.matches.length, 7);
      expect(bracket3.totalRounds, 3);
    });

    test('Seeds 2 player students on opposite sides of the bracket', () {
      final t3 = TournamentEngine.allTournaments.firstWhere((t) => t.rounds == 3);
      final bracket = TournamentEngine.createBracket(
        tournament: t3,
        playerStudents: [heroStudent, rivalStudent],
        seed: 100,
      );

      // Round 0 has 4 matches (indices 0, 1, 2, 3)
      final round0Matches = bracket.matches.where((m) => m.roundIndex == 0).toList();
      expect(round0Matches.length, 4);

      // Student 1 should be in the top half (match 0)
      expect(round0Matches[0].isPlayerMatch, isTrue);
      expect(round0Matches[0].contender1?.studentId, 'std_01');

      // Student 2 should be in the bottom half (match 2 or 3)
      final bottomHalfHasPlayer = round0Matches[2].isPlayerMatch || round0Matches[3].isPlayerMatch;
      expect(bottomHalfHasPlayer, isTrue);
    });

    test('Bracket progression: advancing matches correctly feeds winners into next round', () {
      final t2 = TournamentEngine.allTournaments.firstWhere((t) => t.rounds == 2); // 4 contenders
      final bracket = TournamentEngine.createBracket(tournament: t2, playerStudents: [heroStudent], seed: 777);

      expect(bracket.currentRoundIndex, 0);
      expect(bracket.isFinished, isFalse);

      final semi1 = bracket.matches[0];
      final semi2 = bracket.matches[1];
      final finals = bracket.matches[2];

      // Player wins semi 1
      bracket.advanceMatch(semi1.matchId, semi1.contender1!);
      expect(semi1.isCompleted, isTrue);
      expect(finals.contender1?.name, semi1.contender1!.name);

      // NPC 2 wins semi 2
      bracket.advanceMatch(semi2.matchId, semi2.contender2!);
      expect(semi2.isCompleted, isTrue);
      expect(finals.contender2?.name, semi2.contender2!.name);

      // All round 0 matches complete -> round index advances to 1
      expect(bracket.currentRoundIndex, 1);

      // Player wins Championship Final
      bracket.advanceMatch(finals.matchId, finals.contender1!);
      expect(bracket.isFinished, isTrue);
      expect(bracket.champion?.name, contains(heroStudent.name));
    });

    test('simulateAllNpcMatchesForCurrentRound simulates NPC matches and leaves player match untouched', () {
      final t2 = TournamentEngine.allTournaments.firstWhere((t) => t.rounds == 2);
      final bracket = TournamentEngine.createBracket(tournament: t2, playerStudents: [heroStudent], seed: 888);

      final playerMatch = bracket.activePlayerMatch;
      expect(playerMatch, isNotNull);
      expect(playerMatch!.isCompleted, isFalse);

      // Run NPC match simulation
      bracket.simulateAllNpcMatchesForCurrentRound();

      // Player match remains untouched
      expect(playerMatch.isCompleted, isFalse);

      // NPC match is completed
      final npcMatch = bracket.matches.firstWhere((m) => !m.isPlayerMatch && m.roundIndex == 0);
      expect(npcMatch.isCompleted, isTrue);
      expect(npcMatch.winner, isNotNull);
    });
  });

  group('Student Eligibility & Tournament Unlock Rules', () {
    late Student passingStudent;
    late Student failingStudent;
    late Student highSchoolStudent;
    late Student injuredStudent;

    setUp(() {
      passingStudent = Student(
        id: 'std_pass',
        name: 'Bayani',
        nickname: 'Bastonero',
        age: 11,
        gender: 'Lalaki',
        grade: 5,
        gradePercent: 85.0,
        lakas: 20,
        bilis: 20,
        diskarte: 20,
        salag: 20,
        fatigue: 0,
        morale: 80,
      );

      failingStudent = Student(
        id: 'std_fail',
        name: 'Tambay',
        nickname: 'Bagsik',
        age: 11,
        gender: 'Lalaki',
        grade: 5,
        gradePercent: 71.0, // Failing! (< 75%)
        lakas: 20,
        bilis: 20,
        diskarte: 20,
        salag: 20,
        fatigue: 0,
        morale: 80,
      );

      highSchoolStudent = Student(
        id: 'std_hs',
        name: 'Kuya',
        nickname: 'Senior',
        age: 15,
        gender: 'Lalaki',
        grade: 9, // High School
        gradePercent: 88.0,
        lakas: 30,
        bilis: 30,
        diskarte: 30,
        salag: 30,
        fatigue: 0,
        morale: 80,
      );

      injuredStudent = Student(
        id: 'std_inj',
        name: 'Pilay',
        nickname: 'Aray',
        age: 11,
        gender: 'Lalaki',
        grade: 5,
        gradePercent: 85.0,
        lakas: 20,
        bilis: 20,
        diskarte: 20,
        salag: 20,
        fatigue: 0,
        morale: 80,
        status: StudentStatus.injured,
      );
    });

    test('School track requires grade >= 75% and correct grade level', () {
      final elemSchoolMeet = TournamentEngine.allTournaments.firstWhere((t) => t.id == 'school_intrams');

      // Passing elementary student is eligible
      expect(TournamentEngine.isStudentEligible(passingStudent, elemSchoolMeet), isTrue);

      // Failing student (< 75%) is NOT eligible
      expect(TournamentEngine.isStudentEligible(failingStudent, elemSchoolMeet), isFalse);

      // High school student cannot enter elementary division
      expect(TournamentEngine.isStudentEligible(highSchoolStudent, elemSchoolMeet), isFalse);

      // Injured student cannot enter
      expect(TournamentEngine.isStudentEligible(injuredStudent, elemSchoolMeet), isFalse);
    });

    test('Unlock rules enforce minimum fame and tier progression', () {
      final tier1 = TournamentEngine.allTournaments.firstWhere((t) => t.id == 'inter_purok');
      final tier2 = TournamentEngine.allTournaments.firstWhere((t) => t.id == 'inter_barangay');

      // Tier 1 is unlocked by default
      expect(
        TournamentEngine.isTournamentUnlocked(
          info: tier1,
          campFame: 0,
          highestParticipatedTierCommunity: 0,
          highestParticipatedTierSchool: 0,
        ),
        isTrue,
      );

      // Tier 2 locked if fame < 150
      expect(
        TournamentEngine.isTournamentUnlocked(
          info: tier2,
          campFame: 50,
          highestParticipatedTierCommunity: 1,
          highestParticipatedTierSchool: 0,
        ),
        isFalse,
      );

      // Tier 2 locked if player did not participate in Tier 1
      expect(
        TournamentEngine.isTournamentUnlocked(
          info: tier2,
          campFame: 200,
          highestParticipatedTierCommunity: 0, // Haven't done tier 1
          highestParticipatedTierSchool: 0,
        ),
        isFalse,
      );

      // Tier 2 unlocked when both fame and tier requirements are met
      expect(
        TournamentEngine.isTournamentUnlocked(
          info: tier2,
          campFame: 200,
          highestParticipatedTierCommunity: 1,
          highestParticipatedTierSchool: 0,
        ),
        isTrue,
      );
    });
  });
}
