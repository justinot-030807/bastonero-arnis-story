// lib/ui/overlays/tutorial_modal.dart
// 6-step interactive walkthrough for first-time players (Section 15).

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';
import '../theme.dart';

class TutorialModal extends StatefulWidget {
  final GameStateProvider gameState;
  final VoidCallback? onComplete;

  const TutorialModal({super.key, required this.gameState, this.onComplete});

  @override
  State<TutorialModal> createState() => _TutorialModalState();
}

class _TutorialModalState extends State<TutorialModal> {
  int _currentStep = 0;

  static const List<_TutorialStep> _steps = [
    _TutorialStep(
      title: 'MALIGAYANG PAGDATING SA BASTONERO!',
      subtitle: 'Pangangasiwa ng Arnis Bakuran',
      content:
          'Ikaw ang tagapagtatag at punong guro ng Bakuran Arnis Camp! Layunin mong gabayan ang mga batang estudyante mula sa bakanteng lote hanggang maging Alamat ng Pambansang Kampeonato.',
      iconMatrix: PixelArtCatalog.bahiStick,
    ),
    _TutorialStep(
      title: 'PAG-AATAS NG GAWAIN (SANAY, ARAL, HINGA)',
      subtitle: 'Balanse sa Palakasan at Eskwela',
      content:
          'Bawat linggo, italaga ang iyong mga estudyante:\n'
          '• SANAY: Nagpapataas ng Lakas, Bilis, Salag, at Diskarte.\n'
          '• ARAL: Nagpapataas ng Grado upang manatiling Varsity Eligible (>=75%).\n'
          '• HINGA: Nagpapababa ng Fatigue at nagpapanumbalik ng Morale!',
      iconMatrix: PixelArtCatalog.iconSanay,
    ),
    _TutorialStep(
      title: 'PAGTATAYO NG GAMIT SA ITAYO',
      subtitle: 'Palakihin ang Kapasidad ng Camp',
      content:
          'Magtayo ng kagamitan tulad ng Bangko, Banig, Sako, at Bentilador!\n'
          'Ang Bangko at Banig ay nagdaragdag ng +2 estudyante slots.\n'
          'Maaari ka ring magpalawak ng 2nd hanggang 5th floor sa pag-angat ng antas ng Camp!',
      iconMatrix: PixelArtCatalog.iconTiangge,
    ),
    _TutorialStep(
      title: 'ORAS AT BILIS NG LINGGO (x1, x2, x4)',
      subtitle: 'Kalendaryo at Lingguhang Pag-usad',
      content:
          'Gamitin ang bilis ng laro (x1, x2, x4) o I-PAUSE anumang oras.\n'
          'Bawat linggo ay may stat gains at sweldo. Tuwing katapusan ng buwan ay may Tuition Income at buwanang report!',
      iconMatrix: PixelArtCatalog.iconAral,
    ),
    _TutorialStep(
      title: 'SPARRING AT TIMING MINIGAME',
      subtitle: 'Pagsasanay sa Labanang Baston',
      content:
          'Gamitin ang SPAR button upang subukan ang mga diskarte ng estudyante.\n'
          'Sa oras ng TAMAAN (Finisher), pindutin ang screen sa berdeng sona upang magdulot ng 2x pinsala!',
      iconMatrix: PixelArtCatalog.iconSpar,
    ),
    _TutorialStep(
      title: 'MGA TORNEYO AT GRADUATION (PAMANA)',
      subtitle: 'Purok hanggang Palarong Pambansa',
      content:
          'Sumali sa Torneyo (LABAN) para kumita ng Pera at Dangal (Fame)!\n'
          'Pagdating ng Grade 12 sa Marso, ga-graduate ang iyong mga kampeon upang maging GURO, SPONSOR, o pumasok sa HALL OF FAME!',
      iconMatrix: PixelArtCatalog.iconLaban,
    ),
  ];

  Future<void> _completeTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_tutorial', true);
    } catch (_) {}
    widget.gameState.hasCompletedTutorial = true;
    if (mounted) {
      Navigator.of(context).pop();
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLast = _currentStep == _steps.length - 1;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: RetroBox(
          width: 360,
          title: 'GABAY NG BAGONG GURO',
          backgroundColor: const Color(0xFF0F172A),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Indicator Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      border: Border.all(color: RetroColors.gold),
                    ),
                    child: Text(
                      'HAKBANG ${_currentStep + 1} / ${_steps.length}',
                      style: const TextStyle(
                        color: RetroColors.gold,
                        fontSize: 8,
                        fontFamily: 'Silkscreen',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _completeTutorial,
                    child: const Text(
                      'Laktawan (Skip) >',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 8,
                        fontFamily: 'monospace',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Step Title & Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      border: Border.all(color: const Color(0xFF3B82F6)),
                    ),
                    alignment: Alignment.center,
                    child: PixelSpriteWidget(
                      matrix: step.iconMatrix,
                      pixelSize: 2.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Silkscreen',
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.subtitle,
                          style: const TextStyle(
                            color: Color(0xFF60A5FA),
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Content Box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: const Color(0xFF475569)),
                ),
                child: Text(
                  step.content,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 8.5,
                    fontFamily: 'monospace',
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Navigation Buttons
              Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: RetroButton(
                        color: const Color(0xFF475569),
                        onTap: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        child: const Text(
                          '< BUMALIK',
                          style: TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'Silkscreen'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    flex: 2,
                    child: RetroButton(
                      color: isLast ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                      onTap: () {
                        if (isLast) {
                          _completeTutorial();
                        } else {
                          setState(() {
                            _currentStep++;
                          });
                        }
                      },
                      child: Text(
                        isLast ? 'SIMULAN ANG PAGSASANAY!' : 'SUSUNOD >',
                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'Silkscreen'),
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

class _TutorialStep {
  final String title;
  final String subtitle;
  final String content;
  final List<String> iconMatrix;

  const _TutorialStep({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.iconMatrix,
  });
}
