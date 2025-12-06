import 'package:flutter/material.dart';

import 'actor_stats.dart';

/// 캐릭터 데이터 (정적 정의)
class CharacterData {
  final String id;
  final String name;
  final String description;
  final CharacterRarity rarity;
  final ActorStats baseStats;
  final String baseSkillId;  // 캐릭터 기본 스킬 (게임 시작 시 장비 무기 스킬과 함께 획득)
  final Color color;  // 캐릭터 대표 색상
  final int spriteIndex;  // 스프라이트 인덱스 (hero_0.png → 0)

  const CharacterData({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.baseStats,
    required this.baseSkillId,
    required this.color,
    this.spriteIndex = 0,
  });
}

enum CharacterRarity {
  common,
  rare,
  epic,
  legendary,
}

/// 기본 캐릭터 정의
class DefaultCharacters {
  DefaultCharacters._();

  /// 특공대원 - 기본 캐릭터 (에너지 볼트)
  static const CharacterData COMMANDO = CharacterData(
    id: 'char_commando',
    name: '특공대원',
    description: '균형 잡힌 스탯의 기본 캐릭터.\n에너지 볼트로 적을 공격합니다.',
    rarity: CharacterRarity.common,
    baseStats: ActorStats(
      hp: 100,
      atk: 10,
      def: 5,
      spd: 3.0,
      critRate: 5.0,
      critDmg: 150.0,
    ),
    baseSkillId: 'skill_energy_bolt',
    color: Colors.blue,
    spriteIndex: 0,  // hero_0.png
  );

  /// 검사 - 근접 캐릭터 (회전 검)
  static const CharacterData SWORDSMAN = CharacterData(
    id: 'char_swordsman',
    name: '검사',
    description: '높은 공격력과 크리티컬의 근접 캐릭터.\n회전 검으로 주변을 휩쓸어버립니다.',
    rarity: CharacterRarity.common,
    baseStats: ActorStats(
      hp: 80,
      atk: 15,
      def: 3,
      spd: 3.5,
      critRate: 10.0,
      critDmg: 180.0,
    ),
    baseSkillId: 'skill_spinning_blade',
    color: Colors.red,
    spriteIndex: 1,  // hero_1.png
  );

  /// 화염 마법사 - 범위 캐릭터 (화염 폭발)
  static const CharacterData PYROMANCER = CharacterData(
    id: 'char_pyromancer',
    name: '화염 마법사',
    description: '강력한 범위 공격의 마법사.\n주변에 화염 폭발을 일으킵니다.',
    rarity: CharacterRarity.rare,
    baseStats: ActorStats(
      hp: 70,
      atk: 18,
      def: 2,
      spd: 2.5,
      critRate: 8.0,
      critDmg: 160.0,
    ),
    baseSkillId: 'skill_fire_burst',
    color: Colors.orange,
    spriteIndex: 2,  // hero_2.png
  );

  /// 궁수 - 관통 캐릭터 (독 화살)
  static const CharacterData ARCHER = CharacterData(
    id: 'char_archer',
    name: '궁수',
    description: '빠른 이동과 관통 공격의 궁수.\n독 화살로 적을 관통합니다.',
    rarity: CharacterRarity.rare,
    baseStats: ActorStats(
      hp: 75,
      atk: 12,
      def: 3,
      spd: 4.0,
      critRate: 15.0,
      critDmg: 170.0,
    ),
    baseSkillId: 'skill_poison_arrow',
    color: Colors.green,
    spriteIndex: 3,  // hero_3.png
  );

  /// 번개 마법사 - 연쇄 캐릭터 (번개 연쇄)
  static const CharacterData STORMCALLER = CharacterData(
    id: 'char_stormcaller',
    name: '번개 마법사',
    description: '여러 적을 동시에 공격하는 마법사.\n번개가 적들 사이를 연쇄합니다.',
    rarity: CharacterRarity.epic,
    baseStats: ActorStats(
      hp: 65,
      atk: 20,
      def: 2,
      spd: 2.8,
      critRate: 12.0,
      critDmg: 200.0,
    ),
    baseSkillId: 'skill_chain_lightning',
    color: Colors.purple,
  );

  static List<CharacterData> get all => [
    COMMANDO,
    SWORDSMAN,
    PYROMANCER,
    ARCHER,
    STORMCALLER,
  ];

  static CharacterData? GetById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<CharacterData> GetByRarity(CharacterRarity rarity) {
    return all.where((c) => c.rarity == rarity).toList();
  }

  /// 해금된 캐릭터 목록 (초기에는 기본 캐릭터만)
  static List<CharacterData> GetUnlockedCharacters() {
    // TODO: 저장소에서 해금 상태 확인
    // 현재는 common + rare 캐릭터만 해금
    return all.where((c) =>
      c.rarity == CharacterRarity.common ||
      c.rarity == CharacterRarity.rare
    ).toList();
  }
}

/// 캐릭터 등급별 색상
extension CharacterRarityExtension on CharacterRarity {
  Color get color {
    switch (this) {
      case CharacterRarity.common:
        return Colors.grey;
      case CharacterRarity.rare:
        return Colors.blue;
      case CharacterRarity.epic:
        return Colors.purple;
      case CharacterRarity.legendary:
        return Colors.orange;
    }
  }

  String get displayName {
    switch (this) {
      case CharacterRarity.common:
        return '일반';
      case CharacterRarity.rare:
        return '희귀';
      case CharacterRarity.epic:
        return '영웅';
      case CharacterRarity.legendary:
        return '전설';
    }
  }
}
