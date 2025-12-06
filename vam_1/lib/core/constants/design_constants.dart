import 'package:flutter/material.dart';

/// 디자인 상수 정의 (해상도, 색상 등)
class DesignConstants {
  DesignConstants._();

  // 기준 해상도
  static const double DESIGN_WIDTH = 1080.0;
  static const double DESIGN_HEIGHT = 1920.0;
  static const double DESIGN_RATIO = 9.0 / 16.0;

  // 조이스틱
  static const double JOYSTICK_SIZE = 150.0;
  static const double JOYSTICK_DEAD_ZONE = 10.0;
  static const double JOYSTICK_OPACITY = 0.7;

  // UI 마진
  static const double SAFE_AREA_MARGIN = 8.0;
  static const double CORNER_RADIUS = 12.0;

  // 폰트 크기
  static const double FONT_SIZE_SMALL = 12.0;
  static const double FONT_SIZE_MEDIUM = 16.0;
  static const double FONT_SIZE_LARGE = 20.0;
  static const double FONT_SIZE_TITLE = 32.0;

  // 색상
  static const Color COLOR_PRIMARY = Color(0xFF6200EE);
  static const Color COLOR_SECONDARY = Color(0xFF03DAC6);
  static const Color COLOR_BACKGROUND = Color(0xFF121212);
  static const Color COLOR_SURFACE = Color(0xFF1E1E1E);
  static const Color COLOR_ERROR = Color(0xFFCF6679);

  // 등급 색상
  static const Color COLOR_GRADE_COMMON = Color(0xFF808080);
  static const Color COLOR_GRADE_UNCOMMON = Color(0xFF00FF00);
  static const Color COLOR_GRADE_RARE = Color(0xFF0080FF);
  static const Color COLOR_GRADE_ELITE = Color(0xFF8000FF);
  static const Color COLOR_GRADE_EPIC = Color(0xFFFFD700);
  static const Color COLOR_GRADE_LEGENDARY = Color(0xFFFF0000);

  // HP 바 색상
  static const Color COLOR_HP_HIGH = Color(0xFF4CAF50);
  static const Color COLOR_HP_MEDIUM = Color(0xFFFFEB3B);
  static const Color COLOR_HP_LOW = Color(0xFFF44336);

  // EXP 바 색상
  static const Color COLOR_EXP = Color(0xFF2196F3);

  // 카메라
  static const double CAMERA_ZOOM_DEFAULT = 5.0;
  static const double CAMERA_ZOOM_BOSS = 7.0;
  static const double CAMERA_SHAKE_DURATION_HIT = 0.1;
  static const double CAMERA_SHAKE_DURATION_BOSS = 0.5;
  static const double CAMERA_SHAKE_INTENSITY_HIT = 0.05;
  static const double CAMERA_SHAKE_INTENSITY_BOSS = 0.2;
}
