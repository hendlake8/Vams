import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import '../../../data/models/weapon_data.dart';
import '../../vam_game.dart';
import '../actors/monster.dart';

/// 투사체 컴포넌트
class Projectile extends PositionComponent with HasGameReference<VamGame>, CollisionCallbacks {
  final WeaponData mWeaponData;
  final Vector2 mDirection;
  final int mLevel;
  final double mDamage;

  // 상태
  double mDistanceTraveled = 0;
  int mPierceCount = 0;
  bool mIsActive = true;

  // 이미 타격한 몬스터 추적 (관통탄용)
  final Set<Monster> mHitMonsters = {};

  // 시각적 요소
  late RectangleComponent mBody;

  Projectile({
    required Vector2 position,
    required Vector2 direction,
    required WeaponData weaponData,
    required int level,
  })  : mWeaponData = weaponData,
        mDirection = direction.normalized(),
        mLevel = level,
        mDamage = weaponData.GetDamageAtLevel(level),
        super(
          position: position,
          size: Vector2(12, 12),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 시각적 표현 (원형)
    mBody = RectangleComponent(
      size: size,
      paint: Paint()..color = mWeaponData.color,
    );
    add(mBody);

    // 히트박스
    add(CircleHitbox(radius: 6));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!mIsActive) return;

    // 이동
    final velocity = mDirection * mWeaponData.projectileSpeed * dt;
    position += velocity;
    mDistanceTraveled += velocity.length;

    // 사거리 초과 시 제거
    if (mDistanceTraveled >= mWeaponData.range) {
      Destroy();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (!mIsActive) return;

    if (other is Monster && other.mIsAlive) {
      // 이미 타격한 몬스터는 무시 (관통탄)
      if (mHitMonsters.contains(other)) return;

      // 데미지 적용
      final damage = mDamage.round();
      other.TakeDamage(damage);
      mHitMonsters.add(other);

      Logger.combat('Projectile hit monster for $damage damage');

      // 관통 처리
      if (mWeaponData.piercing) {
        mPierceCount++;
        if (mPierceCount >= mWeaponData.pierceCount) {
          Destroy();
        }
      } else {
        // 비관통 투사체는 즉시 제거
        Destroy();
      }
    }
  }

  /// 투사체 제거
  void Destroy() {
    mIsActive = false;
    removeFromParent();
  }
}
