import '../../core/utils/logger.dart';
import '../../data/models/challenge_data.dart';
import '../../data/models/equipment_data.dart';
import '../vam_game.dart';
import 'progress_system.dart';

/// 도전 시스템 - 도전 모드 관리, 진행 상태, 보상 처리
class ChallengeSystem {
  final VamGame mGame;

  // 현재 도전 모드
  ChallengeData? mCurrentChallenge;
  bool mIsInChallengeMode = false;

  // 도전 진행 상태
  int mCurrentWave = 0;
  int mKillCount = 0;
  double mElapsedTime = 0;
  int mBossKillCount = 0;

  // 웨이브 타이머 (무한 모드용)
  double mWaveTimer = 0;
  static const double WAVE_INTERVAL = 30.0;  // 30초마다 웨이브 증가

  ChallengeSystem(this.mGame);

  /// 플레이어 레벨 (ProgressSystem에서 가져옴)
  int get playerLevel => ProgressSystem.instance.playerLevel;

  /// 도전 시작
  bool StartChallenge(String challengeId) {
    final challenge = DefaultChallenges.GetById(challengeId);
    if (challenge == null) {
      Logger.game('Challenge not found: $challengeId');
      return false;
    }

    // 해금 조건 확인
    if (!IsUnlocked(challenge)) {
      Logger.game('Challenge not unlocked: ${challenge.name}');
      return false;
    }

    mCurrentChallenge = challenge;
    mIsInChallengeMode = true;
    mCurrentWave = 1;  // 웨이브 1부터 시작
    mKillCount = 0;
    mElapsedTime = 0;
    mBossKillCount = 0;
    mWaveTimer = 0;

    // 게임 변경자 적용
    _applyModifier(challenge.modifier);

    Logger.game('Challenge started: ${challenge.name}');
    return true;
  }

  /// 도전 업데이트 (매 프레임)
  void Update(double dt) {
    if (!mIsInChallengeMode || mCurrentChallenge == null) return;

    mElapsedTime += dt;

    // 무한 모드: 시간 기반 웨이브 증가
    if (mCurrentChallenge!.type == ChallengeType.endless) {
      mWaveTimer += dt;
      if (mWaveTimer >= WAVE_INTERVAL) {
        mWaveTimer = 0;
        AdvanceWave();

        // 웨이브 증가 시 스폰 속도 증가
        final newInterval = 0.5 - (mCurrentWave * 0.02);  // 웨이브당 0.02초 감소
        mGame.spawnSystem.SetSpawnInterval(newInterval.clamp(0.1, 0.5));
      }
    }

    // 클리어 조건 체크
    if (_checkClearCondition()) {
      _onChallengeCleared();
    }

    // 타임어택/서바이벌 시간 초과 체크
    if (_checkTimeOut()) {
      _onChallengeFailed();
    }
  }

  /// 킬 카운트 증가
  void AddKill({bool isBoss = false}) {
    mKillCount++;
    if (isBoss) {
      mBossKillCount++;
      Logger.game('Boss killed! Total: $mBossKillCount');
    }
  }

  /// 웨이브 증가 (무한 웨이브 모드)
  void AdvanceWave() {
    mCurrentWave++;
    Logger.game('Wave advanced: $mCurrentWave');
  }

  /// 클리어 조건 체크
  bool _checkClearCondition() {
    final condition = mCurrentChallenge!.condition;

    switch (mCurrentChallenge!.type) {
      case ChallengeType.endless:
        return condition.targetWave != null && mCurrentWave >= condition.targetWave!;

      case ChallengeType.bossRush:
        return condition.targetBossKills != null && mBossKillCount >= condition.targetBossKills!;

      case ChallengeType.timeAttack:
        return condition.targetKills != null && mKillCount >= condition.targetKills!;

      case ChallengeType.survival:
        return condition.targetTime != null && mElapsedTime >= condition.targetTime!;
    }
  }

  /// 시간 초과 체크
  bool _checkTimeOut() {
    final condition = mCurrentChallenge!.condition;

    // 타임어택: 시간 내 목표 미달성
    if (mCurrentChallenge!.type == ChallengeType.timeAttack) {
      if (condition.targetTime != null && mElapsedTime >= condition.targetTime!) {
        return mKillCount < (condition.targetKills ?? 0);
      }
    }

    return false;
  }

  /// 도전 클리어
  Future<void> _onChallengeCleared() async {
    if (mCurrentChallenge == null) return;

    Logger.game('Challenge cleared: ${mCurrentChallenge!.name}');

    // 보상 지급 (async 처리)
    await _grantRewards();

    // ProgressSystem에 기록 저장
    _saveProgress(cleared: true);

    // 도전 종료
    mGame.Victory();
  }

  /// 도전 실패
  void _onChallengeFailed() {
    if (mCurrentChallenge == null) return;

    Logger.game('Challenge failed: ${mCurrentChallenge!.name}');

    // ProgressSystem에 기록 저장 (클리어 아님)
    _saveProgress(cleared: false);

    mGame.GameOver();
  }

  /// ProgressSystem에 진행 저장
  void _saveProgress({required bool cleared}) {
    ProgressSystem.instance.OnGameEnd(
      playTime: mElapsedTime.toInt(),
      kills: mKillCount,
      isVictory: cleared,
      challengeId: mCurrentChallenge?.id,
      wave: mCurrentWave,
      bossKills: mBossKillCount,
    );
  }

  /// 보상 지급
  Future<void> _grantRewards() async {
    int totalGold = 0;
    int totalGems = 0;

    for (final reward in mCurrentChallenge!.rewards) {
      switch (reward.type) {
        case ChallengeRewardType.gold:
          totalGold += reward.amount;
          Logger.game('Reward: ${reward.amount} Gold');
          break;

        case ChallengeRewardType.gem:
          totalGems += reward.amount;
          Logger.game('Reward: ${reward.amount} Gems');
          break;

        case ChallengeRewardType.equipment:
          if (reward.itemId != null) {
            final equipData = DefaultEquipments.GetById(reward.itemId!);
            if (equipData != null) {
              await ProgressSystem.instance.AddEquipment(reward.itemId!);
              Logger.game('Reward: Equipment ${equipData.name}');
            }
          }
          break;

        case ChallengeRewardType.exp:
          // 경험치는 OnGameEnd에서 자동 계산됨
          Logger.game('Reward: ${reward.amount} EXP (bonus)');
          break;
      }
    }

    // 재화 지급
    if (totalGold > 0 || totalGems > 0) {
      await ProgressSystem.instance.AddCurrency(gold: totalGold, gems: totalGems);
      Logger.game('Currency granted: $totalGold gold, $totalGems gems');
    }
  }

  /// 게임 변경자 적용
  void _applyModifier(ChallengeModifier modifier) {
    // 스폰 속도 조절
    if (modifier.spawnRateMultiplier != 1.0) {
      final baseInterval = 0.5;  // 기본 스폰 간격
      mGame.spawnSystem.SetSpawnInterval(baseInterval / modifier.spawnRateMultiplier);
    }

    // TODO: 적 체력/공격력 배율은 Monster 생성 시 적용
    // TODO: 회복 불가/엘리트만 출현 등 추가 구현

    Logger.game('Challenge modifier applied: ${modifier.GetModifierTexts().join(", ")}');
  }

  /// 해금 여부 확인
  bool IsUnlocked(ChallengeData challenge) {
    // 레벨 조건 (ProgressSystem에서 가져옴)
    if (playerLevel < challenge.unlockLevel) {
      return false;
    }

    // 선행 도전 조건 (ProgressSystem에서 확인)
    if (challenge.prerequisiteId != null) {
      if (!ProgressSystem.instance.IsChallengeCleared(challenge.prerequisiteId!)) {
        return false;
      }
    }

    return true;
  }

  /// 도전 상태 조회
  ChallengeStatus GetStatus(ChallengeData challenge) {
    if (!IsUnlocked(challenge)) {
      return ChallengeStatus.locked;
    }

    if (ProgressSystem.instance.IsChallengeCleared(challenge.id)) {
      return ChallengeStatus.cleared;
    }

    return ChallengeStatus.available;
  }

  /// 도전 기록 조회 (ProgressSystem 연동)
  ChallengeRecord? GetRecord(String challengeId) {
    final data = ProgressSystem.instance.GetChallengeRecord(challengeId);
    if (data == null) return null;

    return ChallengeRecord(
      challengeId: data.challengeId,
      isCleared: data.isCleared,
      bestWave: data.bestWave,
      bestKills: data.bestKills,
      bestTime: data.bestTime,
      clearedAt: data.clearedAt != null ? DateTime.parse(data.clearedAt!) : null,
    );
  }

  /// 현재 도전 진행률 (0.0 ~ 1.0)
  double get progress {
    if (mCurrentChallenge == null) return 0.0;

    final condition = mCurrentChallenge!.condition;

    switch (mCurrentChallenge!.type) {
      case ChallengeType.endless:
        if (condition.targetWave == null) return 0.0;
        return (mCurrentWave / condition.targetWave!).clamp(0.0, 1.0);

      case ChallengeType.bossRush:
        if (condition.targetBossKills == null) return 0.0;
        return (mBossKillCount / condition.targetBossKills!).clamp(0.0, 1.0);

      case ChallengeType.timeAttack:
        if (condition.targetKills == null) return 0.0;
        return (mKillCount / condition.targetKills!).clamp(0.0, 1.0);

      case ChallengeType.survival:
        if (condition.targetTime == null) return 0.0;
        return (mElapsedTime / condition.targetTime!).clamp(0.0, 1.0);
    }
  }

  /// 남은 시간 (타임어택/서바이벌)
  int get remainingTime {
    if (mCurrentChallenge == null) return 0;
    final targetTime = mCurrentChallenge!.condition.targetTime;
    if (targetTime == null) return 0;
    return (targetTime - mElapsedTime).clamp(0, targetTime).toInt();
  }

  /// 도전 종료
  void EndChallenge() {
    mCurrentChallenge = null;
    mIsInChallengeMode = false;
    Logger.game('Challenge ended');
  }

  /// 리셋
  void Reset() {
    mCurrentWave = 0;
    mKillCount = 0;
    mElapsedTime = 0;
    mBossKillCount = 0;
    mWaveTimer = 0;
  }

  // Getters
  bool get isInChallengeMode => mIsInChallengeMode;
  ChallengeData? get currentChallenge => mCurrentChallenge;
  int get currentWave => mCurrentWave;
  int get killCount => mKillCount;
}
