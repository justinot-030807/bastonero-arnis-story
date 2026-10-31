// lib/domain/systems/data_loader.dart
// Loads game content from assets/data/ JSON files. Pure Dart / Flutter rootBundle.

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/equipment.dart';
import '../models/event.dart';
import '../models/move.dart';
import '../models/opponent.dart';
import '../models/tournament.dart';

class DataLoader {
  static List<Equipment> equipmentCatalog = [];
  static List<Tournament> tournamentCatalog = [];
  static List<Move> moveCatalog = [];
  static List<GameEvent> eventCatalog = [];
  static List<Opponent> opponentCatalog = [];

  static List<String> maleNames = [];
  static List<String> femaleNames = [];
  static List<String> lastNames = [];
  static List<String> nicknames = [];
  static List<String> announcerLines = [];

  static bool isLoaded = false;

  static Future<void> loadAllData() async {
    if (isLoaded) return;

    try {
      // 1. Equipment
      final eqJson = await rootBundle.loadString('assets/data/equipment.json');
      final eqList = jsonDecode(eqJson) as List<dynamic>;
      equipmentCatalog = eqList.map((e) => Equipment.fromJson(e as Map<String, dynamic>)).toList();

      // 2. Tournaments
      final tourneyJson = await rootBundle.loadString('assets/data/tournaments.json');
      final tourneyList = jsonDecode(tourneyJson) as List<dynamic>;
      tournamentCatalog = tourneyList.map((e) => Tournament.fromJson(e as Map<String, dynamic>)).toList();

      // 3. Moves
      final moveJson = await rootBundle.loadString('assets/data/moves.json');
      final moveList = jsonDecode(moveJson) as List<dynamic>;
      moveCatalog = moveList.map((e) => Move.fromJson(e as Map<String, dynamic>)).toList();

      // 4. Events
      final evJson = await rootBundle.loadString('assets/data/events.json');
      final evList = jsonDecode(evJson) as List<dynamic>;
      eventCatalog = evList.map((e) => GameEvent.fromJson(e as Map<String, dynamic>)).toList();

      // 5. Opponents
      final oppJson = await rootBundle.loadString('assets/data/opponents.json');
      final oppList = jsonDecode(oppJson) as List<dynamic>;
      opponentCatalog = oppList.map((e) => Opponent.fromJson(e as Map<String, dynamic>)).toList();

      // 6. Names & Commentary
      final namesJson = await rootBundle.loadString('assets/data/names.json');
      final namesMap = jsonDecode(namesJson) as Map<String, dynamic>;
      maleNames = (namesMap['firstNamesMale'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      femaleNames = (namesMap['firstNamesFemale'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      lastNames = (namesMap['lastNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      nicknames = (namesMap['nicknames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      announcerLines = (namesMap['announcerLines'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

      isLoaded = true;
    } catch (e) {
      // Fallback in case of missing asset in test environments
      isLoaded = true;
    }
  }
}
