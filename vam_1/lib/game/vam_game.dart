import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../core/resources/sprite_manager.dart';
import '../core/utils/screen_utils.dart';
import '../core/utils/logger.dart';
import '../data/models/character_data.dart';
import '../data/models/equipment_data.dart';
import 'components/actors/player.dart';
import 'components/tiled_background.dart';
import 'systems/combat_system.dart';
import 'systems/spawn_system.dart';
import 'systems/wave_system.dart';
import 'systems/level_system.dart';
import 'systems/skill_system.dart';
import 'systems/challenge_system.dart';
import 'systems/progress_system.dart';
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
  late SkillSystem skillSystem;
  late ChallengeSystem challengeSystem;

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

    // 스프라이트 매니저 초기화
    await SpriteManager.instance.Initialize(this);
    Logger.game('SpriteManager initialized');

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
    skillSystem = SkillSystem(this);
    challengeSystem = ChallengeSystem(this);

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
    skillSystem.Update(dt);
    challengeSystem.Update(dt);
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
  void AddKill({bool isBoss = false}) {
    mKillCount++;
    challengeSystem.AddKill(isBoss: isBoss);
  }

  /// 게임 오버
  void GameOver() {
    mIsGameOver = true;
    pauseEngine();

    // 일반 모드일 때만 ProgressSystem에 기록 (도전 모드는 ChallengeSystem이 처리)
    if (!challengeSystem.isInChallengeMode) {
      _saveProgress(isVictory: false);
    }

    onGameOver?.call();
    Logger.game('Game Over - Kills: $mKillCount, Time: ${mElapsedTime.toStringAsFixed(1)}s');
  }

  /// 승리
  void Victory() {
    mIsGameOver = true;
    pauseEngine();

    // 일반 모드일 때만 ProgressSystem에 기록 (도전 모드는 ChallengeSystem이 처리)
    if (!challengeSystem.isInChallengeMode) {
      _saveProgress(isVictory: true);
    }

    onVictory?.call();
    Logger.game('Victory! - Kills: $mKillCount, Time: ${mElapsedTime.toStringAsFixed(1)}s');
  }

  /// 진행 데이터 저장
  void _saveProgress({required bool isVictory}) {
    ProgressSystem.instance.OnGameEnd(
      playTime: mElapsedTime.toInt(),
      kills: mKillCount,
      isVictory: isVictory,
    );
  }

  /// 초기 스킬 설정 (장비 무기 스킬 + 캐릭터 기본 스킬)
  void InitializeStarterSkills() {
    // 스킬별 레벨을 누적할 맵
    final Map<String, int> skillLevels = {};

    // 1. 장비 무기의 스킬 추가 (레벨 1)
    final weaponSkillId = ProgressSystem.instance.GetEquippedWeaponSkillId();
    if (weaponSkillId != null) {
      skillLevels[weaponSkillId] = (skillLevels[weaponSkillId] ?? 0) + 1;
      Logger.game('Equipped weapon skill: $weaponSkillId (+1)');
    } else {
      // 장비가 없으면 기본 무기 스킬 사용
      const defaultWeaponSkillId = 'skill_energy_bolt';
      skillLevels[defaultWeaponSkillId] = (skillLevels[defaultWeaponSkillId] ?? 0) + 1;
      Logger.game('Default weapon skill: $defaultWeaponSkillId (+1)');
    }

    // 2. 캐릭터 기본 스킬 추가 (레벨 1)
    // 장비 스킬과 같아도 레벨이 합산됨
    final characterSkillId = mCharacterData.baseSkillId;
    skillLevels[characterSkillId] = (skillLevels[characterSkillId] ?? 0) + 1;
    Logger.game('Character base skill: $characterSkillId (+1)');

    // 3. 누적된 레벨로 스킬 적용
    for (final entry in skillLevels.entries) {
      final skillId = entry.key;
      final level = entry.value;
      skillSystem.AddSkill(skillId, level: level);
      levelSystem.mAcquiredSkills[skillId] = level;
      Logger.game('Skill initialized: $skillId Lv.$level');
    }

    // 4. 장비 스탯 보너스 적용 (장비 시스템에서 가져옴)
    _applyEquipmentBonuses();
  }

  /// 장비 스탯 보너스 적용
  void _applyEquipmentBonuses() {
    final progress = ProgressSystem.instance;

    // 각 슬롯의 장착된 장비에서 스탯 보너스 계산
    for (final slot in EquipmentSlot.values) {
      final instance = progress.GetEquippedItem(slot);
      if (instance == null) continue;

      final equipmentData = DefaultEquipments.GetById(instance.equipmentId);
      if (equipmentData == null) continue;

      // 레벨에 따른 스탯 보너스 적용
      final levelMultiplier = 1.0 + (instance.level - 1) * 0.1;
      final stats = equipmentData.stats;

      // 플레이어 스탯에 보너스 적용
      player.mBaseStats = player.mBaseStats.copyWith(
        hp: player.mBaseStats.hp + (stats.hp * levelMultiplier).round(),
        atk: player.mBaseStats.atk + (stats.atk * levelMultiplier).round(),
        def: player.mBaseStats.def + (stats.def * levelMultiplier).round(),
      );
    }

    // HP 재계산
    player.mMaxHp = player.mBaseStats.hp;
    player.mCurrentHp = player.mMaxHp;

    Logger.game('Equipment bonuses applied');
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
    skillSystem.Reset();
    challengeSystem.Reset();

    // 초기 스킬 재설정
    InitializeStarterSkills();

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
