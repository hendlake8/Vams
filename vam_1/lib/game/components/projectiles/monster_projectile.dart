import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../vam_game.dart';
import '../actors/player.dart';

/// 몬스터 투사체 (엘리트 몬스터용)
class MonsterProjectile extends PositionComponent
    with HasGameReference<VamGame>, CollisionCallbacks {
  final Vector2 mDirection;
  final double mSpeed;
  final int mDamage;

  double mDistanceTraveled = 0;
  bool mIsActive = true;

  static const double MAX_RANGE = 500;
  static const double SIZE = 12;

  late RectangleComponent mBody;

  MonsterProjectile({
    required Vector2 position,
    required Vector2 direction,
    required double speed,
    required int damage,
  })  : mDirection = direction.normalized(),
        mSpeed = speed,
        mDamage = damage,
        super(
          position: position,
          size: Vector2.all(SIZE),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 투사체 외형 (주황색 원형)
    mBody = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.orange.shade700,
    );
    add(mBody);

    // 히트박스
    add(CircleHitbox(radius: SIZE / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!mIsActive) return;

    // 이동
    final movement = mDirection * mSpeed * dt;
    position += movement;
    mDistanceTraveled += movement.length;

    // 최대 사거리 도달 시 제거
    if (mDistanceTraveled >= MAX_RANGE) {
      _destroy();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (!mIsActive) return;

    if (other is Player && other.mIsAlive) {
      other.TakeDamage(mDamage);
      _destroy();
    }
  }

  void _destroy() {
    mIsActive = false;
    removeFromParent();
  }
}
