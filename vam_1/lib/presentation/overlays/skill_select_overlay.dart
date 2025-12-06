import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../game/vam_game.dart';
import '../../game/systems/level_system.dart';

/// 스킬 선택 오버레이
class SkillSelectOverlay extends StatelessWidget {
  final VamGame game;

  const SkillSelectOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final choices = game.levelSystem.GenerateSkillChoices();

    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 타이틀
            const Text(
              '레벨 업!',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: DesignConstants.FONT_SIZE_TITLE,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'LV. ${game.player.mLevel}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: DesignConstants.FONT_SIZE_LARGE,
              ),
            ),

            const SizedBox(height: 32),

            // 스킬 선택지
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: choices.map((choice) {
                return _SkillCard(
                  choice: choice,
                  onTap: () {
                    game.OnSkillSelected(choice.skillId);
                    game.overlays.remove('SkillSelect');
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final SkillChoice choice;
  final VoidCallback onTap;

  const _SkillCard({
    required this.choice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DesignConstants.COLOR_SURFACE,
          borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
          border: Border.all(
            color: choice.isNew ? Colors.green : Colors.yellow,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 스킬 아이콘 (임시)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 32,
              ),
            ),

            const SizedBox(height: 8),

            // 스킬 이름
            Text(
              choice.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: DesignConstants.FONT_SIZE_MEDIUM,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // 레벨 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: choice.isNew ? Colors.green : Colors.yellow[700],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                choice.isNew ? '신규' : 'Lv.${choice.nextLevel}',
                style: TextStyle(
                  color: choice.isNew ? Colors.white : Colors.black,
                  fontSize: DesignConstants.FONT_SIZE_SMALL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 설명
            Text(
              choice.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
