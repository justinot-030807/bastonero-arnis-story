import 'package:flutter/material.dart';
import '../../models/fighter_model.dart';
import '../../providers/game_state_provider.dart';
import '../retro_ui.dart';

class TianggeModal extends StatefulWidget {
  final GameStateProvider gameState;

  const TianggeModal({super.key, required this.gameState});

  @override
  State<TianggeModal> createState() => _TianggeModalState();
}

class _TianggeModalState extends State<TianggeModal> {
  int _selectedTab = 0; // 0 = Nutrition & Food, 1 = Weapons, 2 = Gear

  List<String> _getMatrixForFood(String itemRef) {
    switch (itemRef) {
      case 'buko_juice':
      case 'buko':
        return PixelArtCatalog.bukoJuice;
      case 'nilagang_saba':
      case 'saba':
        return PixelArtCatalog.nilagangSaba;
      case 'taho':
        return PixelArtCatalog.taho;
      case 'adobo':
        return PixelArtCatalog.adobongManok;
      case 'balut':
        return PixelArtCatalog.balut;
      case 'mangga':
        return PixelArtCatalog.hinogNaMangga;
      default:
        return PixelArtCatalog.bukoJuice;
    }
  }

  List<String> _getMatrixForWeapon(String weaponId) {
    switch (weaponId) {
      case 'bahi':
        return PixelArtCatalog.bahiStick;
      case 'kamagong':
        return PixelArtCatalog.kamagongStick;
      case 'padded_stick':
        return PixelArtCatalog.paddedStick;
      case 'yantok':
      default:
        return PixelArtCatalog.yantokStick;
    }
  }

  List<String> _getMatrixForGear(String gearId) {
    switch (gearId) {
      case 'headgear':
        return PixelArtCatalog.gearHeadgear;
      case 'body_armor':
        return PixelArtCatalog.gearArmor;
      case 'rubber_shoes':
      default:
        return PixelArtCatalog.gearShoes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.gameState;
    final fighter = state.fighter;

    return Center(
      child: RetroBox(
        width: 520,
        height: MediaQuery.of(context).size.height * 0.88,
        title: 'PINOY TIANGGE AT NUTRITION',
        titleTrailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        backgroundColor: const Color(0xFF0F172A),
        child: Column(
          children: [
            // WALLET & ACTIVE BUFF STATUS
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border.all(color: const Color(0xFF475569)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const PixelSpriteWidget(matrix: PixelArtCatalog.miniPeso, pixelSize: 2.0),
                      const SizedBox(width: 6),
                      Text(
                        'PERA: P${state.pesos}',
                        style: const TextStyle(
                          color: Color(0xFFFDE047),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  if (state.activeBuffs.isNotEmpty)
                    Row(
                      children: [
                        const Text(
                          'BUFFS: ',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontFamily: 'monospace'),
                        ),
                        for (final b in state.activeBuffs) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A),
                              border: Border.all(color: const Color(0xFFF4ECE1)),
                            ),
                            child: Text(
                              '${b.name} (${b.remainingWeeks}w)',
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // TABS (3 TABS: NUTRITION, WEAPONS, GEAR)
            Row(
              children: [
                Expanded(
                  child: RetroButton(
                    height: 34,
                    color: _selectedTab == 0 ? const Color(0xFFE6482E) : const Color(0xFF334155),
                    onTap: () => setState(() => _selectedTab = 0),
                    child: const Text('NUTRISYON (FOOD)', style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: RetroButton(
                    height: 34,
                    color: _selectedTab == 1 ? const Color(0xFFE6482E) : const Color(0xFF334155),
                    onTap: () => setState(() => _selectedTab = 1),
                    child: const Text('BASTON (WEAPONS)', style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: RetroButton(
                    height: 34,
                    color: _selectedTab == 2 ? const Color(0xFFE6482E) : const Color(0xFF334155),
                    onTap: () => setState(() => _selectedTab = 2),
                    child: const Text('GEAR (ARMOR)', style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // CONTENT LIST
            Expanded(
              child: ListView(
                children: [
                  if (_selectedTab == 0) ..._buildNutritionItems(state),
                  if (_selectedTab == 1) ..._buildWeaponsList(state, fighter),
                  if (_selectedTab == 2) ..._buildGearList(state, fighter),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNutritionItems(GameStateProvider state) {
    return state.inventory.map((item) {
      final canAfford = state.pesos >= item.price;
      final isOwned = item.quantity > 0;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          border: Border.all(
            color: isOwned ? const Color(0xFFF4B41B) : const Color(0xFF475569),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            PixelSpriteWidget(matrix: _getMatrixForFood(item.id), pixelSize: 2.2),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (item.quantity > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          color: const Color(0xFF16A34A),
                          child: Text(
                            'x${item.quantity}',
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(item.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9)),
                  const SizedBox(height: 2),
                  Text('Presyo: P${item.price}', style: const TextStyle(color: Color(0xFFFDE047), fontSize: 9, fontFamily: 'monospace')),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              children: [
                if (isOwned) ...[
                  RetroButton(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    color: const Color(0xFF16A34A),
                    onTap: () {
                      state.consumeFoodItem(item);
                      setState(() {});
                    },
                    child: const Text('KAININ', style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace')),
                  ),
                  const SizedBox(height: 4),
                ],
                RetroButton(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: canAfford ? const Color(0xFF0284C7) : const Color(0xFF475569),
                  onTap: canAfford
                      ? () {
                          state.buyFoodItem(item, 1);
                          setState(() {});
                        }
                      : null,
                  child: const Text('BILI', style: TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace')),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildWeaponsList(GameStateProvider state, FighterModel fighter) {
    return WeaponItem.defaultShopWeapons.map((weapon) {
      final isEquipped = fighter.equippedWeapon.id == weapon.id;
      final canAfford = state.pesos >= weapon.price;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          border: Border.all(
            color: isEquipped ? const Color(0xFF22C55E) : const Color(0xFF475569),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            PixelSpriteWidget(matrix: _getMatrixForWeapon(weapon.id), pixelSize: 2.2),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weapon.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(weapon.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9)),
                  const SizedBox(height: 2),
                  Text(
                    '+${weapon.powerBonus} Lakas | ${weapon.speedBonus >= 0 ? '+' : ''}${weapon.speedBonus} Bilis | +${weapon.techniqueBonus} Diskarte',
                    style: const TextStyle(color: Color(0xFFFDE047), fontSize: 9, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            RetroButton(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: isEquipped ? const Color(0xFF334155) : (canAfford ? const Color(0xFFE6482E) : const Color(0xFF475569)),
              onTap: isEquipped
                  ? null
                  : (canAfford
                      ? () {
                          state.buyWeapon(weapon);
                          setState(() {});
                        }
                      : null),
              child: Text(
                isEquipped ? 'SUOT NA' : 'P${weapon.price}',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildGearList(GameStateProvider state, FighterModel fighter) {
    return GearItem.defaultShopGears.map((gear) {
      final isEquipped = fighter.equippedGears.any((g) => g.id == gear.id);
      final canAfford = state.pesos >= gear.price;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          border: Border.all(
            color: isEquipped ? const Color(0xFF22C55E) : const Color(0xFF475569),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            PixelSpriteWidget(matrix: _getMatrixForGear(gear.id), pixelSize: 2.2),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gear.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(gear.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9)),
                  const SizedBox(height: 2),
                  Text(
                    '+${gear.defenseBonus} Salag | +${gear.staminaBonus} Hangin | ${gear.speedBonus >= 0 ? '+' : ''}${gear.speedBonus} Bilis',
                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            RetroButton(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: isEquipped ? const Color(0xFF334155) : (canAfford ? const Color(0xFF0284C7) : const Color(0xFF475569)),
              onTap: isEquipped
                  ? null
                  : (canAfford
                      ? () {
                          state.buyGear(gear);
                          setState(() {});
                        }
                      : null),
              child: Text(
                isEquipped ? 'SUOT NA' : 'P${gear.price}',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
