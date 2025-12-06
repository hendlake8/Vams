import 'dart:math';

import '../../core/constants/game_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/actor_stats.dart';

/// 전투 시스템
class CombatSystem {
  final Random _random = Random();

  /// 데미지 계산
  /// 공식: (기본ATK × 무기계수 × 스킬계수) × (1 + 크리배율) × 속성보너스
  DamageResult CalculateDamage({
    required ActorStats attacker,
    required ActorStats defender,
    double weaponMultiplier = 1.0,
    double skillMultiplier = 1.0,
    double elementBonus = 1.0,
  }) {
    // 기본 데미지
    double damage = attacker.atk * weaponMultiplier * skillMultiplier;

    // 크리티컬 체크
    bool isCritical = false;
    if (_rollCritical(attacker.critRate)) {
      isCritical = true;
      final critMultiplier = (attacker.critDmg / 100).clamp(
        GameConstants.DEFAULT_CRIT_MULTIPLIER,
        GameConstants.MAX_CRIT_MULTIPLIER,
      );
      damage *= critMultiplier;
    }

    // 속성 보너스
    damage *= elementBonus;

    // 방어력 적용
    final defense = defender.def;
    final damageReduction = defense / (defense + 100);
    final finalDamage = damage * (1 - damageReduction);

    Logger.combat(
      'Damage: ${finalDamage.round()} (Base: ${attacker.atk}, '
      'Crit: $isCritical, Def: $defense)',
    );

    return DamageResult(
      damage: finalDamage.round().clamp(1, 999999),
      isCritical: isCritical,
    );
  }

  bool _rollCritical(double critRate) {
    return _random.nextDouble() * 100 < critRate;
  }

  /// 회피 체크
  bool CheckDodge(double dodgeRate) {
    return _random.nextDouble() * 100 < dodgeRate;
  }

  /// 블록 체크
  bool CheckBlock(double blockRate) {
    return _random.nextDouble() * 100 < blockRate;
  }
}

/// 데미지 결과
class DamageResult {
  final int damage;
  final bool isCritical;
  final bool isDodged;
  final bool isBlocked;

  const DamageResult({
    required this.damage,
    this.isCritical = false,
    this.isDodged = false,
    this.isBlocked = false,
  });
}
