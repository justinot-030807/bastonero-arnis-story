import 'package:flutter/material.dart';
import '../../providers/game_state_provider.dart';
import '../../models/facility_model.dart';
import '../retro_ui.dart';

class GymBuilderModal extends StatelessWidget {
  final GameStateProvider gameState;
  final int slotIndex;

  const GymBuilderModal({
    super.key,
    required this.gameState,
    required this.slotIndex,
  });

  @override
  Widget build(BuildContext context) {
    final facility = gameState.slots[slotIndex];

    return Center(
      child: RetroBox(
        width: 480,
        height: MediaQuery.of(context).size.height * 0.85,
        title: 'BAKURAN GYM: PHYSICAL SLOT ${slotIndex + 1}',
        titleTrailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        backgroundColor: const Color(0xFF0F172A),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border.all(color: const Color(0xFF475569)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KABANG YAMAN: P${gameState.pesos}',
                    style: const TextStyle(
                      color: Color(0xFFFDE047),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    facility == null ? 'Bakante (Available Slot)' : 'Level ${facility.level}',
                    style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 10, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            if (facility != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: const Color(0xFFF4B41B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.type.displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 4),
                    Text(facility.type.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                    const SizedBox(height: 6),
                    Text(
                      'Epekto: ${facility.type.primaryStatEffect} (Level ${facility.level})',
                      style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: RetroButton(
                      color: const Color(0xFF16A34A),
                      onTap: gameState.pesos >= facility.upgradeCost
                          ? () {
                              gameState.upgradeFacility(slotIndex);
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text(
                        'UPGRADE (P${facility.upgradeCost})',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RetroButton(
                      color: const Color(0xFFDC2626),
                      onTap: () {
                        gameState.demolishFacility(slotIndex);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'BUWAGIN (BAWI P${(facility.type.baseCost * 0.4).round()})',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Expanded(
                child: ListView(
                  children: FacilityType.values.map((type) {
                    final canAfford = gameState.pesos >= type.baseCost;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        border: Border.all(
                          color: canAfford ? const Color(0xFFF4B41B).withValues(alpha: 0.6) : const Color(0xFF475569),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type.displayName,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  type.primaryStatEffect,
                                  style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                ),
                                const SizedBox(height: 2),
                                Text(type.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          RetroButton(
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            color: canAfford ? const Color(0xFF16A34A) : const Color(0xFF475569),
                            onTap: canAfford
                                ? () {
                                    gameState.buildFacility(slotIndex, type);
                                    Navigator.of(context).pop();
                                  }
                                : null,
                            child: Text(
                              'ITAYO P${type.baseCost}',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
