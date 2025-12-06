import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../game/vam_game.dart';

/// 일시정지 오버레이
class PauseOverlay extends StatelessWidget {
  final VamGame game;

  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '일시정지',
              style: TextStyle(
                color: Colors.white,
                fontSize: DesignConstants.FONT_SIZE_TITLE,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 48),

            // 계속하기 버튼
            _MenuButton(
              text: '계속하기',
              onPressed: () {
                game.overlays.remove('Pause');
                game.ResumeGame();
              },
            ),

            const SizedBox(height: 16),

            // 재시작 버튼
            _MenuButton(
              text: '재시작',
              onPressed: () {
                game.overlays.remove('Pause');
                game.Restart();
              },
            ),

            const SizedBox(height: 16),

            // 나가기 버튼
            _MenuButton(
              text: '나가기',
              color: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const _MenuButton({
    required this.text,
    required this.onPressed,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: DesignConstants.FONT_SIZE_LARGE,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
