import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/actor_stats.dart';
import '../../vam_game.dart';

/// 플레이어 컴포넌트
class Player extends PositionComponent with HasGameReference<VamGame>, CollisionCallbacks {
  // 스탯
  late ActorStats mBaseStats;
  int mCurrentHp = 0;
  int mMaxHp = 0;

  // 경험치/레벨
  int mLevel = 1;
  int mCurrentExp = 0;

  // 스킬 슬롯
  final List<PlayerSkill> mSkills = [];

  // 상태
  bool mIsAlive = true;
  double mInvincibilityTimer = 0;
  bool get isInvincible => mInvincibilityTimer > 0;

  // 시각적 요소
  late RectangleComponent mBody;

  Player() : super(
    size: Vector2(48, 48),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 캐릭터 데이터에서 스탯 로드
    final characterData = game.mCharacterData;
    mBaseStats = characterData.baseStats;

    mMaxHp = mBaseStats.hp;
    mCurrentHp = mMaxHp;

    // 캐릭터 색상으로 시각적 표현
    mBody = RectangleComponent(
      size: size,
      paint: Paint()..color = characterData.color,
    );
    add(mBody);

    // 히트박스
    add(CircleHitbox(radius: 20));

    // 초기 스킬 설정 (장비 무기 스킬 + 캐릭터 기본 스킬)
    game.InitializeStarterSkills();

    Logger.game('Player loaded - HP: $mCurrentHp/$mMaxHp');
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 무적 타이머
    if (mInvincibilityTimer > 0) {
      mInvincibilityTimer -= dt;

      // 무적 시 깜빡임 효과
      final characterColor = game.mCharacterData.color;
      mBody.paint.color = (mInvincibilityTimer * 10).floor() % 2 == 0
          ? characterColor
          : characterColor.withValues(alpha: 0.3);
    } else {
      mBody.paint.color = game.mCharacterData.color;
    }

    // 스킬 업데이트
    for (final skill in mSkills) {
      skill.Update(dt);
    }
  }

  /// 이동
  void Move(Vector2 direction, double dt) {
    if (!mIsAlive) return;

    if (direction.length > 0) {
      position += direction * mBaseStats.spd * 60 * dt;
    }
  }

  /// 피해 받기
  void TakeDamage(int damage) {
    if (!mIsAlive || isInvincible) return;

    mCurrentHp -= damage;
    mInvincibilityTimer = GameConstants.INVINCIBILITY_DURATION;

    Logger.combat('Player took $damage damage. HP: $mCurrentHp/$mMaxHp');

    if (mCurrentHp <= 0) {
      mCurrentHp = 0;
      Die();
    }
  }

  /// 회복
  void Heal(int amount) {
    if (!mIsAlive) return;

    mCurrentHp = (mCurrentHp + amount).clamp(0, mMaxHp);
    Logger.game('Player healed $amount. HP: $mCurrentHp/$mMaxHp');
  }

  /// 경험치 획득
  void GainExp(int amount) {
    if (!mIsAlive) return;

    mCurrentExp += amount;

    final requiredExp = game.levelSystem.GetRequiredExp(mLevel);
    if (mCurrentExp >= requiredExp) {
      LevelUp();
    }
  }

  /// 레벨업
  void LevelUp() {
    final requiredExp = game.levelSystem.GetRequiredExp(mLevel);
    mCurrentExp -= requiredExp;
    mLevel++;

    Logger.game('Player leveled up to $mLevel!');

    // 레벨업 시 스킬 선택 UI 표시
    game.OnPlayerLevelUp();
  }

  /// 스킬 추가
  void AddSkill(String skillId, int level) {
    final existing = mSkills.firstWhere(
      (s) => s.skillId == skillId,
      orElse: () => PlayerSkill(skillId: '', level: 0),
    );

    if (existing.skillId.isEmpty) {
      // 새 스킬
      mSkills.add(PlayerSkill(skillId: skillId, level: level));
    } else {
      // 레벨업
      existing.level = level;
    }
  }

  /// 사망
  void Die() {
    mIsAlive = false;
    mBody.paint.color = Colors.grey;
    Logger.game('Player died');
    game.GameOver();
  }

  /// 리셋
  void Reset() {
    position = Vector2.zero();
    mCurrentHp = mMaxHp;
    mLevel = 1;
    mCurrentExp = 0;
    mIsAlive = true;
    mInvincibilityTimer = 0;
    mSkills.clear();
    mBody.paint.color = game.mCharacterData.color;
  }

  // Getters
  double get hpPercent => mCurrentHp / mMaxHp;

  double get expPercent {
    final required = game.levelSystem.GetRequiredExp(mLevel);
    return mCurrentExp / required;
  }

  ActorStats get stats => mBaseStats;
}

/// 플레이어 스킬 인스턴스
class PlayerSkill {
  final String skillId;
  int level;
  double mCooldownTimer = 0;

  PlayerSkill({
    required this.skillId,
    required this.level,
  });

  void Update(double dt) {
    if (mCooldownTimer > 0) {
      mCooldownTimer -= dt;
    }

    // TODO: 스킬 발동 로직
  }
}
