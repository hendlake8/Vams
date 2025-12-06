import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../data/models/skill_data.dart';
import '../../game/vam_game.dart';
import '../screens/equipment_screen.dart';

/// 일시정지 오버레이
class PauseOverlay extends StatelessWidget {
  final VamGame game;

  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            // 상단: 습득한 스킬 목록
            Expanded(
              child: _AcquiredSkillsPanel(game: game),
            ),

            // 하단: 메뉴 버튼들
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '일시정지',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 계속하기 버튼
                  _MenuButton(
                    text: '계속하기',
                    onPressed: () {
                      game.overlays.remove('Pause');
                      game.ResumeGame();
                    },
                  ),

                  const SizedBox(height: 12),

                  // 장비 관리 버튼
                  _MenuButton(
                    text: '장비 관리',
                    color: Colors.purple,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EquipmentScreen(
                            equipmentSystem: game.equipmentSystem,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // 재시작 버튼
                  _MenuButton(
                    text: '재시작',
                    onPressed: () {
                      game.overlays.remove('Pause');
                      game.Restart();
                    },
                  ),

                  const SizedBox(height: 12),

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
          ],
        ),
      ),
    );
  }
}

/// 습득한 스킬 목록 패널
class _AcquiredSkillsPanel extends StatelessWidget {
  final VamGame game;

  const _AcquiredSkillsPanel({required this.game});

  @override
  Widget build(BuildContext context) {
    final acquiredSkills = game.levelSystem.mAcquiredSkills;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white24,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Colors.yellow,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '습득한 스킬',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${acquiredSkills.length}개',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Divider(color: Colors.white24),

          const SizedBox(height: 8),

          // 스킬 목록
          Expanded(
            child: acquiredSkills.isEmpty
                ? const Center(
                    child: Text(
                      '아직 습득한 스킬이 없습니다.',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 16,
                      ),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: acquiredSkills.length,
                    itemBuilder: (context, index) {
                      final skillId = acquiredSkills.keys.elementAt(index);
                      final level = acquiredSkills[skillId]!;
                      final skillData = DefaultSkills.GetById(skillId);

                      if (skillData == null) return const SizedBox();

                      return _SkillItem(
                        skillData: skillData,
                        level: level,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 스킬 아이템
class _SkillItem extends StatelessWidget {
  final SkillData skillData;
  final int level;

  const _SkillItem({
    required this.skillData,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor(skillData.rarity);
    final skillIcon = _getSkillIcon(skillData.id);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: rarityColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rarityColor.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 스킬 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rarityColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              skillIcon,
              color: rarityColor,
              size: 26,
            ),
          ),

          const SizedBox(height: 6),

          // 스킬 이름
          Text(
            skillData.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // 레벨 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: rarityColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Lv.$level',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(SkillRarity rarity) {
    switch (rarity) {
      case SkillRarity.common:
        return Colors.grey[400]!;
      case SkillRarity.rare:
        return Colors.blue[400]!;
      case SkillRarity.epic:
        return Colors.purple[400]!;
      case SkillRarity.legendary:
        return Colors.orange[400]!;
    }
  }

  IconData _getSkillIcon(String skillId) {
    switch (skillId) {
      case 'skill_energy_bolt':
        return Icons.bolt;
      case 'skill_spinning_blade':
        return Icons.rotate_right;
      case 'skill_fire_burst':
        return Icons.local_fire_department;
      case 'skill_poison_arrow':
        return Icons.arrow_forward;
      case 'skill_chain_lightning':
        return Icons.flash_on;
      case 'skill_swift_boots':
        return Icons.directions_run;
      case 'skill_vital_heart':
        return Icons.favorite;
      case 'skill_power_gauntlet':
        return Icons.fitness_center;
      default:
        return Icons.star;
    }
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
