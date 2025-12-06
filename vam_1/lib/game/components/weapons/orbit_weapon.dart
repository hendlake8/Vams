import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../data/models/skill_data.dart';
import '../../vam_game.dart';
import '../actors/monster.dart';

/// 회전형 무기 컴포넌트 (플레이어 주변을 회전)
/// 월드에 추가되며, 매 프레임 플레이어 위치를 기준으로 회전 위치 계산
class OrbitWeapon extends PositionComponent with HasGameReference<VamGame>, CollisionCallbacks {
  final SkillData mSkillData;
  final int mLevel;
  final double mOrbitRadius;
  final double mStartAngle;
  final double mDamageBonus;

  // 회전 상태
  double mCurrentAngle = 0;
  double mRotationSpeed = 3.0; // 초당 회전 속도 (라디안)

  // 데미지 쿨다운 (같은 적 연속 타격 방지)
  final Map<Monster, double> mDamageCooldowns = {};
  static const double DAMAGE_COOLDOWN = 0.3;

  // 시각적 요소
  late RectangleComponent mBody;

  OrbitWeapon({
    required SkillData skillData,
    required int level,
    required double orbitRadius,
    required double startAngle,
    double damageBonus = 0,
  })  : mSkillData = skillData,
        mLevel = level,
        mOrbitRadius = orbitRadius,
        mStartAngle = startAngle,
        mDamageBonus = damageBonus,
        super(
          size: Vector2(32, 12),
          anchor: Anchor.center,
        ) {
    mCurrentAngle = startAngle;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 시각적 표현 (검 모양 직사각형)
    mBody = RectangleComponent(
      size: size,
      paint: Paint()..color = mSkillData.color,
    );
    add(mBody);

    // 히트박스
    add(RectangleHitbox());

    // 초기 위치 설정
    _updatePosition();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 회전
    mCurrentAngle += mRotationSpeed * dt;
    if (mCurrentAngle > 2 * pi) {
      mCurrentAngle -= 2 * pi;
    }

    // 위치 업데이트
    _updatePosition();

    // 데미지 쿨다운 업데이트
    _updateCooldowns(dt);
  }

  void _updatePosition() {
    // 플레이어 위치 기준 월드 좌표로 회전 위치 계산
    final playerPos = game.player.position;
    final x = cos(mCurrentAngle) * mOrbitRadius;
    final y = sin(mCurrentAngle) * mOrbitRadius;
    position = playerPos + Vector2(x, y);

    // 검 방향 회전
    angle = mCurrentAngle + pi / 2;
  }

  void _updateCooldowns(double dt) {
    final keysToRemove = <Monster>[];
    mDamageCooldowns.forEach((monster, time) {
      mDamageCooldowns[monster] = time - dt;
      if (mDamageCooldowns[monster]! <= 0) {
        keysToRemove.add(monster);
      }
    });
    keysToRemove.forEach(mDamageCooldowns.remove);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Monster && other.mIsAlive) {
      // 쿨다운 체크
      if (mDamageCooldowns.containsKey(other)) return;

      // 데미지 적용
      final damage = mSkillData.GetDamageAtLevel(mLevel) * (1 + mDamageBonus);
      other.TakeDamage(damage.round());

      // 쿨다운 설정
      mDamageCooldowns[other] = DAMAGE_COOLDOWN;
    }
  }
}
