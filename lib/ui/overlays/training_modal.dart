import 'package:flutter/material.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';
import 'estudyante_modal.dart';

class TrainingModal extends StatelessWidget {
  final GameStateProvider gameState;

  const TrainingModal({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final fighter = gameState.fighter;
    final staminaDiscount = (gameState.totalStaminaCostReduction * 100).toInt();

    return Center(
      child: RetroBox(
        width: 480,
        height: MediaQuery.of(context).size.height * 0.86,
        title: 'PAGSASANAY (TRAINING CAMP)',
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
                    'HANGIN: ${fighter.stamina.toInt()}/${fighter.maxStamina.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFFFDE047),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (staminaDiscount > 0)
                    Text(
                      'Synergy Discount: -$staminaDiscount%',
                      style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 10, fontFamily: 'monospace'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (ctx) => EstudyanteModal(gameState: gameState),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: Text(
                    'BUKSAN ANG BUONG ROSTER NG MGA ESTUDYANTE (${gameState.students.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7.5,
                      fontFamily: 'Silkscreen',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: [
                  _buildCard(
                    context,
                    title: 'GULONG DUMMY POWER DRILL',
                    desc: 'Strike truck tires to build heavy baston impact.',
                    statGain: '+1.5 ~ 3.0 Lakas & +HP',
                    multiplier: gameState.totalPowerMultiplier,
                    staminaCost: (20 * (1.0 - gameState.totalStaminaCostReduction)).round(),
                    iconMatrix: PixelArtCatalog.iconSanay,
                    color: const Color(0xFFDC2626),
                    onTap: () {
                      if (gameState.performTraining(ActionType.trainPower)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'FOOTWORK AGILITY TIRES',
                    desc: 'Zigzag hop between tires for quick in-and-out steps.',
                    statGain: '+1.5 ~ 3.0 Bilis',
                    multiplier: gameState.totalSpeedMultiplier,
                    staminaCost: (20 * (1.0 - gameState.totalStaminaCostReduction)).round(),
                    iconMatrix: PixelArtCatalog.gearShoes,
                    color: const Color(0xFF38BDF8),
                    onTap: () {
                      if (gameState.performTraining(ActionType.trainSpeed)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'SINAWALI & ANYO DRILL',
                    desc: 'Weave continuous stick patterns and form mastery.',
                    statGain: '+1.4 ~ 2.8 Diskarte & Style Mastery',
                    multiplier: gameState.totalTechniqueMultiplier,
                    staminaCost: (20 * (1.0 - gameState.totalStaminaCostReduction)).round(),
                    iconMatrix: PixelArtCatalog.iconSpar,
                    color: const Color(0xFFF4B41B),
                    onTap: () {
                      if (gameState.performTraining(ActionType.trainTechnique)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'SALAG & PARRYING BLOCK',
                    desc: 'Deflect incoming blows and harden your guard.',
                    statGain: '+1.3 ~ 2.6 Salag (Depensa)',
                    multiplier: gameState.totalDefenseMultiplier,
                    staminaCost: (20 * (1.0 - gameState.totalStaminaCostReduction)).round(),
                    iconMatrix: PixelArtCatalog.gearHeadgear,
                    color: const Color(0xFF4ADE80),
                    onTap: () {
                      if (gameState.performTraining(ActionType.trainDefense)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'MANGO TREE STUDY SESSION',
                    desc: 'Hit the school books! Maintain Grade >= 80 for Varsity.',
                    statGain: '+2.5 ~ 5.0 Grado',
                    multiplier: gameState.totalAcademicsMultiplier,
                    staminaCost: 10,
                    iconMatrix: PixelArtCatalog.iconAral,
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      if (gameState.performTraining(ActionType.study)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'BUKO BREAK & DEEP REST',
                    desc: 'Drink fresh coconut water and rest up for a week.',
                    statGain: '100% Hangin & Tibay + P50',
                    multiplier: 1.0,
                    staminaCost: 0,
                    iconMatrix: PixelArtCatalog.bukoJuice,
                    color: const Color(0xFF06B6D4),
                    onTap: () {
                      gameState.performTraining(ActionType.rest);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String desc,
    required String statGain,
    required double multiplier,
    required int staminaCost,
    required List<String> iconMatrix,
    required Color color,
    required VoidCallback onTap,
  }) {
    final canAfford = gameState.fighter.stamina >= staminaCost;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border.all(
          color: canAfford ? color.withValues(alpha: 0.6) : const Color(0xFF475569),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          PixelSpriteWidget(matrix: iconMatrix, pixelSize: 2.0),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    if (multiplier > 1.0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        color: const Color(0xFF16A34A),
                        child: Text(
                          '+${((multiplier - 1.0) * 100).toInt()}% XP',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9)),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(statGain, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    Text(
                      staminaCost == 0 ? 'Libre' : '-$staminaCost Hangin',
                      style: TextStyle(color: canAfford ? const Color(0xFFFDE047) : const Color(0xFFDC2626), fontSize: 9, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          RetroButton(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: canAfford ? color : const Color(0xFF475569),
            onTap: canAfford ? onTap : null,
            child: const Text('GO', style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
