import 'package:flutter/material.dart';

/// 스킬 데이터 모델
class SkillData {
  final String id;
  final String name;
  final String description;
  final SkillCategory category;
  final SkillRarity rarity;
  final int maxLevel;
  final double baseDamage;
  final double cooldown;
  final double range;
  final double projectileSpeed;
  final int projectileCount;
  final double spreadAngle;
  final bool piercing;
  final int pierceCount;
  final double duration;
  final Color color;
  final String? evolutionPairId;
  final String? evolutionSkillId;

  const SkillData({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.rarity,
    required this.maxLevel,
    required this.baseDamage,
    required this.cooldown,
    this.range = 300,
    this.projectileSpeed = 400,
    this.projectileCount = 1,
    this.spreadAngle = 0,
    this.piercing = false,
    this.pierceCount = 0,
    this.duration = 0,
    this.color = Colors.white,
    this.evolutionPairId,
    this.evolutionSkillId,
  });

  /// 레벨별 데미지 계산
  double GetDamageAtLevel(int level) {
    // 레벨별 배율: 1.0, 1.3, 1.6, 2.0, 2.5
    const multipliers = [1.0, 1.0, 1.3, 1.6, 2.0, 2.5];
    return baseDamage * multipliers[level.clamp(0, 5)];
  }

  /// 레벨별 쿨다운 계산
  double GetCooldownAtLevel(int level) {
    if (level >= 5) return cooldown * 0.7;
    if (level >= 3) return cooldown * 0.85;
    return cooldown;
  }

  /// 레벨별 투사체 수
  int GetProjectileCountAtLevel(int level) {
    int count = projectileCount;
    if (level >= 2) count++;
    if (level >= 4) count++;
    return count;
  }

  /// 레벨별 사거리
  double GetRangeAtLevel(int level) {
    return range + (level * 20);
  }

  bool get canEvolve => evolutionPairId != null && evolutionSkillId != null;
}

enum SkillCategory {
  projectile,   // 투사체형
  area,         // 범위형
  orbit,        // 회전형
  summon,       // 소환형
  passive,      // 패시브
}

enum SkillRarity {
  common,
  rare,
  epic,
  legendary,
}

/// 기본 스킬 5종 정의
class DefaultSkills {
  DefaultSkills._();

  /// 1. 에너지 볼트 - 기본 투사체, 가장 가까운 적에게 발사
  static const SkillData ENERGY_BOLT = SkillData(
    id: 'skill_energy_bolt',
    name: '에너지 볼트',
    description: '가장 가까운 적에게 에너지 볼트를 발사합니다.',
    category: SkillCategory.projectile,
    rarity: SkillRarity.common,
    maxLevel: 5,
    baseDamage: 15,
    cooldown: 0.8,
    range: 350,
    projectileSpeed: 450,
    projectileCount: 1,
    piercing: false,
    color: Colors.lightBlue,
  );

  /// 2. 회전 검 - 플레이어 주변을 회전하며 피해
  static const SkillData SPINNING_BLADE = SkillData(
    id: 'skill_spinning_blade',
    name: '회전 검',
    description: '플레이어 주변을 회전하는 검이 적을 베어냅니다.',
    category: SkillCategory.orbit,
    rarity: SkillRarity.common,
    maxLevel: 5,
    baseDamage: 8,
    cooldown: 0.3,
    range: 80,
    projectileCount: 2,
    duration: 0,
    color: Colors.grey,
  );

  /// 3. 화염 폭발 - 주변 적에게 범위 피해
  static const SkillData FIRE_BURST = SkillData(
    id: 'skill_fire_burst',
    name: '화염 폭발',
    description: '주변 적들에게 화염 피해를 입힙니다.',
    category: SkillCategory.area,
    rarity: SkillRarity.rare,
    maxLevel: 5,
    baseDamage: 20,
    cooldown: 1.5,
    range: 120,
    color: Colors.orange,
  );

  /// 4. 독 화살 - 관통 + 지속 피해
  static const SkillData POISON_ARROW = SkillData(
    id: 'skill_poison_arrow',
    name: '독 화살',
    description: '적을 관통하며 독 피해를 남깁니다.',
    category: SkillCategory.projectile,
    rarity: SkillRarity.rare,
    maxLevel: 5,
    baseDamage: 12,
    cooldown: 1.2,
    range: 400,
    projectileSpeed: 380,
    projectileCount: 1,
    piercing: true,
    pierceCount: 3,
    duration: 3.0,
    color: Colors.green,
  );

  /// 5. 번개 연쇄 - 적 사이를 튕기며 피해
  static const SkillData CHAIN_LIGHTNING = SkillData(
    id: 'skill_chain_lightning',
    name: '번개 연쇄',
    description: '적 사이를 튕기는 번개를 발사합니다.',
    category: SkillCategory.projectile,
    rarity: SkillRarity.epic,
    maxLevel: 5,
    baseDamage: 18,
    cooldown: 1.0,
    range: 300,
    projectileSpeed: 600,
    projectileCount: 1,
    piercing: true,
    pierceCount: 4,
    color: Colors.yellow,
  );

  /// 패시브: 이동 속도 증가
  static const SkillData SWIFT_BOOTS = SkillData(
    id: 'skill_swift_boots',
    name: '신속 부츠',
    description: '이동 속도가 증가합니다.',
    category: SkillCategory.passive,
    rarity: SkillRarity.common,
    maxLevel: 5,
    baseDamage: 0,
    cooldown: 0,
    range: 0,
  );

  /// 패시브: 최대 체력 증가
  static const SkillData VITAL_HEART = SkillData(
    id: 'skill_vital_heart',
    name: '강인한 심장',
    description: '최대 체력이 증가합니다.',
    category: SkillCategory.passive,
    rarity: SkillRarity.common,
    maxLevel: 5,
    baseDamage: 0,
    cooldown: 0,
    range: 0,
  );

  /// 패시브: 공격력 증가
  static const SkillData POWER_GAUNTLET = SkillData(
    id: 'skill_power_gauntlet',
    name: '힘의 건틀릿',
    description: '공격력이 증가합니다.',
    category: SkillCategory.passive,
    rarity: SkillRarity.common,
    maxLevel: 5,
    baseDamage: 0,
    cooldown: 0,
    range: 0,
  );

  static List<SkillData> get activeSkills => [
    ENERGY_BOLT,
    SPINNING_BLADE,
    FIRE_BURST,
    POISON_ARROW,
    CHAIN_LIGHTNING,
  ];

  static List<SkillData> get passiveSkills => [
    SWIFT_BOOTS,
    VITAL_HEART,
    POWER_GAUNTLET,
  ];

  static List<SkillData> get all => [...activeSkills, ...passiveSkills];

  static SkillData? GetById(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
