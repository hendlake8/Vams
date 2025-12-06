import 'actor_stats.dart';

/// 캐릭터 모델
class CharacterModel {
  final String id;
  final String name;
  final int rarity;
  final ActorStats baseStats;
  final String uniqueSkillId;
  final UnlockCondition unlockCondition;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.rarity,
    required this.baseStats,
    required this.uniqueSkillId,
    required this.unlockCondition,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      rarity: json['rarity'] as int,
      baseStats: ActorStats.fromJson(json['baseStats']),
      uniqueSkillId: json['uniqueSkillId'] as String,
      unlockCondition: UnlockCondition.fromJson(json['unlockCondition']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rarity': rarity,
      'baseStats': baseStats.toJson(),
      'uniqueSkillId': uniqueSkillId,
      'unlockCondition': unlockCondition.toJson(),
    };
  }

  /// 성급 적용 스탯 계산
  ActorStats GetStatsWithStar(int star) {
    return baseStats.ApplyStarBonus(star);
  }
}

/// 해금 조건
class UnlockCondition {
  final UnlockType type;
  final dynamic value;

  const UnlockCondition({
    required this.type,
    this.value,
  });

  factory UnlockCondition.fromJson(Map<String, dynamic> json) {
    return UnlockCondition(
      type: UnlockType.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['type'] as String).toUpperCase(),
        orElse: () => UnlockType.defaultUnlock,
      ),
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name.toUpperCase(),
      'value': value,
    };
  }
}

enum UnlockType {
  defaultUnlock,
  gacha,
  event,
  shop,
  achievement,
}
