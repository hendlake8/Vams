import 'actor_stats.dart';

/// 몬스터 모델
class MonsterModel {
  final String id;
  final String name;
  final MonsterType type;
  final ActorStats stats;
  final DropInfo dropInfo;
  final String? specialAbility;
  final int spawnWeight;

  const MonsterModel({
    required this.id,
    required this.name,
    required this.type,
    required this.stats,
    required this.dropInfo,
    this.specialAbility,
    required this.spawnWeight,
  });

  factory MonsterModel.fromJson(Map<String, dynamic> json) {
    return MonsterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MonsterType.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['type'] as String).toUpperCase(),
      ),
      stats: ActorStats.fromJson(json['stats']),
      dropInfo: DropInfo.fromJson(json['dropInfo']),
      specialAbility: json['specialAbility'] as String?,
      spawnWeight: json['spawnWeight'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name.toUpperCase(),
      'stats': stats.toJson(),
      'dropInfo': dropInfo.toJson(),
      'specialAbility': specialAbility,
      'spawnWeight': spawnWeight,
    };
  }
}

/// 드롭 정보
class DropInfo {
  final int exp;
  final int gold;
  final double goldChance;

  const DropInfo({
    required this.exp,
    required this.gold,
    required this.goldChance,
  });

  factory DropInfo.fromJson(Map<String, dynamic> json) {
    return DropInfo(
      exp: json['exp'] as int,
      gold: json['gold'] as int,
      goldChance: (json['goldChance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exp': exp,
      'gold': gold,
      'goldChance': goldChance,
    };
  }
}

enum MonsterType {
  normal,
  elite,
  boss,
}
