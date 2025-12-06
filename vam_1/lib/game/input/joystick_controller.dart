import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';

/// 플로팅 조이스틱 컨트롤러
/// - 기본 상태: 숨김
/// - 터치 시: 터치 위치에 조이스틱 표시
/// - 드래그: 조이스틱 조작
/// - 손 떼면: 조이스틱 숨김
class FloatingJoystickController extends PositionComponent {
  // 조이스틱 상태
  bool mIsActive = false;
  Vector2 mBasePosition = Vector2.zero();
  Vector2 mKnobPosition = Vector2.zero();
  Vector2 mDelta = Vector2.zero();

  // 컴포넌트
  late CircleComponent mBackground;
  late CircleComponent mKnob;

  // 크기 상수
  static const double BACKGROUND_RADIUS = 60.0;
  static const double KNOB_RADIUS = 25.0;
  static const double MAX_DISTANCE = 50.0;

  // 터치 영역 제한 (상단 UI 제외)
  double mTopBoundary = 80.0;

  FloatingJoystickController() : super(priority: 100);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 배경 원
    mBackground = CircleComponent(
      radius: BACKGROUND_RADIUS,
      anchor: Anchor.center,
      paint: Paint()..color = Colors.grey.withValues(alpha: 0.0),
    );
    add(mBackground);

    // 노브
    mKnob = CircleComponent(
      radius: KNOB_RADIUS,
      anchor: Anchor.center,
      paint: Paint()..color = Colors.white.withValues(alpha: 0.0),
    );
    add(mKnob);
  }

  /// 드래그 시작 (VamGame에서 호출)
  void OnDragStart(Vector2 position) {
    // 상단 UI 영역 체크
    if (position.y <= mTopBoundary) return;

    mIsActive = true;
    mBasePosition = position;
    mKnobPosition = position.clone();

    mBackground.position = position;
    mKnob.position = position;

    mBackground.paint.color = Colors.grey.withValues(alpha: 0.4);
    mKnob.paint.color = Colors.white.withValues(alpha: 0.8);
  }

  /// 드래그 업데이트 (VamGame에서 호출)
  void OnDragUpdate(Vector2 position) {
    if (!mIsActive) return;

    mKnobPosition = position;

    // 최대 거리 제한
    final diff = mKnobPosition - mBasePosition;
    if (diff.length > MAX_DISTANCE) {
      mKnobPosition = mBasePosition + diff.normalized() * MAX_DISTANCE;
    }

    mKnob.position = mKnobPosition;
    mDelta = mKnobPosition - mBasePosition;
  }

  /// 드래그 종료 (VamGame에서 호출)
  void OnDragEnd() {
    mIsActive = false;
    mBackground.paint.color = Colors.grey.withValues(alpha: 0.0);
    mKnob.paint.color = Colors.white.withValues(alpha: 0.0);
    mDelta = Vector2.zero();
  }

  /// 이동 방향 벡터 (정규화됨)
  Vector2 get moveDirection {
    if (mDelta.length < DesignConstants.JOYSTICK_DEAD_ZONE) {
      return Vector2.zero();
    }
    return mDelta.normalized();
  }

  /// 이동 강도 (0.0 ~ 1.0)
  double get intensity {
    return (mDelta.length / MAX_DISTANCE).clamp(0.0, 1.0);
  }

  /// 상단 경계 설정 (상단 UI 높이에 맞게 조정)
  void SetTopBoundary(double height) {
    mTopBoundary = height;
  }
}
