import 'dart:math';

/// 수학 유틸리티
class MathUtils {
  MathUtils._();

  static final Random _random = Random();

  /// 두 점 사이의 거리
  static double Distance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return sqrt(dx * dx + dy * dy);
  }

  /// 두 점 사이의 각도 (라디안)
  static double AngleBetween(double x1, double y1, double x2, double y2) {
    return atan2(y2 - y1, x2 - x1);
  }

  /// 각도를 방향 벡터로 변환
  static (double, double) AngleToDirection(double angle) {
    return (cos(angle), sin(angle));
  }

  /// 랜덤 범위 내 값
  static double RandomRange(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  /// 랜덤 정수 범위
  static int RandomRangeInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  /// 확률 체크 (0.0 ~ 1.0)
  static bool RollChance(double chance) {
    return _random.nextDouble() < chance;
  }

  /// 원 위의 랜덤 포인트
  static (double, double) RandomPointOnCircle(double centerX, double centerY, double radius) {
    final angle = _random.nextDouble() * 2 * pi;
    return (
      centerX + cos(angle) * radius,
      centerY + sin(angle) * radius,
    );
  }

  /// 값을 범위 내로 제한
  static double Clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// 선형 보간
  static double Lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// 부드러운 감속 보간
  static double SmoothStep(double t) {
    return t * t * (3 - 2 * t);
  }
}
