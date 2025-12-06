import '../../core/constants/game_constants.dart';
import '../../core/utils/logger.dart';
import '../vam_game.dart';

/// 웨이브 관리 시스템
class WaveSystem {
  final VamGame mGame;

  WavePhase mCurrentPhase = WavePhase.wave1;
  double mPhaseTimer = 0;
  bool mMidBossSpawned = false;
  bool mFinalBossSpawned = false;

  WaveSystem(this.mGame);

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
    mCurrentPhase = newPhase;
    mPhaseTimer = 0;
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
  }
}

enum WavePhase {
  wave1,
  midBoss,
  wave2,
  finalBoss,
  completed,
}
