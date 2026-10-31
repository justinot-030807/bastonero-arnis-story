// lib/ui/overlays/estudyante_modal.dart
// Student roster management, individual & batch activity scheduling, detail attributes, and Focus Tap.

import 'package:flutter/material.dart';
import '../../domain/models/alumni.dart';
import '../../domain/models/student.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';
import '../theme.dart';
import 'focus_tap_modal.dart';

class EstudyanteModal extends StatefulWidget {
  final GameStateProvider gameState;
  final Student? initialSelectedStudent;

  const EstudyanteModal({
    super.key,
    required this.gameState,
    this.initialSelectedStudent,
  });

  @override
  State<EstudyanteModal> createState() => _EstudyanteModalState();
}

class _EstudyanteModalState extends State<EstudyanteModal> {
  Student? _detailStudent;
  int _selectedTab = 0; // 0 = Aktibo, 1 = Alumni at Guro

  @override
  void initState() {
    super.initState();
    _detailStudent = widget.initialSelectedStudent;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;

    return Center(
      child: RetroBox(
        width: 480,
        height: MediaQuery.of(context).size.height * 0.90,
        title: _detailStudent != null
            ? 'DETALYE NG ESTUDYANTE'
            : (_selectedTab == 0
                ? 'MGA ESTUDYANTE NG KAMPO (${state.students.length}/${state.camp.maxStudents})'
                : 'MGA ALUMNI AT GURO (${state.camp.alumni.length + state.camp.trainers.length})'),
        titleTrailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        backgroundColor: RetroColors.deepBackground,
        child: _detailStudent != null
            ? _buildDetailView(state, _detailStudent!)
            : Column(
                children: [
                  // Tab selector buttons
                  Row(
                    children: [
                      Expanded(
                        child: RetroButton(
                          height: 32,
                          color: _selectedTab == 0 ? const Color(0xFFE6482E) : const Color(0xFF334155),
                          onTap: () => setState(() => _selectedTab = 0),
                          child: Text(
                            'AKTIBO (${state.students.length}/${state.camp.maxStudents})',
                            style: const TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: RetroButton(
                          height: 32,
                          color: _selectedTab == 1 ? const Color(0xFF0284C7) : const Color(0xFF334155),
                          onTap: () => setState(() => _selectedTab = 1),
                          child: Text(
                            'ALUMNI & GURO (${state.camp.alumni.length})',
                            style: const TextStyle(color: Colors.white, fontSize: 8.5, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _selectedTab == 0
                        ? _buildRosterListView(state)
                        : _buildAlumniAndGuroView(state),
                  ),
                ],
              ),
      ),
    );
  }

  // --- ROSTER LIST VIEW ---
  Widget _buildRosterListView(GameStateProvider state) {
    return Column(
      children: [
        // TOP BATCH ACTIONS BAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ITAKDA LAHAT (BATCH SCHEDULE):',
                style: TextStyle(
                  color: RetroColors.gold,
                  fontSize: 7.5,
                  fontFamily: 'Silkscreen',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildBatchButton('LAHAT LAKAS', ActivityType.sanayLakas, state),
                    _buildBatchButton('LAHAT BILIS', ActivityType.sanayBilis, state),
                    _buildBatchButton('LAHAT DISKARTE', ActivityType.sanayDiskarte, state),
                    _buildBatchButton('LAHAT SALAG', ActivityType.sanaySalag, state),
                    _buildBatchButton('LAHAT ANYO', ActivityType.sanayAnyo, state),
                    _buildBatchButton('LAHAT ARAL', ActivityType.aral, state),
                    _buildBatchButton('LAHAT HINGA', ActivityType.hinga, state),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // STUDENTS LIST
        Expanded(
          child: ListView.builder(
            itemCount: state.students.length,
            itemBuilder: (ctx, index) {
              final student = state.students[index];
              final isMain = student.id == state.activeStudentId;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMain ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B),
                  border: Border.all(
                    color: isMain ? RetroColors.gold : const Color(0xFF334155),
                    width: isMain ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    // TOP ROW: AVATAR, NAME, STYLE, ACTIVE BADGE
                    Row(
                      children: [
                        // AVATAR PLACEHOLDER / SPRITE
                        Container(
                          width: 32,
                          height: 32,
                          color: const Color(0xFF0F172A),
                          child: Center(
                            child: PixelSpriteWidget(
                              matrix: PixelArtCatalog.bayaniPortrait,
                              pixelSize: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    student.nickname.isNotEmpty
                                        ? '${student.name} "${student.nickname}"'
                                        : student.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Silkscreen',
                                    ),
                                  ),
                                  if (isMain) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      color: const Color(0xFFDC2626),
                                      child: const Text(
                                        'PANGUNAHIN',
                                        style: TextStyle(color: Colors.white, fontSize: 6.5, fontFamily: 'Silkscreen'),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                '${student.gradeDescription} | ${student.style.displayName}',
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 7, fontFamily: 'Silkscreen'),
                              ),
                            ],
                          ),
                        ),
                        // DETAIL BUTTON
                        RetroButton(
                          height: 24,
                          color: const Color(0xFF0284C7),
                          onTap: () {
                            setState(() {
                              _detailStudent = student;
                            });
                          },
                          child: const Text('DETALYE', style: TextStyle(fontSize: 7.5, fontFamily: 'Silkscreen')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // STATS ROW & PROGRESS BARS
                    Row(
                      children: [
                        _buildMiniStat('LAKAS', student.lakas, const Color(0xFFEF4444)),
                        _buildMiniStat('BILIS', student.bilis, const Color(0xFF38BDF8)),
                        _buildMiniStat('DISKARTE', student.diskarte, const Color(0xFFF59E0B)),
                        _buildMiniStat('SALAG', student.salag, const Color(0xFF10B981)),
                        _buildMiniStat('GRADO', student.gradePercent, const Color(0xFFA855F7), isPercent: true),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // BOTTOM ROW: FATIGUE, MORALE, ACTIVITY PICKER
                    Row(
                      children: [
                        // FATIGUE INDICATOR
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'PAGOD: ${student.fatigue.toInt()}%',
                                    style: TextStyle(
                                      color: student.fatigue > 70 ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
                                      fontSize: 7,
                                      fontFamily: 'Silkscreen',
                                    ),
                                  ),
                                  Text(
                                    'GANA: ${student.morale.toInt()}%',
                                    style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 7, fontFamily: 'Silkscreen'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              LinearProgressIndicator(
                                value: (student.fatigue / 100.0).clamp(0.0, 1.0),
                                backgroundColor: const Color(0xFF334155),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  student.fatigue > 70 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                                ),
                                minHeight: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // CURRENT ACTIVITY DROPDOWN
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            border: Border.all(color: RetroColors.gold),
                          ),
                          child: DropdownButton<ActivityType>(
                            value: student.currentActivity,
                            isDense: true,
                            underline: const SizedBox.shrink(),
                            dropdownColor: const Color(0xFF0F172A),
                            items: ActivityType.values.map((act) {
                              return DropdownMenuItem(
                                value: act,
                                child: Text(
                                  act.displayName,
                                  style: const TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'Silkscreen'),
                                ),
                              );
                            }).toList(),
                            onChanged: (newAct) {
                              if (newAct != null) {
                                state.assignStudentActivity(student.id, newAct);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBatchButton(String label, ActivityType act, GameStateProvider state) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => state.batchAssignActivity(act),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            border: Border.all(color: const Color(0xFF64748B)),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 7, fontFamily: 'Silkscreen'),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, double val, Color col, {bool isPercent = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 6.5, fontFamily: 'Silkscreen')),
          Text(
            isPercent ? '${val.toStringAsFixed(1)}%' : val.toStringAsFixed(1),
            style: TextStyle(color: col, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Silkscreen'),
          ),
        ],
      ),
    );
  }

  // --- DETAIL VIEW ---
  Widget _buildDetailView(GameStateProvider state, Student s) {
    final isMain = s.id == state.activeStudentId;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BACK BUTTON & PROFILE HEADER
          Row(
            children: [
              RetroButton(
                height: 26,
                color: const Color(0xFF475569),
                onTap: () {
                  setState(() {
                    _detailStudent = null;
                  });
                },
                child: const Text('BUMALIK SA LISTAHAN', style: TextStyle(fontSize: 7.5, fontFamily: 'Silkscreen')),
              ),
              const Spacer(),
              if (!isMain) ...[
                RetroButton(
                  height: 26,
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    state.setActiveStudent(s.id);
                    setState(() {});
                  },
                  child: const Text('GAWING PANGUNAHIN', style: TextStyle(fontSize: 7.5, fontFamily: 'Silkscreen')),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // BASIC STATS CARD
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              border: Border.all(color: RetroColors.gold),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.nickname.isNotEmpty ? '${s.name} "${s.nickname}"' : s.name,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Silkscreen'),
                    ),
                    Text(
                      s.status == StudentStatus.injured ? '[INJURED ${s.injuryWeeks}w]' : '[AKTIBO]',
                      style: TextStyle(
                        color: s.status == StudentStatus.injured ? const Color(0xFFEF4444) : const Color(0xFF4ADE80),
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Silkscreen',
                      ),
                    ),
                  ],
                ),
                Text(
                  '${s.gradeDescription} | Edad: ${s.age} | Kasarian: ${s.gender}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontFamily: 'Silkscreen'),
                ),
                Text(
                  'Arnis Style: ${s.style.displayName} | Matrikula: P${s.tuition}/linggo',
                  style: const TextStyle(color: RetroColors.gold, fontSize: 8, fontFamily: 'Silkscreen'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ATTRIBUTES BREAKDOWN
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
                  'MGA KATANGIAN AT ABILIDAD:',
                  style: TextStyle(color: RetroColors.gold, fontSize: 8, fontFamily: 'Silkscreen', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _buildStatProgressRow('LAKAS (STRIKE POWER)', s.lakas, 60.0, const Color(0xFFEF4444)),
                const SizedBox(height: 4),
                _buildStatProgressRow('BILIS (AGILITY & DODGE)', s.bilis, 60.0, const Color(0xFF38BDF8)),
                const SizedBox(height: 4),
                _buildStatProgressRow('DISKARTE (TECHNIQUE & ANYO)', s.diskarte, 60.0, const Color(0xFFF59E0B)),
                const SizedBox(height: 4),
                _buildStatProgressRow('SALAG (DEFENSE & BLOCK)', s.salag, 60.0, const Color(0xFF10B981)),
                const SizedBox(height: 4),
                _buildStatProgressRow('GRADO (ACADEMICS)', s.gradePercent, 100.0, const Color(0xFFA855F7), isPercent: true),
                const SizedBox(height: 4),
                _buildStatProgressRow('PAGOD (FATIGUE)', s.fatigue, 100.0, const Color(0xFFF97316), isPercent: true),
                const SizedBox(height: 4),
                _buildStatProgressRow('GANA (MORALE)', s.morale, 100.0, const Color(0xFF22C55E), isPercent: true),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // TRAITS & MOVES
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
                    const Text('TRAITS:', style: TextStyle(color: RetroColors.gold, fontSize: 8, fontFamily: 'Silkscreen')),
                    Text(
                      s.traits.join(', '),
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'Silkscreen'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('MOVES:', style: TextStyle(color: RetroColors.gold, fontSize: 8, fontFamily: 'Silkscreen')),
                    Text(
                      s.moves.join(', '),
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 8, fontFamily: 'Silkscreen'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('RECORD:', style: TextStyle(color: RetroColors.gold, fontSize: 8, fontFamily: 'Silkscreen')),
                    Text(
                      '${s.wins} Panalo - ${s.losses} Talo',
                      style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 8, fontFamily: 'Silkscreen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // FOCUS TAP MINI-GAME BUTTON
          RetroButton(
            height: 34,
            color: const Color(0xFFE6482E),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => FocusTapModal(
                  gameState: state,
                  student: s,
                  onCompleted: () {
                    setState(() {});
                  },
                ),
              );
            },
            child: const Text(
              'MAGSULIT NG FOCUS TAP (+25% / +40%)',
              style: TextStyle(fontSize: 8.5, fontFamily: 'Silkscreen', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlumniAndGuroView(GameStateProvider state) {
    final alumni = state.camp.alumni;
    final trainers = state.camp.trainers;

    return ListView(
      children: [
        // GURO TRAINERS SECTION
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            border: Border.all(color: const Color(0xFF0284C7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MGA GURO AT TRAINER',
                    style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                  Text(
                    '${trainers.length} Aktibo',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (trainers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    'Wala pang karagdagang guro. Ang mga nagtatapos na estudyante ay maaaring maging guro ng kampo.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 8, fontFamily: 'monospace', fontStyle: FontStyle.italic),
                  ),
                )
              else
                ...trainers.map((t) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(6),
                    color: const Color(0xFF0F172A),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                            ),
                            Text(
                              'Espesyalista: ${t.specialty.toUpperCase()} (+${t.skill * 4}% bilis ng ensayo)',
                              style: const TextStyle(color: Color(0xFFFDE047), fontSize: 7.5, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                        Text(
                          'P${t.salary}/buwan',
                          style: const TextStyle(color: Color(0xFFF87171), fontSize: 8, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ALUMNI SECTION
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            border: Border.all(color: const Color(0xFFF4B41B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MGA ALUMNI NG BAKURAN (PAMANA)',
                    style: TextStyle(color: Color(0xFFFDE047), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                  Text(
                    '${alumni.length} Nagtapos',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (alumni.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Wala pang nagtatapos na estudyante.\nSa pagtatapos ng Grade 12 o pagsapit ng edad 18, maaari silang pumili ng pamana: maging Guro, maging Sponsor, o ilagay sa Hall of Fame!',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 8, fontFamily: 'monospace', fontStyle: FontStyle.italic),
                  ),
                )
              else
                ...alumni.map((a) {
                  String roleLabel = '';
                  Color roleColor = Colors.white;
                  if (a.role == AlumniRole.trainer) {
                    roleLabel = '[GURO TRAINER]';
                    roleColor = const Color(0xFF38BDF8);
                  } else if (a.role == AlumniRole.sponsor) {
                    roleLabel = '[SPONSOR +P${a.monthlySponsorship}/mo]';
                    roleColor = const Color(0xFF4ADE80);
                  } else {
                    roleLabel = '[HALL OF FAME]';
                    roleColor = const Color(0xFFC084FC);
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${a.name} "${a.nickname}"',
                              style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              color: roleColor.withValues(alpha: 0.2),
                              child: Text(
                                roleLabel,
                                style: TextStyle(color: roleColor, fontSize: 7, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Nagtapos: Taon ${a.graduatedYear} Buwan ${a.graduatedMonth} | Stats: ${a.totalStats.toStringAsFixed(1)} | Rekord: ${a.wins}W - ${a.losses}L',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 7.5, fontFamily: 'monospace'),
                        ),
                        if (a.titles.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Mga Titulo: ${a.titles.join(", ")}',
                            style: const TextStyle(color: Color(0xFFFDE047), fontSize: 7, fontFamily: 'monospace'),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatProgressRow(String label, double val, double max, Color col, {bool isPercent = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 7, fontFamily: 'Silkscreen')),
            Text(
              isPercent ? '${val.toStringAsFixed(1)}%' : val.toStringAsFixed(1),
              style: TextStyle(color: col, fontSize: 7.5, fontWeight: FontWeight.bold, fontFamily: 'Silkscreen'),
            ),
          ],
        ),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: (val / max).clamp(0.0, 1.0),
          backgroundColor: const Color(0xFF334155),
          valueColor: AlwaysStoppedAnimation<Color>(col),
          minHeight: 4,
        ),
      ],
    );
  }
}
