/// 액터 스탯 모델
class ActorStats {
  final int hp;
  final int atk;
  final int def;
  final double spd;
  final double critRate;
  final double critDmg;

  const ActorStats({
    required this.hp,
    required this.atk,
    required this.def,
    required this.spd,
    required this.critRate,
    required this.critDmg,
  });

  factory ActorStats.fromJson(Map<String, dynamic> json) {
    return ActorStats(
      hp: json['hp'] as int,
      atk: json['atk'] as int,
      def: json['def'] as int,
      spd: (json['spd'] as num).toDouble(),
      critRate: (json['critRate'] as num).toDouble(),
      critDmg: (json['critDmg'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hp': hp,
      'atk': atk,
      'def': def,
      'spd': spd,
      'critRate': critRate,
      'critDmg': critDmg,
    };
  }

  /// 성급 보너스 적용
  ActorStats ApplyStarBonus(int star) {
    final multiplier = _getStarMultiplier(star);
    return ActorStats(
      hp: (hp * (1 + multiplier)).round(),
      atk: (atk * (1 + multiplier)).round(),
      def: (def * (1 + multiplier)).round(),
      spd: spd,
      critRate: critRate,
      critDmg: critDmg,
    );
  }

  double _getStarMultiplier(int star) {
    const multipliers = [0.0, 0.0, 0.1, 0.25, 0.45, 0.70, 1.0];
    return multipliers[star.clamp(0, 6)];
  }

  /// 스탯 합산
  ActorStats operator +(ActorStats other) {
    return ActorStats(
      hp: hp + other.hp,
      atk: atk + other.atk,
      def: def + other.def,
      spd: spd + other.spd,
      critRate: critRate + other.critRate,
      critDmg: critDmg + other.critDmg,
    );
  }

  ActorStats copyWith({
    int? hp,
    int? atk,
    int? def,
    double? spd,
    double? critRate,
    double? critDmg,
  }) {
    return ActorStats(
      hp: hp ?? this.hp,
      atk: atk ?? this.atk,
      def: def ?? this.def,
      spd: spd ?? this.spd,
      critRate: critRate ?? this.critRate,
      critDmg: critDmg ?? this.critDmg,
    );
  }
}
