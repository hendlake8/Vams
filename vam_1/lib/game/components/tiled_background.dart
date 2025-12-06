import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../vam_game.dart';

/// 타일링 배경 컴포넌트
class TiledBackground extends Component with HasGameRef<VamGame> {
  // 타일 설정
  static const double TILE_SIZE = 512.0;
  static const Color TILE_COLOR_1 = Color(0xFF2D5A27);
  static const Color TILE_COLOR_2 = Color(0xFF3D6A37);

  late int mTilesX;
  late int mTilesY;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 화면을 덮기 위해 필요한 타일 수 계산 (+4는 스크롤 시 여유분)
    mTilesX = (gameRef.size.x / TILE_SIZE).ceil() + 4;
    mTilesY = (gameRef.size.y / TILE_SIZE).ceil() + 4;
  }

  @override
  void render(Canvas canvas) {
    // 카메라 위치 기반 오프셋 계산
    final cameraPos = gameRef.camera.viewfinder.position;

    // 타일 시작 위치 (무한 반복을 위한 모듈로 연산)
    final startX = (cameraPos.x / TILE_SIZE).floor() - mTilesX ~/ 2;
    final startY = (cameraPos.y / TILE_SIZE).floor() - mTilesY ~/ 2;

    // 타일 그리기
    for (int y = 0; y < mTilesY; y++) {
      for (int x = 0; x < mTilesX; x++) {
        final tileX = startX + x;
        final tileY = startY + y;

        // 체커보드 패턴
        final isEven = (tileX + tileY) % 2 == 0;
        final color = isEven ? TILE_COLOR_1 : TILE_COLOR_2;

        final rect = Rect.fromLTWH(
          tileX * TILE_SIZE,
          tileY * TILE_SIZE,
          TILE_SIZE,
          TILE_SIZE,
        );

        canvas.drawRect(rect, Paint()..color = color);

        // 격자선 (선택사항)
        canvas.drawRect(
          rect,
          Paint()
            ..color = Colors.black.withOpacity(0.1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }
  }
}
