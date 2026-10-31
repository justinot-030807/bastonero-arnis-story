// lib/ui/overlays/recruit_dialog_modal.dart
// Retro pixel-art modal for walk-in recruits and scouting candidates.

import 'package:flutter/material.dart';
import '../../domain/systems/recruitment_system.dart';
import '../retro_ui.dart';

class RecruitDialogModal extends StatelessWidget {
  final RecruitmentCandidate candidate;
  final bool canAfford;
  final bool hasSpace;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const RecruitDialogModal({
    super.key,
    required this.candidate,
    required this.canAfford,
    required this.hasSpace,
    required this.onAccept,
    required this.onDecline,
  });

  String _getStarsString(int stars) {
    return '★' * stars + '☆' * (5 - stars);
  }

  String _getTraitDescription(String trait) {
    switch (trait) {
      case 'Masipag':
        return '+10% bilis ng pagsasanay';
      case 'Tamad':
        return '-10% sanay, +Gana sa hinga';
      case 'Matalino':
        return '+15% bilis ng aral/grado';
      case 'Palaban':
        return '+5% tsansa ng kritikal na palo';
      case 'Kabado':
        return '-5% depensa sa malalakas';
      case 'Maliksi':
        return '+5% dagdag sa Bilis';
      case 'Matibay':
        return '-20% tsansa ng pilay/injury';
      case 'Pasaway':
        return 'Pabago-bago ang gana, mataas ang galing';
      default:
        return 'Espesyal na katangian';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = candidate.student;
    final canEnroll = canAfford && hasSpace;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: RetroBox(
          width: 440,
          title: candidate.isScholarship
              ? 'BAGONG SCHOLARSHIP APPLICANT!'
              : 'MAY DUMALAW NA WALK-IN RECRUIT!',
          backgroundColor: const Color(0xFF0F172A),
          borderColor: const Color(0xFF1A1C2C),
          bevelColor: candidate.isScholarship ? const Color(0xFF38BDF8) : const Color(0xFFF4B41B),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Candidate Header Row
              Row(
                children: [
                  PixelSpriteWidget(
                    matrix: PixelArtCatalog.lorenzoPortrait,
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${s.gradeDescription} | Edad: ${s.age}',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 8.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'Potensyal: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              _getStarsString(candidate.potentialStars),
                              style: const TextStyle(
                                color: Color(0xFFFACC15),
                                fontSize: 11,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Traits Box
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KATANGIAN (TRAITS):',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...s.traits.map((t) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Row(
                          children: [
                            Text(
                              '• $t: ',
                              style: const TextStyle(
                                color: Color(0xFFFDE047),
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _getTraitDescription(t),
                                style: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Stats Preview Grid
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LAKAS: ${s.lakas.toStringAsFixed(1)}', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 8.5, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    Text('BILIS: ${s.bilis.toStringAsFixed(1)}', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 8.5, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    Text('DISKARTE: ${s.diskarte.toStringAsFixed(1)}', style: const TextStyle(color: Color(0xFFFACC15), fontSize: 8.5, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    Text('SALAG: ${s.salag.toStringAsFixed(1)}', style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 8.5, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Fee & Capacity Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    candidate.fee == 0 ? 'Bayad: LIBRE' : 'Bayad: P${candidate.fee}',
                    style: TextStyle(
                      color: canAfford ? const Color(0xFF4ADE80) : const Color(0xFFEF4444),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    hasSpace ? 'May Bakante sa Bakuran' : 'PUNO NA ANG BAKURAN',
                    style: TextStyle(
                      color: hasSpace ? const Color(0xFF38BDF8) : const Color(0xFFEF4444),
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: RetroButton(
                      height: 36,
                      color: const Color(0xFF475569),
                      onTap: onDecline,
                      child: const Text(
                        'TANGGIHAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RetroButton(
                      height: 36,
                      color: canEnroll ? const Color(0xFF16A34A) : const Color(0xFF334155),
                      onTap: canEnroll ? onAccept : null,
                      child: Text(
                        canEnroll ? 'TANGGAPIN (ENROLL)' : 'HINDI PWEDE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
