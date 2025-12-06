import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../game/vam_game.dart';

/// 게임 오버 / 승리 오버레이
class GameOverOverlay extends StatelessWidget {
  final VamGame game;
  final bool isVictory;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.isVictory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 결과 타이틀
            Text(
              isVictory ? '승리!' : '게임 오버',
              style: TextStyle(
                color: isVictory ? Colors.yellow : Colors.red,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            // 결과 정보
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: DesignConstants.COLOR_SURFACE,
                borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
              ),
              child: Column(
                children: [
                  _ResultRow(
                    label: '생존 시간',
                    value: game.formattedTime,
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: '처치 수',
                    value: '${game.mKillCount}',
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: '도달 레벨',
                    value: 'Lv.${game.player.mLevel}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // 재시작 버튼
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  game.overlays.remove(isVictory ? 'Victory' : 'GameOver');
                  game.Restart();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignConstants.COLOR_PRIMARY,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
                  ),
                ),
                child: const Text(
                  '재시작',
                  style: TextStyle(
                    fontSize: DesignConstants.FONT_SIZE_LARGE,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 나가기 버튼
            SizedBox(
              width: 200,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
                  ),
                ),
                child: const Text(
                  '나가기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DesignConstants.FONT_SIZE_LARGE,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: DesignConstants.FONT_SIZE_MEDIUM,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: DesignConstants.FONT_SIZE_LARGE,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
