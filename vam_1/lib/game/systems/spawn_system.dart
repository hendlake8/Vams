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
  }
}
