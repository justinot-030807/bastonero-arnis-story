// lib/ui/overlays/graduation_modal.dart
// Retro pixel-art graduation and alumni legacy selection modal.

import 'package:flutter/material.dart';
import '../../domain/models/alumni.dart';
import '../../domain/systems/graduation_system.dart';
import '../retro_ui.dart';

class GraduationModal extends StatelessWidget {
  final GraduationCandidate candidate;
  final void Function(AlumniRole role) onChooseRole;

  const GraduationModal({
    super.key,
    required this.candidate,
    required this.onChooseRole,
  });

  @override
  Widget build(BuildContext context) {
    final s = candidate.student;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: RetroBox(
          width: 460,
          title: 'PAGPAPALAYA AT PAGTATAPOS (GRADUATION)!',
          backgroundColor: const Color(0xFF0F172A),
          borderColor: const Color(0xFF1A1C2C),
          bevelColor: const Color(0xFFFACC15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Congratulatory Header
              Row(
                children: [
                  const PixelSpriteWidget(
                    matrix: PixelArtCatalog.miniTrophy,
                    pixelSize: 2.2,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${s.name} "${s.nickname}"',
                          style: const TextStyle(
                            color: Color(0xFFFDE047),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          candidate.reason,
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 8.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Career Summary Box
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'REKORD: ${s.wins} Panalo - ${s.losses} Talo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'KABUUANG STATS: ${s.totalStats.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Color(0xFF4ADE80),
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    if (s.titles.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Mga Titulo: ${s.titles.join(", ")}',
                        style: const TextStyle(
                          color: Color(0xFFFDE047),
                          fontSize: 8,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'PUMILI NG PAMANA (ALUMNI ROLE):',
                style: TextStyle(
                  color: Color(0xFFFACC15),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 6),

              // Role Choice 1: Guro Trainer
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: RetroButton(
                  height: 42,
                  color: const Color(0xFF0284C7),
                  onTap: () => onChooseRole(AlumniRole.trainer),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'MAGING GURO (TRAINER)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'Espesyalista sa ${candidate.bestSpecialty.toUpperCase()} (+${candidate.trainerSkill * 4}% training gain)',
                        style: const TextStyle(
                          color: Color(0xFFFDE047),
                          fontSize: 7.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Role Choice 2: Sponsor
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: RetroButton(
                  height: 42,
                  color: const Color(0xFF16A34A),
                  onTap: () => onChooseRole(AlumniRole.sponsor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'MAGING SPONSOR NG BAKURAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'Magbibigay ng +P${candidate.monthlySponsorshipEstimate} kada buwan para sa pondo',
                        style: const TextStyle(
                          color: Color(0xFFFDE047),
                          fontSize: 7.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Role Choice 3: Hall of Fame
              RetroButton(
                height: 42,
                color: const Color(0xFF7C3AED),
                onTap: () => onChooseRole(AlumniRole.hallOfFame),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'HALL OF FAME (DANGAL NG KAMPYON)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Magiging inspirasyon sa buong bayan (+50 Permanent Katanyagan/Fame)',
                      style: TextStyle(
                        color: Color(0xFFFDE047),
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
      ),
    );
  }
}
