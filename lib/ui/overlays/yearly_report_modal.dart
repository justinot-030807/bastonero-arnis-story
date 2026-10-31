// lib/ui/overlays/yearly_report_modal.dart
// Annual review modal celebrating student achievements, titles, and camp growth (Section 17).

import 'package:flutter/material.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';
import '../theme.dart';

class YearlyReportData {
  final int completedYear;
  final int endingMoney;
  final int totalFame;
  final String campRank;
  final int activeStudentsCount;
  final int alumniCount;
  final String topStudentName;
  final double topStudentTotalStats;
  final int totalTitlesWon;

  const YearlyReportData({
    required this.completedYear,
    required this.endingMoney,
    required this.totalFame,
    required this.campRank,
    required this.activeStudentsCount,
    required this.alumniCount,
    required this.topStudentName,
    required this.topStudentTotalStats,
    required this.totalTitlesWon,
  });
}

class YearlyReportModal extends StatelessWidget {
  final GameStateProvider gameState;
  final YearlyReportData data;
  final VoidCallback onDismiss;

  const YearlyReportModal({
    super.key,
    required this.gameState,
    required this.data,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: RetroBox(
          width: 360,
          title: 'TAUNANG ULAT (YEAR ${data.completedYear})',
          backgroundColor: const Color(0xFF0F172A),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: RetroColors.gold),
                ),
                child: Column(
                  children: [
                    const Text(
                      'PAGSUSURI NG NAKARAANG TAON',
                      style: TextStyle(
                        color: RetroColors.gold,
                        fontSize: 10,
                        fontFamily: 'Silkscreen',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Antas ng Camp: ${data.campRank.toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFF60A5FA),
                        fontSize: 8,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Key Stats Table
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: const Color(0xFF475569)),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Kabuuang Pera:', 'P${data.endingMoney}', RetroColors.gold),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow('Dangal (Fame):', '${data.totalFame} pts', const Color(0xFF38BDF8)),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow('Aktibong Estudyante:', '${data.activeStudentsCount} bata', Colors.white),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow('Nagtapos na Alumni:', '${data.alumniCount} arnisador', const Color(0xFF4ADE80)),
                    const Divider(color: Color(0xFF334155), height: 8),
                    _buildStatRow('Koleksyon ng Titulo:', '${data.totalTitlesWon} kampeonato', const Color(0xFFF472B6)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Best Student Spotlight
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: const Color(0xFF22C55E)),
                ),
                child: Row(
                  children: [
                    const PixelSpriteWidget(
                      matrix: PixelArtCatalog.kamagongStick,
                      pixelSize: 2.0,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PINAKAMAHUSAY NA ARNISADOR:',
                            style: TextStyle(
                              color: Color(0xFF4ADE80),
                              fontSize: 7.5,
                              fontFamily: 'Silkscreen',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data.topStudentName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontFamily: 'Silkscreen',
                            ),
                          ),
                          Text(
                            'Kabuuang Lakas at Bilis: ${data.topStudentTotalStats.toStringAsFixed(0)} pts',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 7.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              RetroButton(
                color: const Color(0xFF16A34A),
                onTap: onDismiss,
                child: const Text(
                  'SALUBUNGIN ANG BAGONG TAON!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontFamily: 'Silkscreen',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 8,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 8.5,
            fontFamily: 'Silkscreen',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
