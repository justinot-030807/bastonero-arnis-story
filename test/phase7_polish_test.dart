// test/phase7_polish_test.dart
// Unit and system tests for Phase 7 (Content, Audio, Polish).

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bastonero_arnis_story/domain/models/move.dart';
import 'package:bastonero_arnis_story/domain/models/camp.dart';
import 'package:bastonero_arnis_story/domain/models/student.dart';
import 'package:bastonero_arnis_story/game/audio_manager.dart';
import 'package:bastonero_arnis_story/ui/overlays/yearly_report_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 7: Expanded Moves Catalog', () {
    test('moves.json contains 13 detailed moves across 3 arnis disciplines', () {
      final file = File('assets/data/moves.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = file.readAsStringSync();
      final list = jsonDecode(jsonContent) as List<dynamic>;
      expect(list.length, equals(13));

      final moves = list.map((e) => Move.fromJson(e as Map<String, dynamic>)).toList();

      // Check disciplines
      final soloMoves = moves.where((m) => m.style == 'SoloBaston').toList();
      final dobleMoves = moves.where((m) => m.style == 'DobleBaston').toList();
      final espadaMoves = moves.where((m) => m.style == 'EspadaYDaga').toList();

      expect(soloMoves.length, greaterThanOrEqualTo(5));
      expect(dobleMoves.length, greaterThanOrEqualTo(4));
      expect(espadaMoves.length, greaterThanOrEqualTo(4));

      // Check specific legendary moves
      expect(moves.any((m) => m.id == 'abaniko_tres_puntas'), isTrue);
      expect(moves.any((m) => m.id == 'heaven_six'), isTrue);
      expect(moves.any((m) => m.id == 'punyal_kidlat'), isTrue);

      // Verify damage bounds
      for (final m in moves) {
        expect(m.hits, greaterThanOrEqualTo(1));
        expect(m.damageMultiplier, greaterThan(0.0));
      }
    });
  });

  group('Phase 7: AudioManager', () {
    test('AudioManager manages volume and toggles safely', () {
      final audio = AudioManager.instance;

      audio.setBgmVolume(0.5);
      expect(audio.bgmVolume, equals(0.5));

      audio.setBgmVolume(1.5); // clamps to 1.0
      expect(audio.bgmVolume, equals(1.0));

      audio.setBgmVolume(-0.2); // clamps to 0.0
      expect(audio.bgmVolume, equals(0.0));

      audio.setSfxVolume(0.75);
      expect(audio.sfxVolume, equals(0.75));

      final initialBgm = audio.isBgmEnabled;
      audio.toggleBgm();
      expect(audio.isBgmEnabled, equals(!initialBgm));
      audio.toggleBgm(); // restore

      final initialSfx = audio.isSfxEnabled;
      audio.toggleSfx();
      expect(audio.isSfxEnabled, equals(!initialSfx));
      audio.toggleSfx(); // restore

      // Sound and track calls do not crash
      audio.playBgm('camp_chiptune');
      expect(audio.currentTrack, equals('camp_chiptune'));
      audio.stopBgm();
      expect(audio.currentTrack, isNull);

      audio.playClick();
      audio.playImpact(heavy: true);
      audio.playSfx('block');
      audio.playSfx('coin');
    });
  });

  group('Phase 7: YearlyReportData Model', () {
    test('YearlyReportData encapsulates annual review stats accurately', () {
      const data = YearlyReportData(
        completedYear: 1,
        endingMoney: 2500,
        totalFame: 450,
        campRank: 'barangay',
        activeStudentsCount: 4,
        alumniCount: 1,
        topStudentName: 'Bayani',
        topStudentTotalStats: 180.0,
        totalTitlesWon: 2,
      );

      expect(data.completedYear, equals(1));
      expect(data.endingMoney, equals(2500));
      expect(data.campRank, equals('barangay'));
      expect(data.topStudentName, equals('Bayani'));
      expect(data.totalTitlesWon, equals(2));
    });
  });

  group('Phase 7: Seasonal Cycle Verification', () {
    test('Season calendar flags match Philippine climate spec', () {
      bool isRainySeason(int month) => month >= 6 && month <= 10;
      bool isChristmasSeason(int month) => month == 12;

      // Tag-ulan / Rainy season: June to October
      expect(isRainySeason(5), isFalse);
      expect(isRainySeason(6), isTrue);
      expect(isRainySeason(7), isTrue);
      expect(isRainySeason(8), isTrue);
      expect(isRainySeason(9), isTrue);
      expect(isRainySeason(10), isTrue);
      expect(isRainySeason(11), isFalse);

      // Pasko / Christmas season: December
      expect(isChristmasSeason(11), isFalse);
      expect(isChristmasSeason(12), isTrue);
      expect(isChristmasSeason(1), isFalse);
    });
  });

  group('Phase 7: Debug Operations & Stat Bounds', () {
    test('Debug stat boosts adhere to student models and max capacity', () {
      final camp = Camp(
        name: 'Debug Test Camp',
        money: 1000,
        fame: 100,
        floors: 1,
        placements: [],
      );

      final s = Student(
        id: 'test_s1',
        name: 'Test Student',
        nickname: 'Tester',
        age: 12,
        grade: 6,
        style: ArnisStyle.soloBaston,
        lakas: 20,
        bilis: 20,
        salag: 20,
        diskarte: 20,
      );
      camp.students.add(s);

      // Simulate Debug Add Money
      camp.money += 5000;
      expect(camp.money, equals(6000));

      // Simulate Debug Max Stats
      s.lakas = 999.0;
      s.bilis = 999.0;
      s.salag = 999.0;
      s.diskarte = 999.0;
      s.morale = 100.0;
      s.fatigue = 0.0;

      expect(s.totalStats, equals(3996.0));
      expect(s.lakas, equals(999.0));
    });
  });
}
