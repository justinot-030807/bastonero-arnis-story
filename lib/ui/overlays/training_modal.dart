import 'package:flutter/material.dart';
import '../../providers/game_state_provider.dart';

class TrainingModal extends StatelessWidget {
  final GameStateProvider gameState;

  const TrainingModal({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final fighter = gameState.fighter;
    final staminaDiscount = (gameState.totalStaminaCostReduction * 100).toInt();

    return Center(
      child: Container(
        width: 480,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(color: const Color(0xFF38BDF8), width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.fitness_center, color: Color(0xFF38BDF8), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'PAGSASANAY (TRAINING CAMP)',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // CURRENT STAMINA STATUS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border.all(color: const Color(0xFF475569)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STAMINA: ${fighter.stamina.toInt()}/${fighter.maxStamina.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFFFDE047),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (staminaDiscount > 0)
                    Text(
                      'Synergy Discount: -$staminaDiscount%',
                      style: const TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // LIST OF TRAINING OPTIONS
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildTrainingCard(
                    context,
                    title: 'GULONG DUMMY POWER DRILL',
                    desc: 'Strike truck tires to build heavy baston impact.',
                    statGain: '+1.5 ~ 3.0 Power (Lakas) & +HP',
                    multiplier: gameState.totalPowerMultiplier,
                    staminaCost: (20 * (1.0 - gameState.totalStaminaCostReduction)).round(),
                    icon: Icons.sports_mma,
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      if (gameState.performTraining(ActionType.trainPower)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildTrainingCard(
                    context,
                    title: 'FOOTWORK AGILITY TIRES',
                    desc: 'Zigzag hop between tires for quick in-and-out steps.',
                    statGain: '+1.5 ~ 3.0 Speed (Bilis)',
                    multiplier: gameState.totalSpeedMultiplier,
                    staminaCost: (20 * (1.0 - gameState.totalStaminaCostReduction)).round(),
                    icon: Icons.directions_run,
                    color: const Color(0xFF38BDF8),
                    onTap: () {
                      if (gameState.performTraining(ActionType.trainSpeed)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildTrainingCard(
                    context,
                    title: 'SINAWALI & ANYO DRILL',
                    desc: 'Weave continuous stick patterns and form mastery.',
                    statGain: '+1.4 ~ 2.8 Technique & Style Level Up',
                    multiplier: gameState.totalTechniqueMultiplier,
                    staminaCost: (20 * (1.0 - gameState.totalStaminaCostReduction)).round(),
                    icon: Icons.change_circle,
                    color: const Color(0xFFEAB308),
                    onTap: () {
                      if (gameState.performTraining(ActionType.trainTechnique)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildTrainingCard(
                    context,
                    title: 'SALAG & PARRYING BLOCK',
                    desc: 'Deflect incoming blows and harden your guard.',
                    statGain: '+1.3 ~ 2.6 Defense (Salag)',
                    multiplier: gameState.totalDefenseMultiplier,
                    staminaCost: (20 * (1.0 - gameState.totalStaminaCostReduction)).round(),
                    icon: Icons.shield,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      if (gameState.performTraining(ActionType.trainDefense)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildTrainingCard(
                    context,
                    title: 'MANGO TREE STUDY SESSION',
                    desc: 'Hit the school books! Maintain Grade >= 80 for Varsity.',
                    statGain: '+2.5 ~ 5.0 Academics (Grado)',
                    multiplier: gameState.totalAcademicsMultiplier,
                    staminaCost: 10,
                    icon: Icons.menu_book,
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      if (gameState.performTraining(ActionType.study)) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildTrainingCard(
                    context,
                    title: 'BUKO BREAK & DEEP REST',
                    desc: 'Drink fresh coconut water and rest up for a week.',
                    statGain: '100% Stamina & HP Restored + ₱50',
                    multiplier: 1.0,
                    staminaCost: 0,
                    icon: Icons.local_drink,
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

  Widget _buildTrainingCard(
    BuildContext context, {
    required String title,
    required String desc,
    required String statGain,
    required double multiplier,
    required int staminaCost,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final canAfford = gameState.fighter.stamina >= staminaCost;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border.all(
          color: canAfford ? color.withValues(alpha: 0.6) : Colors.grey[700]!,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            if (multiplier > 1.0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '+${((multiplier - 1.0) * 100).toInt()}% XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              desc,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  statGain,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  staminaCost == 0 ? 'Pahinga (Free)' : '-$staminaCost Stamina',
                  style: TextStyle(
                    color: canAfford ? const Color(0xFFFDE047) : const Color(0xFFEF4444),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: canAfford ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            minimumSize: const Size(60, 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: const Text(
            'GO',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}
