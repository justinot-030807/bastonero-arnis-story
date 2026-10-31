import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bastonero_arnis_story/game/arnis_match_game.dart';
import 'package:bastonero_arnis_story/models/fighter_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ArnisMatchGame & Combat Engine Tests', () {
    test('Game initializes fighters, coach gigil meter, and round timer', () async {
      final player = FighterModel(name: 'Hero Player', power: 20, speed: 20);
      final opponent = FighterModel.createBertoRival();

      final game = ArnisMatchGame(
        playerFighter: player,
        opponentFighter: opponent,
      );

      // Set game size for headless tests
      game.onGameResize(Vector2(800, 600));
      await game.onLoad();

      expect(game.matchTimer, 60.0);
      expect(game.coachGigilMeter, greaterThanOrEqualTo(30.0));
      expect(game.player.fighter.name, 'Hero Player');
      expect(game.opponent.fighter.name, contains('Berto'));
    });

    test('Coach Aura Shouts consume Gigil Meter and apply buffs', () async {
      final player = FighterModel(name: 'Hero Player', power: 20, speed: 20, defense: 20);
      final opponent = FighterModel.createBertoRival();

      final game = ArnisMatchGame(
        playerFighter: player,
        opponentFighter: opponent,
      );
      game.onGameResize(Vector2(800, 600));
      await game.onLoad();

      // Give 100% gigil
      game.coachGigilMeter = 100.0;

      // Shout Bira!
      final biraSuccess = game.shoutBira();
      expect(biraSuccess, isTrue);
      expect(game.player.hasBiraAura, isTrue);
      expect(game.coachGigilMeter, 65.0); // 100 - 35

      // Shout Salag!
      final salagSuccess = game.shoutSalag();
      expect(salagSuccess, isTrue);
      expect(game.player.hasSalagAura, isTrue);
      expect(game.coachGigilMeter, 35.0); // 65 - 30
    });

    test('Timing Mini-Game Clinch Resolution: Perfect Hit triggers signature move & disarm', () async {
      final player = FighterModel(name: 'Hero Player', power: 25, speed: 20);
      final opponent = FighterModel.createBertoRival();

      final game = ArnisMatchGame(
        playerFighter: player,
        opponentFighter: opponent,
      );
      game.onGameResize(Vector2(800, 600));
      await game.onLoad();

      final initialOpponentHp = game.opponent.currentHp;

      // Simulate Clinch Sweet Spot Perfect Hit
      game.resolveClinchMiniGame(isPerfect: true, isSuccess: true);

      // Opponent takes heavy damage and is disarmed
      expect(game.opponent.currentHp, lessThan(initialOpponentHp));
      expect(game.opponent.isDisarmed, isTrue);
    });

    test('Finisher Tap (TAMAAN!) resolution deals signature damage and updates engine stats', () async {
      final player = FighterModel(name: 'Hero Player', power: 30, speed: 20);
      final opponent = FighterModel.createBertoRival();

      final game = ArnisMatchGame(
        playerFighter: player,
        opponentFighter: opponent,
      );
      game.onGameResize(Vector2(800, 600));
      await game.onLoad();

      final initialOpponentHp = game.opponent.currentHp;

      // Charge Puso to 100% and resolve Finisher Tap with Bullseye (0.50)
      game.engine.player.pusoMeter = 100.0;
      game.resolveFinisherTap(tapOffset: 0.50);

      expect(game.opponent.currentHp, lessThan(initialOpponentHp));
      expect(game.engine.player.pusoMeter, 0.0);
      expect(game.engine.player.strikesLanded, greaterThan(0));
    });
  });
}
