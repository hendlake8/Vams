import 'package:flutter/material.dart';

/// 무기 데이터 모델
class WeaponData {
  final String id;
  final String name;
  final WeaponType type;
  final double baseDamage;
  final double cooldown;
  final double projectileSpeed;
  final double range;
  final int projectileCount;
  final double spreadAngle;
  final bool piercing;
  final int pierceCount;
  final Color color;

  const WeaponData({
    required this.id,
    required this.name,
    required this.type,
    required this.baseDamage,
    required this.cooldown,
    required this.projectileSpeed,
    required this.range,
    this.projectileCount = 1,
    this.spreadAngle = 0,
    this.piercing = false,
    this.pierceCount = 0,
    this.color = Colors.yellow,
  });

  /// 레벨별 데미지 계산
  double GetDamageAtLevel(int level) {
    const multipliers = [1.0, 1.0, 1.3, 1.6, 2.0, 2.5];
    return baseDamage * multipliers[level.clamp(0, 5)];
  }

  /// 레벨별 쿨다운 계산
  double GetCooldownAtLevel(int level) {
    // 레벨 3, 5에서 쿨다운 감소
    if (level >= 5) return cooldown * 0.7;
    if (level >= 3) return cooldown * 0.85;
    return cooldown;
  }

  /// 레벨별 투사체 수
  int GetProjectileCountAtLevel(int level) {
    // 레벨 2, 4에서 투사체 +1
    int count = projectileCount;
    if (level >= 2) count++;
    if (level >= 4) count++;
    return count;
  }
}

enum WeaponType {
  projectile,   // 일반 투사체
  spread,       // 산탄
  orbit,        // 궤도
  aura,         // 오라 (범위)
  chain,        // 연쇄
}

/// 기본 무기 정의
class DefaultWeapons {
  DefaultWeapons._();

  /// 기본 탄환 - 가장 가까운 적에게 자동 발사
  static const WeaponData BASIC_BULLET = WeaponData(
    id: 'basic_bullet',
    name: '기본 탄환',
    type: WeaponType.projectile,
    baseDamage: 10,
    cooldown: 0.5,
    projectileSpeed: 400,
    range: 300,
    projectileCount: 1,
    piercing: false,
    color: Colors.yellow,
  );

  /// 산탄총 - 부채꼴로 발사
  static const WeaponData SHOTGUN = WeaponData(
    id: 'shotgun',
    name: '산탄총',
    type: WeaponType.spread,
    baseDamage: 5,
    cooldown: 1.0,
    projectileSpeed: 350,
    range: 200,
    projectileCount: 5,
    spreadAngle: 60,
    piercing: false,
    color: Colors.orange,
  );

  /// 관통탄 - 적을 관통
  static const WeaponData PIERCING_SHOT = WeaponData(
    id: 'piercing_shot',
    name: '관통탄',
    type: WeaponType.projectile,
    baseDamage: 15,
    cooldown: 0.8,
    projectileSpeed: 500,
    range: 500,
    projectileCount: 1,
    piercing: true,
    pierceCount: 5,
    color: Colors.cyan,
  );

  /// 오라 - 주변 적에게 지속 피해
  static const WeaponData AURA = WeaponData(
    id: 'aura',
    name: '보호막',
    type: WeaponType.aura,
    baseDamage: 3,
    cooldown: 0.3,
    projectileSpeed: 0,
    range: 100,
    projectileCount: 0,
    color: Colors.purple,
  );

  static List<WeaponData> get all => [
    BASIC_BULLET,
    SHOTGUN,
    PIERCING_SHOT,
    AURA,
  ];

  static WeaponData? GetById(String id) {
    try {
      return all.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}
