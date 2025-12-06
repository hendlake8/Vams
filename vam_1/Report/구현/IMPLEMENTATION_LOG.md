# 뱀서라이크 슈팅 게임 구현 내역서

> 문서 버전: 1.7
> 최종 수정일: 2025-12-06

---

## 목차

1. [프로젝트 현황](#1-프로젝트-현황)
2. [구현 완료 항목](#2-구현-완료-항목)
3. [파일 구조](#3-파일-구조)
4. [주요 클래스 설명](#4-주요-클래스-설명)
5. [데이터 모델](#5-데이터-모델)
6. [시스템 연동 흐름](#6-시스템-연동-흐름)
7. [개발 로드맵 진행 현황](#7-개발-로드맵-진행-현황)
8. [버그 수정 이력](#8-버그-수정-이력)
9. [장비 시스템 아키텍처 변경](#9-장비-시스템-아키텍처-변경)
10. [순찰/상점 시스템](#10-순찰상점-시스템)

---

## 1. 프로젝트 현황

### 1.1 개발 환경

| 항목 | 버전/사양 |
|------|-----------|
| Flutter | 3.x |
| Dart SDK | ^3.10.1 |
| Flame Engine | 1.x |
| 타겟 플랫폼 | Android |

### 1.2 빌드 상태

- ✅ Debug 빌드 성공
- ✅ Flutter Analyze 오류/경고 없음

---

## 2. 구현 완료 항목

### 2.1 핵심 시스템

| 시스템 | 파일 | 상태 | 설명 |
|--------|------|------|------|
| 게임 메인 | `vam_game.dart` | ✅ 완료 | FlameGame 기반 메인 게임 클래스 |
| 무기 시스템 | `weapon_system.dart` | ✅ 완료 | 무기 장착 → 스킬 자동 활성화 |
| 스킬 시스템 | `skill_system.dart` | ✅ 완료 | 스킬 발동, 투사체/범위/회전 처리 |
| 레벨 시스템 | `level_system.dart` | ✅ 완료 | 경험치, 레벨업, 스킬 선택지 생성 |
| 스폰 시스템 | `spawn_system.dart` | ✅ 완료 | 몬스터 스폰 관리 |
| 웨이브 시스템 | `wave_system.dart` | ✅ 완료 | 시간 기반 웨이브 진행 |
| 전투 시스템 | `combat_system.dart` | ✅ 완료 | 데미지 계산 |
| 장비 시스템 | `equipment_system.dart` | ✅ 완료 | 장비 인벤토리, 장착/해제, 강화 (Phase 2) |
| 도전 시스템 | `challenge_system.dart` | ✅ 완료 | 도전 모드 관리, 진행/클리어/보상 (Phase 2) |
| 진행 시스템 | `progress_system.dart` | ✅ 완료 | 영구 저장 (계정 레벨, 재화, 기록) (Phase 2) |
| 순찰 시스템 | `patrol_data.dart` | ✅ 완료 | 방치형 보상 시스템 (Phase 2.2) |
| 상점 시스템 | `shop_data.dart` | ✅ 완료 | 재화 교환/아이템 구매 (Phase 2.2) |

### 2.2 게임 오브젝트

| 컴포넌트 | 파일 | 상태 | 설명 |
|----------|------|------|------|
| 플레이어 | `player.dart` | ✅ 완료 | 이동, HP, 레벨, 스킬 관리 |
| 몬스터 | `monster.dart` | ✅ 완료 | AI 이동, 피격, 경험치 드롭 |
| 경험치 젬 | `exp_gem.dart` | ✅ 완료 | 자석 효과, 경험치 획득 |
| 회전 무기 | `orbit_weapon.dart` | ✅ 완료 | 플레이어 주변 회전 공격 |
| 데미지 텍스트 | `damage_text.dart` | ✅ 완료 | 데미지/힐/레벨업 텍스트 표시 |
| 타일 배경 | `tiled_background.dart` | ✅ 완료 | 무한 타일 배경 |

### 2.3 UI/오버레이

| UI | 파일 | 상태 | 설명 |
|----|------|------|------|
| HUD | `hud_overlay.dart` | ✅ 완료 | HP바, EXP바, 시간, 킬수 |
| 스킬 선택 | `skill_select_overlay.dart` | ✅ 완료 | 레벨업 시 스킬 선택 UI |
| 일시정지 | `pause_overlay.dart` | ✅ 완료 | 일시정지 + 습득 스킬 목록 |
| 게임오버 | `game_over_overlay.dart` | ✅ 완료 | 게임오버/승리 화면 |
| 캐릭터 선택 | `character_select_screen.dart` | ✅ 완료 | 캐릭터 선택 UI (Phase 2) |
| 장비 관리 (게임 내) | `equipment_screen.dart` | ✅ 완료 | 장비 장착/강화 UI (Phase 2, 게임 인스턴스용) |
| 장비 관리 (로비) | `equipment_management_screen.dart` | ✅ 완료 | 로비 장비 관리 (Phase 2.1, 영구 저장) |
| 장비 합성 | `fusion_screen.dart` | ✅ 완료 | 장비 합성 UI (Phase 2) |
| 도전 선택 | `challenge_screen.dart` | ✅ 완료 | 도전 모드 선택 UI (Phase 2) |
| 순찰 화면 | `patrol_screen.dart` | ✅ 완료 | 방치형 순찰 UI (Phase 2.2) |
| 상점 화면 | `shop_screen.dart` | ✅ 완료 | 상점 구매 UI (Phase 2.2) |

### 2.4 데이터 모델

| 모델 | 파일 | 상태 | 설명 |
|------|------|------|------|
| 스킬 데이터 | `skill_data.dart` | ✅ 완료 | 8개 스킬 정의 (5 공격 + 3 패시브) |
| 무기 데이터 | `weapon_data.dart` | ✅ 완료 | 5개 무기 정의 (스킬 연결) |
| 캐릭터 데이터 | `character_data.dart` | ✅ 완료 | 5개 캐릭터 정의 (Phase 2) |
| 장비 데이터 | `equipment_data.dart` | ✅ 완료 | 9개 장비 정의 (Phase 2) |
| 도전 데이터 | `challenge_data.dart` | ✅ 완료 | 8개 도전 정의 (Phase 2) |
| 진행 데이터 | `progress_data.dart` | ✅ 완료 | 계정 레벨, 재화, 기록 (Phase 2) |
| 순찰 데이터 | `patrol_data.dart` | ✅ 완료 | 순찰 지역, 보상 계산 (Phase 2.2) |
| 상점 데이터 | `shop_data.dart` | ✅ 완료 | 상점 아이템, 구매 기록 (Phase 2.2) |
| 액터 스탯 | `actor_stats.dart` | ✅ 완료 | 공통 스탯 구조 |

---

## 3. 파일 구조

```
lib/
├── main.dart                          # 앱 진입점
│
├── core/                              # 핵심 유틸리티
│   ├── constants/
│   │   ├── asset_paths.dart           # 리소스 경로
│   │   ├── design_constants.dart      # UI 상수
│   │   └── game_constants.dart        # 게임 밸런스 상수
│   └── utils/
│       ├── logger.dart                # 로깅
│       ├── math_utils.dart            # 수학 유틸
│       └── screen_utils.dart          # 화면 유틸
│
├── data/models/                       # 데이터 모델
│   ├── skill_data.dart                # 스킬 정의 ⭐
│   ├── weapon_data.dart               # 무기 정의 ⭐
│   ├── character_data.dart            # 캐릭터 정의 ⭐ (Phase 2)
│   ├── equipment_data.dart            # 장비 정의 ⭐ (Phase 2)
│   ├── challenge_data.dart            # 도전 정의 ⭐ (Phase 2)
│   ├── progress_data.dart             # 진행 데이터 ⭐ (Phase 2)
│   ├── patrol_data.dart               # 순찰 데이터 ⭐ (Phase 2.2)
│   ├── shop_data.dart                 # 상점 데이터 ⭐ (Phase 2.2)
│   └── actor_stats.dart
│
├── game/                              # 게임 로직
│   ├── vam_game.dart                  # 메인 게임 ⭐
│   ├── components/
│   │   ├── actors/
│   │   │   ├── player.dart            # 플레이어 ⭐
│   │   │   └── monster.dart           # 몬스터
│   │   ├── effects/
│   │   │   └── damage_text.dart       # 데미지 텍스트
│   │   ├── items/
│   │   │   └── exp_gem.dart           # 경험치 젬
│   │   ├── weapons/
│   │   │   └── orbit_weapon.dart      # 회전 무기
│   │   └── tiled_background.dart      # 타일 배경
│   ├── input/
│   │   └── joystick_controller.dart   # 조이스틱
│   └── systems/
│       ├── weapon_system.dart         # 무기 시스템 ⭐
│       ├── skill_system.dart          # 스킬 시스템 ⭐
│       ├── level_system.dart          # 레벨 시스템 ⭐
│       ├── equipment_system.dart      # 장비 시스템 ⭐ (Phase 2)
│       ├── challenge_system.dart      # 도전 시스템 ⭐ (Phase 2)
│       ├── progress_system.dart       # 진행 시스템 ⭐ (Phase 2)
│       ├── combat_system.dart
│       ├── spawn_system.dart
│       └── wave_system.dart
│
└── presentation/                      # UI 레이어
    ├── screens/
    │   ├── main_lobby_screen.dart
    │   ├── character_select_screen.dart  # 캐릭터 선택 ⭐ (Phase 2)
    │   ├── equipment_screen.dart         # 장비 관리 (게임 내) ⭐ (Phase 2)
    │   ├── equipment_management_screen.dart  # 장비 관리 (로비) ⭐ (Phase 2.1)
    │   ├── fusion_screen.dart            # 장비 합성 ⭐ (Phase 2)
    │   ├── patrol_screen.dart            # 순찰 화면 ⭐ (Phase 2.2)
    │   ├── shop_screen.dart              # 상점 화면 ⭐ (Phase 2.2)
    │   └── game_screen.dart
    └── overlays/
        ├── hud_overlay.dart
        ├── skill_select_overlay.dart  # 스킬 선택 UI ⭐
        ├── pause_overlay.dart         # 일시정지 UI ⭐
        └── game_over_overlay.dart
```

---

## 4. 주요 클래스 설명

### 4.1 WeaponSystem

**역할**: 무기 장착 및 스킬 연결 관리

```dart
class WeaponSystem {
  WeaponData? mEquippedWeapon;  // 장착된 무기
  int mWeaponLevel = 1;         // 무기 레벨

  // 무기 장착 → 기본 스킬 자동 활성화
  void EquipWeapon(String weaponId, {int level = 1}) {
    // 1. WeaponData 조회
    // 2. SkillSystem에 스킬 추가
    // 3. LevelSystem 습득 목록에 추가
  }
}
```

### 4.2 SkillSystem

**역할**: 스킬 발동 및 효과 처리

```dart
class SkillSystem {
  List<EquippedSkill> mEquippedSkills;  // 장착된 스킬 목록

  // 패시브 보너스
  double mSpeedBonus = 0;
  double mHealthBonus = 0;
  double mDamageBonus = 0;

  void AddSkill(String skillId, {int level = 1});
  void Update(double dt);  // 쿨다운 체크, 스킬 발동
}
```

**지원 스킬 카테고리**:
- `Projectile`: 투사체 발사 (`SkillProjectile`)
- `Area`: 범위 공격 (`AreaEffectComponent`)
- `Orbit`: 회전 무기 (`OrbitWeapon`)
- `Passive`: 패시브 능력치

### 4.3 LevelSystem

**역할**: 레벨업 및 스킬 선택지 관리

```dart
class LevelSystem {
  Map<String, int> mAcquiredSkills;  // 습득 스킬 및 레벨

  int GetRequiredExp(int level);           // 필요 경험치 계산
  List<SkillChoice> GenerateSkillChoices(); // 스킬 선택지 생성
  void ApplySkill(String skillId);         // 스킬 적용
}
```

### 4.4 SkillSelectOverlay (StatefulWidget)

**역할**: 레벨업 스킬 선택 UI

**구성 요소**:
- `_SkillCard`: 스킬 카드 (아이콘, 이름, 레벨 뱃지)
- `_SkillDescriptionPanel`: 선택된 스킬 상세 설명
- `_AcquireButton`: 획득 버튼

**상태 관리**:
```dart
int mSelectedIndex = 0;  // 선택된 스킬 인덱스 (초기값: 첫 번째)
```

### 4.5 PauseOverlay

**역할**: 일시정지 화면 + 습득 스킬 목록 + 장비 관리

**구성 요소**:
- `_AcquiredSkillsPanel`: 습득 스킬 그리드 표시
- `_SkillItem`: 개별 스킬 아이템
- `_MenuButton`: 메뉴 버튼 (계속/장비 관리/재시작/나가기)

### 4.6 EquipmentSystem

**역할**: 장비 인벤토리 관리, 장착/해제, 강화

```dart
class EquipmentSystem {
  List<EquipmentInstance> mInventory;  // 보유 장비 목록
  Map<EquipmentSlot, EquipmentInstance?> mEquipped;  // 장착된 장비

  EquipmentInstance AddEquipment(EquipmentData data);  // 장비 추가
  bool Equip(EquipmentInstance equipment);             // 장착
  void Unequip(EquipmentSlot slot);                    // 해제
  bool UpgradeEquipment(EquipmentInstance equipment);  // 강화
  ActorStats GetTotalEquipmentStats();                 // 장비 총 스탯
  EquipmentInstance? TryDropEquipment(double chance);  // 랜덤 드롭
}
```

### 4.7 EquipmentScreen (StatefulWidget)

**역할**: 장비 관리 UI

**구성 요소**:
- `_buildEquippedSection`: 장착 중인 장비 표시
- `_buildInventorySection`: 인벤토리 목록 (슬롯별 탭)
- `_buildDetailPanel`: 선택된 장비 상세 정보
- `_buildStatsGrid`: 스탯 표시 그리드

**상태 관리**:
```dart
EquipmentSlot mSelectedSlot;         // 선택된 슬롯 탭
EquipmentInstance? mSelectedEquipment;  // 선택된 장비
```

### 4.8 FusionScreen (StatefulWidget) - Phase 2

**역할**: 장비 합성 UI

**구성 요소**:
- `_buildFusionSlots`: 재료 3개 + 결과 슬롯 표시
- `_buildFusionButton`: 합성 실행 버튼
- `_buildMaterialSelection`: 재료 선택 그리드
- `_buildMaterialCard`: 개별 재료 카드

**상태 관리**:
```dart
List<EquipmentInstance> mSelectedMaterials;  // 선택된 재료 (최대 3개)
EquipmentSlot? mFilterSlot;                   // 슬롯 필터
EquipmentRarity? mFilterRarity;               // 등급 필터
EquipmentInstance? mFusionResult;             // 합성 결과
```

**합성 규칙**:
- 동일 슬롯 + 동일 등급 장비 3개 필요
- 상위 등급 장비 1개 획득
- Legendary는 합성 불가 (최상위)
- 장착 중인 장비는 합성 불가

### 4.9 ChallengeSystem (Phase 2)

**역할**: 도전 모드 관리, 진행 상태, 클리어/보상 처리

```dart
class ChallengeSystem {
  ChallengeData? mCurrentChallenge;  // 현재 진행 중인 도전
  bool mIsInChallengeMode;

  // 진행 상태
  int mCurrentWave;
  int mKillCount;
  double mElapsedTime;
  int mBossKillCount;

  int get playerLevel => ProgressSystem.instance.playerLevel;  // 계정 레벨 연동

  bool StartChallenge(String challengeId);  // 도전 시작
  void Update(double dt);                   // 매 프레임 업데이트 (클리어 조건 체크)
  void AddKill({bool isBoss = false});      // 킬 카운트 증가
  void AdvanceWave();                       // 웨이브 진행

  bool IsUnlocked(ChallengeData challenge); // 해금 여부 (레벨 + 선행 도전)
  ChallengeStatus GetStatus(ChallengeData); // 잠금/가능/클리어 상태
  ChallengeRecord? GetRecord(String id);    // 기록 조회
}
```

**도전 타입 (4종)**:
- `Endless`: 무한 웨이브 버티기
- `BossRush`: 보스 연속 처치
- `TimeAttack`: 시간 내 처치 수
- `Survival`: 생존 시간

### 4.10 ProgressSystem (Phase 2)

**역할**: 영구 진행 데이터 저장/불러오기 (SharedPreferences 기반)

```dart
class ProgressSystem {
  static ProgressSystem get instance;  // 싱글톤

  ProgressData _data;  // 전체 진행 데이터

  int get playerLevel;  // 계정 레벨
  int get gold;         // 골드
  int get gems;         // 보석

  Future<void> Initialize();  // 저장 데이터 불러오기
  Future<void> Save();        // 저장

  Future<void> OnGameEnd({    // 게임 종료 시 호출
    required int playTime,
    required int kills,
    required bool isVictory,
    String? challengeId,
    int wave, int bossKills,
  });

  Future<void> AddCurrency({int gold, int gems});   // 재화 추가
  Future<bool> SpendCurrency({int gold, int gems}); // 재화 사용

  ChallengeRecordData? GetChallengeRecord(String id);  // 도전 기록 조회
  bool IsChallengeCleared(String challengeId);         // 클리어 여부
}
```

**경험치/골드 계산**:
- 기본 경험치: 10
- 처치 보너스: 10킬당 1exp
- 시간 보너스: 1분당 1exp
- 승리 보너스: 50exp
- 골드: 처치당 2골드 + 승리 보너스 100

### 4.11 ChallengeScreen (StatefulWidget) - Phase 2

**역할**: 도전 모드 선택 UI

**구성 요소**:
- `TabBar`: 도전 타입별 탭 (무한/보스러시/타임어택/서바이벌)
- `_buildTypeDescription`: 선택된 타입 설명
- `_buildChallengeList`: 도전 목록 (ListView)
- `_buildChallengeCard`: 개별 도전 카드 (잠금/클리어 상태, 난이도 별)
- `_showChallengeDetail`: 도전 상세/시작 다이얼로그

**상태 관리**:
```dart
TabController mTabController;
ChallengeType mSelectedType;  // 선택된 도전 타입
```

---

## 5. 데이터 모델

### 5.1 WeaponData

```dart
class WeaponData {
  final String id;
  final String name;
  final String description;
  final WeaponRarity rarity;
  final String baseSkillId;  // 무기에 내장된 스킬 ID
}
```

### 5.2 SkillData

```dart
class SkillData {
  final String id;
  final String name;
  final String description;
  final SkillCategory category;  // projectile, area, orbit, passive
  final SkillRarity rarity;
  final int maxLevel;

  // 스킬 속성
  final double baseDamage;
  final double baseCooldown;
  final double range;
  final double projectileSpeed;
  final bool piercing;
  final int pierceCount;
  final Color color;

  // 레벨별 스케일링 메서드
  double GetDamageAtLevel(int level);
  double GetCooldownAtLevel(int level);
  int GetProjectileCountAtLevel(int level);
}
```

### 5.3 정의된 스킬 목록

| 스킬 ID | 카테고리 | 등급 |
|---------|----------|------|
| skill_energy_bolt | Projectile | Common |
| skill_spinning_blade | Orbit | Common |
| skill_fire_burst | Area | Rare |
| skill_poison_arrow | Projectile | Rare |
| skill_chain_lightning | Projectile | Epic |
| skill_swift_boots | Passive | Common |
| skill_vital_heart | Passive | Common |
| skill_power_gauntlet | Passive | Rare |

### 5.4 정의된 무기 목록

| 무기 ID | 기본 스킬 | 등급 |
|---------|-----------|------|
| weapon_starter_wand | skill_energy_bolt | Common |
| weapon_spinning_sword | skill_spinning_blade | Common |
| weapon_fire_staff | skill_fire_burst | Rare |
| weapon_poison_bow | skill_poison_arrow | Rare |
| weapon_lightning_staff | skill_chain_lightning | Epic |

### 5.5 EquipmentData (Phase 2)

```dart
class EquipmentData {
  final String id;
  final String name;
  final String description;
  final EquipmentSlot slot;     // weapon, armor, accessory
  final EquipmentRarity rarity; // common ~ legendary
  final ActorStats bonusStats;  // 장착 시 추가 스탯
}

class EquipmentInstance {
  final EquipmentData data;
  int level;               // 강화 레벨
  bool isEquipped;

  ActorStats GetCurrentStats();  // 레벨 적용 스탯
  int GetMaxLevel();             // 등급별 최대 레벨
  bool CanUpgrade();             // 강화 가능 여부
}
```

### 5.6 정의된 장비 목록 (Phase 2)

| 장비 ID | 이름 | 슬롯 | 등급 | 주요 스탯 |
|---------|------|------|------|----------|
| equip_iron_sword | 철 검 | 무기 | Common | ATK+5 |
| equip_flame_blade | 화염 검 | 무기 | Rare | ATK+12, CRIT+5%, CDMG+20% |
| equip_thunder_staff | 번개 지팡이 | 무기 | Epic | ATK+20, SPD+0.2, CRIT+8% |
| equip_leather_armor | 가죽 갑옷 | 방어구 | Common | HP+20, DEF+3 |
| equip_knight_plate | 기사의 판금 갑옷 | 방어구 | Rare | HP+50, DEF+8 |
| equip_dragon_scale | 용린 갑옷 | 방어구 | Legendary | HP+100, ATK+5, DEF+15 |
| equip_speed_boots | 신속의 부츠 | 액세서리 | Common | SPD+0.3 |
| equip_critical_ring | 치명의 반지 | 액세서리 | Rare | CRIT+10%, CDMG+25% |
| equip_life_pendant | 생명의 펜던트 | 액세서리 | Epic | HP+80, DEF+5 |

### 5.7 ChallengeData (Phase 2)

```dart
class ChallengeData {
  final String id;
  final String name;
  final String description;
  final ChallengeType type;        // endless, bossRush, timeAttack, survival
  final ChallengeDifficulty difficulty;  // easy ~ hell
  final ChallengeCondition condition;    // 클리어 조건
  final ChallengeModifier modifier;      // 난이도 변경자
  final List<ChallengeReward> rewards;   // 클리어 보상
  final int unlockLevel;                 // 해금 레벨
  final String? prerequisiteId;          // 선행 도전 ID
}
```

### 5.8 정의된 도전 목록 (Phase 2)

| 도전 ID | 이름 | 타입 | 난이도 | 해금 레벨 | 클리어 조건 |
|---------|------|------|--------|-----------|-------------|
| endless_1 | 무한의 시련 | Endless | Easy | 1 | 웨이브 10 도달 |
| endless_2 | 끝없는 전쟁 | Endless | Hard | 5 | 웨이브 20 도달 |
| boss_rush_1 | 보스 사냥꾼 | BossRush | Normal | 3 | 보스 5마리 처치 |
| boss_rush_2 | 보스 학살자 | BossRush | Hard | 7 | 보스 10마리 처치 |
| time_attack_1 | 속도전 | TimeAttack | Easy | 2 | 60초 내 100킬 |
| time_attack_2 | 학살자 | TimeAttack | Normal | 4 | 90초 내 200킬 |
| survival_1 | 생존자 | Survival | Normal | 3 | 120초 생존 |
| survival_2 | 불사신 | Survival | Hell | 10 | 300초 생존 |

### 5.9 ProgressData (Phase 2)

```dart
class ProgressData {
  final AccountLevel accountLevel;           // 계정 레벨
  final CurrencyData currency;               // 재화 (골드, 보석)
  final Map<String, ChallengeRecordData> challengeRecords;  // 도전 기록
  final int totalPlayTime;                   // 총 플레이 시간
  final int totalKills;                      // 총 처치 수
  final int totalGamesPlayed;                // 총 게임 수
}

class AccountLevel {
  final int level;
  final int currentExp;
  final int totalExp;

  static int GetRequiredExpForLevel(int level);  // 100 + (level-1) * 50
  AccountLevel AddExp(int exp);                  // 레벨업 자동 처리
}

class ChallengeRecordData {
  final String challengeId;
  final bool isCleared;
  final int bestWave;
  final int bestKills;
  final int bestTime;
  final String? clearedAt;
}
```

---

## 6. 시스템 연동 흐름

### 6.1 게임 시작 흐름

```
[VamGame.onLoad()]
    │
    ├── 시스템 초기화
    │   ├── CombatSystem
    │   ├── SpawnSystem
    │   ├── WaveSystem
    │   ├── LevelSystem
    │   ├── WeaponSystem
    │   └── SkillSystem
    │
    ├── weaponSystem.EquipWeapon('weapon_starter_wand')
    │   ├── skillSystem.AddSkill('skill_energy_bolt')
    │   └── levelSystem.mAcquiredSkills['skill_energy_bolt'] = 1
    │
    ├── 컴포넌트 생성
    │   ├── TiledBackground
    │   ├── Player
    │   └── JoystickController
    │
    └── 카메라 설정 (player 팔로우)
```

### 6.2 레벨업 흐름

```
[Player.AddExp()]
    │
    ▼
[경험치 >= 필요량?]
    │ Yes
    ▼
[Player.LevelUp()]
    │
    ▼
[game.OnPlayerLevelUp()]
    │
    ▼
[game.PauseGame()]
    │
    ▼
[overlays.add('SkillSelect')]
    │
    ▼
[SkillSelectOverlay 표시]
    │
    ▼
[사용자 스킬 선택]
    │
    ▼
[game.OnSkillSelected(skillId)]
    │
    ├── levelSystem.ApplySkill(skillId)
    │   ├── mAcquiredSkills[skillId] = level
    │   ├── skillSystem.AddSkill(skillId, level)
    │   └── player.AddSkill(skillId, level)
    │
    └── game.ResumeGame()
```

### 6.3 스킬 발동 흐름

```
[VamGame.update(dt)]
    │
    ▼
[skillSystem.Update(dt)]
    │
    ├── 각 EquippedSkill 순회
    │   ├── Passive: 건너뜀 (항상 적용 중)
    │   ├── Orbit: 건너뜀 (OrbitWeapon이 처리)
    │   └── Projectile/Area:
    │       ├── 쿨다운 감소
    │       └── 쿨다운 <= 0 → _fireSkill()
    │
    ├── _fireProjectileSkill()
    │   ├── 가장 가까운 몬스터 탐색
    │   ├── SkillProjectile 생성
    │   └── world.add(projectile)
    │
    └── _fireAreaSkill()
        ├── 범위 내 몬스터 탐색
        ├── 데미지 적용
        └── AreaEffectComponent 표시
```

### 6.4 도전 모드 흐름 (Phase 2)

```
[메인 로비]
    │
    ├── ProgressSystem.Initialize()
    │   └── SharedPreferences에서 저장 데이터 불러오기
    │
    ▼
[도전 모드 버튼 클릭]
    │
    ▼
[ChallengeScreen]
    │
    ├── 도전 타입 탭 선택
    ├── challengeSystem.GetStatus() → 잠금/가능/클리어 표시
    │
    ▼
[도전 선택 → 캐릭터 선택]
    │
    ▼
[GameScreen(characterId, challengeId)]
    │
    ├── VamGame 생성
    ├── challengeSystem.StartChallenge(challengeId)
    │   ├── 변경자 적용 (스폰 속도, 적 강화 등)
    │   └── 진행 상태 초기화
    │
    ▼
[게임 플레이]
    │
    ├── challengeSystem.Update(dt)
    │   ├── 클리어 조건 체크
    │   └── 시간 초과 체크 (타임어택)
    │
    ├── 클리어 시:
    │   ├── _grantRewards() → 보상 지급
    │   ├── _saveProgress() → 기록 저장
    │   └── game.Victory()
    │
    └── 실패 시:
        ├── _saveProgress() → 기록 저장 (최고 기록)
        └── game.GameOver()
```

### 6.5 영구 진행 데이터 흐름 (Phase 2)

```
[앱 시작]
    │
    ▼
[MainLobbyScreen]
    │
    ├── ProgressSystem.Initialize()
    │   └── SharedPreferences.getString('vam_progress_data')
    │       └── ProgressData.FromJson()
    │
    ├── _buildTopBar()
    │   ├── 레벨 뱃지 (accountLevel.level)
    │   ├── 경험치 바 (accountLevel.progress)
    │   ├── 골드 표시 (currency.gold)
    │   └── 보석 표시 (currency.gems)
    │
    ▼
[게임 종료]
    │
    ▼
[ProgressSystem.OnGameEnd()]
    │
    ├── 경험치 계산 (기본 + 킬 + 시간 + 승리)
    ├── 골드 계산 (킬 + 승리)
    ├── accountLevel.AddExp() → 레벨업 처리
    ├── 도전 기록 업데이트 (최고 기록, 클리어 여부)
    │
    └── Save()
        └── SharedPreferences.setString()
```

---

## 7. 개발 로드맵 진행 현황

### 7.1 MVP (Phase 1) - 완료 ✅

| 항목 | 상태 | 설명 |
|------|------|------|
| 화면 시스템 | ✅ 완료 | 해상도 대응, SafeArea |
| 플레이어 이동 | ✅ 완료 | 조이스틱 컨트롤 |
| 자동 공격 시스템 | ✅ 완료 | SkillSystem 기반 |
| 몬스터 스폰 시스템 | ✅ 완료 | 시간 기반 스폰 |
| 데미지 계산 및 적용 | ✅ 완료 | CombatSystem |
| 경험치 시스템 | ✅ 완료 | ExpGem 획득 |
| 레벨업 스킬 선택 | ✅ 완료 | SkillSelectOverlay |
| 기본 스킬 5종 + 패시브 3종 | ✅ 완료 | SkillData |
| 보스 전투 | ✅ 완료 | FinalBoss 페이즈 |
| 스테이지 클리어 | ✅ 완료 | Victory 화면 |

### 7.2 Phase 2 - 진행 중 🚧

| 항목 | 상태 | 설명 |
|------|------|------|
| 캐릭터 시스템 | ✅ 완료 | 5개 캐릭터, 선택 UI |
| 장비 시스템 | ✅ 완료 | 장비 인벤토리, 장착/해제, 9개 장비 |
| 장비 강화 | ✅ 완료 | 레벨업 강화 (등급별 최대 레벨) |
| 장비 관리 UI | ✅ 완료 | 탭 기반 슬롯 선택, 상세 정보 패널 |
| 장비 드롭 | ✅ 완료 | 확률 기반 랜덤 드롭 시스템 |
| 장비 합성 | ✅ 완료 | 동일 등급 3개 → 상위 등급 합성 |
| 장비 합성 UI | ✅ 완료 | 재료 선택, 합성 실행, 결과 표시 |
| 도전 콘텐츠 | ✅ 완료 | 4종 도전 모드 (무한/보스러시/타임어택/서바이벌) |
| 진행 시스템 | ✅ 완료 | 계정 레벨, 재화, 도전 기록 영구 저장 |
| 순찰/상점 | ✅ 완료 | 방치형 보상, 상점 (Phase 2.2) |

### 7.3 정의된 캐릭터 목록 (Phase 2)

| 캐릭터 ID | 이름 | 등급 | 기본 무기 | 특징 |
|-----------|------|------|----------|------|
| char_commando | 특공대원 | Common | 에너지 볼트 | 균형 잡힌 스탯 |
| char_swordsman | 검사 | Common | 회전 검 | 높은 ATK/CRIT |
| char_pyromancer | 화염 마법사 | Rare | 화염 폭발 | 범위 공격 |
| char_archer | 궁수 | Rare | 독 화살 | 빠른 이동/관통 |
| char_stormcaller | 번개 마법사 | Epic | 번개 연쇄 | 연쇄 공격 |

### 7.4 게임 흐름 (업데이트)

```
[메인 로비]
    │
    ├── ProgressSystem.Initialize() 호출
    ├── 상단바: 레벨/경험치/골드/보석 표시
    │
    ├── [게임 시작 버튼]
    │   │
    │   ▼
    │   [캐릭터 선택 화면]
    │       ├── 캐릭터 카드 리스트 (가로 스크롤)
    │       ├── 캐릭터 상세 정보 (스탯, 무기, 설명)
    │       └── 시작 버튼
    │
    └── [도전 모드 버튼]
        │
        ▼
        [ChallengeScreen]
            ├── 도전 타입 탭 (무한/보스러시/타임어택/서바이벌)
            ├── 도전 목록 (잠금/가능/클리어 상태)
            └── 도전 선택 → 캐릭터 선택 화면
    │
    ▼
[게임 시작]
    │
    ├── VamGame(characterId, challengeId?)
    ├── 캐릭터별 기본 무기 장착
    ├── 캐릭터별 스탯/색상 적용
    ├── (도전 모드) 변경자 적용
    │
    ▼
[게임 플레이]
    │
    ├── 일반 모드: Wave1 (60초) → MidBoss → Wave2 (70초) → FinalBoss
    ├── 도전 모드: 도전별 규칙 (웨이브/보스/타임어택/서바이벌)
    │
    ▼
[게임 종료]
    │
    ├── ProgressSystem.OnGameEnd() → 경험치/골드/기록 저장
    └── Victory / GameOver 화면
```

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|-----------|
| 1.0 | 2025-12-06 | 최초 작성 - 무기/스킬 시스템, UI 구현 완료 |
| 1.1 | 2025-12-06 | Phase 2 캐릭터 시스템 추가 (캐릭터 선택 UI, 5개 캐릭터 정의) |
| 1.2 | 2025-12-06 | Phase 2 장비 시스템 추가 (장비 데이터, 시스템, UI, 9개 장비 정의) |
| 1.3 | 2025-12-06 | Phase 2 장비 합성 추가 (합성 로직, 합성 UI) |
| 1.4 | 2025-12-06 | Phase 2 도전/진행 시스템 추가 (ChallengeSystem, ProgressSystem) |
| 1.5 | 2025-12-06 | 버그 수정: 레벨업/도전모드/결과화면/로비UI/회전무기 수정 |
| 1.6 | 2025-12-06 | 장비 시스템 아키텍처 변경: 영구 저장, 로비 UI, 스킬 기반 캐릭터 |
| 1.7 | 2025-12-06 | 순찰/상점 시스템 구현, 스킬 레벨 합산 버그 수정 |

---

## 8. 버그 수정 이력

### 8.1 레벨업 시스템 버그 수정

**문제**: 일반 게임 모드에서 레벨업이 되지 않음

**원인**: `ProgressSystem.OnGameEnd()`가 `ChallengeSystem`에서만 호출되고 일반 모드에서는 호출되지 않음

**수정 파일**: `lib/game/vam_game.dart`

**수정 내용**:
```dart
void GameOver() {
  mIsGameOver = true;
  pauseEngine();

  // 일반 모드일 때만 ProgressSystem에 기록 (도전 모드는 ChallengeSystem이 처리)
  if (!challengeSystem.isInChallengeMode) {
    _saveProgress(isVictory: false);
  }

  onGameOver?.call();
}

void _saveProgress({required bool isVictory}) {
  ProgressSystem.instance.OnGameEnd(
    playTime: mElapsedTime.toInt(),
    kills: mKillCount,
    isVictory: isVictory,
  );
}
```

### 8.2 도전 모드 클리어 버그 수정

**문제**: 무한 웨이브 도전 모드에서 클리어 조건을 충족해도 클리어되지 않음

**원인**: `AdvanceWave()` 메서드가 정의만 되어 있고 실제로 호출되지 않아 `mCurrentWave`가 항상 0

**수정 파일**: `lib/game/systems/challenge_system.dart`

**수정 내용**:
```dart
// 웨이브 타이머 (무한 모드용)
double mWaveTimer = 0;
static const double WAVE_INTERVAL = 30.0;  // 30초마다 웨이브 증가

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
      final newInterval = 0.5 - (mCurrentWave * 0.02);
      mGame.spawnSystem.SetSpawnInterval(newInterval.clamp(0.1, 0.5));
    }
  }

  // 클리어/시간초과 체크...
}
```

### 8.3 결과 화면 계정 정보 누락 수정

**문제**: 게임 오버/승리 화면에 획득 경험치/골드/레벨업 정보가 표시되지 않음

**수정 파일**:
- `lib/game/systems/progress_system.dart`
- `lib/presentation/overlays/game_over_overlay.dart`

**수정 내용**:

1. `progress_system.dart`에 게임 결과 데이터 클래스 추가:
```dart
// 마지막 게임 결과 (결과창 표시용)
GameEndResult? mLastGameResult;

class GameEndResult {
  final int expGained;
  final int goldGained;
  final int previousLevel;
  final int newLevel;
  final bool leveledUp;
  final int currentExp;
  final int requiredExp;
}
```

2. `game_over_overlay.dart`에 계정 보상 섹션 추가:
```dart
Widget _buildAccountRewardSection() {
  final result = ProgressSystem.instance.mLastGameResult;
  if (result == null) return const SizedBox.shrink();

  return Container(
    // 레벨업 배너 (if leveledUp)
    // 획득 EXP/GOLD 표시
    // 현재 경험치 바
  );
}
```

### 8.4 로비 UI 갱신 버그 수정

**문제**: 게임 종료 후 로비로 돌아와도 레벨/경험치/재화 정보가 갱신되지 않음

**원인**: `CharacterSelectScreen`에서 `pushReplacement` 사용으로 `.then()` 콜백 체인이 끊김

**수정 파일**: `lib/presentation/screens/character_select_screen.dart`

**수정 내용**:
```dart
// 변경 전
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => GameScreen(...)),
);

// 변경 후
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => GameScreen(...)),
).then((_) {
  // 게임에서 돌아오면 로비로 돌아가기
  if (mounted) {
    Navigator.of(context).pop();
  }
});
```

### 8.5 회전 무기(OrbitWeapon) 회전 중심 버그 수정

**문제**: 회전칼(spinning blade)이 캐릭터 중심이 아닌 화면 원점(0,0)을 중심으로 회전

**원인**:
- OrbitWeapon이 Player의 자식 컴포넌트로 추가되고 상대 좌표로 위치 계산
- Flame 엔진에서 자식 컴포넌트의 충돌 히트박스가 부모의 transform을 제대로 상속받지 못함
- 렌더링은 따라가지만 실제 위치 및 충돌 감지는 로컬 좌표 기준으로 동작

**수정 파일**:
- `lib/game/components/weapons/orbit_weapon.dart`
- `lib/game/systems/skill_system.dart`

**수정 내용**:

1. `orbit_weapon.dart` - 플레이어 위치를 월드 좌표로 계산:
```dart
void _updatePosition() {
  // 플레이어 위치 기준 월드 좌표로 회전 위치 계산
  final playerPos = game.player.position;
  final x = cos(mCurrentAngle) * mOrbitRadius;
  final y = sin(mCurrentAngle) * mOrbitRadius;
  position = playerPos + Vector2(x, y);

  // 검 방향 회전
  angle = mCurrentAngle + pi / 2;
}
```

2. `skill_system.dart` - 월드에 직접 추가:
```dart
void _createOrbitWeapons(EquippedSkill skill) {
  for (int i = 0; i < count; i++) {
    final orbitWeapon = OrbitWeapon(...);
    // 변경 전: mGame.player.add(orbitWeapon);
    // 변경 후: 월드에 직접 추가
    mGame.world.add(orbitWeapon);
  }
}

void _updateOrbitWeapons(EquippedSkill skill) {
  // 월드에서 검색
  mGame.world.children
      .whereType<OrbitWeapon>()
      .where((w) => w.mSkillData.id == skill.skillData.id)
      .toList()
      .forEach((w) => w.removeFromParent());
  _createOrbitWeapons(skill);
}

void Reset() {
  // 월드에서 검색
  mGame.world.children
      .whereType<OrbitWeapon>()
      .toList()
      .forEach((w) => w.removeFromParent());
  // ...
}
```

### 8.6 장비/캐릭터 스킬 레벨 합산 버그 수정

**문제**: 철검 착용한 검사가 회전칼 2레벨로 시작해야 하는데 1레벨로 시작됨

**원인**: `InitializeStarterSkills()`에서 장비 스킬과 캐릭터 스킬이 같을 경우 조건문으로 캐릭터 스킬이 추가되지 않음

**문제 코드**:
```dart
// 장비 무기 스킬과 캐릭터 기본 스킬이 다르면 추가
if (characterSkillId != weaponSkillId) {
  skillSystem.AddSkill(characterSkillId, level: 1);  // 같은 스킬이면 실행 안됨!
}
```

**수정 파일**: `lib/game/vam_game.dart`

**수정 내용**:
```dart
void InitializeStarterSkills() {
  // 스킬별 레벨을 누적할 맵
  final Map<String, int> skillLevels = {};

  // 1. 장비 무기의 스킬 추가 (레벨 1)
  final weaponSkillId = ProgressSystem.instance.GetEquippedWeaponSkillId();
  if (weaponSkillId != null) {
    skillLevels[weaponSkillId] = (skillLevels[weaponSkillId] ?? 0) + 1;
  } else {
    const defaultWeaponSkillId = 'skill_energy_bolt';
    skillLevels[defaultWeaponSkillId] = (skillLevels[defaultWeaponSkillId] ?? 0) + 1;
  }

  // 2. 캐릭터 기본 스킬 추가 (레벨 1)
  // 장비 스킬과 같아도 레벨이 합산됨!
  final characterSkillId = mCharacterData.baseSkillId;
  skillLevels[characterSkillId] = (skillLevels[characterSkillId] ?? 0) + 1;

  // 3. 누적된 레벨로 스킬 적용
  for (final entry in skillLevels.entries) {
    final skillId = entry.key;
    final level = entry.value;
    skillSystem.AddSkill(skillId, level: level);
    levelSystem.mAcquiredSkills[skillId] = level;
  }

  // 4. 장비 스탯 보너스 적용
  _applyEquipmentBonuses();
}
```

**결과 예시**:

| 캐릭터 | 장비 | 결과 |
|--------|------|------|
| 검사 (`spinning_blade`) | 철검 (`spinning_blade`) | **회전칼 Lv.2** |
| 검사 (`spinning_blade`) | 지팡이 (`energy_bolt`) | 회전칼 Lv.1 + 에너지볼트 Lv.1 |
| 마법사 (`fire_burst`) | 화염검 (`fire_burst`) | **화염폭발 Lv.2** |

---

## 9. 장비 시스템 아키텍처 변경

### 9.1 변경 개요

**버전**: 1.6 (Phase 2.1)

**변경 목적**:
- 장비를 **영구적인 계정 성장 요소**로 전환 (기존: 게임 인스턴스 기반)
- 장비 관리 UI를 **로비**로 이동 (기존: 일시정지 메뉴)
- 캐릭터 시스템을 **무기 기반에서 스킬 기반**으로 변경

### 9.2 데이터 모델 변경

#### 9.2.1 새로운 데이터 클래스 (progress_data.dart)

```dart
/// 장비 인스턴스 데이터 (영구 저장용)
class EquipmentInstanceData {
  final String instanceId;    // 고유 인스턴스 ID
  final String equipmentId;   // 장비 템플릿 ID
  final int level;            // 강화 레벨

  EquipmentInstanceData({
    required this.instanceId,
    required this.equipmentId,
    this.level = 1,
  });

  // JSON 직렬화/역직렬화
  Map<String, dynamic> ToJson() => {...};
  factory EquipmentInstanceData.FromJson(Map<String, dynamic> json) => ...;
  EquipmentInstanceData copyWith({String? instanceId, String? equipmentId, int? level}) => ...;
}

/// 장비 진행 데이터 (ProgressData 내 포함)
class EquipmentProgressData {
  final List<EquipmentInstanceData> inventory;  // 보유 장비 목록
  final Map<String, String?> equippedIds;        // 슬롯별 장착 인스턴스 ID
  // equippedIds 키: 'weapon', 'armor', 'accessory'

  // CRUD 메서드
  EquipmentProgressData AddItem(EquipmentInstanceData item) => ...;
  EquipmentProgressData RemoveItem(String instanceId) => ...;
  EquipmentProgressData EquipItem(String instanceId, String slotKey) => ...;
  EquipmentProgressData UnequipItem(String slotKey) => ...;
  EquipmentProgressData UpgradeItem(String instanceId) => ...;
  String? GetEquippedWeaponId() => ...;  // 장착된 무기의 equipmentId 반환
}
```

#### 9.2.2 ProgressData 확장

```dart
class ProgressData {
  final AccountLevel accountLevel;
  final CurrencyData currency;
  final Map<String, ChallengeRecordData> challengeRecords;
  final EquipmentProgressData equipment;  // ⭐ 추가
  // ...
}
```

#### 9.2.3 EquipmentData 확장 (equipment_data.dart)

```dart
/// 장비 스탯 (단순화된 버전)
class EquipmentStats {
  final int hp;
  final int atk;
  final int def;
  const EquipmentStats({this.hp = 0, this.atk = 0, this.def = 0});
}

class EquipmentData {
  final EquipmentStats stats;   // ⭐ 변경: ActorStats → EquipmentStats
  final String? skillId;        // ⭐ 추가: 무기 전용 스킬 ID

  // bonusStats getter (하위 호환성)
  ActorStats get bonusStats => ActorStats(hp: stats.hp, atk: stats.atk, def: stats.def, ...);
}
```

#### 9.2.4 정의된 무기와 스킬 연결

| 장비 ID | 이름 | skillId | 설명 |
|---------|------|---------|------|
| equip_starter_wand | 초보자의 지팡이 | skill_energy_bolt | 기본 에너지 볼트 |
| equip_iron_sword | 철 검 | skill_spinning_blade | 회전 검 |
| equip_flame_blade | 화염 검 | skill_fire_burst | 화염 폭발 |
| equip_thunder_staff | 번개 지팡이 | skill_chain_lightning | 연쇄 번개 |
| equip_poison_bow | 독 활 | skill_poison_arrow | 독 화살 |

### 9.3 CharacterData 변경

#### 9.3.1 baseWeaponId → baseSkillId

```dart
// 변경 전
class CharacterData {
  final String baseWeaponId;  // 무기 ID
}

// 변경 후
class CharacterData {
  final String baseSkillId;   // 스킬 ID (직접 참조)
}
```

#### 9.3.2 캐릭터별 기본 스킬

| 캐릭터 ID | 이름 | 기존 (baseWeaponId) | 변경 후 (baseSkillId) |
|-----------|------|---------------------|----------------------|
| char_commando | 특공대원 | weapon_starter_wand | skill_energy_bolt |
| char_swordsman | 검사 | weapon_spinning_sword | skill_spinning_blade |
| char_pyromancer | 화염 마법사 | weapon_fire_staff | skill_fire_burst |
| char_archer | 궁수 | weapon_poison_bow | skill_poison_arrow |
| char_stormcaller | 번개 마법사 | weapon_lightning_staff | skill_chain_lightning |

### 9.4 ProgressSystem 장비 관리 기능

```dart
class ProgressSystem {
  // ==================== 장비 관리 ====================

  EquipmentProgressData get equipment => _data.equipment;
  List<EquipmentInstanceData> get equipmentInventory => _data.equipment.inventory;
  Map<String, String?> get equippedIds => _data.equipment.equippedIds;
  String? get equippedWeaponId => _data.equipment.GetEquippedWeaponId();

  /// 장비 추가 (인벤토리에)
  Future<void> AddEquipment(String equipmentId) async {...}

  /// 장비 제거 (인벤토리에서)
  Future<void> RemoveEquipment(String instanceId) async {...}

  /// 장비 장착
  Future<void> EquipItem(String instanceId, EquipmentSlot slot) async {...}

  /// 장비 해제
  Future<void> UnequipItem(EquipmentSlot slot) async {...}

  /// 장비 강화
  Future<void> UpgradeEquipment(String instanceId) async {...}

  /// 인스턴스 ID로 장비 조회
  EquipmentInstanceData? GetEquipmentByInstanceId(String instanceId) {...}

  /// 슬롯에 장착된 장비 조회
  EquipmentInstanceData? GetEquippedItem(EquipmentSlot slot) {...}

  /// 장착된 무기의 스킬 ID 반환
  String? GetEquippedWeaponSkillId() {
    final weaponId = _data.equipment.GetEquippedWeaponId();
    if (weaponId == null) return null;
    final equipmentData = DefaultEquipments.GetById(weaponId);
    return equipmentData?.skillId;
  }

  /// 초기 장비 설정 (신규 계정)
  Future<void> InitializeStarterEquipment() async {
    if (_data.equipment.inventory.isEmpty) {
      await AddEquipment('equip_starter_wand');
      // 초보자 지팡이 자동 장착
      final starterWand = _data.equipment.inventory.first;
      await EquipItem(starterWand.instanceId, EquipmentSlot.weapon);
    }
  }
}
```

### 9.5 게임 시작 시 초기 스킬 설정

#### 9.5.1 VamGame.InitializeStarterSkills()

```dart
/// 초기 스킬 설정 (장비 무기 스킬 + 캐릭터 기본 스킬)
void InitializeStarterSkills() {
  // 1. 장비 무기의 스킬 추가
  final weaponSkillId = ProgressSystem.instance.GetEquippedWeaponSkillId();
  if (weaponSkillId != null) {
    skillSystem.AddSkill(weaponSkillId, level: 1);
    levelSystem.mAcquiredSkills[weaponSkillId] = 1;  // ⭐ 습득 스킬로 등록
    Logger.game('Equipped weapon skill added: $weaponSkillId');
  } else {
    // 장비가 없으면 기본 무기 스킬 사용
    const defaultWeaponSkillId = 'skill_energy_bolt';
    skillSystem.AddSkill(defaultWeaponSkillId, level: 1);
    levelSystem.mAcquiredSkills[defaultWeaponSkillId] = 1;
  }

  // 2. 캐릭터 기본 스킬 추가
  final characterSkillId = mCharacterData.baseSkillId;
  // 장비 무기 스킬과 캐릭터 기본 스킬이 다르면 추가
  if (characterSkillId != weaponSkillId) {
    skillSystem.AddSkill(characterSkillId, level: 1);
    levelSystem.mAcquiredSkills[characterSkillId] = 1;  // ⭐ 습득 스킬로 등록
  }

  // 3. 장비 스탯 보너스 적용
  _applyEquipmentBonuses();
}
```

#### 9.5.2 장비 스탯 보너스 적용

```dart
void _applyEquipmentBonuses() {
  final progress = ProgressSystem.instance;

  for (final slot in EquipmentSlot.values) {
    final instance = progress.GetEquippedItem(slot);
    if (instance == null) continue;

    final equipmentData = DefaultEquipments.GetById(instance.equipmentId);
    if (equipmentData == null) continue;

    // 레벨에 따른 스탯 보너스 적용
    final levelMultiplier = 1.0 + (instance.level - 1) * 0.1;
    final stats = equipmentData.stats;

    player.mBaseStats = player.mBaseStats.copyWith(
      hp: player.mBaseStats.hp + (stats.hp * levelMultiplier).round(),
      atk: player.mBaseStats.atk + (stats.atk * levelMultiplier).round(),
      def: player.mBaseStats.def + (stats.def * levelMultiplier).round(),
    );
  }

  // HP 재계산
  player.mMaxHp = player.mBaseStats.hp;
  player.mCurrentHp = player.mMaxHp;
}
```

### 9.6 UI 변경 사항

#### 9.6.1 일시정지 메뉴에서 장비 관리 제거

**파일**: `pause_overlay.dart`

- `equipment_screen.dart` import 제거
- 장비 관리 버튼 제거
- 일시정지 메뉴는 **습득 스킬 목록 표시**에 집중

#### 9.6.2 로비에 장비 관리 버튼 추가

**파일**: `main_lobby_screen.dart`

```dart
// 초기화 시 초보자 장비 설정
Future<void> _initializeProgress() async {
  await ProgressSystem.instance.Initialize();
  await ProgressSystem.instance.InitializeStarterEquipment();  // ⭐ 추가
  // ...
}

// 장비 관리 버튼 추가
SizedBox(
  width: 240,
  height: 60,
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const EquipmentManagementScreen(),
        ),
      ).then((_) => setState(() {}));
    },
    icon: const Icon(Icons.shield, color: Colors.purple),
    label: const Text('장비 관리'),
    // ...
  ),
),
```

#### 9.6.3 새로운 EquipmentManagementScreen

**파일**: `equipment_management_screen.dart`

**특징**:
- `ProgressSystem` 기반 영구 저장 데이터 사용
- 슬롯 탭 (무기/방어구/장신구)
- 장착 중인 장비 표시
- 인벤토리 장비 목록 (슬롯별 필터링)
- 장착/해제 기능

```dart
class EquipmentManagementScreen extends StatefulWidget {
  // ...
}

class _EquipmentManagementScreenState extends State<EquipmentManagementScreen> {
  EquipmentSlot mSelectedSlot = EquipmentSlot.weapon;

  Widget _buildSlotTabs() { /* 슬롯 탭 UI */ }
  Widget _buildEquippedSection() { /* 장착 장비 표시 */ }
  Widget _buildInventorySection() { /* 인벤토리 목록 */ }
  Widget _buildEquipmentCard() { /* 장비 카드 */ }

  void _equipItem(EquipmentInstanceData instance) async {
    await ProgressSystem.instance.EquipItem(instance.instanceId, mSelectedSlot);
    setState(() {});
  }

  void _unequipItem() async {
    await ProgressSystem.instance.UnequipItem(mSelectedSlot);
    setState(() {});
  }
}
```

### 9.7 시스템 연동 흐름 (업데이트)

```
[앱 시작]
    │
    ▼
[MainLobbyScreen]
    │
    ├── ProgressSystem.Initialize()
    │   └── SharedPreferences에서 저장 데이터 불러오기
    │
    ├── ProgressSystem.InitializeStarterEquipment()
    │   └── 신규 계정이면 초보자 지팡이 지급 및 장착
    │
    ├── [장비 관리 버튼] → EquipmentManagementScreen
    │   ├── 슬롯별 인벤토리 표시
    │   ├── 장착/해제 (ProgressSystem에 저장)
    │   └── 로비로 복귀
    │
    └── [게임 시작] → CharacterSelectScreen → GameScreen
        │
        ▼
[VamGame.onLoad()]
    │
    ├── Player 생성
    │   └── game.InitializeStarterSkills() 호출
    │       │
    │       ├── 장비 무기 스킬 추가 (ProgressSystem에서 조회)
    │       │   └── levelSystem.mAcquiredSkills에 등록
    │       │
    │       ├── 캐릭터 기본 스킬 추가
    │       │   └── levelSystem.mAcquiredSkills에 등록
    │       │
    │       └── 장비 스탯 보너스 적용
    │           └── player.mBaseStats 업데이트
    │
    ▼
[게임 플레이]
    │
    ├── 일시정지 메뉴
    │   └── 습득 스킬 목록 표시 (장비/캐릭터 스킬 포함)
    │
    ▼
[게임 종료]
    └── 로비로 복귀 (장비는 영구 저장되어 유지)
```

### 9.8 기술적 변경 요약

| 항목 | 변경 전 | 변경 후 |
|------|---------|---------|
| 장비 저장 | 게임 인스턴스 (EquipmentSystem) | 영구 저장 (ProgressSystem) |
| 장비 관리 UI 위치 | 일시정지 메뉴 | 로비 |
| 캐릭터 기본 속성 | baseWeaponId (무기 ID) | baseSkillId (스킬 ID) |
| 게임 시작 스킬 | 1개 (무기 스킬) | 2개 (장비 무기 + 캐릭터 기본) |
| 스킬 습득 등록 | 레벨업 시에만 | 게임 시작 시에도 등록 |
| 장비 스탯 | ActorStats | EquipmentStats (단순화) |

### 9.9 관련 파일 목록

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `lib/data/models/progress_data.dart` | 수정 | EquipmentInstanceData, EquipmentProgressData 추가 |
| `lib/data/models/equipment_data.dart` | 수정 | EquipmentStats, skillId 필드 추가 |
| `lib/data/models/character_data.dart` | 수정 | baseWeaponId → baseSkillId |
| `lib/game/systems/progress_system.dart` | 수정 | 장비 관리 CRUD 메서드 추가 |
| `lib/game/vam_game.dart` | 수정 | InitializeStarterSkills, _applyEquipmentBonuses 추가 |
| `lib/game/components/actors/player.dart` | 수정 | 초기 스킬 설정 호출 변경 |
| `lib/game/systems/weapon_system.dart` | 수정 | Reset() 자동 장착 제거 |
| `lib/presentation/screens/main_lobby_screen.dart` | 수정 | 장비 관리 버튼 추가 |
| `lib/presentation/screens/equipment_management_screen.dart` | 신규 | 로비용 장비 관리 화면 |
| `lib/presentation/screens/character_select_screen.dart` | 수정 | baseSkillId 사용 |
| `lib/presentation/overlays/pause_overlay.dart` | 수정 | 장비 관리 버튼 제거 |

---

## 10. 순찰/상점 시스템

### 10.1 개요

**버전**: 1.7 (Phase 2.2)

**구현 목적**:
- **순찰 시스템**: 오프라인/방치형 보상 획득 (골드, 경험치, 장비)
- **상점 시스템**: 골드/보석으로 아이템 구매

### 10.2 순찰 시스템

#### 10.2.1 데이터 모델 (patrol_data.dart)

```dart
/// 순찰 지역 열거형
enum PatrolZone {
  forest,    // 숲
  cave,      // 동굴
  ruins,     // 폐허
  volcano,   // 화산
  abyss,     // 심연
}

/// 순찰 지역 데이터
class PatrolZoneData {
  final PatrolZone zone;
  final String name;
  final String description;
  final int unlockLevel;       // 해금 레벨
  final int goldPerMinute;     // 분당 골드 획득
  final int expPerMinute;      // 분당 경험치 획득
  final double equipDropChance; // 시간당 장비 드롭 확률
  final List<String> possibleEquipments;  // 드롭 가능 장비 ID
}

/// 순찰 진행 데이터 (영구 저장)
class PatrolProgressData {
  final PatrolZone? activeZone;       // 현재 순찰 중인 지역
  final String? patrolStartTime;      // 순찰 시작 시간 (ISO8601)
  final String? lastCollectTime;      // 마지막 보상 수령 시간
  final int accumulatedGold;          // 누적 골드 (수령 전)
  final int accumulatedExp;           // 누적 경험치 (수령 전)
  final List<String> accumulatedEquipmentIds;  // 누적 장비 ID 목록

  // 메서드
  PatrolProgressData StartPatrol(PatrolZone zone);
  PatrolProgressData StopPatrol();
  PatrolProgressData UpdateRewards(int gold, int exp, List<String> equipIds);
  PatrolProgressData ClearRewards();
  PatrolProgressData ChangeZone(PatrolZone newZone);
  int GetMinutesSinceLastCollect();
}
```

#### 10.2.2 순찰 지역 정의

| 지역 | 해금 레벨 | 골드/분 | 경험치/분 | 장비 확률/시간 | 드롭 장비 |
|------|----------|--------|----------|---------------|----------|
| 숲 | Lv.1 | 5 | 2 | 5% | 철검, 가죽갑옷, 신속부츠 |
| 동굴 | Lv.5 | 10 | 4 | 10% | 철검, 화염검, 기사갑옷 |
| 폐허 | Lv.10 | 15 | 6 | 15% | 화염검, 기사갑옷, 치명반지 |
| 화산 | Lv.15 | 25 | 10 | 20% | 번개지팡이, 생명펜던트, 용린갑옷 |
| 심연 | Lv.20 | 40 | 15 | 25% | 전 장비 드롭 가능 |

#### 10.2.3 ProgressSystem 순찰 기능

```dart
class ProgressSystem {
  // 순찰 관련 getter
  PatrolProgressData get patrol => _data.patrol;
  bool get isPatrolling => _data.patrol.activeZone != null;
  PatrolZone? get activePatrolZone => _data.patrol.activeZone;

  // 지역 해금 여부
  bool IsPatrolZoneUnlocked(PatrolZone zone);

  // 순찰 시작/중지/변경
  Future<void> StartPatrol(PatrolZone zone);
  Future<void> StopPatrol();
  Future<void> ChangePatrolZone(PatrolZone newZone);

  // 보상 계산 및 수령
  PatrolRewardResult CalculatePatrolRewards();
  Future<PatrolRewardResult> CollectPatrolRewards();
}

/// 순찰 보상 결과
class PatrolRewardResult {
  final int gold;
  final int exp;
  final List<String> equipmentIds;
  bool get hasRewards => gold > 0 || exp > 0 || equipmentIds.isNotEmpty;
}
```

#### 10.2.4 PatrolScreen UI

**파일**: `lib/presentation/screens/patrol_screen.dart`

**구성 요소**:
- `_buildCurrentPatrolSection`: 현재 순찰 상태 표시
- `_buildActivePatrolCard`: 활성 순찰 카드 (경과 시간, 보상률)
- `_buildRewardSection`: 대기 중인 보상 표시 + 수령 버튼
- `_buildZoneList`: 순찰 지역 목록
- `_buildZoneCard`: 지역 카드 (잠금/해금/진행 중 상태)
- `_showZoneDetailDialog`: 지역 상세 다이얼로그

**기능**:
- 1초마다 Timer로 UI 업데이트 (누적 보상 계산)
- 순찰 시작/중지/지역 변경
- 보상 수령 (골드, 경험치, 장비)

### 10.3 상점 시스템

#### 10.3.1 데이터 모델 (shop_data.dart)

```dart
/// 상점 아이템 타입
enum ShopItemType {
  equipment,  // 장비
  currency,   // 재화 (골드 ↔ 보석)
  special,    // 특수 아이템
}

/// 결제 타입
enum PriceType {
  gold,   // 골드
  gems,   // 보석
  free,   // 무료
}

/// 상점 아이템 데이터
class ShopItemData {
  final String id;
  final String name;
  final String description;
  final ShopItemType type;
  final PriceType priceType;
  final int price;
  final String? equipmentId;   // 장비 ID (장비 타입)
  final int? goldAmount;       // 골드량 (재화 타입)
  final int? gemsAmount;       // 보석량 (재화 타입)
  final int? expAmount;        // 경험치량
  final int purchaseLimit;     // 구매 제한 (0 = 무제한)
  final bool isDailyReset;     // 일일 초기화 여부
}

/// 상점 탭
enum ShopTab {
  featured,   // 추천
  equipment,  // 장비
  currency,   // 재화
  special,    // 특수
}

/// 상점 구매 기록 (영구 저장)
class ShopPurchaseRecord {
  final String itemId;
  final int purchaseCount;
  final String? lastPurchaseDate;  // ISO8601

  int GetTodayPurchaseCount();  // 오늘 구매 횟수
  ShopPurchaseRecord AddPurchase();
  ShopPurchaseRecord ResetDaily();
}

/// 상점 진행 데이터
class ShopProgressData {
  final Map<String, ShopPurchaseRecord> purchaseRecords;

  bool CanPurchase(ShopItemData item);
  int GetRemainingPurchases(ShopItemData item);
  ShopProgressData RecordPurchase(String itemId);
}
```

#### 10.3.2 상점 아이템 정의

**추천 (일일 상점)**:

| ID | 이름 | 가격 | 보상 | 제한 |
|----|------|------|------|------|
| daily_free_gold | 무료 골드 | 무료 | 골드 100 | 일일 1회 |
| daily_gold_pack | 일일 골드 팩 | 보석 10 | 골드 500 | 일일 3회 |
| daily_exp_boost | 경험치 부스터 | 보석 20 | 경험치 100 | 일일 2회 |

**장비 상점**:

| ID | 이름 | 가격 | 장비 |
|----|------|------|------|
| shop_starter_wand | 초보자의 지팡이 | 골드 200 | equip_starter_wand |
| shop_iron_sword | 철 검 | 골드 300 | equip_iron_sword |
| shop_leather_armor | 가죽 갑옷 | 골드 250 | equip_leather_armor |
| shop_speed_boots | 신속의 부츠 | 골드 200 | equip_speed_boots |
| shop_flame_blade | 화염 검 | 보석 50 | equip_flame_blade |
| shop_knight_plate | 기사의 판금 갑옷 | 보석 45 | equip_knight_plate |
| shop_critical_ring | 치명의 반지 | 보석 40 | equip_critical_ring |

**재화 상점**:

| ID | 이름 | 가격 | 보상 |
|----|------|------|------|
| gold_pack_small | 골드 팩 (소) | 보석 10 | 골드 300 |
| gold_pack_medium | 골드 팩 (중) | 보석 25 | 골드 800 |
| gold_pack_large | 골드 팩 (대) | 보석 50 | 골드 2000 |
| gems_pack_starter | 보석 스타터 팩 | 골드 1000 | 보석 10 |

**특수 상점**:

| ID | 이름 | 가격 | 효과 |
|----|------|------|------|
| random_equipment | 랜덤 장비 상자 | 보석 30 | 랜덤 장비 1개 |
| rare_equipment_box | 희귀 장비 상자 | 보석 80 | 희귀+ 등급 장비 1개 |

#### 10.3.3 ProgressSystem 상점 기능

```dart
class ProgressSystem {
  // 상점 관련 getter
  ShopProgressData get shop => _data.shop;

  // 구매 가능 여부/남은 횟수
  bool CanPurchaseItem(ShopItemData item);
  int GetRemainingPurchases(ShopItemData item);

  // 아이템 구매
  Future<ShopPurchaseResult> PurchaseItem(ShopItemData item);
}

/// 구매 결과
class ShopPurchaseResult {
  final bool success;
  final String message;
}
```

#### 10.3.4 ShopScreen UI

**파일**: `lib/presentation/screens/shop_screen.dart`

**구성 요소**:
- `TabController`: 4개 탭 (추천/장비/재화/특수)
- `_buildCurrencyBar`: 상단 재화 표시 (골드, 보석)
- `_buildItemGrid`: 아이템 그리드 (GridView)
- `_buildShopItemCard`: 개별 아이템 카드
- `_buildPriceButton`: 가격 버튼 (무료/골드/보석)
- `_showItemDetailDialog`: 아이템 상세 다이얼로그 + 구매

### 10.4 ProgressData 확장

```dart
class ProgressData {
  final AccountLevel accountLevel;
  final CurrencyData currency;
  final Map<String, ChallengeRecordData> challengeRecords;
  final EquipmentProgressData equipment;
  final PatrolProgressData patrol;   // ⭐ 추가
  final ShopProgressData shop;       // ⭐ 추가
  // ...

  ProgressData UpdatePatrol(PatrolProgressData newPatrol);
  ProgressData UpdateShop(ShopProgressData newShop);
}
```

### 10.5 로비 UI 변경

**파일**: `lib/presentation/screens/main_lobby_screen.dart`

```dart
// 순찰 / 상점 버튼 (가로 배치)
SizedBox(
  width: 240,
  child: Row(
    children: [
      // 순찰 버튼
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(PatrolScreen),
          icon: Icon(Icons.explore, color: Colors.green),
          label: Text('순찰'),
        ),
      ),
      SizedBox(width: 12),
      // 상점 버튼
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(ShopScreen),
          icon: Icon(Icons.storefront, color: Colors.orange),
          label: Text('상점'),
        ),
      ),
    ],
  ),
),
```

### 10.6 관련 파일 목록

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `lib/data/models/patrol_data.dart` | 신규 | 순찰 지역, 보상, 진행 데이터 |
| `lib/data/models/shop_data.dart` | 신규 | 상점 아이템, 구매 기록 데이터 |
| `lib/data/models/progress_data.dart` | 수정 | patrol, shop 필드 추가 |
| `lib/game/systems/progress_system.dart` | 수정 | 순찰/상점 관리 메서드 추가 |
| `lib/presentation/screens/patrol_screen.dart` | 신규 | 순찰 화면 UI |
| `lib/presentation/screens/shop_screen.dart` | 신규 | 상점 화면 UI |
| `lib/presentation/screens/main_lobby_screen.dart` | 수정 | 순찰/상점 버튼 추가 |
