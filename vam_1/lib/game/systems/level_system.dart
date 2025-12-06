import '../../core/constants/game_constants.dart';
import '../../core/utils/logger.dart';
import '../vam_game.dart';

/// 레벨업 시스템
class LevelSystem {
  final VamGame mGame;

  final List<String> mAcquiredSkills = [];

  LevelSystem(this.mGame);

  /// 레벨업에 필요한 경험치 계산
  int GetRequiredExp(int level) {
    // 공식: 기본값 + (레벨-1) × 증가량
    return GameConstants.BASE_EXP_REQUIRED +
        (level - 1) * GameConstants.EXP_INCREMENT;
  }

  /// 스킬 선택지 생성
  List<SkillChoice> GenerateSkillChoices() {
    // TODO: 실제 스킬 테이블에서 가져오기
    final choices = <SkillChoice>[];

    // 임시 선택지
    choices.add(SkillChoice(
      skillId: 'SK_A001',
      name: '축구공',
      description: '튕기는 공을 발사합니다.',
      isNew: !mAcquiredSkills.contains('SK_A001'),
      currentLevel: _getSkillLevel('SK_A001'),
    ));

    choices.add(SkillChoice(
      skillId: 'SK_A002',
      name: '화염병',
      description: '불타는 영역을 생성합니다.',
      isNew: !mAcquiredSkills.contains('SK_A002'),
      currentLevel: _getSkillLevel('SK_A002'),
    ));

    choices.add(SkillChoice(
      skillId: 'SK_P001',
      name: '운동화',
      description: '이동 속도가 증가합니다.',
      isNew: !mAcquiredSkills.contains('SK_P001'),
      currentLevel: _getSkillLevel('SK_P001'),
    ));

    return choices;
  }

  int _getSkillLevel(String skillId) {
    return mAcquiredSkills.where((s) => s == skillId).length;
  }

  /// 스킬 적용
  void ApplySkill(String skillId) {
    mAcquiredSkills.add(skillId);
    final level = _getSkillLevel(skillId);

    Logger.game('Skill applied: $skillId (Level $level)');

    // TODO: 실제 스킬 효과 적용
    mGame.player.AddSkill(skillId, level);
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

  const SkillChoice({
    required this.skillId,
    required this.name,
    required this.description,
    required this.isNew,
    required this.currentLevel,
  });

  int get nextLevel => currentLevel + 1;
}
