// lib/ui/overlays/itayo_modal.dart
// Itayo (Build / Manage) Screen for placing, moving, and selling camp equipment on 14-tile floors.

import 'package:flutter/material.dart';
import '../../domain/models/equipment.dart';
import '../../domain/systems/data_loader.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';
import '../theme.dart';

class ItayoModal extends StatefulWidget {
  final GameStateProvider gameState;
  final int initialFloor;

  const ItayoModal({
    super.key,
    required this.gameState,
    this.initialFloor = 1,
  });

  @override
  State<ItayoModal> createState() => _ItayoModalState();
}

class _ItayoModalState extends State<ItayoModal> {
  late int _selectedFloor;
  Equipment? _selectedCatalogItem;
  PlacedEquipment? _selectedPlacedItem;
  bool _isMoveMode = false;
  int? _previewTileX;
  String _selectedCategory = 'lahat';

  @override
  void initState() {
    super.initState();
    _selectedFloor = widget.initialFloor.clamp(1, widget.gameState.unlockedFloors);
  }

  List<Equipment> get _catalogItems {
    final list = DataLoader.equipmentCatalog.isNotEmpty
        ? DataLoader.equipmentCatalog
        : _fallbackCatalog;

    if (_selectedCategory == 'lahat') return list;
    return list.where((e) => e.category.toLowerCase() == _selectedCategory).toList();
  }

  static const List<Equipment> _fallbackCatalog = [
    Equipment(id: 'rack_yantok', name: 'Rack ng Yantok', cost: 200, width: 2, category: 'training', statBonus: 'diskarte', bonusPercent: 0.05, description: 'Kailangan sa baston.'),
    Equipment(id: 'sako_buhangin', name: 'Sako ng Buhangin', cost: 300, width: 2, category: 'training', statBonus: 'lakas', bonusPercent: 0.10, description: '+10% Lakas ng palo.'),
    Equipment(id: 'poste_kawayan', name: 'Poste ng Kawayan', cost: 250, width: 1, category: 'training', statBonus: 'diskarte', bonusPercent: 0.10, description: '+10% Diskarte.'),
    Equipment(id: 'pad_target', name: 'Pad / Target', cost: 350, width: 2, category: 'training', statBonus: 'bilis', bonusPercent: 0.10, description: '+10% Bilis.'),
    Equipment(id: 'gulong_tire', name: 'Gulong (Tire)', cost: 400, width: 2, category: 'training', statBonus: 'lakas', bonusPercent: 0.15, description: '+15% Lakas.'),
    Equipment(id: 'banig_mat', name: 'Banig (Sparring)', cost: 150, width: 3, category: 'training', statBonus: 'all', bonusPercent: 0.05, description: 'Lugar para sa sparring.'),
    Equipment(id: 'mesa_aklat', name: 'Mesa at Aklat', cost: 400, width: 2, category: 'facility', statBonus: 'grado', bonusPercent: 0.10, description: 'Aral desks (+10% Grado).'),
    Equipment(id: 'sari_sari_store', name: 'Sari-sari Store', cost: 1200, width: 4, category: 'store', statBonus: 'morale', bonusPercent: 0.05, description: '+P60/linggo passive income.'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;

    return Center(
      child: RetroBox(
        width: 480,
        height: MediaQuery.of(context).size.height * 0.90,
        title: 'ITAYO (CAMP BUILD & MANAGE)',
        titleTrailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        backgroundColor: RetroColors.deepBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FUNDS & STATS HEADER
            _buildFundsHeader(state),
            const SizedBox(height: 8),

            // FLOOR SELECTOR TABS
            _buildFloorSelector(state),
            const SizedBox(height: 8),

            // 14-TILE INTERACTIVE FLOOR LANE
            _buildFloorGridLane(state),
            const SizedBox(height: 8),

            // ACTION BAR FOR SELECTED PLACEMENT / PREVIEW
            _buildActionControlBar(state),
            const SizedBox(height: 8),

            // CATALOG TABS & LIST
            Expanded(
              child: _buildCatalogSection(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundsHeader(GameStateProvider state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border.all(color: RetroColors.gold, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const PixelSpriteWidget(matrix: PixelArtCatalog.miniPeso, pixelSize: 1.5),
              const SizedBox(width: 6),
              Text(
                'KABANG YAMAN: P${state.pesos}',
                style: const TextStyle(
                  color: RetroColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Silkscreen',
                ),
              ),
            ],
          ),
          Text(
            'Floor $_selectedFloor ng ${state.unlockedFloors}F',
            style: const TextStyle(
              color: RetroColors.textCream,
              fontSize: 9,
              fontFamily: 'Silkscreen',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorSelector(GameStateProvider state) {
    return Row(
      children: [
        for (int f = 1; f <= state.unlockedFloors; f++) ...[
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFloor = f;
                  _selectedPlacedItem = null;
                  _previewTileX = null;
                  _isMoveMode = false;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedFloor == f ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                  border: Border.all(
                    color: _selectedFloor == f ? RetroColors.gold : const Color(0xFF475569),
                    width: _selectedFloor == f ? 2 : 1,
                  ),
                ),
                child: Text(
                  'FLOOR $f',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedFloor == f ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Silkscreen',
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFloorGridLane(GameStateProvider state) {
    final floorPlacements = state.placements.where((p) => p.floor == _selectedFloor).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Expanded(
              child: Text(
                'LANE NG PALAPAG (14 TILES):',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: RetroColors.textCream, fontSize: 7.5, fontFamily: 'Silkscreen'),
              ),
            ),
            Text(
              'Pumili ng tile',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 7, fontFamily: 'Silkscreen'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 52,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            border: Border.all(color: const Color(0xFF1A1C2C), width: 2),
          ),
          child: Row(
            children: List.generate(14, (tileIndex) {
              // Check if a placed equipment occupies this tile
              PlacedEquipment? occupyingItem;
              int relativeOffset = 0;
              for (final p in floorPlacements) {
                final meta = state.camp.getEquipmentMeta(p.equipmentId);
                final width = meta?.width ?? 2;
                if (tileIndex >= p.tileX && tileIndex < p.tileX + width) {
                  occupyingItem = p;
                  relativeOffset = tileIndex - p.tileX;
                  break;
                }
              }

              // Check if tile is in current placement preview
              bool isPreview = false;
              bool isPreviewValid = false;
              final targetWidth = _isMoveMode && _selectedPlacedItem != null
                  ? (state.camp.getEquipmentMeta(_selectedPlacedItem!.equipmentId)?.width ?? 2)
                  : (_selectedCatalogItem?.width ?? 0);

              if (_previewTileX != null && targetWidth > 0) {
                if (tileIndex >= _previewTileX! && tileIndex < _previewTileX! + targetWidth) {
                  isPreview = true;
                  final itemId = _isMoveMode && _selectedPlacedItem != null
                      ? _selectedPlacedItem!.equipmentId
                      : (_selectedCatalogItem?.id ?? '');
                  isPreviewValid = state.camp.canPlaceEquipment(
                    equipmentId: itemId,
                    floor: _selectedFloor,
                    tileX: _previewTileX!,
                    ignoreInstanceId: _isMoveMode ? _selectedPlacedItem?.instanceId : null,
                  );
                }
              }

              Color tileBg = const Color(0xFF0F172A);
              Border border = Border.all(color: const Color(0xFF334155), width: 0.5);

              if (isPreview) {
                tileBg = isPreviewValid ? const Color(0x8822C55E) : const Color(0x88EF4444);
                border = Border.all(
                  color: isPreviewValid ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                  width: 1.5,
                );
              } else if (occupyingItem != null) {
                final isSelected = _selectedPlacedItem?.instanceId == occupyingItem.instanceId;
                tileBg = isSelected ? const Color(0xFFF59E0B) : const Color(0xFF2563EB);
                border = Border.all(
                  color: isSelected ? Colors.white : const Color(0xFF1A1C2C),
                  width: isSelected ? 1.5 : 1.0,
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_isMoveMode) {
                        _previewTileX = tileIndex;
                      } else if (occupyingItem != null) {
                        _selectedPlacedItem = occupyingItem;
                        _selectedCatalogItem = null;
                        _previewTileX = null;
                      } else if (_selectedCatalogItem != null) {
                        _previewTileX = tileIndex;
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0.5),
                    decoration: BoxDecoration(
                      color: tileBg,
                      border: border,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (occupyingItem != null && relativeOffset == 0) ...[
                            Text(
                              occupyingItem.equipmentId.split('_').first.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 6.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Silkscreen',
                              ),
                              overflow: TextOverflow.clip,
                            ),
                          ] else ...[
                            Text(
                              '${tileIndex + 1}',
                              style: TextStyle(
                                color: isPreview ? Colors.white : const Color(0xFF64748B),
                                fontSize: 6.5,
                                fontFamily: 'Silkscreen',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildActionControlBar(GameStateProvider state) {
    if (_isMoveMode && _selectedPlacedItem != null && _previewTileX != null) {
      final isValid = state.camp.canPlaceEquipment(
        equipmentId: _selectedPlacedItem!.equipmentId,
        floor: _selectedFloor,
        tileX: _previewTileX!,
        ignoreInstanceId: _selectedPlacedItem!.instanceId,
      );

      return Container(
        padding: const EdgeInsets.all(6),
        color: const Color(0xFF1E293B),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Ilipat sa Tile ${_previewTileX! + 1}? ${isValid ? "[PWEDE]" : "[BAWAL/HARANG]"}',
                style: TextStyle(
                  color: isValid ? const Color(0xFF4ADE80) : const Color(0xFFEF4444),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Silkscreen',
                ),
              ),
            ),
            RetroButton(
              height: 28,
              color: const Color(0xFF64748B),
              onTap: () {
                setState(() {
                  _isMoveMode = false;
                  _previewTileX = null;
                });
              },
              child: const Text('KANSELA', style: TextStyle(fontSize: 8, fontFamily: 'Silkscreen')),
            ),
            const SizedBox(width: 6),
            RetroButton(
              height: 28,
              color: isValid ? const Color(0xFF16A34A) : const Color(0xFF334155),
              onTap: isValid
                  ? () {
                      state.moveEquipmentPlacement(
                        instanceId: _selectedPlacedItem!.instanceId,
                        newFloor: _selectedFloor,
                        newTileX: _previewTileX!,
                      );
                      setState(() {
                        _isMoveMode = false;
                        _previewTileX = null;
                        _selectedPlacedItem = null;
                      });
                    }
                  : null,
              child: const Text('KUMPIRMA (LIBRE)', style: TextStyle(fontSize: 8, fontFamily: 'Silkscreen')),
            ),
          ],
        ),
      );
    }

    if (_selectedPlacedItem != null) {
      final meta = state.camp.getEquipmentMeta(_selectedPlacedItem!.equipmentId);
      final refund = ((meta?.cost ?? 200) * 0.5).round();

      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta?.name ?? _selectedPlacedItem!.equipmentId,
                    style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold, fontFamily: 'Silkscreen'),
                  ),
                  Text(
                    'Pwesto: Tile ${_selectedPlacedItem!.tileX + 1} | Lapad: ${meta?.width ?? 2} tiles',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 7.5, fontFamily: 'Silkscreen'),
                  ),
                ],
              ),
            ),
            RetroButton(
              height: 28,
              color: const Color(0xFF0284C7),
              onTap: () {
                setState(() {
                  _isMoveMode = true;
                  _previewTileX = _selectedPlacedItem!.tileX;
                });
              },
              child: const Text('ILIPAT', style: TextStyle(fontSize: 8, fontFamily: 'Silkscreen')),
            ),
            const SizedBox(width: 6),
            RetroButton(
              height: 28,
              color: const Color(0xFFDC2626),
              onTap: () {
                state.sellEquipmentPlacement(_selectedPlacedItem!.instanceId);
                setState(() {
                  _selectedPlacedItem = null;
                  _previewTileX = null;
                });
              },
              child: Text('IBENTA (+P$refund)', style: const TextStyle(fontSize: 8, fontFamily: 'Silkscreen')),
            ),
          ],
        ),
      );
    }

    if (_selectedCatalogItem != null) {
      final canAfford = state.pesos >= _selectedCatalogItem!.cost;
      final isValid = _previewTileX != null &&
          state.camp.canPlaceEquipment(
            equipmentId: _selectedCatalogItem!.id,
            floor: _selectedFloor,
            tileX: _previewTileX!,
          );

      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          border: Border.all(color: RetroColors.gold, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Napili: ${_selectedCatalogItem!.name} (P${_selectedCatalogItem!.cost})',
                    style: const TextStyle(color: RetroColors.gold, fontSize: 8.5, fontWeight: FontWeight.bold, fontFamily: 'Silkscreen'),
                  ),
                  Text(
                    _previewTileX != null
                        ? 'Pwesto: Tile ${_previewTileX! + 1} ${isValid ? "[PWEDE]" : "[HARANG/KULANG]"}'
                        : 'Pumili ng tile sa lane sa itaas',
                    style: TextStyle(
                      color: isValid ? const Color(0xFF4ADE80) : const Color(0xFF94A3B8),
                      fontSize: 7.5,
                      fontFamily: 'Silkscreen',
                    ),
                  ),
                ],
              ),
            ),
            RetroButton(
              height: 28,
              color: const Color(0xFF64748B),
              onTap: () {
                setState(() {
                  _selectedCatalogItem = null;
                  _previewTileX = null;
                });
              },
              child: const Text('KANSELA', style: TextStyle(fontSize: 8, fontFamily: 'Silkscreen')),
            ),
            const SizedBox(width: 6),
            RetroButton(
              height: 28,
              color: (canAfford && isValid) ? const Color(0xFF16A34A) : const Color(0xFF334155),
              onTap: (canAfford && isValid)
                  ? () {
                      state.placeEquipmentOnFloor(
                        equipmentId: _selectedCatalogItem!.id,
                        floor: _selectedFloor,
                        tileX: _previewTileX!,
                      );
                      setState(() {
                        _selectedCatalogItem = null;
                        _previewTileX = null;
                      });
                    }
                  : null,
              child: Text(
                'ITAYO (P${_selectedCatalogItem!.cost})',
                style: const TextStyle(fontSize: 8, fontFamily: 'Silkscreen'),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCatalogSection(GameStateProvider state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // CATEGORY TABS
        Row(
          children: [
            _buildCategoryTab('lahat', 'LAHAT'),
            _buildCategoryTab('training', 'PAGSASANAY'),
            _buildCategoryTab('facility', 'PASILIDAD'),
            _buildCategoryTab('store', 'TINDAHAN'),
          ],
        ),
        const SizedBox(height: 6),

        // CATALOG CARDS
        Expanded(
          child: ListView.builder(
            itemCount: _catalogItems.length,
            itemBuilder: (ctx, index) {
              final item = _catalogItems[index];
              final isSelected = _selectedCatalogItem?.id == item.id;
              final canAfford = state.pesos >= item.cost;

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B),
                  border: Border.all(
                    color: isSelected ? RetroColors.gold : const Color(0xFF334155),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // ITEM ICON / BADGE
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        border: Border.all(color: const Color(0xFF1A1C2C)),
                      ),
                      child: Center(
                        child: Text(
                          item.name.substring(0, item.name.length > 3 ? 3 : item.name.length).toUpperCase(),
                          style: const TextStyle(color: RetroColors.gold, fontSize: 8, fontFamily: 'Silkscreen'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold, fontFamily: 'Silkscreen'),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                color: const Color(0xFF0F172A),
                                child: Text(
                                  '${item.width} TILES',
                                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 7, fontFamily: 'Silkscreen'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 7.5, fontFamily: 'monospace'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // PRICE & SELECT BUTTON
                    RetroButton(
                      height: 30,
                      color: canAfford ? (isSelected ? const Color(0xFFF59E0B) : const Color(0xFF16A34A)) : const Color(0xFF475569),
                      onTap: canAfford
                          ? () {
                              setState(() {
                                _selectedCatalogItem = item;
                                _selectedPlacedItem = null;
                                _isMoveMode = false;
                                _previewTileX ??= 0;
                              });
                            }
                          : null,
                      child: Text(
                        isSelected ? 'NAPILI' : 'P${item.cost}',
                        style: const TextStyle(fontSize: 8, fontFamily: 'Silkscreen', fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildCategoryTab(String catKey, String label) {
    final isActive = _selectedCategory == catKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = catKey),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
            border: Border.all(
              color: isActive ? RetroColors.gold : const Color(0xFF334155),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
              fontSize: 6.5,
              fontWeight: FontWeight.bold,
              fontFamily: 'Silkscreen',
            ),
          ),
        ),
      ),
    );
  }
}
