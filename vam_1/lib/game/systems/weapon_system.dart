import 'dart:math';

import 'package:flame/components.dart';

import '../../core/utils/logger.dart';
import '../../data/models/weapon_data.dart';
import '../components/actors/monster.dart';
import '../components/weapons/projectile.dart';
import '../vam_game.dart';

/// 무기 시스템 - 자동 공격 처리
class WeaponSystem {
  final VamGame mGame;
  final Random _random = Random();

  // 장착된 무기들
  final List<EquippedWeapon> mEquippedWeapons = [];

  WeaponSystem(this.mGame);

  /// 무기 추가
  void AddWeapon(String weaponId, {int level = 1}) {
    final weaponData = DefaultWeapons.GetById(weaponId);
    if (weaponData == null) {
      Logger.e('Unknown weapon: $weaponId');
      return;
    }

    final existing = mEquippedWeapons.firstWhere(
      (w) => w.weaponData.id == weaponId,
      orElse: () => EquippedWeapon(weaponData: weaponData, level: 0),
    );

    if (existing.level == 0) {
      mEquippedWeapons.add(EquippedWeapon(weaponData: weaponData, level: level));
      Logger.game('Weapon added: ${weaponData.name} Lv.$level');
    } else {
      existing.level = level;
      Logger.game('Weapon upgraded: ${weaponData.name} Lv.$level');
    }
  }

  /// 무기 레벨업
  void UpgradeWeapon(String weaponId) {
    final weapon = mEquippedWeapons.firstWhere(
      (w) => w.weaponData.id == weaponId,
      orElse: () => EquippedWeapon(
        weaponData: DefaultWeapons.BASIC_BULLET,
        level: 0,
      ),
    );

    if (weapon.level > 0 && weapon.level < 5) {
      weapon.level++;
      Logger.game('Weapon upgraded: ${weapon.weaponData.name} Lv.${weapon.level}');
    }
  }

  /// 시스템 업데이트 (자동 공격)
  void Update(double dt) {
    if (!mGame.player.mIsAlive) return;

    for (final weapon in mEquippedWeapons) {
      weapon.mCooldownTimer -= dt;

      if (weapon.mCooldownTimer <= 0) {
        _fireWeapon(weapon);
        weapon.mCooldownTimer = weapon.weaponData.GetCooldownAtLevel(weapon.level);
      }
    }
  }

  /// 무기 발사
  void _fireWeapon(EquippedWeapon weapon) {
    switch (weapon.weaponData.type) {
      case WeaponType.projectile:
        _fireProjectile(weapon);
        break;
      case WeaponType.spread:
        _fireSpread(weapon);
        break;
      case WeaponType.aura:
        _fireAura(weapon);
        break;
      case WeaponType.orbit:
      case WeaponType.chain:
        // TODO: 구현 예정
        break;
    }
  }

  /// 일반 투사체 발사 (가장 가까운 적 방향)
  void _fireProjectile(EquippedWeapon weapon) {
    final target = _findNearestMonster();
    if (target == null) return;

    final playerPos = mGame.player.position;
    final direction = (target.position - playerPos).normalized();

    final projectileCount = weapon.weaponData.GetProjectileCountAtLevel(weapon.level);

    for (int i = 0; i < projectileCount; i++) {
      // 여러 발 시 약간씩 각도 변화
      Vector2 adjustedDir = direction;
      if (projectileCount > 1) {
        final angleOffset = (i - (projectileCount - 1) / 2) * 0.1;
        adjustedDir = _rotateVector(direction, angleOffset);
      }

      final projectile = Projectile(
        position: playerPos.clone(),
        direction: adjustedDir,
        weaponData: weapon.weaponData,
        level: weapon.level,
      );
      mGame.world.add(projectile);
    }
  }

  /// 산탄 발사
  void _fireSpread(EquippedWeapon weapon) {
    final target = _findNearestMonster();
    Vector2 baseDirection;

    if (target != null) {
      baseDirection = (target.position - mGame.player.position).normalized();
    } else {
      // 타겟 없으면 랜덤 방향
      final angle = _random.nextDouble() * 2 * pi;
      baseDirection = Vector2(cos(angle), sin(angle));
    }

    final projectileCount = weapon.weaponData.GetProjectileCountAtLevel(weapon.level);
    final spreadRadians = weapon.weaponData.spreadAngle * pi / 180;
    final angleStep = spreadRadians / (projectileCount - 1);
    final startAngle = -spreadRadians / 2;

    for (int i = 0; i < projectileCount; i++) {
      final angle = startAngle + angleStep * i;
      final direction = _rotateVector(baseDirection, angle);

      final projectile = Projectile(
        position: mGame.player.position.clone(),
        direction: direction,
        weaponData: weapon.weaponData,
        level: weapon.level,
      );
      mGame.world.add(projectile);
    }
  }

  /// 오라 발사 (주변 적 데미지)
  void _fireAura(EquippedWeapon weapon) {
    final playerPos = mGame.player.position;
    final range = weapon.weaponData.range + (weapon.level * 10);
    final damage = weapon.weaponData.GetDamageAtLevel(weapon.level).round();

    // 범위 내 모든 몬스터에 데미지
    final monsters = mGame.world.children.whereType<Monster>().where((m) {
      return m.mIsAlive && (m.position - playerPos).length <= range;
    });

    for (final monster in monsters) {
      monster.TakeDamage(damage);
    }
  }

  /// 가장 가까운 몬스터 찾기
  Monster? _findNearestMonster() {
    final playerPos = mGame.player.position;
    Monster? nearest;
    double minDist = double.infinity;

    for (final component in mGame.world.children) {
      if (component is Monster && component.mIsAlive) {
        final dist = (component.position - playerPos).length;
        if (dist < minDist) {
          minDist = dist;
          nearest = component;
        }
      }
    }

    return nearest;
  }

  /// 벡터 회전
  Vector2 _rotateVector(Vector2 v, double angle) {
    final cos_a = cos(angle);
    final sin_a = sin(angle);
    return Vector2(
      v.x * cos_a - v.y * sin_a,
      v.x * sin_a + v.y * cos_a,
    );
  }

  /// 리셋
  void Reset() {
    mEquippedWeapons.clear();
    // 기본 무기 장착
    AddWeapon('basic_bullet', level: 1);
  }

  /// 장착된 무기 목록
  List<EquippedWeapon> get weapons => mEquippedWeapons;
}

/// 장착된 무기 정보
class EquippedWeapon {
  final WeaponData weaponData;
  int level;
  double mCooldownTimer = 0;

  EquippedWeapon({
    required this.weaponData,
    required this.level,
  });
}
