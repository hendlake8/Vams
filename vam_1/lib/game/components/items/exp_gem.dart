import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../vam_game.dart';
import '../actors/player.dart';

/// 경험치 젬 컴포넌트
class ExpGem extends PositionComponent with HasGameReference<VamGame>, CollisionCallbacks {
  final int mExpAmount;

  // 자석 효과
  bool mIsBeingPulled = false;
  static const double MAGNET_SPEED = 8.0;

  ExpGem({
    required Vector2 position,
    required int expAmount,
  })  : mExpAmount = expAmount,
        super(
          position: position,
          size: _getSize(expAmount),
          anchor: Anchor.center,
        );

  static Vector2 _getSize(int exp) {
    if (exp >= GameConstants.EXP_GEM_LARGE) {
      return Vector2(20, 20);
    } else if (exp >= GameConstants.EXP_GEM_MEDIUM) {
      return Vector2(14, 14);
    }
    return Vector2(10, 10);
  }

  Color get _color {
    if (mExpAmount >= GameConstants.EXP_GEM_LARGE) {
      return Colors.yellow;
    } else if (mExpAmount >= GameConstants.EXP_GEM_MEDIUM) {
      return Colors.green;
    }
    return Colors.cyan;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(CircleComponent(
      radius: size.x / 2,
      paint: Paint()..color = _color,
    ));

    add(CircleHitbox(radius: size.x / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);

    final player = game.player;
    final distance = position.distanceTo(player.position);

    // 자석 범위 체크
    final magnetRadius = GameConstants.DEFAULT_MAGNET_RADIUS * 60;
    if (distance < magnetRadius) {
      mIsBeingPulled = true;
    }

    // 플레이어에게 끌려가기
    if (mIsBeingPulled) {
      final direction = (player.position - position).normalized();
      position += direction * MAGNET_SPEED * 60 * dt;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Player) {
      // 경험치 획득
      other.GainExp(mExpAmount);
      removeFromParent();
    }
  }
}
