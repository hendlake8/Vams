# 뱀서라이크 슈팅 게임 구현 내역서

> 문서 버전: 1.1
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

### 2.4 데이터 모델

| 모델 | 파일 | 상태 | 설명 |
|------|------|------|------|
| 스킬 데이터 | `skill_data.dart` | ✅ 완료 | 8개 스킬 정의 (5 공격 + 3 패시브) |
| 무기 데이터 | `weapon_data.dart` | ✅ 완료 | 5개 무기 정의 (스킬 연결) |
| 캐릭터 데이터 | `character_data.dart` | ✅ 완료 | 5개 캐릭터 정의 (Phase 2) |
| 액터 스탯 | `actor_stats.dart` | ✅ 완료 | 공통 스탯 구조 |
| 몬스터 모델 | `monster_model.dart` | ✅ 완료 | 몬스터 데이터 |

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
│   ├── actor_stats.dart
│   ├── character_model.dart
│   ├── monster_model.dart
│   └── skill_model.dart
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
│       ├── combat_system.dart
│       ├── spawn_system.dart
│       └── wave_system.dart
│
└── presentation/                      # UI 레이어
    ├── screens/
    │   ├── main_lobby_screen.dart
    │   ├── character_select_screen.dart  # 캐릭터 선택 ⭐ (Phase 2)
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

**역할**: 일시정지 화면 + 습득 스킬 목록

**구성 요소**:
- `_AcquiredSkillsPanel`: 습득 스킬 그리드 표시
- `_SkillItem`: 개별 스킬 아이템
- `_MenuButton`: 메뉴 버튼 (계속/재시작/나가기)

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
| 장비 시스템 | 📋 예정 | 장비 장착/해제 |
| 장비 강화/합성 | 📋 예정 | 레벨업, 등급 합성 |
| 도전 콘텐츠 | 📋 예정 | 도전 스테이지 |
| 순찰/상점 | 📋 예정 | 방치형 보상, 상점 |

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
    ▼
[캐릭터 선택 화면] ← Phase 2 추가
    │
    ├── 캐릭터 카드 리스트 (가로 스크롤)
    ├── 캐릭터 상세 정보 (스탯, 무기, 설명)
    └── 시작 버튼
    │
    ▼
[게임 시작]
    │
    ├── VamGame(characterId)
    ├── 캐릭터별 기본 무기 장착
    ├── 캐릭터별 스탯/색상 적용
    │
    ▼
[게임 플레이]
    │
    ├── Wave1 (60초) → MidBoss → Wave2 (70초) → FinalBoss
    │
    ▼
[보스 처치 → Victory / 사망 → GameOver]
```

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|-----------|
| 1.0 | 2025-12-06 | 최초 작성 - 무기/스킬 시스템, UI 구현 완료 |
| 1.1 | 2025-12-06 | Phase 2 캐릭터 시스템 추가 (캐릭터 선택 UI, 5개 캐릭터 정의) |
