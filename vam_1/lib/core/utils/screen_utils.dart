import 'package:flutter/material.dart';
import '../constants/design_constants.dart';

/// 화면 유틸리티 (해상도 대응, SafeArea)
class ScreenUtils {
  ScreenUtils._();

  static late double screenWidth;
  static late double screenHeight;
  static late double screenRatio;
  static late double scaleX;
  static late double scaleY;
  static late double scale;

  // 게임 영역 (확장 포함)
  static late double gameWidth;
  static late double gameHeight;

  // SafeArea
  static late EdgeInsets safeAreaPadding;
  static late double topPadding;
  static late double bottomPadding;
  static late double leftPadding;
  static late double rightPadding;

  static bool _isInitialized = false;

  /// 초기화 (앱 시작 시 호출)
  static void init(BuildContext context) {
    if (_isInitialized) return;

    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    screenRatio = screenWidth / screenHeight;

    // 스케일 계산
    scaleX = screenWidth / DesignConstants.DESIGN_WIDTH;
    scaleY = screenHeight / DesignConstants.DESIGN_HEIGHT;

    // UI 스케일: 너비 기준 (레터박스 없이 확장)
    scale = scaleX;

    // 게임 영역 계산 (확장 영역 포함)
    _calculateGameArea();

    // SafeArea 초기화
    safeAreaPadding = mediaQuery.padding;
    topPadding = safeAreaPadding.top;
    bottomPadding = safeAreaPadding.bottom;
    leftPadding = safeAreaPadding.left;
    rightPadding = safeAreaPadding.right;

    _isInitialized = true;
  }

  static void _calculateGameArea() {
    if (screenRatio < DesignConstants.DESIGN_RATIO) {
      // 기기가 더 넓음 (좌우 확장)
      gameWidth = DesignConstants.DESIGN_HEIGHT * screenRatio;
      gameHeight = DesignConstants.DESIGN_HEIGHT;
    } else {
      // 기기가 더 길쭉함 (상하 확장)
      gameWidth = DesignConstants.DESIGN_WIDTH;
      gameHeight = DesignConstants.DESIGN_WIDTH / screenRatio;
    }
  }

  /// 디자인 픽셀 → 실제 픽셀 변환
  static double w(double designPixel) => designPixel * scaleX;
  static double h(double designPixel) => designPixel * scaleY;
  static double sp(double designPixel) => designPixel * scale;

  /// SafeArea 내부 크기
  static double get safeWidth =>
      screenWidth - leftPadding - rightPadding;

  static double get safeHeight =>
      screenHeight - topPadding - bottomPadding;

  /// UI 요소 배치용 패딩
  static EdgeInsets get uiPadding => EdgeInsets.only(
    top: topPadding + DesignConstants.SAFE_AREA_MARGIN,
    bottom: bottomPadding + DesignConstants.SAFE_AREA_MARGIN,
    left: leftPadding + DesignConstants.SAFE_AREA_MARGIN,
    right: rightPadding + DesignConstants.SAFE_AREA_MARGIN,
  );
}
