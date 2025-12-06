import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../data/models/skill_data.dart';
import '../../game/vam_game.dart';
import '../../game/systems/level_system.dart';

/// 스킬 선택 오버레이
class SkillSelectOverlay extends StatefulWidget {
  final VamGame game;

  const SkillSelectOverlay({super.key, required this.game});

  @override
  State<SkillSelectOverlay> createState() => _SkillSelectOverlayState();
}

class _SkillSelectOverlayState extends State<SkillSelectOverlay> {
  late List<SkillChoice> mChoices;
  int mSelectedIndex = 0; // 최초 가장 왼쪽 스킬 선택

  @override
  void initState() {
    super.initState();
    mChoices = widget.game.levelSystem.GenerateSkillChoices();
  }

  SkillChoice get selectedSkill => mChoices[mSelectedIndex];

  void _onSkillTap(int index) {
    setState(() {
      mSelectedIndex = index;
    });
  }

  void _onAcquire() {
    widget.game.OnSkillSelected(selectedSkill.skillId);
    widget.game.overlays.remove('SkillSelect');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 타이틀
                  const Text(
                    '레벨 업!',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.orange,
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'LV. ${widget.game.player.mLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 스킬 선택 안내
                  const Text(
                    '스킬을 선택하세요',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 스킬 카드들 (설명 없이 간략하게)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(mChoices.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _SkillCard(
                              choice: mChoices[index],
                              isSelected: index == mSelectedIndex,
                              onTap: () => _onSkillTap(index),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // 선택된 스킬 설명 영역 (2배 크기)
                  _SkillDescriptionPanel(choice: selectedSkill),

                  const SizedBox(height: 28),

                  // 획득 버튼
                  _AcquireButton(
                    choice: selectedSkill,
                    onPressed: _onAcquire,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 스킬 카드 (간략화 - 설명 없음)
class _SkillCard extends StatelessWidget {
  final SkillChoice choice;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkillCard({
    required this.choice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor(choice.rarity);
    final skillIcon = _getSkillIcon(choice.skillId);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? rarityColor.withValues(alpha: 0.2)
              : DesignConstants.COLOR_SURFACE,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? rarityColor : rarityColor.withValues(alpha: 0.5),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.5),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 스킬 아이콘
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: rarityColor, width: 2),
              ),
              child: Icon(
                skillIcon,
                color: rarityColor,
                size: 40,
              ),
            ),

            const SizedBox(height: 10),

            // 스킬 이름
            Text(
              choice.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // 레벨 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: choice.isNew ? Colors.green : Colors.yellow[700],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                choice.isNew ? '신규' : 'Lv.${choice.nextLevel}',
                style: TextStyle(
                  color: choice.isNew ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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

/// 선택된 스킬 설명 패널 (2배 크기)
class _SkillDescriptionPanel extends StatelessWidget {
  final SkillChoice choice;

  const _SkillDescriptionPanel({required this.choice});

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor(choice.rarity);
    final rarityName = _getRarityName(choice.rarity);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rarityColor.withValues(alpha: 0.6),
          width: 3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 스킬 이름 + 등급
          Row(
            children: [
              Text(
                choice.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: rarityColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: rarityColor, width: 2),
                ),
                child: Text(
                  rarityName,
                  style: TextStyle(
                    color: rarityColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 스킬 설명
          Text(
            choice.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 20),

          // 레벨 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: choice.isNew
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.yellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: choice.isNew
                    ? Colors.green.withValues(alpha: 0.5)
                    : Colors.yellow.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              choice.isNew
                  ? '✨ 새로운 스킬을 습득합니다!'
                  : '⬆ 레벨 ${choice.currentLevel} → ${choice.nextLevel}',
              style: TextStyle(
                color: choice.isNew ? Colors.green[300] : Colors.yellow[400],
                fontSize: 18,
                fontWeight: FontWeight.w600,
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

  String _getRarityName(SkillRarity rarity) {
    switch (rarity) {
      case SkillRarity.common:
        return '일반';
      case SkillRarity.rare:
        return '레어';
      case SkillRarity.epic:
        return '에픽';
      case SkillRarity.legendary:
        return '전설';
    }
  }
}

/// 획득 버튼
class _AcquireButton extends StatelessWidget {
  final SkillChoice choice;
  final VoidCallback onPressed;

  const _AcquireButton({
    required this.choice,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor(choice.rarity);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              rarityColor,
              rarityColor.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '획득',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(SkillRarity rarity) {
    switch (rarity) {
      case SkillRarity.common:
        return Colors.grey[600]!;
      case SkillRarity.rare:
        return Colors.blue[600]!;
      case SkillRarity.epic:
        return Colors.purple[600]!;
      case SkillRarity.legendary:
        return Colors.orange[600]!;
    }
  }
}
