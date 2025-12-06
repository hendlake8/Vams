import 'package:flutter/material.dart';

import 'actor_stats.dart';

/// 장비 슬롯 타입
enum EquipmentSlot {
  weapon,     // 무기
  armor,      // 방어구
  accessory,  // 액세서리
}

/// 장비 등급
enum EquipmentRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// 장비 스탯 (장비 전용)
class EquipmentStats {
  final int hp;
  final int atk;
  final int def;

  const EquipmentStats({
    this.hp = 0,
    this.atk = 0,
    this.def = 0,
  });
}

/// 장비 데이터 모델
class EquipmentData {
  final String id;
  final String name;
  final String description;
  final EquipmentSlot slot;
  final EquipmentRarity rarity;
  final EquipmentStats stats;  // 장비 착용 시 추가 스탯
  final String? skillId;  // 무기 전용: 스킬 ID
  final String? specialEffect;  // 특수 효과 ID (선택)

  const EquipmentData({
    required this.id,
    required this.name,
    required this.description,
    required this.slot,
    required this.rarity,
    required this.stats,
    this.skillId,
    this.specialEffect,
  });

  // 하위 호환성을 위한 getter
  ActorStats get bonusStats => ActorStats(
    hp: stats.hp,
    atk: stats.atk,
    def: stats.def,
    spd: 0,
    critRate: 0,
    critDmg: 0,
  );

  /// 등급별 스탯 배율 (강화 시 사용)
  double GetRarityMultiplier() {
    switch (rarity) {
      case EquipmentRarity.common:
        return 1.0;
      case EquipmentRarity.uncommon:
        return 1.2;
      case EquipmentRarity.rare:
        return 1.5;
      case EquipmentRarity.epic:
        return 2.0;
      case EquipmentRarity.legendary:
        return 3.0;
    }
  }
}

/// 장비 인스턴스 (보유 장비)
class EquipmentInstance {
  final String instanceId;  // 고유 인스턴스 ID
  final EquipmentData data;
  int level;
  bool isEquipped;

  EquipmentInstance({
    required this.instanceId,
    required this.data,
    this.level = 1,
    this.isEquipped = false,
  });

  /// 현재 레벨의 보너스 스탯 계산
  ActorStats GetCurrentStats() {
    final multiplier = 1.0 + (level - 1) * 0.1;  // 레벨당 10% 증가
    return ActorStats(
      hp: (data.bonusStats.hp * multiplier).round(),
      atk: (data.bonusStats.atk * multiplier).round(),
      def: (data.bonusStats.def * multiplier).round(),
      spd: data.bonusStats.spd * multiplier,
      critRate: data.bonusStats.critRate * multiplier,
      critDmg: data.bonusStats.critDmg * multiplier,
    );
  }

  /// 최대 레벨 (등급별)
  int GetMaxLevel() {
    switch (data.rarity) {
      case EquipmentRarity.common:
        return 10;
      case EquipmentRarity.uncommon:
        return 15;
      case EquipmentRarity.rare:
        return 20;
      case EquipmentRarity.epic:
        return 25;
      case EquipmentRarity.legendary:
        return 30;
    }
  }

  /// 강화 가능 여부
  bool CanUpgrade() => level < GetMaxLevel();
}

/// 기본 장비 정의
class DefaultEquipments {
  DefaultEquipments._();

  // ========== 무기 ==========

  /// 초보자의 지팡이 - 에너지 볼트
  static const EquipmentData STARTER_WAND = EquipmentData(
    id: 'equip_starter_wand',
    name: '초보자의 지팡이',
    description: '에너지 볼트를 발사하는 기본 지팡이.',
    slot: EquipmentSlot.weapon,
    rarity: EquipmentRarity.common,
    stats: EquipmentStats(hp: 0, atk: 3, def: 0),
    skillId: 'skill_energy_bolt',
  );

  static const EquipmentData IRON_SWORD = EquipmentData(
    id: 'equip_iron_sword',
    name: '철 검',
    description: '기본적인 철제 검. 공격력을 소폭 올려줍니다.',
    slot: EquipmentSlot.weapon,
    rarity: EquipmentRarity.common,
    stats: EquipmentStats(hp: 0, atk: 5, def: 0),
    skillId: 'skill_spinning_blade',
  );

  static const EquipmentData FLAME_BLADE = EquipmentData(
    id: 'equip_flame_blade',
    name: '화염 검',
    description: '불꽃이 깃든 검. 높은 공격력과 화염 폭발 스킬.',
    slot: EquipmentSlot.weapon,
    rarity: EquipmentRarity.rare,
    stats: EquipmentStats(hp: 0, atk: 12, def: 0),
    skillId: 'skill_fire_burst',
  );

  static const EquipmentData THUNDER_STAFF = EquipmentData(
    id: 'equip_thunder_staff',
    name: '번개 지팡이',
    description: '번개의 힘을 담은 지팡이. 연쇄 번개 스킬.',
    slot: EquipmentSlot.weapon,
    rarity: EquipmentRarity.epic,
    stats: EquipmentStats(hp: 0, atk: 20, def: 0),
    skillId: 'skill_chain_lightning',
  );

  static const EquipmentData POISON_BOW = EquipmentData(
    id: 'equip_poison_bow',
    name: '독 활',
    description: '관통하는 독 화살을 발사하는 활.',
    slot: EquipmentSlot.weapon,
    rarity: EquipmentRarity.rare,
    stats: EquipmentStats(hp: 0, atk: 8, def: 0),
    skillId: 'skill_poison_arrow',
  );

  // ========== 방어구 ==========

  static const EquipmentData LEATHER_ARMOR = EquipmentData(
    id: 'equip_leather_armor',
    name: '가죽 갑옷',
    description: '기본적인 가죽 갑옷. 방어력을 소폭 올려줍니다.',
    slot: EquipmentSlot.armor,
    rarity: EquipmentRarity.common,
    stats: EquipmentStats(hp: 20, atk: 0, def: 3),
  );

  static const EquipmentData KNIGHT_PLATE = EquipmentData(
    id: 'equip_knight_plate',
    name: '기사의 판금 갑옷',
    description: '튼튼한 판금 갑옷. 높은 방어력과 체력을 제공합니다.',
    slot: EquipmentSlot.armor,
    rarity: EquipmentRarity.rare,
    stats: EquipmentStats(hp: 50, atk: 0, def: 8),
  );

  static const EquipmentData DRAGON_SCALE = EquipmentData(
    id: 'equip_dragon_scale',
    name: '용린 갑옷',
    description: '용의 비늘로 만든 전설의 갑옷.',
    slot: EquipmentSlot.armor,
    rarity: EquipmentRarity.legendary,
    stats: EquipmentStats(hp: 100, atk: 5, def: 15),
  );

  // ========== 액세서리 ==========

  static const EquipmentData SPEED_BOOTS = EquipmentData(
    id: 'equip_speed_boots',
    name: '신속의 부츠',
    description: '이동 속도를 높여주는 부츠.',
    slot: EquipmentSlot.accessory,
    rarity: EquipmentRarity.common,
    stats: EquipmentStats(hp: 0, atk: 0, def: 0),
  );

  static const EquipmentData CRITICAL_RING = EquipmentData(
    id: 'equip_critical_ring',
    name: '치명의 반지',
    description: '크리티컬 확률과 데미지를 높여주는 반지.',
    slot: EquipmentSlot.accessory,
    rarity: EquipmentRarity.rare,
    stats: EquipmentStats(hp: 0, atk: 5, def: 0),
  );

  static const EquipmentData LIFE_PENDANT = EquipmentData(
    id: 'equip_life_pendant',
    name: '생명의 펜던트',
    description: '착용자의 생명력을 크게 높여주는 펜던트.',
    slot: EquipmentSlot.accessory,
    rarity: EquipmentRarity.epic,
    stats: EquipmentStats(hp: 80, atk: 0, def: 5),
  );

  static List<EquipmentData> get allWeapons => [STARTER_WAND, IRON_SWORD, FLAME_BLADE, THUNDER_STAFF, POISON_BOW];
  static List<EquipmentData> get allArmors => [LEATHER_ARMOR, KNIGHT_PLATE, DRAGON_SCALE];
  static List<EquipmentData> get allAccessories => [SPEED_BOOTS, CRITICAL_RING, LIFE_PENDANT];
  static List<EquipmentData> get all => [...allWeapons, ...allArmors, ...allAccessories];

  static EquipmentData? GetById(String id) {
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<EquipmentData> GetBySlot(EquipmentSlot slot) {
    return all.where((e) => e.slot == slot).toList();
  }

  static List<EquipmentData> GetByRarity(EquipmentRarity rarity) {
    return all.where((e) => e.rarity == rarity).toList();
  }
}

/// 등급별 색상
extension EquipmentRarityExtension on EquipmentRarity {
  Color get color {
    switch (this) {
      case EquipmentRarity.common:
        return Colors.grey;
      case EquipmentRarity.uncommon:
        return Colors.green;
      case EquipmentRarity.rare:
        return Colors.blue;
      case EquipmentRarity.epic:
        return Colors.purple;
      case EquipmentRarity.legendary:
        return Colors.orange;
    }
  }

  String get displayName {
    switch (this) {
      case EquipmentRarity.common:
        return '일반';
      case EquipmentRarity.uncommon:
        return '고급';
      case EquipmentRarity.rare:
        return '희귀';
      case EquipmentRarity.epic:
        return '영웅';
      case EquipmentRarity.legendary:
        return '전설';
    }
  }
}

/// 슬롯 이름
extension EquipmentSlotExtension on EquipmentSlot {
  String get displayName {
    switch (this) {
      case EquipmentSlot.weapon:
        return '무기';
      case EquipmentSlot.armor:
        return '방어구';
      case EquipmentSlot.accessory:
        return '액세서리';
    }
  }

  String get icon {
    switch (this) {
      case EquipmentSlot.weapon:
        return '⚔️';
      case EquipmentSlot.armor:
        return '🛡️';
      case EquipmentSlot.accessory:
        return '💍';
    }
  }
}
