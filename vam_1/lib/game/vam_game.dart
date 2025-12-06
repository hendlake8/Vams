import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../core/utils/screen_utils.dart';
import '../core/utils/logger.dart';
import '../data/models/character_data.dart';
import 'components/actors/player.dart';
import 'components/tiled_background.dart';
import 'systems/combat_system.dart';
import 'systems/spawn_system.dart';
import 'systems/wave_system.dart';
import 'systems/level_system.dart';
import 'systems/weapon_system.dart';
import 'systems/skill_system.dart';
import 'input/joystick_controller.dart';

/// 메인 게임 클래스
class VamGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  // 선택된 캐릭터
  final String? mCharacterId;
  late CharacterData mCharacterData;
  // 게임 컴포넌트
  late Player player;
  late TiledBackground background;
  late FloatingJoystickController joystick;

  // 게임 시스템
  late CombatSystem combatSystem;
  late SpawnSystem spawnSystem;
  late WaveSystem waveSystem;
  late LevelSystem levelSystem;
  late WeaponSystem weaponSystem;
  late SkillSystem skillSystem;

  // 게임 상태
  double mElapsedTime = 0;
  bool mIsPaused = false;
  bool mIsGameOver = false;
  int mKillCount = 0;

  // 콜백
  VoidCallback? onPauseRequested;
  VoidCallback? onLevelUp;
  VoidCallback? onGameOver;
  VoidCallback? onVictory;

  VamGame({String? characterId}) : mCharacterId = characterId;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    Logger.game('VamGame onLoad started');

    // 캐릭터 데이터 로드
    mCharacterData = DefaultCharacters.GetById(mCharacterId ?? 'char_commando')
        ?? DefaultCharacters.COMMANDO;
    Logger.game('Selected character: ${mCharacterData.name}');

    // 카메라 설정
    camera.viewfinder.visibleGameSize = Vector2(
      ScreenUtils.gameWidth,
      ScreenUtils.gameHeight,
    );
    camera.viewfinder.anchor = Anchor.center;

    // 시스템 초기화
    combatSystem = CombatSystem();
    spawnSystem = SpawnSystem(this);
    waveSystem = WaveSystem(this);
    levelSystem = LevelSystem(this);
    weaponSystem = WeaponSystem(this);
    skillSystem = SkillSystem(this);

    // 배경 추가
    background = TiledBackground();
    world.add(background);

    // 플레이어 생성
    player = Player();
    world.add(player);

    // 카메라가 플레이어 따라다니게
    camera.follow(player);

    // 플로팅 조이스틱 생성
    joystick = FloatingJoystickController();
    camera.viewport.add(joystick);

    Logger.game('VamGame onLoad completed');
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    joystick.OnDragStart(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    joystick.OnDragUpdate(event.localStartPosition + event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    joystick.OnDragEnd();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    joystick.OnDragEnd();
  }

  @override
  void update(double dt) {
    if (mIsPaused || mIsGameOver) return;

    super.update(dt);
    mElapsedTime += dt;

    // 조이스틱 입력 처리
    player.Move(joystick.moveDirection, dt);

    // 시스템 업데이트
    waveSystem.Update(dt);
    spawnSystem.Update(dt);
    weaponSystem.Update(dt);
    skillSystem.Update(dt);
  }

  /// 게임 일시정지
  void PauseGame() {
    mIsPaused = true;
    pauseEngine();
    Logger.game('Game Paused');
  }

  /// 게임 재개
  void ResumeGame() {
    mIsPaused = false;
    resumeEngine();
    Logger.game('Game Resumed');
  }

  /// 플레이어 레벨업 처리
  void OnPlayerLevelUp() {
    PauseGame();
    onLevelUp?.call();
  }

  /// 스킬 선택 완료
  void OnSkillSelected(String skillId) {
    levelSystem.ApplySkill(skillId);
    ResumeGame();
  }

  /// 킬 카운트 증가
  void AddKill() {
    mKillCount++;
  }

  /// 게임 오버
  void GameOver() {
    mIsGameOver = true;
    pauseEngine();
    onGameOver?.call();
    Logger.game('Game Over - Kills: $mKillCount, Time: ${mElapsedTime.toStringAsFixed(1)}s');
  }

  /// 승리
  void Victory() {
    mIsGameOver = true;
    pauseEngine();
    onVictory?.call();
    Logger.game('Victory! - Kills: $mKillCount, Time: ${mElapsedTime.toStringAsFixed(1)}s');
  }

  /// 게임 재시작
  void Restart() {
    mElapsedTime = 0;
    mIsPaused = false;
    mIsGameOver = false;
    mKillCount = 0;

    // 컴포넌트 리셋
    player.Reset();
    spawnSystem.Reset();
    waveSystem.Reset();
    levelSystem.Reset();
    weaponSystem.Reset();
    skillSystem.Reset();

    resumeEngine();
    Logger.game('Game Restarted');
  }

  /// 시간 포맷팅
  String get formattedTime {
    final mins = (mElapsedTime / 60).floor();
    final secs = (mElapsedTime % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
