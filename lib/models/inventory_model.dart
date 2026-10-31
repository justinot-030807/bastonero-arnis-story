class ActiveBuff {
  final String id;
  final String name;
  final String itemRef;
  int remainingWeeks;
  final double powerMultiplier;
  final double speedMultiplier;
  final double techniqueMultiplier;
  final double defenseMultiplier;
  final double academicBonus;

  ActiveBuff({
    required this.id,
    required this.name,
    required this.itemRef,
    required this.remainingWeeks,
    this.powerMultiplier = 0.0,
    this.speedMultiplier = 0.0,
    this.techniqueMultiplier = 0.0,
    this.defenseMultiplier = 0.0,
    this.academicBonus = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'itemRef': itemRef,
        'remainingWeeks': remainingWeeks,
        'powerMultiplier': powerMultiplier,
        'speedMultiplier': speedMultiplier,
        'techniqueMultiplier': techniqueMultiplier,
        'defenseMultiplier': defenseMultiplier,
        'academicBonus': academicBonus,
      };

  factory ActiveBuff.fromJson(Map<String, dynamic> json) => ActiveBuff(
        id: json['id'] as String,
        name: json['name'] as String,
        itemRef: json['itemRef'] as String? ?? 'buko',
        remainingWeeks: json['remainingWeeks'] as int? ?? 1,
        powerMultiplier: (json['powerMultiplier'] as num?)?.toDouble() ?? 0.0,
        speedMultiplier: (json['speedMultiplier'] as num?)?.toDouble() ?? 0.0,
        techniqueMultiplier: (json['techniqueMultiplier'] as num?)?.toDouble() ?? 0.0,
        defenseMultiplier: (json['defenseMultiplier'] as num?)?.toDouble() ?? 0.0,
        academicBonus: (json['academicBonus'] as num?)?.toDouble() ?? 0.0,
      );
}

class InventoryItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final double staminaRestore;
  final double hpRestore;
  final double academicGain;
  final ActiveBuff? grantedBuff;
  final bool isHarvestable;
  int quantity;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.staminaRestore = 0.0,
    this.hpRestore = 0.0,
    this.academicGain = 0.0,
    this.grantedBuff,
    this.isHarvestable = false,
    this.quantity = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'staminaRestore': staminaRestore,
        'hpRestore': hpRestore,
        'academicGain': academicGain,
        'grantedBuff': grantedBuff?.toJson(),
        'isHarvestable': isHarvestable,
        'quantity': quantity,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: json['price'] as int? ?? 0,
        staminaRestore: (json['staminaRestore'] as num?)?.toDouble() ?? 0.0,
        hpRestore: (json['hpRestore'] as num?)?.toDouble() ?? 0.0,
        academicGain: (json['academicGain'] as num?)?.toDouble() ?? 0.0,
        grantedBuff: json['grantedBuff'] != null
            ? ActiveBuff.fromJson(json['grantedBuff'] as Map<String, dynamic>)
            : null,
        isHarvestable: json['isHarvestable'] as bool? ?? false,
        quantity: json['quantity'] as int? ?? 0,
      );

  static List<InventoryItem> createDefaultCatalog() {
    return [
      InventoryItem(
        id: 'buko_juice',
        name: 'Sariwang Buko Juice',
        description: 'Fresh coconut water. Restores 40 Hangin (Stamina). Harvestable from Buko Stand!',
        price: 35,
        staminaRestore: 40.0,
        isHarvestable: true,
        quantity: 2,
      ),
      InventoryItem(
        id: 'nilagang_saba',
        name: 'Nilagang Saba',
        description: 'Boiled saba bananas. Grants +30% Bilis (Speed) training buff for 2 weeks.',
        price: 45,
        staminaRestore: 15.0,
        grantedBuff: ActiveBuff(
          id: 'buff_saba',
          name: 'Saba Agility',
          itemRef: 'saba',
          remainingWeeks: 2,
          speedMultiplier: 0.30,
        ),
        quantity: 1,
      ),
      InventoryItem(
        id: 'taho',
        name: 'Mainit na Taho',
        description: 'Sweet silken tofu and sago pearls. Restores 25 Stamina, +15% Speed XP for 2 weeks.',
        price: 30,
        staminaRestore: 25.0,
        grantedBuff: ActiveBuff(
          id: 'buff_taho',
          name: 'Taho Rush',
          itemRef: 'taho',
          remainingWeeks: 2,
          speedMultiplier: 0.15,
        ),
        quantity: 1,
      ),
      InventoryItem(
        id: 'adobo',
        name: 'Adobong Manok sa Palayok',
        description: 'Savory pinoy chicken adobo. High protein! Grants +40% Lakas & +25% Salag for 2 weeks.',
        price: 120,
        staminaRestore: 30.0,
        hpRestore: 20.0,
        grantedBuff: ActiveBuff(
          id: 'buff_adobo',
          name: 'Adobo Power',
          itemRef: 'adobo',
          remainingWeeks: 2,
          powerMultiplier: 0.40,
          defenseMultiplier: 0.25,
        ),
        quantity: 0,
      ),
      InventoryItem(
        id: 'balut',
        name: 'Mainit na Balut',
        description: 'Steaming fertilized duck egg. Heavy stamina and raw power! +50% Lakas for 2 weeks.',
        price: 50,
        staminaRestore: 20.0,
        hpRestore: 15.0,
        grantedBuff: ActiveBuff(
          id: 'buff_balut',
          name: 'Balut Grit',
          itemRef: 'balut',
          remainingWeeks: 2,
          powerMultiplier: 0.50,
        ),
        quantity: 0,
      ),
      InventoryItem(
        id: 'mangga',
        name: 'Hinog na Mangga',
        description: 'Sweet golden mango picked from camp tree. Boosts Grado (+3.0) and +25% Diskarte for 2 weeks.',
        price: 60,
        staminaRestore: 20.0,
        academicGain: 3.0,
        isHarvestable: true,
        grantedBuff: ActiveBuff(
          id: 'buff_mangga',
          name: 'Mango Genius',
          itemRef: 'mangga',
          remainingWeeks: 2,
          techniqueMultiplier: 0.25,
          academicBonus: 0.20,
        ),
        quantity: 1,
      ),
    ];
  }
}
