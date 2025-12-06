import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 보스 돌진 전조 표시 컴포넌트
class ChargeIndicator extends PositionComponent {
  final Vector2 mDirection;
  final double mWidth;
  final double mLength;

  double mFlashTimer = 0;

  late RectangleComponent mBody;
  late RectangleComponent mBorder;

  ChargeIndicator({
    required Vector2 startPos,
    required Vector2 direction,
    required double width,
    required double length,
  })  : mDirection = direction.normalized(),
        mWidth = width,
        mLength = length,
        super(
          position: startPos,
          size: Vector2(width, length),
          anchor: Anchor.topCenter,
          // 방향에 따른 회전 (상단 중앙 기준)
          // Flame Y축이 아래로 증가하므로 -pi/2 사용
          angle: atan2(direction.y, direction.x) - pi / 2,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 채우기 영역 (반투명 빨강)
    mBody = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.red.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );
    add(mBody);

    // 테두리 (빨강)
    mBorder = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.red.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    add(mBorder);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 깜빡임 효과
    mFlashTimer += dt;
    final alpha = 0.2 + (sin(mFlashTimer * 10) + 1) * 0.15;
    mBody.paint.color = Colors.red.withValues(alpha: alpha);
  }
}
