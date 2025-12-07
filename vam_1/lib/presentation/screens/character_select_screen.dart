import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../data/models/character_data.dart';
import '../../data/models/skill_data.dart';
import 'game_screen.dart';

/// 캐릭터 선택 화면
class CharacterSelectScreen extends StatefulWidget {
  final String? challengeId;  // 도전 모드 ID (있으면 도전 모드)

  const CharacterSelectScreen({
    super.key,
    this.challengeId,
  });

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  late List<CharacterData> mUnlockedCharacters;
  int mSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    mUnlockedCharacters = DefaultCharacters.GetUnlockedCharacters();
  }

  CharacterData get mSelectedCharacter => mUnlockedCharacters[mSelectedIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignConstants.COLOR_BACKGROUND,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 타이틀
            _buildHeader(),

            // 캐릭터 카드 리스트 (가로 스크롤)
            _buildCharacterList(),

            // 선택된 캐릭터 상세 정보
            Expanded(
              child: _buildCharacterDetail(),
            ),

            // 하단 버튼
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Text(
            '캐릭터 선택',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterList() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: mUnlockedCharacters.length,
        itemBuilder: (context, index) {
          final character = mUnlockedCharacters[index];
          final isSelected = index == mSelectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                mSelectedIndex = index;
              });
            },
            child: _CharacterCard(
              character: character,
              isSelected: isSelected,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCharacterDetail() {
    final character = mSelectedCharacter;
    final skill = DefaultSkills.GetById(character.baseSkillId);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignConstants.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
        border: Border.all(
          color: character.rarity.color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 캐릭터 이름 + 등급
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: character.color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: character.color, width: 2),
                ),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: character.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: character.rarity.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: character.rarity.color),
                      ),
                      child: Text(
                        character.rarity.displayName,
                        style: TextStyle(
                          color: character.rarity.color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 설명
          Text(
            character.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const Divider(color: Colors.white24, height: 32),

          // 스탯
          Text(
            '기본 스탯',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatsGrid(character),

          const Divider(color: Colors.white24, height: 32),

          // 기본 스킬
          Text(
            '기본 스킬',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (skill != null)
            _buildSkillInfo(skill),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(CharacterData character) {
    final stats = character.baseStats;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _StatRow(label: 'HP', value: '${stats.hp}', color: Colors.green),
              const SizedBox(height: 8),
              _StatRow(label: 'ATK', value: '${stats.atk}', color: Colors.red),
              const SizedBox(height: 8),
              _StatRow(label: 'DEF', value: '${stats.def}', color: Colors.blue),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _StatRow(label: 'SPD', value: '${stats.spd}', color: Colors.cyan),
              const SizedBox(height: 8),
              _StatRow(label: 'CRIT', value: '${stats.critRate}%', color: Colors.orange),
              const SizedBox(height: 8),
              _StatRow(label: 'C.DMG', value: '${stats.critDmg.toInt()}%', color: Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillInfo(SkillData skill) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: skill.color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getSkillIcon(skill.category),
              color: skill.color,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: TextStyle(
                    color: skill.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  skill.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSkillIcon(SkillCategory category) {
    switch (category) {
      case SkillCategory.projectile:
        return Icons.flash_on;
      case SkillCategory.area:
        return Icons.blur_circular;
      case SkillCategory.orbit:
        return Icons.rotate_right;
      case SkillCategory.passive:
        return Icons.shield;
      case SkillCategory.summon:
        return Icons.pets;
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 뒤로가기 버튼
          SizedBox(
            width: 60,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
                ),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          const SizedBox(width: 12),

          // 시작 버튼
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        characterId: mSelectedCharacter.id,
                        challengeId: widget.challengeId,
                      ),
                    ),
                  ).then((_) {
                    // 게임에서 돌아오면 로비로 돌아가기 (결과값 true 전달)
                    if (mounted) {
                      Navigator.of(context).pop(true);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.challengeId != null
                      ? Colors.amber
                      : DesignConstants.COLOR_PRIMARY,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
                  ),
                ),
                child: Text(
                  widget.challengeId != null
                      ? '${mSelectedCharacter.name}(으)로 도전!'
                      : '${mSelectedCharacter.name}(으)로 시작',
                  style: const TextStyle(
                    fontSize: DesignConstants.FONT_SIZE_LARGE,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 캐릭터 카드 위젯
class _CharacterCard extends StatelessWidget {
  final CharacterData character;
  final bool isSelected;

  const _CharacterCard({
    required this.character,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? character.color.withValues(alpha: 0.3)
            : DesignConstants.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? character.color : character.rarity.color.withValues(alpha: 0.5),
          width: isSelected ? 3 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: character.color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 캐릭터 아이콘
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: character.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: character.color.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 32,
              color: character.color,
            ),
          ),

          const SizedBox(height: 8),

          // 이름
          Text(
            character.name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // 등급
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: character.rarity.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              character.rarity.displayName,
              style: TextStyle(
                color: character.rarity.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 스탯 행 위젯
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
