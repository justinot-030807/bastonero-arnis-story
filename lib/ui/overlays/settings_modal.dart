// lib/ui/overlays/settings_modal.dart
// Unified Settings, Audio, and Data Backup Dialog (Section 15 & 17).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../game/audio_manager.dart';
import '../../providers/game_state_provider.dart';
import '../../utils/storage_service.dart';
import '../retro_ui.dart';
import '../theme.dart';
import 'tutorial_modal.dart';

class SettingsModal extends StatefulWidget {
  final GameStateProvider gameState;
  final bool isInGame;

  const SettingsModal({
    super.key,
    required this.gameState,
    this.isInGame = false,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  final TextEditingController _jsonController = TextEditingController();
  String _statusMsg = '';
  final _audio = AudioManager.instance;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  void _exportJson() async {
    final jsonStr = await StorageService.exportActiveSaveJson(widget.gameState.activeSlotIndex);
    _jsonController.text = jsonStr;
    await Clipboard.setData(ClipboardData(text: jsonStr));
    setState(() {
      _statusMsg = '[KOPYA] Save JSON nakopya sa Clipboard!';
    });
    _audio.playClick();
  }

  void _importJson() async {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      setState(() => _statusMsg = '[MALI] I-paste muna ang Save JSON!');
      return;
    }

    final success = await StorageService.importSaveJson(widget.gameState.activeSlotIndex, text);
    if (success) {
      await widget.gameState.loadSavedGame(slot: widget.gameState.activeSlotIndex);
      setState(() => _statusMsg = '[AYOS] Tagumpay na na-import ang Save Data!');
      _audio.playClick();
    } else {
      setState(() => _statusMsg = '[MALI] Hindi wastong Save JSON data!');
    }
  }

  void _showCreditsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: RetroBox(
            width: 340,
            title: 'CREDITS & PASASALAMAT',
            titleTrailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 16),
              onPressed: () => Navigator.of(ctx).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            backgroundColor: const Color(0xFF0F172A),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'BASTONERO: ARNIS STORY v3.0\nKairosoft-style Arnis Gym Simulator',
                    style: TextStyle(
                      color: RetroColors.gold,
                      fontSize: 8.5,
                      fontFamily: 'Silkscreen',
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: const Color(0xFF1E293B),
                    child: const Text(
                      '• MGA TITIK AT FONT:\n'
                      '  Press Start 2P (CodeMan38 - SIL OFL v1.1)\n'
                      '  Silkscreen (Jason Kottke - SIL OFL v1.1)\n\n'
                      '• AUDIO AT TUNOG:\n'
                      '  8-bit Chiptune SFX (Kenney.nl / CC0)\n'
                      '  Tactile Haptics (Flutter System Services)\n\n'
                      '• SINING AT GRAFIKS:\n'
                      '  Custom Filipino Pixel-Art & CC0 Tilesets\n\n'
                      'Para sa pagpapalaganap ng Pambansang Palakasan ng Pilipinas: ARNIS!',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 7.5,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: RetroBox(
          width: 440,
          title: 'SETTINGS AT CONFIGURATION',
          titleTrailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          backgroundColor: const Color(0xFF0F172A),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. AUDIO CONTROLS
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    children: [
                      // BGM
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() => _audio.toggleBgm());
                            },
                            child: Icon(
                              _audio.isBgmEnabled ? Icons.volume_up : Icons.volume_off,
                              color: _audio.isBgmEnabled ? const Color(0xFFFDE047) : Colors.grey,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'BGM MUSIKA:',
                            style: TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'Silkscreen'),
                          ),
                          Expanded(
                            child: Slider(
                              value: _audio.bgmVolume,
                              onChanged: (val) {
                                setState(() {
                                  _audio.setBgmVolume(val);
                                  state.bgmVolume = val;
                                });
                              },
                              activeColor: const Color(0xFFF4B41B),
                            ),
                          ),
                        ],
                      ),
                      // SFX
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() => _audio.toggleSfx());
                            },
                            child: Icon(
                              _audio.isSfxEnabled ? Icons.notifications_active : Icons.notifications_off,
                              color: _audio.isSfxEnabled ? const Color(0xFF38BDF8) : Colors.grey,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'SFX HATAW:',
                            style: TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'Silkscreen'),
                          ),
                          Expanded(
                            child: Slider(
                              value: _audio.sfxVolume,
                              onChanged: (val) {
                                setState(() {
                                  _audio.setSfxVolume(val);
                                  state.sfxVolume = val;
                                });
                              },
                              activeColor: const Color(0xFF38BDF8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 2. TUTORIAL & CREDITS
                Row(
                  children: [
                    Expanded(
                      child: RetroButton(
                        color: const Color(0xFF4338CA),
                        onTap: () {
                          state.resetTutorial();
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (ctx) => TutorialModal(gameState: state),
                          );
                        },
                        child: const Text(
                          'BUKSAN ANG TUTORIAL',
                          style: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'Silkscreen'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RetroButton(
                        color: const Color(0xFF0F766E),
                        onTap: _showCreditsDialog,
                        child: const Text(
                          'CREDITS & TUNGKOL',
                          style: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'Silkscreen'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 3. IN-GAME SPECIFIC BUTTONS (SAVE / QUIT TO TITLE)
                if (widget.isInGame) ...[
                  Row(
                    children: [
                      Expanded(
                        child: RetroButton(
                          color: const Color(0xFF16A34A),
                          onTap: () {
                            state.saveGame();
                            _audio.playClick();
                            setState(() {
                              _statusMsg = '[NA-SAVE] Matagumpay na nai-save ang laro!';
                            });
                          },
                          child: const Text(
                            'MANUAL SAVE NGAYON',
                            style: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'Silkscreen'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RetroButton(
                          color: const Color(0xFFDC2626),
                          onTap: () {
                            Navigator.of(context).pop();
                            state.returnToTitle();
                          },
                          child: const Text(
                            'TITLE SCREEN',
                            style: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'Silkscreen'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // 4. JSON DATA BACKUP
                const Text(
                  'MANUAL JSON BACKUP & CLOUD TRANSFER:',
                  style: TextStyle(
                    color: Color(0xFFFDE047),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _jsonController,
                  maxLines: 3,
                  style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 8, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    hintText: 'I-paste ang JSON save string dito para i-import...',
                    hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 8),
                    fillColor: Color(0xFF1E293B),
                    filled: true,
                    isDense: true,
                    border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF475569))),
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: RetroButton(
                        color: const Color(0xFF0284C7),
                        onTap: _exportJson,
                        child: const Text(
                          'KOPYAHIN ANG SAVE',
                          style: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'Silkscreen'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RetroButton(
                        color: const Color(0xFFD97706),
                        onTap: _importJson,
                        child: const Text(
                          'I-IMPORT ANG SAVE',
                          style: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'Silkscreen'),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_statusMsg.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _statusMsg,
                    style: const TextStyle(
                      color: Color(0xFFFDE047),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
