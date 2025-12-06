import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 데미지 텍스트 이펙트
class DamageText extends TextComponent {
  final int mDamage;
  final bool mIsCritical;

  // 애니메이션 상태
  double mLifetime = 0;
  static const double MAX_LIFETIME = 0.8;
  static const double RISE_SPEED = 60;
  static const double FADE_START = 0.5;

  final Vector2 mStartPosition;

  DamageText({
    required Vector2 position,
    required int damage,
    bool isCritical = false,
  })  : mDamage = damage,
        mIsCritical = isCritical,
        mStartPosition = position.clone(),
        super(
          text: damage.toString(),
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: TextStyle(
              color: isCritical ? Colors.yellow : Colors.white,
              fontSize: isCritical ? 24 : 18,
              fontWeight: isCritical ? FontWeight.bold : FontWeight.normal,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);

    mLifetime += dt;

    // 위로 상승
    position.y = mStartPosition.y - (mLifetime * RISE_SPEED);

    // 좌우 약간 흔들림 (크리티컬)
    if (mIsCritical) {
      position.x = mStartPosition.x + (mLifetime * 10).remainder(4) - 2;
    }

    // 페이드 아웃
    if (mLifetime > FADE_START) {
      final fadeProgress = (mLifetime - FADE_START) / (MAX_LIFETIME - FADE_START);
      final alpha = (1 - fadeProgress).clamp(0.0, 1.0);

      textRenderer = TextPaint(
        style: TextStyle(
          color: (mIsCritical ? Colors.yellow : Colors.white).withValues(alpha: alpha),
          fontSize: mIsCritical ? 24 : 18,
          fontWeight: mIsCritical ? FontWeight.bold : FontWeight.normal,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: alpha),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      );
    }

    // 수명 종료
    if (mLifetime >= MAX_LIFETIME) {
      removeFromParent();
    }
  }
}

/// 힐 텍스트 이펙트 (초록색)
class HealText extends TextComponent {
  double mLifetime = 0;
  static const double MAX_LIFETIME = 0.8;
  static const double RISE_SPEED = 50;

  final Vector2 mStartPosition;

  HealText({
    required Vector2 position,
    required int amount,
  })  : mStartPosition = position.clone(),
        super(
          text: '+$amount',
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.green,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);

    mLifetime += dt;
    position.y = mStartPosition.y - (mLifetime * RISE_SPEED);

    // 페이드 아웃
    if (mLifetime > 0.5) {
      final fadeProgress = (mLifetime - 0.5) / 0.3;
      final alpha = (1 - fadeProgress).clamp(0.0, 1.0);

      textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.green.withValues(alpha: alpha),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: alpha),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      );
    }

    if (mLifetime >= MAX_LIFETIME) {
      removeFromParent();
    }
  }
}

/// 레벨업 텍스트
class LevelUpText extends TextComponent {
  double mLifetime = 0;
  static const double MAX_LIFETIME = 1.5;

  final Vector2 mStartPosition;
  double mScale = 0.5;

  LevelUpText({
    required Vector2 position,
  })  : mStartPosition = position.clone(),
        super(
          text: 'LEVEL UP!',
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.orange,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);

    mLifetime += dt;

    // 스케일 애니메이션 (팝업)
    if (mLifetime < 0.2) {
      mScale = 0.5 + (mLifetime / 0.2) * 0.7;
    } else if (mLifetime < 0.4) {
      mScale = 1.2 - ((mLifetime - 0.2) / 0.2) * 0.2;
    } else {
      mScale = 1.0;
    }

    scale = Vector2.all(mScale);

    // 위로 상승
    position.y = mStartPosition.y - (mLifetime * 30);

    // 페이드 아웃
    if (mLifetime > 1.0) {
      final fadeProgress = (mLifetime - 1.0) / 0.5;
      final alpha = (1 - fadeProgress).clamp(0.0, 1.0);

      textRenderer = TextPaint(
        style: TextStyle(
          color: Colors.yellow.withValues(alpha: alpha),
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.orange.withValues(alpha: alpha),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      );
    }

    if (mLifetime >= MAX_LIFETIME) {
      removeFromParent();
    }
  }
}
