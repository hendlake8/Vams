import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../core/constants/game_constants.dart';
import 'game_screen.dart';

/// 메인 로비 화면
class MainLobbyScreen extends StatelessWidget {
  const MainLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignConstants.COLOR_BACKGROUND,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 게임 타이틀
              const Text(
                '뱀서라이크\n슈팅',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'v${GameConstants.GAME_VERSION}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: DesignConstants.FONT_SIZE_SMALL,
                ),
              ),

              const SizedBox(height: 64),

              // 시작 버튼
              SizedBox(
                width: 240,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignConstants.COLOR_PRIMARY,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
                    ),
                  ),
                  child: const Text(
                    '게임 시작',
                    style: TextStyle(
                      fontSize: DesignConstants.FONT_SIZE_LARGE,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 120),

              // 안내 텍스트
              const Text(
                '조이스틱으로 이동\n공격은 자동!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: DesignConstants.FONT_SIZE_MEDIUM,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
