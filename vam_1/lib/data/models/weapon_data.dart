/// 무기 데이터 모델
/// 무기는 기본 스킬을 내장하고 있음
class WeaponData {
  final String id;
  final String name;
  final String description;
  final WeaponRarity rarity;
  final String baseSkillId;  // 무기에 내장된 기본 스킬 ID

  const WeaponData({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.baseSkillId,
  });
}

enum WeaponRarity {
  common,
  rare,
  epic,
  legendary,
}

/// 기본 무기 정의
class DefaultWeapons {
  DefaultWeapons._();

  /// 초보자의 지팡이 - 에너지 볼트 발사
  static const WeaponData STARTER_WAND = WeaponData(
    id: 'weapon_starter_wand',
    name: '초보자의 지팡이',
    description: '에너지 볼트를 발사하는 기본 지팡이',
    rarity: WeaponRarity.common,
    baseSkillId: 'skill_energy_bolt',
  );

  /// 회전 검 - 회전 검 스킬
  static const WeaponData SPINNING_SWORD = WeaponData(
    id: 'weapon_spinning_sword',
    name: '회전 검',
    description: '주변을 회전하며 적을 베는 검',
    rarity: WeaponRarity.common,
    baseSkillId: 'skill_spinning_blade',
  );

  /// 화염 지팡이 - 화염 폭발
  static const WeaponData FIRE_STAFF = WeaponData(
    id: 'weapon_fire_staff',
    name: '화염 지팡이',
    description: '주변에 화염 폭발을 일으키는 지팡이',
    rarity: WeaponRarity.rare,
    baseSkillId: 'skill_fire_burst',
  );

  /// 독 활 - 독 화살 발사
  static const WeaponData POISON_BOW = WeaponData(
    id: 'weapon_poison_bow',
    name: '독 활',
    description: '관통하는 독 화살을 발사하는 활',
    rarity: WeaponRarity.rare,
    baseSkillId: 'skill_poison_arrow',
  );

  /// 번개 지팡이 - 번개 연쇄
  static const WeaponData LIGHTNING_STAFF = WeaponData(
    id: 'weapon_lightning_staff',
    name: '번개 지팡이',
    description: '적 사이를 튕기는 번개를 발사',
    rarity: WeaponRarity.epic,
    baseSkillId: 'skill_chain_lightning',
  );

  static List<WeaponData> get all => [
    STARTER_WAND,
    SPINNING_SWORD,
    FIRE_STAFF,
    POISON_BOW,
    LIGHTNING_STAFF,
  ];

  static WeaponData? GetById(String id) {
    try {
      return all.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 스킬 ID로 무기 찾기
  static WeaponData? GetBySkillId(String skillId) {
    try {
      return all.firstWhere((w) => w.baseSkillId == skillId);
    } catch (_) {
      return null;
    }
  }
}
