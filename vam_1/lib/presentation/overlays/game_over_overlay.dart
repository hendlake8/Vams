import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../game/systems/progress_system.dart';
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

  /// 계정 보상 섹션 빌드
  Widget _buildAccountRewardSection() {
    final result = ProgressSystem.instance.mLastGameResult;
    if (result == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // 레벨업 표시
          if (result.leveledUp)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'LEVEL UP! Lv.${result.previousLevel} → Lv.${result.newLevel}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

          // 획득 정보
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 경험치
              _RewardItem(
                icon: Icons.trending_up,
                color: Colors.purple,
                label: 'EXP',
                value: '+${result.expGained}',
              ),
              const SizedBox(width: 24),
              // 골드
              _RewardItem(
                icon: Icons.monetization_on,
                color: Colors.amber,
                label: 'GOLD',
                value: '+${result.goldGained}',
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 현재 경험치 바
          if (!result.leveledUp) ...[
            Text(
              'Lv.${result.newLevel}  (${result.currentExp}/${result.requiredExp})',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: result.currentExp / result.requiredExp,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

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

            const SizedBox(height: 16),

            // 계정 보상 정보
            _buildAccountRewardSection(),

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

class _RewardItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _RewardItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
