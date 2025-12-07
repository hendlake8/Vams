import 'package:flame/components.dart';

import '../../core/constants/game_constants.dart';
import '../../core/utils/math_utils.dart';
import '../../core/utils/logger.dart';
import '../vam_game.dart';
import '../components/actors/monster.dart';

/// 몬스터 스폰 시스템
class SpawnSystem {
  final VamGame mGame;

  double mSpawnTimer = 0;
  double mSpawnInterval = GameConstants.DEFAULT_SPAWN_INTERVAL;
  int mCurrentMonsterCount = 0;
  bool mIsSpawning = true;

  // ========== 웨이브 기준 엘리트 스폰 ==========
  int mLastEliteWave = 0;  // 마지막 엘리트 스폰 웨이브
  static const int ELITE_WAVE_INTERVAL = 3;  // 3웨이브마다

  // ========== 킬 기준 엘리트 스폰 (확률 시스템) ==========
  int mLastKillCheck = 0;           // 마지막 확률 체크한 킬 수
  double mEliteSpawnChance = 0.1;   // 현재 엘리트 스폰 확률 (10%)

  // 킬 기준 설정값 (조절 가능)
  static const int ELITE_KILL_INTERVAL = 10;        // 10킬마다 확률 체크
  static const double ELITE_BASE_CHANCE = 0.1;      // 기본 확률 10%
  static const double ELITE_CHANCE_INCREMENT = 0.1; // 실패 시 증가량 10%

  SpawnSystem(this.mGame);

  void Update(double dt) {
    if (!mIsSpawning) return;

    mSpawnTimer += dt;

    if (mSpawnTimer >= mSpawnInterval) {
      mSpawnTimer = 0;
      _spawnMonster();
    }
  }

  void _spawnMonster() {
    if (mCurrentMonsterCount >= GameConstants.MAX_MONSTERS_ON_SCREEN) {
      return;
    }

    // 플레이어 위치 기준 스폰 위치 계산
    final playerPos = mGame.player.position;
    final spawnDistance = mGame.size.x / 2 + GameConstants.SPAWN_DISTANCE_FROM_SCREEN * 64;

    final (spawnX, spawnY) = MathUtils.RandomPointOnCircle(
      playerPos.x,
      playerPos.y,
      spawnDistance,
    );

    final monster = Monster(
      monsterId: 'MON_001',
      position: Vector2(spawnX, spawnY),
    );

    monster.mOnRemoveCallback = () {
      mCurrentMonsterCount--;
    };

    mGame.world.add(monster);
    mCurrentMonsterCount++;

    Logger.spawn('Monster spawned at ($spawnX, $spawnY). Total: $mCurrentMonsterCount');
  }

  /// 웨이브 기준 엘리트 스폰 체크 (웨이브 전환 시 호출)
  void CheckEliteSpawnByWave() {
    final waveCount = mGame.waveSystem.mWaveCount;

    // 웨이브 기준: 3, 6, 9, ...
    // 스폰 수: 웨이브 3 → 1마리, 웨이브 6 → 2마리, 웨이브 9 → 3마리
    if (waveCount >= ELITE_WAVE_INTERVAL &&
        waveCount % ELITE_WAVE_INTERVAL == 0 &&
        waveCount > mLastEliteWave) {
      final eliteCount = waveCount ~/ ELITE_WAVE_INTERVAL;  // 3→1, 6→2, 9→3
      for (int i = 0; i < eliteCount; i++) {
        SpawnElite();
      }
      mLastEliteWave = waveCount;
      Logger.spawn('Elite spawned by wave $waveCount: $eliteCount elite(s)');
    }
  }

  /// 킬 기준 엘리트 스폰 체크 (킬 시 호출)
  void CheckEliteSpawnByKill() {
    final killCount = mGame.mKillCount;

    // 10킬마다 확률 체크
    final killMilestone = (killCount ~/ ELITE_KILL_INTERVAL) * ELITE_KILL_INTERVAL;
    if (killMilestone > 0 && killMilestone > mLastKillCheck) {
      mLastKillCheck = killMilestone;

      // 확률 판정
      final roll = MathUtils.RandomRange(0.0, 1.0);
      if (roll < mEliteSpawnChance) {
        // 스폰 성공 → 확률 초기화
        SpawnElite();
        Logger.spawn('Elite spawned by kill! (chance: ${(mEliteSpawnChance * 100).toInt()}%, roll: ${(roll * 100).toInt()}%)');
        mEliteSpawnChance = ELITE_BASE_CHANCE;
      } else {
        // 스폰 실패 → 확률 증가
        mEliteSpawnChance += ELITE_CHANCE_INCREMENT;
        Logger.spawn('Elite spawn failed. Next chance: ${(mEliteSpawnChance * 100).toInt()}%');
      }
    }
  }

  /// 엘리트 스폰 조건 체크 (킬 시 호출 - 하위 호환용)
  void CheckEliteSpawn() {
    CheckEliteSpawnByKill();
  }

  /// 엘리트 몬스터 스폰
  void SpawnElite() {
    final playerPos = mGame.player.position;
    final spawnDistance = mGame.size.x / 2 + GameConstants.SPAWN_DISTANCE_FROM_SCREEN * 64;

    final (spawnX, spawnY) = MathUtils.RandomPointOnCircle(
      playerPos.x,
      playerPos.y,
      spawnDistance,
    );

    final elite = Monster(
      monsterId: 'MON_E01',
      position: Vector2(spawnX, spawnY),
      isElite: true,
    );

    elite.mOnRemoveCallback = () {
      mCurrentMonsterCount--;
    };

    mGame.world.add(elite);
    mCurrentMonsterCount++;

    Logger.spawn('Elite monster spawned!');
  }

  /// 보스 스폰
  void SpawnBoss(String bossId) {
    final playerPos = mGame.player.position;
    final spawnY = playerPos.y - mGame.size.y / 2 - 100;

    final boss = Monster(
      monsterId: bossId,
      position: Vector2(playerPos.x, spawnY),
      isBoss: true,
    );

    boss.mOnRemoveCallback = () {
      mCurrentMonsterCount--;
      mGame.Victory();
    };

    mGame.world.add(boss);
    mCurrentMonsterCount++;

    Logger.spawn('Boss spawned: $bossId');
  }

  /// 스폰 속도 변경
  void SetSpawnInterval(double interval) {
    mSpawnInterval = interval;
  }

  /// 스폰 시작
  void StartSpawning() {
    mIsSpawning = true;
  }

  /// 스폰 중지
  void StopSpawning() {
    mIsSpawning = false;
  }

  /// 모든 몬스터 제거
  void ClearAllMonsters() {
    mGame.world.children.whereType<Monster>().forEach((monster) {
      monster.removeFromParent();
    });
    mCurrentMonsterCount = 0;
  }

  /// 리셋
  void Reset() {
    ClearAllMonsters();
    mSpawnTimer = 0;
    mSpawnInterval = GameConstants.DEFAULT_SPAWN_INTERVAL;
    mIsSpawning = true;
    // 웨이브 기준 리셋
    mLastEliteWave = 0;
    // 킬 기준 리셋
    mLastKillCheck = 0;
    mEliteSpawnChance = ELITE_BASE_CHANCE;
  }
}
