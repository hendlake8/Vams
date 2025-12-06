import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../core/utils/screen_utils.dart';

/// 조이스틱 컨트롤러
class JoystickController extends JoystickComponent {
  JoystickController()
      : super(
          knob: _Knob(),
          background: _Background(),
          margin: EdgeInsets.only(
            left: ScreenUtils.leftPadding + 40,
            bottom: ScreenUtils.bottomPadding + 40,
          ),
        );

  /// 이동 방향 벡터 (정규화됨)
  Vector2 get moveDirection {
    if (delta.length < DesignConstants.JOYSTICK_DEAD_ZONE) {
      return Vector2.zero();
    }
    return delta.normalized();
  }

  /// 이동 강도 (0.0 ~ 1.0)
  double get intensity {
    return (delta.length / (DesignConstants.JOYSTICK_SIZE / 2)).clamp(0.0, 1.0);
  }
}

class _Knob extends CircleComponent {
  _Knob()
      : super(
          radius: 30,
          paint: Paint()
            ..color = Colors.white.withValues(alpha: DesignConstants.JOYSTICK_OPACITY),
        );
}

class _Background extends CircleComponent {
  _Background()
      : super(
          radius: DesignConstants.JOYSTICK_SIZE / 2,
          paint: Paint()
            ..color = Colors.grey.withValues(alpha: DesignConstants.JOYSTICK_OPACITY * 0.5),
        );
}
