import 'package:flutter/material.dart';
import '../../models/fighter_model.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';

class CharacterCreatorModal extends StatefulWidget {
  final GameStateProvider gameState;
  final int slotIndex;
  final VoidCallback onGameStarted;

  const CharacterCreatorModal({
    super.key,
    required this.gameState,
    required this.slotIndex,
    required this.onGameStarted,
  });

  @override
  State<CharacterCreatorModal> createState() => _CharacterCreatorModalState();
}

class _CharacterCreatorModalState extends State<CharacterCreatorModal> {
  final TextEditingController _nameController = TextEditingController(text: 'Bayani');
  final TextEditingController _nicknameController = TextEditingController(text: 'Bastonero');
  final TextEditingController _gymController = TextEditingController(text: 'Bakuran Arnis Camp');

  String _gender = 'Lalaki';
  int _skinIndex = 0; // 0: Kayumanggi, 1: Moreno, 2: Tisoy
  int _headbandIndex = 0; // 0: Red, 1: Blue, 2: Yellow, 3: Green, 4: Black
  int _hairIndex = 0; // 0: Spiky, 1: Crewcut, 2: Ponytail
  FighterStyle _selectedStyle = FighterStyle.soloBaston;

  int _selectedCoachIndex = 0;

  static const List<Map<String, String>> coaches = [
    {
      'name': 'Coach Kanor',
      'title': 'Tricycle Driver Arnisador',
      'perk': '+20% Hangin / Stamina Recovery',
      'quote': 'Kahit galing sa pamamasada, matatag ang hangin sa bakbakan!',
    },
    {
      'name': 'Maestro Berting',
      'title': 'Grandmaster ng Baryo',
      'perk': '+25% Diskarte & Technique XP',
      'quote': 'Ang tunay na sining ay nasa tamang anggulo at Anyo ng palo.',
    },
    {
      'name': 'Coach Ligaya',
      'title': 'School Varsity Adviser',
      'perk': '+25% Grado & Varsity Standing',
      'quote': 'Disiplina sa silid-aralan, dangal sa court ng Intrams!',
    },
    {
      'name': 'Kuya Dindo',
      'title': 'Kanto Brawler Veteran',
      'perk': '+25% Lakas & Strike Power',
      'quote': 'Wala nang pasikot-sikot, bagsak agad sa unang hataw!',
    },
  ];

  static const List<String> skinNames = ['Kayumanggi', 'Moreno', 'Tisoy'];
  static const List<String> hairNames = ['Spiky', 'Crewcut', 'Tali / Ponytail'];
  static const List<String> headbandNames = ['Pula', 'Asul', 'Dilaw', 'Berde', 'Itim'];
  static const List<Color> headbandColors = [
    Color(0xFFDC2626),
    Color(0xFF2563EB),
    Color(0xFFFACC15),
    Color(0xFF16A34A),
    Color(0xFF1E293B),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _gymController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final name = _nameController.text.trim().isEmpty ? 'Bayani' : _nameController.text.trim();
    final nickname = _nicknameController.text.trim().isEmpty ? 'Bastonero' : _nicknameController.text.trim();
    final gym = _gymController.text.trim().isEmpty ? 'Bakuran Arnis Camp' : _gymController.text.trim();
    final coach = coaches[_selectedCoachIndex];

    widget.gameState.startNewGame(
      slot: widget.slotIndex,
      fighterName: name,
      fighterNickname: nickname,
      gymName: gym,
      coachName: coach['name'],
      coachTitle: coach['title'],
      coachPerk: coach['perk'],
      gender: _gender,
      skinIndex: _skinIndex,
      headbandColorIndex: _headbandIndex,
      hairIndex: _hairIndex,
      startingStyle: _selectedStyle,
    );

    widget.onGameStarted();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: RetroBox(
          width: 520,
          height: MediaQuery.of(context).size.height * 0.94,
          title: 'PAGLIKHA NG ARNISADOR AT COACH',
          backgroundColor: const Color(0xFF0F172A),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SCROLLABLE CUSTOMIZATION BODY
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. CHARACTER PREVIEW + BASIC INFO
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: const Color(0xFFF4B41B), width: 1.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LIVE CHIBI SPRITE PREVIEW
                            Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    border: Border.all(color: headbandColors[_headbandIndex], width: 2),
                                  ),
                                  child: Center(
                                    child: PixelSpriteWidget(
                                      matrix: PixelArtCatalog.chibiBayaniIdle,
                                      pixelSize: 2.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  color: headbandColors[_headbandIndex],
                                  child: Text(
                                    headbandNames[_headbandIndex],
                                    style: const TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),

                            // NAME & NICKNAME FIELDS
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PANGALAN NG ARNISADOR:', style: TextStyle(color: Color(0xFFFDE047), fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 3),
                                  _buildRetroTextField(_nameController, 'e.g. Bayani, Juan, Danilo'),
                                  const SizedBox(height: 6),

                                  const Text('ALYAS / NICKNAME:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 3),
                                  _buildRetroTextField(_nicknameController, 'e.g. Bastonero, Kidlat, Agila'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2. APPEARANCE CONTROLS (GENDER, SKIN, HEADBAND)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: const Color(0xFF475569)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ANYO AT ITSURA:', style: TextStyle(color: Color(0xFFFDE047), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),

                            // Gender selector
                            const Text('KASARIAN:', style: TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'monospace')),
                            const SizedBox(height: 4),
                            Row(
                              children: ['Lalaki', 'Babae'].map((g) {
                                final isSel = _gender == g;
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    child: RetroButton(
                                      height: 26,
                                      color: isSel ? const Color(0xFF0284C7) : const Color(0xFF334155),
                                      onTap: () => setState(() => _gender = g),
                                      child: Text(
                                        g,
                                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),

                            // Hair selector
                            const Text('ESTILO NG BUHOK:', style: TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'monospace')),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(hairNames.length, (idx) {
                                final isSel = _hairIndex == idx;
                                return Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: idx < hairNames.length - 1 ? 6 : 0),
                                    child: RetroButton(
                                      height: 26,
                                      color: isSel ? const Color(0xFF0284C7) : const Color(0xFF334155),
                                      onTap: () => setState(() => _hairIndex = idx),
                                      child: Text(
                                        hairNames[idx],
                                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),

                            // Headband Color selector
                            const Text('KULAY NG BANDERAS / HEADBAND:', style: TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'monospace')),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(headbandColors.length, (idx) {
                                final isSel = _headbandIndex == idx;
                                return GestureDetector(
                                  onTap: () => setState(() => _headbandIndex = idx),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 32,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: headbandColors[idx],
                                      border: Border.all(
                                        color: isSel ? Colors.white : Colors.black,
                                        width: isSel ? 2.5 : 1.0,
                                      ),
                                    ),
                                    child: isSel
                                        ? const Center(child: Icon(Icons.check, color: Colors.white, size: 14))
                                        : null,
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),

                            // Skin Tone selector
                            const Text('KULAY NG BALAT:', style: TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'monospace')),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(skinNames.length, (idx) {
                                final isSel = _skinIndex == idx;
                                return Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: idx < skinNames.length - 1 ? 6 : 0),
                                    child: RetroButton(
                                      height: 28,
                                      color: isSel ? const Color(0xFF0284C7) : const Color(0xFF334155),
                                      onTap: () => setState(() => _skinIndex = idx),
                                      child: Text(
                                        skinNames[idx],
                                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3. STARTING ARNIS STYLE
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: const Color(0xFF475569)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PANIMULANG ISTILO NG ARNIS:', style: TextStyle(color: Color(0xFFFDE047), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            _buildStyleTile(
                              FighterStyle.soloBaston,
                              'Solo Baston (Isang Yantok)',
                              'Balanse sa abot at salag. Magbubukas ng "Abaniko Tres Puntas".',
                            ),
                            const SizedBox(height: 4),
                            _buildStyleTile(
                              FighterStyle.dobleBaston,
                              'Doble Baston / Sinawali (Dalawang Yantok)',
                              'Napakabilis na attack speed at combo hits. Magbubukas ng "Heaven Six".',
                            ),
                            const SizedBox(height: 4),
                            _buildStyleTile(
                              FighterStyle.espadaYDaga,
                              'Espada y Daga (Baston at Daga)',
                              'Malalakas na counter-attack at agaw-baston. Magbubukas ng "Sabong Disarm".',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 4. GYM & COACH SELECTION
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: const Color(0xFFF4B41B), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PANGALAN NG IYONG TRAINING CAMP / GYM:', style: TextStyle(color: Color(0xFFFDE047), fontSize: 9.5, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            _buildRetroTextField(_gymController, 'e.g. Bakuran Arnis Camp'),
                            const SizedBox(height: 10),

                            const Text('PUMILI NG IYONG COACH / TAGASANAY:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Column(
                              children: List.generate(coaches.length, (idx) {
                                final c = coaches[idx];
                                final isSel = _selectedCoachIndex == idx;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedCoachIndex = idx),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSel ? const Color(0xFF1E3A8A) : const Color(0xFF0F172A),
                                      border: Border.all(
                                        color: isSel ? const Color(0xFFF4B41B) : const Color(0xFF475569),
                                        width: isSel ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        PixelSpriteWidget(
                                          matrix: PixelArtCatalog.coachKanorPortrait,
                                          pixelSize: 1.6,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(c['name']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                    color: const Color(0xFF16A34A),
                                                    child: Text(c['perk']!, style: const TextStyle(color: Colors.white, fontSize: 7, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                                  ),
                                                ],
                                              ),
                                              Text(c['title']!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontFamily: 'monospace')),
                                              Text('"${c['quote']!}"', style: const TextStyle(color: Color(0xFFFDE047), fontSize: 7.5, fontFamily: 'monospace', fontStyle: FontStyle.italic)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // CONFIRM BUTTON
              RetroButton(
                height: 42,
                color: const Color(0xFFE6482E),
                onTap: _onConfirm,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PixelSpriteWidget(matrix: PixelArtCatalog.iconSanay, pixelSize: 1.3),
                    SizedBox(width: 8),
                    Text(
                      'SIMULAN ANG PAGLALAKBAY (START GAME)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
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

  Widget _buildRetroTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: const Color(0xFF64748B)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 10, fontFamily: 'monospace'),
        ),
      ),
    );
  }

  Widget _buildStyleTile(FighterStyle style, String title, String desc) {
    final isSel = _selectedStyle == style;
    return GestureDetector(
      onTap: () => setState(() => _selectedStyle = style),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF1E3A8A) : const Color(0xFF0F172A),
          border: Border.all(
            color: isSel ? const Color(0xFF38BDF8) : const Color(0xFF334155),
            width: isSel ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSel ? const Color(0xFF38BDF8) : const Color(0xFF64748B),
              size: 14,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
