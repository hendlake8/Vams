/// 스킬 모델
class SkillModel {
  final String id;
  final String name;
  final String description;
  final SkillType type;
  final SkillRarity rarity;
  final int maxLevel;
  final double baseDamage;
  final double cooldown;
  final double range;
  final String? evolutionPairId;
  final String? evolutionSkillId;

  const SkillModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.maxLevel,
    required this.baseDamage,
    required this.cooldown,
    required this.range,
    this.evolutionPairId,
    this.evolutionSkillId,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: SkillType.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['type'] as String).toUpperCase(),
      ),
      rarity: SkillRarity.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['rarity'] as String).toUpperCase(),
      ),
      maxLevel: json['maxLevel'] as int,
      baseDamage: (json['baseDamage'] as num).toDouble(),
      cooldown: (json['cooldown'] as num).toDouble(),
      range: (json['range'] as num).toDouble(),
      evolutionPairId: json['evolutionPairId'] as String?,
      evolutionSkillId: json['evolutionSkillId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name.toUpperCase(),
      'rarity': rarity.name.toUpperCase(),
      'maxLevel': maxLevel,
      'baseDamage': baseDamage,
      'cooldown': cooldown,
      'range': range,
      'evolutionPairId': evolutionPairId,
      'evolutionSkillId': evolutionSkillId,
    };
  }

  /// 레벨별 데미지 계산
  double GetDamageAtLevel(int level) {
    // 레벨별 배율: 1.0, 1.3, 1.6, 2.0, 2.5
    const multipliers = [1.0, 1.0, 1.3, 1.6, 2.0, 2.5];
    return baseDamage * multipliers[level.clamp(0, 5)];
  }

  /// 레벨별 쿨다운 계산
  double GetCooldownAtLevel(int level) {
    // 레벨 3에서 쿨다운 -15%
    if (level >= 3) {
      return cooldown * 0.85;
    }
    return cooldown;
  }

  bool get canEvolve => evolutionPairId != null && evolutionSkillId != null;
}

enum SkillType {
  active,
  passive,
}

enum SkillRarity {
  common,
  rare,
  epic,
  legendary,
}
