import '../../core/constants/game_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/challenge_data.dart';
import '../vam_game.dart';

/// 웨이브 관리 시스템
class WaveSystem {
  final VamGame mGame;

  WavePhase mCurrentPhase = WavePhase.wave1;
  double mPhaseTimer = 0;
  bool mMidBossSpawned = false;
  bool mFinalBossSpawned = false;

  // 통합 웨이브 카운터 (일반 모드/도전 모드 공용)
  int mWaveCount = 1;

  WaveSystem(this.mGame);

  /// 도전 모드에서 보스 스폰을 비활성화해야 하는지 확인
  bool get _shouldSkipBossInChallenge {
    final challenge = mGame.challengeSystem;
    if (!challenge.isInChallengeMode) return false;

    final currentChallenge = challenge.currentChallenge;
    if (currentChallenge == null) return false;

    // 도전 모드에서는 보스 스폰 비활성화
    // endless: 웨이브 도달이 목표
    // survival: 시간 생존이 목표
    // timeAttack: 처치 수가 목표
    switch (currentChallenge.type) {
      case ChallengeType.endless:
      case ChallengeType.survival:
      case ChallengeType.timeAttack:
        return true;
    }
  }

  void Update(double dt) {
    mPhaseTimer += dt;

    switch (mCurrentPhase) {
      case WavePhase.wave1:
        _handleWave1();
        break;
      case WavePhase.midBoss:
        _handleMidBoss();
        break;
      case WavePhase.wave2:
        _handleWave2();
        break;
      case WavePhase.finalBoss:
        _handleFinalBoss();
        break;
      case WavePhase.completed:
        break;
    }
  }

  void _handleWave1() {
    // 60초 동안 웨이브 1
    if (mPhaseTimer >= GameConstants.WAVE1_DURATION) {
      _transitionTo(WavePhase.midBoss);
    }
  }

  void _handleMidBoss() {
    // 도전 모드에서 보스 스킵 시 바로 웨이브 2로
    if (_shouldSkipBossInChallenge) {
      _transitionTo(WavePhase.wave2);
      return;
    }

    // 중간 보스 스폰
    if (!mMidBossSpawned) {
      mMidBossSpawned = true;
      mGame.spawnSystem.SpawnElite();
      Logger.game('Mid-boss phase started');
    }

    // 30초 후 웨이브 2로
    if (mPhaseTimer >= GameConstants.MID_BOSS_DURATION) {
      _transitionTo(WavePhase.wave2);
    }
  }

  void _handleWave2() {
    // 스폰 속도 증가
    mGame.spawnSystem.SetSpawnInterval(0.3);

    // 70초 후 최종 보스
    if (mPhaseTimer >= GameConstants.WAVE2_DURATION) {
      _transitionTo(WavePhase.finalBoss);
    }
  }

  void _handleFinalBoss() {
    // 도전 모드에서 보스 스킵 시 웨이브 1로 루프 (무한 모드)
    if (_shouldSkipBossInChallenge) {
      // 스폰 속도 유지하면서 웨이브 1로 돌아감
      _transitionTo(WavePhase.wave1);
      Logger.game('Challenge mode: Skipping final boss, looping back to wave1');
      return;
    }

    if (!mFinalBossSpawned) {
      mFinalBossSpawned = true;

      // 필드 몬스터 전멸
      mGame.spawnSystem.StopSpawning();
      mGame.spawnSystem.ClearAllMonsters();

      // 보스 스폰
      mGame.spawnSystem.SpawnBoss('MON_B01');

      Logger.game('Final boss phase started');
    }
  }

  void _transitionTo(WavePhase newPhase) {
    final previousPhase = mCurrentPhase;
    mCurrentPhase = newPhase;
    mPhaseTimer = 0;

    // 웨이브 카운터 증가 로직
    // wave1 → midBoss → wave2: 웨이브 2로 간주
    // wave2 → finalBoss → wave1 (도전모드 루프): 웨이브 3, 4, 5...
    if (newPhase == WavePhase.wave2 && previousPhase == WavePhase.midBoss) {
      mWaveCount++;
      Logger.game('Wave count: $mWaveCount');
      mGame.spawnSystem.CheckEliteSpawnByWave();
    } else if (newPhase == WavePhase.wave1 && previousPhase == WavePhase.finalBoss) {
      // 도전 모드에서 루프할 때
      mWaveCount++;
      Logger.game('Wave count (loop): $mWaveCount');
      mGame.spawnSystem.CheckEliteSpawnByWave();
    }

    Logger.game('Wave transition to: ${newPhase.name}');
  }

  /// 현재 진행률 (0.0 ~ 1.0)
  double get progress {
    final totalTime = GameConstants.WAVE1_DURATION +
        GameConstants.MID_BOSS_DURATION +
        GameConstants.WAVE2_DURATION;

    switch (mCurrentPhase) {
      case WavePhase.wave1:
        return mPhaseTimer / totalTime;
      case WavePhase.midBoss:
        return (GameConstants.WAVE1_DURATION + mPhaseTimer) / totalTime;
      case WavePhase.wave2:
        return (GameConstants.WAVE1_DURATION +
                GameConstants.MID_BOSS_DURATION +
                mPhaseTimer) /
            totalTime;
      case WavePhase.finalBoss:
      case WavePhase.completed:
        return 1.0;
    }
  }

  /// 리셋
  void Reset() {
    mCurrentPhase = WavePhase.wave1;
    mPhaseTimer = 0;
    mMidBossSpawned = false;
    mFinalBossSpawned = false;
    mWaveCount = 1;
  }
}

enum WavePhase {
  wave1,
  midBoss,
  wave2,
  finalBoss,
  completed,
}
