// test/camp_cutaway_test.dart
// Dedicated tests for Phase 1: Camp view cutaway building, floor expansion,
// 14-tile lane equipment placement, move/sell mechanics, and persistence.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bastonero_arnis_story/domain/balance.dart';
import 'package:bastonero_arnis_story/domain/models/camp.dart';
import 'package:bastonero_arnis_story/domain/models/equipment.dart';
import 'package:bastonero_arnis_story/domain/systems/data_loader.dart';
import 'package:bastonero_arnis_story/providers/game_state_provider.dart';
import 'package:bastonero_arnis_story/ui/components/live_bakuran_camp.dart';
import 'package:bastonero_arnis_story/ui/overlays/itayo_modal.dart';

void main() {
  setUpAll(() {
    DataLoader.loadAllData();
  });

  group('Camp Domain Model - Floor Expansion', () {
    test('Initial camp starts at 1 floor with 8 max students', () {
      final camp = Camp(name: 'Bakuran Arnis Camp', money: 1000, floors: 1);
      expect(camp.floors, 1);
      expect(camp.maxStudents, 8); // 4 + (1 * 4) = 8
      expect(camp.nextFloorCost, Balance.floorCosts[2]); // 1800
      expect(camp.canExpandFloor(), isFalse); // Only 1000 pesos, needs 1800
    });

    test('Expands up to 5 floors with correct cost deductions', () {
      final camp = Camp(name: 'Bakuran Arnis Camp', money: 60000, floors: 1);

      // Floor 2: Cost 1,800
      expect(camp.nextFloorCost, 1800);
      expect(camp.canExpandFloor(), isTrue);
      expect(camp.expandFloor(), isTrue);
      expect(camp.floors, 2);
      expect(camp.money, 60000 - 1800);
      expect(camp.maxStudents, 12); // 4 + (2 * 4)

      // Floor 3: Cost 6,000
      expect(camp.nextFloorCost, 6000);
      expect(camp.expandFloor(), isTrue);
      expect(camp.floors, 3);
      expect(camp.money, 60000 - 1800 - 6000);
      expect(camp.maxStudents, 16);

      // Floor 4: Cost 15,000
      expect(camp.nextFloorCost, 15000);
      expect(camp.expandFloor(), isTrue);
      expect(camp.floors, 4);
      expect(camp.money, 60000 - 1800 - 6000 - 15000);
      expect(camp.maxStudents, 20);

      // Floor 5: Cost 35,000
      expect(camp.nextFloorCost, 35000);
      expect(camp.expandFloor(), isTrue);
      expect(camp.floors, 5);
      expect(camp.money, 60000 - 1800 - 6000 - 15000 - 35000);
      expect(camp.maxStudents, 24);

      // Cannot expand beyond Floor 5
      expect(camp.nextFloorCost, isNull);
      expect(camp.canExpandFloor(), isFalse);
      expect(camp.expandFloor(), isFalse);
      expect(camp.floors, 5);
    });
  });

  group('Camp Domain Model - 14-Tile Lane Equipment Placement & Physics', () {
    test('Placement bounds: requires 0 <= tileX and tileX + width <= 14', () {
      final camp = Camp(name: 'Test Camp', money: 5000, floors: 2);
      // rack_yantok has width 2, cost 200
      // Valid placement: tileX = 0..12
      expect(camp.canPlaceEquipment(equipmentId: 'rack_yantok', floor: 1, tileX: 0), isTrue);
      expect(camp.canPlaceEquipment(equipmentId: 'rack_yantok', floor: 1, tileX: 12), isTrue);

      // Out of bounds: tileX = 13 (13 + 2 = 15 > 14) or tileX < 0
      expect(camp.canPlaceEquipment(equipmentId: 'rack_yantok', floor: 1, tileX: 13), isFalse);
      expect(camp.canPlaceEquipment(equipmentId: 'rack_yantok', floor: 1, tileX: -1), isFalse);

      // Floor out of bounds: Floor 3 is locked
      expect(camp.canPlaceEquipment(equipmentId: 'rack_yantok', floor: 3, tileX: 2), isFalse);
    });

    test('Prevents overlapping placements on the same floor', () {
      final camp = Camp(name: 'Test Camp', money: 5000, floors: 1);
      // Place rack_yantok (width 2) at tileX = 2 (occupies tiles 2 and 3)
      final placed1 = camp.placeEquipment(equipmentId: 'rack_yantok', floor: 1, tileX: 2);
      expect(placed1, isNotNull);
      expect(camp.placements.length, 1);

      // Attempting to place another equipment overlapping tile 2 or 3 must fail
      expect(camp.canPlaceEquipment(equipmentId: 'punching_bag', floor: 1, tileX: 2), isFalse);
      expect(camp.canPlaceEquipment(equipmentId: 'punching_bag', floor: 1, tileX: 3), isFalse);
      expect(camp.canPlaceEquipment(equipmentId: 'banig_mat', floor: 1, tileX: 1), isFalse); // width 3 at 1 occupies 1,2,3

      // Non-overlapping placement succeeds (e.g. tileX = 4, or on another floor)
      expect(camp.canPlaceEquipment(equipmentId: 'punching_bag', floor: 1, tileX: 4), isTrue);
      final placed2 = camp.placeEquipment(equipmentId: 'punching_bag', floor: 1, tileX: 4);
      expect(placed2, isNotNull);
      expect(camp.placements.length, 2);
    });

    test('Moving equipment is free and checks collision ignoring self', () {
      final camp = Camp(name: 'Test Camp', money: 5000, floors: 2);
      final placed1 = camp.placeEquipment(equipmentId: 'rack_yantok', floor: 1, tileX: 2)!;
      final placed2 = camp.placeEquipment(equipmentId: 'punching_bag', floor: 1, tileX: 5)!;
      expect(placed2.floor, 1);

      final moneyBeforeMove = camp.money;

      // Moving placed1 to same spot or slightly shifted (tileX = 0) succeeds
      expect(camp.moveEquipment(instanceId: placed1.instanceId, newFloor: 1, newTileX: 0), isTrue);
      expect(camp.money, moneyBeforeMove); // No fee for moving
      expect(placed1.tileX, 0);

      // Moving placed1 to overlap placed2 (tileX = 5) must fail
      expect(camp.moveEquipment(instanceId: placed1.instanceId, newFloor: 1, newTileX: 5), isFalse);

      // Moving placed1 to floor 2 succeeds
      expect(camp.moveEquipment(instanceId: placed1.instanceId, newFloor: 2, newTileX: 5), isTrue);
      expect(placed1.floor, 2);
    });

    test('Selling equipment provides 50% refund and removes placement', () {
      final camp = Camp(name: 'Test Camp', money: 1000, floors: 1);
      // rack_yantok costs 200
      final placed = camp.placeEquipment(equipmentId: 'rack_yantok', floor: 1, tileX: 0)!;
      expect(camp.money, 800);

      final refund = camp.sellEquipment(placed.instanceId);
      expect(refund, 100); // 50% of 200
      expect(camp.money, 900);
      expect(camp.placements, isEmpty);
    });
  });

  group('Camp & Placement Serialization Roundtrip', () {
    test('Preserves unlocked floors and placements through JSON and SaveSystem', () {
      final original = Camp(
        name: 'Camp Panday',
        money: 12500,
        fame: 450,
        rankTier: 'bayan',
        floors: 3,
        placements: [
          PlacedEquipment(instanceId: 'p1', equipmentId: 'tire_dummy', floor: 1, tileX: 1),
          PlacedEquipment(instanceId: 'p2', equipmentId: 'sari_sari_store', floor: 1, tileX: 6),
          PlacedEquipment(instanceId: 'p3', equipmentId: 'banig_mat', floor: 2, tileX: 3),
        ],
      );

      final json = original.toJson();
      final restored = Camp.fromJson(json);

      expect(restored.name, 'Camp Panday');
      expect(restored.money, 12500);
      expect(restored.fame, 450);
      expect(restored.rankTier, 'bayan');
      expect(restored.floors, 3);
      expect(restored.placements.length, 3);
      expect(restored.placements[0].equipmentId, 'tire_dummy');
      expect(restored.placements[0].tileX, 1);
      expect(restored.placements[1].equipmentId, 'sari_sari_store');
      expect(restored.placements[1].tileX, 6);
      expect(restored.placements[2].floor, 2);
      expect(restored.placements[2].equipmentId, 'banig_mat');
    });
  });

  group('GameStateProvider Phase 1 Integration & Widgets', () {
    testWidgets('LiveBakuranCampView renders cutaway building and responds to interaction', (tester) async {
      final state = GameStateProvider();
      state.pesos = 10000;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameStateProvider>.value(
            value: state,
            child: Scaffold(
              body: LiveBakuranCampView(gameState: state),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check title header
      expect(find.textContaining('BAKURAN TRAINING CAMP'), findsOneWidget);
      // Check building controls
      expect(find.textContaining('ITAYO'), findsOneWidget);
      expect(find.textContaining('EXPAND 2F'), findsOneWidget);

      // Tap Expand 2nd Floor
      await tester.tap(find.textContaining('EXPAND 2F'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(state.unlockedFloors, 2);
      expect(find.textContaining('EXPAND 3F'), findsOneWidget);
    });

    testWidgets('ItayoModal opens and renders floor lanes and equipment items', (tester) async {
      final state = GameStateProvider();
      state.pesos = 10000;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<GameStateProvider>.value(
            value: state,
            child: Scaffold(
              body: Stack(
                children: [
                  LiveBakuranCampView(gameState: state),
                  ItayoModal(gameState: state),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check Itayo title and tabs
      expect(find.textContaining('ITAYO (CAMP BUILD & MANAGE)'), findsOneWidget);
      expect(find.textContaining('1F'), findsOneWidget);
      expect(find.textContaining('LAHAT'), findsOneWidget);
      expect(find.textContaining('PAGSASANAY'), findsOneWidget);
    });
  });
}
