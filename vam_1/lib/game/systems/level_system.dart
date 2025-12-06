import 'dart:math';

import '../../core/constants/game_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/skill_data.dart';
import '../vam_game.dart';

/// 레벨업 시스템
class LevelSystem {
  final VamGame mGame;
  final Random _random = Random();

  // 습득한 스킬 및 레벨 추적
  final Map<String, int> mAcquiredSkills = {};

  LevelSystem(this.mGame);

  /// 레벨업에 필요한 경험치 계산
  int GetRequiredExp(int level) {
    // 공식: 기본값 + (레벨-1) × 증가량
    return GameConstants.BASE_EXP_REQUIRED +
        (level - 1) * GameConstants.EXP_INCREMENT;
  }

  /// 스킬 선택지 생성 (실제 구현된 스킬만)
  List<SkillChoice> GenerateSkillChoices() {
    final availableSkills = <SkillData>[];

    // 실제 구현된 스킬 목록에서 선택 가능한 스킬 필터링
    for (final skill in DefaultSkills.all) {
      final currentLevel = mAcquiredSkills[skill.id] ?? 0;

      // 최대 레벨 미만인 스킬만 선택 가능
      if (currentLevel < skill.maxLevel) {
        availableSkills.add(skill);
      }
    }

    // 랜덤하게 3개 선택 (또는 가능한 만큼)
    availableSkills.shuffle(_random);
    final selectedSkills = availableSkills.take(GameConstants.SKILL_CHOICES_COUNT).toList();

    // SkillChoice로 변환
    return selectedSkills.map((skill) {
      final currentLevel = mAcquiredSkills[skill.id] ?? 0;
      return SkillChoice(
        skillId: skill.id,
        name: skill.name,
        description: skill.description,
        isNew: currentLevel == 0,
        currentLevel: currentLevel,
        rarity: skill.rarity,
      );
    }).toList();
  }

  /// 스킬 적용
  void ApplySkill(String skillId) {
    final currentLevel = mAcquiredSkills[skillId] ?? 0;
    final newLevel = currentLevel + 1;
    mAcquiredSkills[skillId] = newLevel;

    Logger.game('Skill applied: $skillId (Level $newLevel)');

    // SkillSystem에 스킬 추가/업그레이드
    mGame.skillSystem.AddSkill(skillId, level: newLevel);

    // Player에도 스킬 추가 (UI 표시용)
    mGame.player.AddSkill(skillId, newLevel);
  }

  /// 특정 스킬 레벨 조회
  int GetSkillLevel(String skillId) {
    return mAcquiredSkills[skillId] ?? 0;
  }

  /// 리셋
  void Reset() {
    mAcquiredSkills.clear();
  }
}

/// 스킬 선택지
class SkillChoice {
  final String skillId;
  final String name;
  final String description;
  final bool isNew;
  final int currentLevel;
  final SkillRarity rarity;

  const SkillChoice({
    required this.skillId,
    required this.name,
    required this.description,
    required this.isNew,
    required this.currentLevel,
    this.rarity = SkillRarity.common,
  });

  int get nextLevel => currentLevel + 1;
}
