# 뱀서라이크 슈팅 게임 구현 설계서

> 문서 버전: 1.0
> 작성일: 2025-12-06
> 기반 문서: INGAME_DESIGN_DOCUMENT.md

---

## 목차

1. [프로젝트 구조](#1-프로젝트-구조)
2. [리소스 관리 시스템](#2-리소스-관리-시스템)
3. [핵심 시스템 설계](#3-핵심-시스템-설계)
4. [게임 오브젝트 설계](#4-게임-오브젝트-설계)
5. [UI 시스템 설계](#5-ui-시스템-설계)
6. [데이터 관리 설계](#6-데이터-관리-설계)
7. [상태 관리 설계](#7-상태-관리-설계)
8. [구현 로드맵](#8-구현-로드맵)

---

## 1. 프로젝트 구조

### 1.1 디렉토리 구조

```
vam_1/
├── lib/                              # Dart 소스 코드
│   ├── main.dart                     # 앱 진입점
│   │
│   ├── core/                         # 핵심 유틸리티
│   │   ├── constants/                # 상수 정의
│   │   │   ├── game_constants.dart   # 게임 상수
│   │   │   ├── asset_paths.dart      # 리소스 경로 상수
│   │   │   └── design_constants.dart # 디자인 상수 (해상도, 색상)
│   │   ├── utils/                    # 유틸리티 함수
│   │   │   ├── math_utils.dart       # 수학 유틸리티
│   │   │   ├── screen_utils.dart     # 화면/SafeArea 유틸리티
│   │   │   └── logger.dart           # 로깅 유틸리티
│   │   └── extensions/               # Dart 확장 메서드
│   │
│   ├── data/                         # 데이터 레이어
│   │   ├── models/                   # 데이터 모델
│   │   │   ├── character_model.dart
│   │   │   ├── equipment_model.dart
│   │   │   ├── skill_model.dart
│   │   │   ├── monster_model.dart
│   │   │   └── stage_model.dart
│   │   ├── repositories/             # 데이터 저장소
│   │   │   ├── game_repository.dart
│   │   │   └── user_repository.dart
│   │   └── tables/                   # 정적 데이터 테이블
│   │       ├── character_table.dart
│   │       ├── equipment_table.dart
│   │       ├── skill_table.dart
│   │       └── monster_table.dart
│   │
│   ├── game/                         # 게임 로직 (Flame 엔진)
│   │   ├── vam_game.dart             # 메인 게임 클래스
│   │   ├── components/               # 게임 컴포넌트
│   │   │   ├── actors/               # 액터 (캐릭터, 몬스터)
│   │   │   │   ├── player.dart
│   │   │   │   ├── monster.dart
│   │   │   │   ├── boss.dart
│   │   │   │   └── pet.dart
│   │   │   ├── weapons/              # 무기/스킬 발사체
│   │   │   │   ├── projectile.dart
│   │   │   │   ├── area_effect.dart
│   │   │   │   └── rotating_weapon.dart
│   │   │   ├── items/                # 드롭 아이템
│   │   │   │   ├── exp_gem.dart
│   │   │   │   ├── health_pickup.dart
│   │   │   │   └── gold_pickup.dart
│   │   │   └── effects/              # 이펙트
│   │   │       ├── damage_text.dart
│   │   │       └── hit_effect.dart
│   │   ├── systems/                  # 게임 시스템
│   │   │   ├── combat_system.dart    # 전투 시스템
│   │   │   ├── spawn_system.dart     # 몬스터 스폰 시스템
│   │   │   ├── wave_system.dart      # 웨이브 관리
│   │   │   ├── skill_system.dart     # 스킬 시스템
│   │   │   ├── level_system.dart     # 레벨업 시스템
│   │   │   └── collision_system.dart # 충돌 처리
│   │   ├── input/                    # 입력 처리
│   │   │   └── joystick_controller.dart
│   │   └── camera/                   # 카메라 시스템
│   │       └── game_camera.dart
│   │
│   ├── presentation/                 # UI 레이어
│   │   ├── screens/                  # 화면
│   │   │   ├── splash_screen.dart
│   │   │   ├── main_lobby_screen.dart
│   │   │   ├── game_screen.dart
│   │   │   ├── result_screen.dart
│   │   │   └── settings_screen.dart
│   │   ├── widgets/                  # 재사용 위젯
│   │   │   ├── common/               # 공통 위젯
│   │   │   ├── hud/                  # 인게임 HUD
│   │   │   │   ├── health_bar.dart
│   │   │   │   ├── exp_bar.dart
│   │   │   │   ├── skill_slots.dart
│   │   │   │   └── game_timer.dart
│   │   │   ├── dialogs/              # 다이얼로그
│   │   │   │   ├── skill_select_dialog.dart
│   │   │   │   ├── pause_dialog.dart
│   │   │   │   └── result_dialog.dart
│   │   │   └── lobby/                # 로비 위젯
│   │   └── overlays/                 # 게임 오버레이
│   │       ├── hud_overlay.dart
│   │       └── pause_overlay.dart
│   │
│   ├── services/                     # 서비스 레이어
│   │   ├── audio_service.dart        # 오디오 관리
│   │   ├── storage_service.dart      # 로컬 저장소
│   │   └── analytics_service.dart    # 분석
│   │
│   └── state/                        # 상태 관리
│       ├── providers/                # Provider/Riverpod
│       │   ├── game_state_provider.dart
│       │   ├── player_state_provider.dart
│       │   └── inventory_provider.dart
│       └── notifiers/                # ChangeNotifier
│
├── assets/                           # 프로젝트 사용 리소스
│   ├── images/                       # 이미지 리소스
│   │   ├── actors/                   # 액터 스프라이트
│   │   │   ├── heroes/               # 영웅 캐릭터
│   │   │   ├── monsters/             # 몬스터
│   │   │   ├── bosses/               # 보스
│   │   │   └── pets/                 # 펫
│   │   ├── weapons/                  # 무기/스킬 이미지
│   │   ├── effects/                  # 이펙트
│   │   ├── items/                    # 아이템
│   │   ├── ui/                       # UI 요소
│   │   │   ├── buttons/
│   │   │   ├── icons/
│   │   │   ├── frames/
│   │   │   └── backgrounds/
│   │   └── maps/                     # 맵 타일/배경
│   ├── audio/                        # 오디오 리소스
│   │   ├── bgm/                      # 배경음악
│   │   └── sfx/                      # 효과음
│   ├── fonts/                        # 폰트
│   └── data/                         # JSON 데이터
│       ├── characters.json
│       ├── equipment.json
│       ├── skills.json
│       ├── monsters.json
│       └── stages.json
│
├── OriginRes/                        # 원본 리소스 저장소
│   ├── Actor/                        # 액터 원본 리소스
│   │   ├── Heroes/                   # 영웅 원본
│   │   ├── Monsters/                 # 몬스터 원본
│   │   ├── Bosses/                   # 보스 원본
│   │   └── Pets/                     # 펫 원본
│   ├── InGameBG/                     # 인게임 배경 이미지 (타일링용)
│   ├── Weapons/                      # 무기 원본
│   ├── Effects/                      # 이펙트 원본
│   ├── Items/                        # 아이템 원본
│   ├── UI/                           # UI 원본
│   ├── Maps/                         # 맵 타일/오브젝트 원본
│   └── Audio/                        # 오디오 원본
│
├── android/                          # Android 네이티브
├── test/                             # 테스트 코드
└── pubspec.yaml                      # 의존성 정의
```

### 1.2 주요 의존성 패키지

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter

  # 게임 엔진
  flame: ^1.14.0                      # 2D 게임 엔진
  flame_audio: ^2.1.0                 # 오디오 처리

  # 상태 관리
  flutter_riverpod: ^2.4.0            # 상태 관리

  # 로컬 저장소
  shared_preferences: ^2.2.0          # 간단한 설정 저장
  hive: ^2.2.3                        # NoSQL 로컬 DB
  hive_flutter: ^1.1.0

  # 유틸리티
  uuid: ^4.2.0                        # 고유 ID 생성
  collection: ^1.18.0                 # 컬렉션 유틸리티

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.0
```

---

## 2. 리소스 관리 시스템

### 2.1 리소스 워크플로우

```
┌─────────────────────────────────────────────────────────────────┐
│                     리소스 관리 워크플로우                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [OriginRes/]              [assets/]              [Runtime]     │
│  원본 리소스 저장소    →    프로젝트 리소스    →    메모리 로드    │
│                                                                  │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐   │
│  │ Actor/       │      │ images/      │      │ SpriteCache  │   │
│  │  ├─Heroes/   │  복사  │  ├─actors/   │  로드  │              │   │
│  │  ├─Monsters/ │ ───→ │  ├─weapons/  │ ───→ │ AudioCache   │   │
│  │  └─Bosses/   │      │  └─effects/  │      │              │   │
│  └──────────────┘      └──────────────┘      └──────────────┘   │
│                                                                  │
│  • 원본은 Git에 포함 (버전 관리)                                  │
│  • Flutter 빌드에서는 제외 (pubspec.yaml 미등록)                  │
│  • 변환/최적화 후 assets로 복사하여 사용                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 OriginRes 빌드 제외 설정

#### 2.2.1 폴더 역할 분리

| 폴더 | Git 포함 | 빌드 포함 | 용도 |
|------|----------|-----------|------|
| `OriginRes/` | O | X | 원본 리소스 저장 (버전 관리용) |
| `assets/` | O | O | 실제 사용 리소스 (앱에 포함) |

#### 2.2.2 pubspec.yaml 설정

```yaml
# pubspec.yaml
# OriginRes는 등록하지 않음 → 빌드에서 자동 제외

flutter:
  assets:
    # assets 폴더만 등록 (OriginRes는 제외)
    - assets/images/actors/heroes/
    - assets/images/actors/monsters/
    - assets/images/actors/bosses/
    - assets/images/actors/pets/
    - assets/images/weapons/
    - assets/images/effects/
    - assets/images/items/
    - assets/images/ui/
    - assets/images/maps/
    - assets/audio/bgm/
    - assets/audio/sfx/
    - assets/data/

  # OriginRes는 여기에 등록하지 않음
  # → Flutter 빌드 시 APK/AAB에 포함되지 않음
```

#### 2.2.3 워크플로우

```
┌─────────────────────────────────────────────────────────────────┐
│                        리소스 워크플로우                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [아티스트/기획자]                                               │
│        │                                                         │
│        ▼                                                         │
│  ┌──────────────┐                                               │
│  │  OriginRes/  │  ← 원본 리소스 커밋 (Git 포함)                 │
│  │  (원본 저장) │  ← pubspec.yaml 미등록 (빌드 제외)             │
│  └──────────────┘                                               │
│        │                                                         │
│        │ 복사 스크립트 실행                                       │
│        ▼                                                         │
│  ┌──────────────┐                                               │
│  │   assets/    │  ← 사용 리소스 (Git 포함)                      │
│  │  (사용 리소스)│  ← pubspec.yaml 등록 (빌드 포함)              │
│  └──────────────┘                                               │
│        │                                                         │
│        ▼                                                         │
│  ┌──────────────┐                                               │
│  │   APK/AAB    │  ← assets만 포함, OriginRes 제외               │
│  └──────────────┘                                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

#### 2.2.4 장점

| 항목 | 설명 |
|------|------|
| **버전 관리** | 원본 리소스도 Git에서 이력 추적 가능 |
| **빌드 최적화** | 불필요한 원본이 앱에 포함되지 않아 APK 용량 절감 |
| **작업 유연성** | 원본 수정 후 필요한 것만 assets로 복사 |
| **협업 용이** | 팀원 모두 동일한 원본 리소스 공유 |

---

### 2.3 리소스 분류 체계

#### 2.3.1 Actor 리소스 (캐릭터)

| 분류 | 경로 | 설명 | 네이밍 규칙 |
|------|------|------|-------------|
| 영웅 | `Actor/Heroes/` | 플레이어블 캐릭터 | `hero_{id}_{state}.png` |
| 몬스터 | `Actor/Monsters/` | 일반/엘리트 몬스터 | `mon_{id}_{state}.png` |
| 보스 | `Actor/Bosses/` | 보스 몬스터 | `boss_{id}_{state}.png` |
| 펫 | `Actor/Pets/` | 동반 펫 | `pet_{id}_{state}.png` |

#### 2.3.2 스프라이트 상태 정의

| State 코드 | 설명 | 프레임 수 |
|------------|------|-----------|
| `idle` | 대기 | 4 |
| `walk` | 이동 | 6 |
| `attack` | 공격 | 4 |
| `hit` | 피격 | 2 |
| `death` | 사망 | 4 |

#### 2.3.3 원본 → 프로젝트 리소스 매핑

```
OriginRes/                          →  assets/images/
├── Actor/                          →  actors/
│   ├── Heroes/                     →  actors/heroes/
│   │   └── hero_001_idle.png       →  actors/heroes/hero_001_idle.png
│   ├── Monsters/                   →  actors/monsters/
│   └── Bosses/                     →  actors/bosses/
├── InGameBG/                       →  backgrounds/
│   └── grass_tile.png              →  backgrounds/grass_tile.png
├── Weapons/                        →  weapons/
├── Effects/                        →  effects/
├── Items/                          →  items/
├── UI/                             →  ui/
└── Maps/                           →  maps/
```

#### 2.3.4 InGameBG (인게임 배경) 리소스

| 항목 | 사양 | 비고 |
|------|------|------|
| **경로** | `OriginRes/InGameBG/` | 원본 저장 위치 |
| **크기** | 512 x 512 px | 2의 거듭제곱 권장 |
| **형식** | PNG 또는 JPG | |
| **조건** | Seamless (이음새 없는 타일) | 무한 반복용 |

```
InGameBG 폴더 구조:
OriginRes/
└── InGameBG/
    ├── grass_tile.png          # 풀밭 배경 (512x512, seamless)
    ├── desert_tile.png         # 사막 배경
    ├── snow_tile.png           # 눈밭 배경
    └── dungeon_tile.png        # 던전 배경

→ assets/images/backgrounds/    # 빌드용 복사 위치
```

### 2.4 리소스 경로 상수

```dart
// lib/core/constants/asset_paths.dart

class AssetPaths {
  AssetPaths._();

  // 기본 경로
  static const String _images = 'assets/images';
  static const String _audio = 'assets/audio';

  // Actor 경로
  static const String actors = '$_images/actors';
  static const String heroes = '$actors/heroes';
  static const String monsters = '$actors/monsters';
  static const String bosses = '$actors/bosses';
  static const String pets = '$actors/pets';

  // 무기/스킬 경로
  static const String weapons = '$_images/weapons';
  static const String effects = '$_images/effects';

  // 아이템 경로
  static const String items = '$_images/items';

  // UI 경로
  static const String ui = '$_images/ui';
  static const String buttons = '$ui/buttons';
  static const String icons = '$ui/icons';
  static const String frames = '$ui/frames';
  static const String backgrounds = '$ui/backgrounds';

  // 맵 경로
  static const String maps = '$_images/maps';

  // 오디오 경로
  static const String bgm = '$_audio/bgm';
  static const String sfx = '$_audio/sfx';

  // 동적 경로 생성
  static String heroSprite(String heroId, String state) =>
      '$heroes/hero_${heroId}_$state.png';

  static String monsterSprite(String monsterId, String state) =>
      '$monsters/mon_${monsterId}_$state.png';

  static String bossSprite(String bossId, String state) =>
      '$bosses/boss_${bossId}_$state.png';

  static String petSprite(String petId, String state) =>
      '$pets/pet_${petId}_$state.png';

  static String weaponSprite(String weaponId) =>
      '$weapons/weapon_$weaponId.png';

  static String skillIcon(String skillId) =>
      '$icons/skill_$skillId.png';

  static String itemSprite(String itemId) =>
      '$items/item_$itemId.png';
}
```

### 2.5 리소스 로더

```dart
// lib/game/vam_game.dart

class VamGame extends FlameGame {
  // 스프라이트 캐시
  final Map<String, Sprite> _spriteCache = {};
  final Map<String, SpriteAnimation> _animationCache = {};

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _preloadAssets();
  }

  Future<void> _preloadAssets() async {
    // 필수 리소스 사전 로드
    await images.loadAll([
      // 영웅 스프라이트
      AssetPaths.heroSprite('001', 'idle'),
      AssetPaths.heroSprite('001', 'walk'),

      // 기본 몬스터
      AssetPaths.monsterSprite('001', 'idle'),
      AssetPaths.monsterSprite('001', 'walk'),

      // UI 요소
      '${AssetPaths.ui}/health_bar.png',
      '${AssetPaths.ui}/exp_bar.png',
    ]);
  }

  /// 스프라이트 로드 (캐싱)
  Future<Sprite> loadSprite(String path) async {
    if (_spriteCache.containsKey(path)) {
      return _spriteCache[path]!;
    }

    final sprite = await Sprite.load(path);
    _spriteCache[path] = sprite;
    return sprite;
  }

  /// 스프라이트 애니메이션 로드
  Future<SpriteAnimation> loadAnimation(
    String basePath,
    int frameCount,
    double stepTime,
  ) async {
    final cacheKey = '$basePath:$frameCount';
    if (_animationCache.containsKey(cacheKey)) {
      return _animationCache[cacheKey]!;
    }

    final sprites = <Sprite>[];
    for (int i = 0; i < frameCount; i++) {
      final sprite = await Sprite.load('${basePath}_$i.png');
      sprites.add(sprite);
    }

    final animation = SpriteAnimation.spriteList(
      sprites,
      stepTime: stepTime,
    );
    _animationCache[cacheKey] = animation;
    return animation;
  }
}
```

### 2.6 리소스 복사 스크립트

```bash
#!/bin/bash
# scripts/copy_resources.sh
# OriginRes에서 assets로 리소스 복사

ORIGIN_DIR="OriginRes"
ASSETS_DIR="assets/images"

# Actor 복사
echo "Copying Actor resources..."
cp -r "$ORIGIN_DIR/Actor/Heroes/"* "$ASSETS_DIR/actors/heroes/"
cp -r "$ORIGIN_DIR/Actor/Monsters/"* "$ASSETS_DIR/actors/monsters/"
cp -r "$ORIGIN_DIR/Actor/Bosses/"* "$ASSETS_DIR/actors/bosses/"
cp -r "$ORIGIN_DIR/Actor/Pets/"* "$ASSETS_DIR/actors/pets/"

# InGameBG (배경) 복사
echo "Copying InGameBG resources..."
cp -r "$ORIGIN_DIR/InGameBG/"* "$ASSETS_DIR/backgrounds/"

# Weapons 복사
echo "Copying Weapon resources..."
cp -r "$ORIGIN_DIR/Weapons/"* "$ASSETS_DIR/weapons/"

# Effects 복사
echo "Copying Effect resources..."
cp -r "$ORIGIN_DIR/Effects/"* "$ASSETS_DIR/effects/"

# Items 복사
echo "Copying Item resources..."
cp -r "$ORIGIN_DIR/Items/"* "$ASSETS_DIR/items/"

# UI 복사
echo "Copying UI resources..."
cp -r "$ORIGIN_DIR/UI/"* "$ASSETS_DIR/ui/"

# Maps 복사
echo "Copying Map resources..."
cp -r "$ORIGIN_DIR/Maps/"* "$ASSETS_DIR/maps/"

# Audio 복사
echo "Copying Audio resources..."
cp -r "$ORIGIN_DIR/Audio/BGM/"* "assets/audio/bgm/"
cp -r "$ORIGIN_DIR/Audio/SFX/"* "assets/audio/sfx/"

echo "Resource copy completed!"
```

---

## 3. 핵심 시스템 설계

### 3.1 화면 관리 시스템

#### 3.1.1 해상도 대응

```dart
// lib/core/utils/screen_utils.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class ScreenUtils {
  ScreenUtils._();

  // 기준 해상도
  static const double DESIGN_WIDTH = 1080.0;
  static const double DESIGN_HEIGHT = 1920.0;
  static const double DESIGN_RATIO = 9.0 / 16.0;  // 0.5625

  static late double screenWidth;
  static late double screenHeight;
  static late double screenRatio;
  static late double scaleX;
  static late double scaleY;
  static late double scale;  // 통합 스케일 (UI용)

  // 게임 영역 (확장 포함)
  static late double gameWidth;
  static late double gameHeight;

  /// 초기화 (앱 시작 시 호출)
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    screenRatio = screenWidth / screenHeight;

    // 스케일 계산
    scaleX = screenWidth / DESIGN_WIDTH;
    scaleY = screenHeight / DESIGN_HEIGHT;

    // UI 스케일: 너비 기준 (레터박스 없이 확장)
    scale = scaleX;

    // 게임 영역 계산 (확장 영역 포함)
    _calculateGameArea();
  }

  static void _calculateGameArea() {
    if (screenRatio < DESIGN_RATIO) {
      // 기기가 더 넓음 (좌우 확장)
      gameWidth = DESIGN_HEIGHT * screenRatio;
      gameHeight = DESIGN_HEIGHT;
    } else {
      // 기기가 더 길쭉함 (상하 확장)
      gameWidth = DESIGN_WIDTH;
      gameHeight = DESIGN_WIDTH / screenRatio;
    }
  }

  /// 디자인 픽셀 → 실제 픽셀 변환
  static double w(double designPixel) => designPixel * scaleX;
  static double h(double designPixel) => designPixel * scaleY;
  static double sp(double designPixel) => designPixel * scale;

  /// 게임 좌표 → 화면 좌표 변환
  static Offset gameToScreen(double gameX, double gameY) {
    final offsetX = (screenWidth - gameWidth * scaleX) / 2;
    final offsetY = (screenHeight - gameHeight * scaleY) / 2;
    return Offset(
      gameX * scaleX + offsetX,
      gameY * scaleY + offsetY,
    );
  }
}
```

#### 3.1.2 SafeArea 관리

```dart
// lib/core/utils/safe_area_utils.dart

import 'package:flutter/material.dart';

class SafeAreaUtils {
  SafeAreaUtils._();

  static late EdgeInsets safeAreaPadding;
  static late double topPadding;
  static late double bottomPadding;
  static late double leftPadding;
  static late double rightPadding;

  /// 초기화 (ScreenUtils 이후 호출)
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    safeAreaPadding = mediaQuery.padding;
    topPadding = safeAreaPadding.top;
    bottomPadding = safeAreaPadding.bottom;
    leftPadding = safeAreaPadding.left;
    rightPadding = safeAreaPadding.right;
  }

  /// SafeArea 내부 크기
  static double get safeWidth =>
      ScreenUtils.screenWidth - leftPadding - rightPadding;

  static double get safeHeight =>
      ScreenUtils.screenHeight - topPadding - bottomPadding;

  /// UI 요소 배치용 오프셋
  static EdgeInsets get uiPadding => EdgeInsets.only(
    top: topPadding + 8,      // 추가 마진
    bottom: bottomPadding + 8,
    left: leftPadding + 8,
    right: rightPadding + 8,
  );
}
```

#### 3.1.3 풀스크린 모드 설정

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 세로 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 풀스크린 몰입 모드
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const VamApp());
}

class VamApp extends StatelessWidget {
  const VamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vampire Survivors Clone',
      theme: ThemeData.dark(),
      home: const InitializerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InitializerScreen extends StatefulWidget {
  const InitializerScreen({super.key});

  @override
  State<InitializerScreen> createState() => _InitializerScreenState();
}

class _InitializerScreenState extends State<InitializerScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면 유틸리티 초기화
    ScreenUtils.init(context);
    SafeAreaUtils.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
```

### 3.2 게임 루프 시스템

```dart
// lib/game/vam_game.dart

import 'package:flame/game.dart';
import 'package:flame/components.dart';

class VamGame extends FlameGame with HasCollisionDetection {
  // 게임 상태
  late Player player;
  late SpawnSystem spawnSystem;
  late WaveSystem waveSystem;
  late CombatSystem combatSystem;
  late LevelSystem levelSystem;

  // 게임 시간
  double mElapsedTime = 0;
  bool mIsPaused = false;

  // 현재 스테이지 정보
  late StageModel mCurrentStage;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 카메라 설정
    camera.viewfinder.visibleGameSize = Vector2(
      ScreenUtils.gameWidth,
      ScreenUtils.gameHeight,
    );

    // 시스템 초기화
    combatSystem = CombatSystem();
    spawnSystem = SpawnSystem(this);
    waveSystem = WaveSystem(this);
    levelSystem = LevelSystem(this);

    // 플레이어 생성
    player = Player();
    add(player);
  }

  @override
  void update(double dt) {
    if (mIsPaused) return;

    super.update(dt);
    mElapsedTime += dt;

    // 시스템 업데이트
    waveSystem.update(dt);
    spawnSystem.update(dt);
  }

  void pauseGame() {
    mIsPaused = true;
    pauseEngine();
  }

  void resumeGame() {
    mIsPaused = false;
    resumeEngine();
  }

  void onPlayerLevelUp() {
    pauseGame();
    // 스킬 선택 UI 표시
    overlays.add('SkillSelect');
  }

  void onSkillSelected(SkillModel skill) {
    levelSystem.applySkill(skill);
    overlays.remove('SkillSelect');
    resumeGame();
  }
}
```

### 3.3 전투 시스템

```dart
// lib/game/systems/combat_system.dart

class CombatSystem {
  /// 데미지 계산
  /// 공식: (기본ATK × 무기계수 × 스킬계수) × (1 + 크리배율) × 속성보너스
  DamageResult CalculateDamage({
    required ActorStats attacker,
    required ActorStats defender,
    required double weaponMultiplier,
    required double skillMultiplier,
    double elementBonus = 1.0,
  }) {
    // 기본 공격력
    final baseAtk = attacker.atk;

    // 기본 데미지
    double damage = baseAtk * weaponMultiplier * skillMultiplier;

    // 크리티컬 체크
    bool isCritical = false;
    if (_rollCritical(attacker.critRate)) {
      isCritical = true;
      damage *= (1 + attacker.critDmg / 100);
    }

    // 속성 보너스
    damage *= elementBonus;

    // 방어력 적용
    final defense = defender.def;
    final damageReduction = defense / (defense + 100); // 감소율
    final finalDamage = damage * (1 - damageReduction);

    return DamageResult(
      damage: finalDamage.round(),
      isCritical: isCritical,
    );
  }

  bool _rollCritical(double critRate) {
    return Random().nextDouble() * 100 < critRate;
  }
}

class DamageResult {
  final int damage;
  final bool isCritical;

  const DamageResult({
    required this.damage,
    required this.isCritical,
  });
}
```

---

## 4. 게임 오브젝트 설계

### 4.1 Actor 기본 클래스

```dart
// lib/game/components/actors/actor_base.dart

abstract class ActorBase extends SpriteAnimationComponent
    with HasGameRef<VamGame>, CollisionCallbacks {

  final String mActorId;
  late ActorStats mStats;

  // 상태
  int mCurrentHp = 0;
  bool mIsAlive = true;
  ActorState mState = ActorState.idle;

  // 애니메이션
  late Map<ActorState, SpriteAnimation> mAnimations;

  ActorBase({
    required this.mActorId,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadAnimations();
    mCurrentHp = mStats.hp;
  }

  Future<void> _loadAnimations();

  void TakeDamage(int damage) {
    if (!mIsAlive) return;

    mCurrentHp -= damage;
    if (mCurrentHp <= 0) {
      mCurrentHp = 0;
      Die();
    } else {
      OnHit();
    }
  }

  void OnHit() {
    ChangeState(ActorState.hit);
  }

  void Die() {
    mIsAlive = false;
    ChangeState(ActorState.death);
  }

  void ChangeState(ActorState newState) {
    if (mState == newState) return;
    mState = newState;
    if (mAnimations.containsKey(newState)) {
      animation = mAnimations[newState];
    }
  }

  void Move(Vector2 direction, double dt) {
    if (!mIsAlive) return;

    position += direction.normalized() * mStats.spd * dt;
    if (direction.length > 0) {
      ChangeState(ActorState.walk);
    } else {
      ChangeState(ActorState.idle);
    }
  }
}

enum ActorState { idle, walk, attack, hit, death }
```

### 4.2 플레이어 클래스

```dart
// lib/game/components/actors/player.dart

class Player extends ActorBase {
  // 스킬 슬롯 (최대 6개)
  final List<SkillInstance> mSkills = [];
  static const int MAX_SKILLS = 6;

  // 경험치
  int mCurrentExp = 0;
  int mLevel = 1;

  // 펫
  Pet? mPet;

  Player() : super(
    mActorId: 'hero_001',
    position: Vector2.zero(),
    size: Vector2(64, 64),
  );

  @override
  Future<void> onLoad() async {
    // 스탯 로드
    mStats = CharacterTable.getCharacter(mActorId).baseStats;
    await super.onLoad();

    // 히트박스
    add(CircleHitbox(radius: 24));
  }

  @override
  Future<void> _loadAnimations() async {
    mAnimations = {
      ActorState.idle: await gameRef.loadAnimation(
        AssetPaths.heroSprite(mActorId, 'idle'),
        4, 0.15,
      ),
      ActorState.walk: await gameRef.loadAnimation(
        AssetPaths.heroSprite(mActorId, 'walk'),
        6, 0.1,
      ),
      ActorState.hit: await gameRef.loadAnimation(
        AssetPaths.heroSprite(mActorId, 'hit'),
        2, 0.1,
      ),
      ActorState.death: await gameRef.loadAnimation(
        AssetPaths.heroSprite(mActorId, 'death'),
        4, 0.15,
      ),
    };
    animation = mAnimations[ActorState.idle];
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateSkills(dt);
  }

  void _updateSkills(double dt) {
    for (final skill in mSkills) {
      skill.Update(dt);
    }
  }

  void GainExp(int amount) {
    mCurrentExp += amount;

    final requiredExp = LevelTable.getRequiredExp(mLevel);
    if (mCurrentExp >= requiredExp) {
      LevelUp();
    }
  }

  void LevelUp() {
    mLevel++;
    mCurrentExp = 0;
    gameRef.onPlayerLevelUp();
  }

  bool CanAddSkill() => mSkills.length < MAX_SKILLS;

  void AddSkill(SkillModel skill) {
    if (!CanAddSkill()) return;

    final existing = mSkills.firstWhereOrNull(
      (s) => s.skillId == skill.id,
    );

    if (existing != null) {
      existing.LevelUp();
    } else {
      mSkills.add(SkillInstance(skill, this));
    }
  }
}
```

### 4.3 몬스터 클래스

```dart
// lib/game/components/actors/monster.dart

class Monster extends ActorBase {
  final MonsterType mType;
  late Player mTarget;

  // 드롭 정보
  late DropInfo mDropInfo;

  Monster({
    required String monsterId,
    required this.mType,
    required Vector2 position,
  }) : super(
    mActorId: monsterId,
    position: position,
    size: Vector2(48, 48),
  );

  @override
  Future<void> onLoad() async {
    final data = MonsterTable.getMonster(mActorId);
    mStats = data.stats;
    mDropInfo = data.dropInfo;
    mTarget = gameRef.player;

    await super.onLoad();
    add(CircleHitbox(radius: 20));
  }

  @override
  Future<void> _loadAnimations() async {
    mAnimations = {
      ActorState.idle: await gameRef.loadAnimation(
        AssetPaths.monsterSprite(mActorId, 'idle'),
        4, 0.2,
      ),
      ActorState.walk: await gameRef.loadAnimation(
        AssetPaths.monsterSprite(mActorId, 'walk'),
        4, 0.15,
      ),
      ActorState.death: await gameRef.loadAnimation(
        AssetPaths.monsterSprite(mActorId, 'death'),
        4, 0.1,
      ),
    };
    animation = mAnimations[ActorState.idle];
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (mIsAlive) {
      _chasePlayer(dt);
    }
  }

  void _chasePlayer(double dt) {
    final direction = mTarget.position - position;
    Move(direction, dt);
  }

  @override
  void Die() {
    super.Die();
    _spawnDrops();

    // 사망 애니메이션 후 제거
    Future.delayed(const Duration(milliseconds: 500), () {
      removeFromParent();
    });
  }

  void _spawnDrops() {
    // 경험치 젬 드롭
    gameRef.add(ExpGem(
      position: position.clone(),
      expAmount: mDropInfo.exp,
    ));

    // 골드 드롭
    if (Random().nextDouble() < mDropInfo.goldChance) {
      gameRef.add(GoldPickup(
        position: position.clone(),
        goldAmount: mDropInfo.gold,
      ));
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Player) {
      // 플레이어에게 접촉 데미지
      final result = gameRef.combatSystem.CalculateDamage(
        attacker: mStats,
        defender: other.mStats,
        weaponMultiplier: 1.0,
        skillMultiplier: 1.0,
      );
      other.TakeDamage(result.damage);
    }
  }
}

enum MonsterType { normal, elite, boss }
```

---

## 5. UI 시스템 설계

### 5.1 게임 화면 레이아웃

```dart
// lib/presentation/screens/game_screen.dart

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late VamGame _game;

  @override
  void initState() {
    super.initState();
    _game = VamGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 게임 영역 (전체 화면)
          Positioned.fill(
            child: GameWidget(
              game: _game,
              overlayBuilderMap: {
                'HUD': (context, game) => HudOverlay(game: game as VamGame),
                'SkillSelect': (context, game) => SkillSelectOverlay(
                  game: game as VamGame,
                ),
                'Pause': (context, game) => PauseOverlay(game: game as VamGame),
                'Result': (context, game) => ResultOverlay(game: game as VamGame),
              },
              initialActiveOverlays: const ['HUD'],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5.2 HUD 오버레이

```dart
// lib/presentation/overlays/hud_overlay.dart

class HudOverlay extends StatelessWidget {
  final VamGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: SafeAreaUtils.uiPadding,
        child: Column(
          children: [
            // 상단 HUD
            _buildTopHud(),

            const Spacer(),

            // 하단 HUD
            _buildBottomHud(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHud() {
    return Row(
      children: [
        // 일시정지 버튼
        IconButton(
          icon: const Icon(Icons.pause, color: Colors.white),
          onPressed: () {
            game.pauseGame();
            game.overlays.add('Pause');
          },
        ),

        const Spacer(),

        // 경과 시간
        StreamBuilder<double>(
          stream: _getTimeStream(),
          builder: (context, snapshot) {
            final time = snapshot.data ?? 0;
            return Text(
              _formatTime(time),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),

        const SizedBox(width: 16),

        // 킬 카운트
        const Text(
          'KILL: 0',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildBottomHud() {
    return Column(
      children: [
        // HP 바
        HealthBar(player: game.player),

        const SizedBox(height: 8),

        // EXP 바
        ExpBar(player: game.player),

        const SizedBox(height: 16),

        // 스킬 슬롯
        SkillSlots(player: game.player),

        const SizedBox(height: 16),

        // 조이스틱 영역 (터치 영역 확보)
        SizedBox(height: ScreenUtils.h(200)),
      ],
    );
  }

  String _formatTime(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Stream<double> _getTimeStream() async* {
    while (true) {
      yield game.mElapsedTime;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
```

### 5.3 스킬 선택 다이얼로그

```dart
// lib/presentation/overlays/skill_select_overlay.dart

class SkillSelectOverlay extends StatelessWidget {
  final VamGame game;

  const SkillSelectOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final skills = _generateSkillChoices();

    return Container(
      color: Colors.black54,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '레벨 업!',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: skills.map((skill) =>
                _SkillCard(
                  skill: skill,
                  onTap: () => game.onSkillSelected(skill),
                ),
              ).toList(),
            ),

            const SizedBox(height: 24),

            // 광고로 다시 뽑기
            TextButton(
              onPressed: _onRerollWithAd,
              child: const Text(
                '광고로 다시 뽑기',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SkillModel> _generateSkillChoices() {
    return game.levelSystem.generateSkillChoices(3);
  }

  void _onRerollWithAd() {
    // 광고 시청 후 스킬 재생성
  }
}

class _SkillCard extends StatelessWidget {
  final SkillModel skill;
  final VoidCallback onTap;

  const _SkillCard({
    required this.skill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ScreenUtils.w(280),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRarityColor(skill.rarity),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // 스킬 아이콘
            Image.asset(
              AssetPaths.skillIcon(skill.id),
              width: 64,
              height: 64,
            ),
            const SizedBox(height: 12),

            // 스킬 이름
            Text(
              skill.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            // 레벨 표시
            Text(
              skill.isNew ? '신규' : 'Lv.${skill.currentLevel + 1}',
              style: TextStyle(
                color: skill.isNew ? Colors.green : Colors.yellow,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            // 효과 설명
            Text(
              skill.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(SkillRarity rarity) {
    switch (rarity) {
      case SkillRarity.common: return Colors.grey;
      case SkillRarity.rare: return Colors.blue;
      case SkillRarity.epic: return Colors.purple;
      case SkillRarity.legendary: return Colors.orange;
    }
  }
}
```

---

## 6. 데이터 관리 설계

### 6.1 데이터 모델

```dart
// lib/data/models/character_model.dart

class CharacterModel {
  final String id;
  final String name;
  final int rarity;
  final ActorStats baseStats;
  final StarGrowth starGrowth;
  final UniqueSkill uniqueSkill;
  final UnlockCondition unlockCondition;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.rarity,
    required this.baseStats,
    required this.starGrowth,
    required this.uniqueSkill,
    required this.unlockCondition,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'],
      name: json['name'],
      rarity: json['rarity'],
      baseStats: ActorStats.fromJson(json['baseStats']),
      starGrowth: StarGrowth.fromJson(json['starGrowth']),
      uniqueSkill: UniqueSkill.fromJson(json['uniqueSkill']),
      unlockCondition: UnlockCondition.fromJson(json['unlockCondition']),
    );
  }
}

class ActorStats {
  final int hp;
  final int atk;
  final int def;
  final double spd;
  final double critRate;
  final double critDmg;

  const ActorStats({
    required this.hp,
    required this.atk,
    required this.def,
    required this.spd,
    required this.critRate,
    required this.critDmg,
  });

  factory ActorStats.fromJson(Map<String, dynamic> json) {
    return ActorStats(
      hp: json['hp'],
      atk: json['atk'],
      def: json['def'],
      spd: (json['spd'] as num).toDouble(),
      critRate: (json['critRate'] as num).toDouble(),
      critDmg: (json['critDmg'] as num).toDouble(),
    );
  }

  /// 성급 보너스 적용
  ActorStats ApplyStarBonus(int star, StarGrowth growth) {
    final multiplier = _getStarMultiplier(star);
    return ActorStats(
      hp: (hp * (1 + growth.hp * multiplier)).round(),
      atk: (atk * (1 + growth.atk * multiplier)).round(),
      def: (def * (1 + growth.def * multiplier)).round(),
      spd: spd,
      critRate: critRate,
      critDmg: critDmg,
    );
  }

  double _getStarMultiplier(int star) {
    const multipliers = [0, 0.1, 0.25, 0.45, 0.70, 1.0];
    return multipliers[star.clamp(0, 5)];
  }
}
```

### 6.2 데이터 테이블

```dart
// lib/data/tables/character_table.dart

class CharacterTable {
  static final Map<String, CharacterModel> _characters = {};
  static bool _isLoaded = false;

  static Future<void> load() async {
    if (_isLoaded) return;

    final jsonString = await rootBundle.loadString('assets/data/characters.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    for (final json in jsonList) {
      final character = CharacterModel.fromJson(json);
      _characters[character.id] = character;
    }

    _isLoaded = true;
  }

  static CharacterModel getCharacter(String id) {
    return _characters[id] ??
      throw Exception('Character not found: $id');
  }

  static List<CharacterModel> getAll() => _characters.values.toList();

  static List<CharacterModel> getByRarity(int rarity) =>
    _characters.values.where((c) => c.rarity == rarity).toList();
}
```

### 6.3 JSON 데이터 구조

```json
// assets/data/characters.json
[
  {
    "id": "CHAR_001",
    "name": "특공대원",
    "rarity": 1,
    "baseStats": {
      "hp": 100,
      "atk": 10,
      "def": 5,
      "spd": 5.0,
      "critRate": 5.0,
      "critDmg": 150.0
    },
    "starGrowth": {
      "hp": 0.1,
      "atk": 0.1,
      "def": 0.1
    },
    "uniqueSkill": {
      "id": "SK_U001",
      "unlockStar": 1,
      "upgrade1Star": 3,
      "upgrade2Star": 6
    },
    "unlockCondition": {
      "type": "DEFAULT",
      "value": null
    }
  }
]
```

---

## 7. 상태 관리 설계

### 7.1 Provider 구조

```dart
// lib/state/providers/game_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// 게임 상태
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>(
  (ref) => GameStateNotifier(),
);

class GameState {
  final GamePhase phase;
  final int currentChapter;
  final int currentWave;
  final double elapsedTime;
  final int killCount;
  final int goldEarned;

  const GameState({
    this.phase = GamePhase.ready,
    this.currentChapter = 1,
    this.currentWave = 1,
    this.elapsedTime = 0,
    this.killCount = 0,
    this.goldEarned = 0,
  });

  GameState copyWith({
    GamePhase? phase,
    int? currentChapter,
    int? currentWave,
    double? elapsedTime,
    int? killCount,
    int? goldEarned,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      currentChapter: currentChapter ?? this.currentChapter,
      currentWave: currentWave ?? this.currentWave,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      killCount: killCount ?? this.killCount,
      goldEarned: goldEarned ?? this.goldEarned,
    );
  }
}

enum GamePhase { ready, playing, paused, bossPhase, victory, defeat }

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(const GameState());

  void StartGame(int chapter) {
    state = GameState(
      phase: GamePhase.playing,
      currentChapter: chapter,
    );
  }

  void UpdateTime(double dt) {
    state = state.copyWith(
      elapsedTime: state.elapsedTime + dt,
    );
  }

  void AddKill() {
    state = state.copyWith(killCount: state.killCount + 1);
  }

  void AddGold(int amount) {
    state = state.copyWith(goldEarned: state.goldEarned + amount);
  }

  void EnterBossPhase() {
    state = state.copyWith(phase: GamePhase.bossPhase);
  }

  void Victory() {
    state = state.copyWith(phase: GamePhase.victory);
  }

  void Defeat() {
    state = state.copyWith(phase: GamePhase.defeat);
  }

  void Pause() {
    state = state.copyWith(phase: GamePhase.paused);
  }

  void Resume() {
    state = state.copyWith(phase: GamePhase.playing);
  }
}
```

### 7.2 플레이어 상태

```dart
// lib/state/providers/player_state_provider.dart

final playerStateProvider = StateNotifierProvider<PlayerStateNotifier, PlayerState>(
  (ref) => PlayerStateNotifier(),
);

class PlayerState {
  final String characterId;
  final int star;
  final int level;
  final int currentExp;
  final int currentHp;
  final int maxHp;
  final List<String> equippedSkillIds;

  const PlayerState({
    this.characterId = 'CHAR_001',
    this.star = 1,
    this.level = 1,
    this.currentExp = 0,
    this.currentHp = 100,
    this.maxHp = 100,
    this.equippedSkillIds = const [],
  });

  double get hpPercent => currentHp / maxHp;
  double get expPercent {
    final required = LevelTable.getRequiredExp(level);
    return currentExp / required;
  }

  PlayerState copyWith({
    String? characterId,
    int? star,
    int? level,
    int? currentExp,
    int? currentHp,
    int? maxHp,
    List<String>? equippedSkillIds,
  }) {
    return PlayerState(
      characterId: characterId ?? this.characterId,
      star: star ?? this.star,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      equippedSkillIds: equippedSkillIds ?? this.equippedSkillIds,
    );
  }
}

class PlayerStateNotifier extends StateNotifier<PlayerState> {
  PlayerStateNotifier() : super(const PlayerState());

  void TakeDamage(int damage) {
    final newHp = (state.currentHp - damage).clamp(0, state.maxHp);
    state = state.copyWith(currentHp: newHp);
  }

  void Heal(int amount) {
    final newHp = (state.currentHp + amount).clamp(0, state.maxHp);
    state = state.copyWith(currentHp: newHp);
  }

  void GainExp(int amount) {
    var newExp = state.currentExp + amount;
    var newLevel = state.level;

    while (newExp >= LevelTable.getRequiredExp(newLevel)) {
      newExp -= LevelTable.getRequiredExp(newLevel);
      newLevel++;
    }

    state = state.copyWith(
      level: newLevel,
      currentExp: newExp,
    );
  }

  void AddSkill(String skillId) {
    if (state.equippedSkillIds.length >= 6) return;

    state = state.copyWith(
      equippedSkillIds: [...state.equippedSkillIds, skillId],
    );
  }
}
```

---

## 8. 구현 로드맵

### 8.1 MVP (Phase 1) - 4주

| 주차 | 작업 항목 | 산출물 |
|------|----------|--------|
| 1주 | 프로젝트 셋업, 화면 시스템 | 기본 구조, SafeArea 대응 |
| 2주 | 게임 루프, 플레이어 | 이동, 자동 공격, 조이스틱 |
| 3주 | 몬스터, 전투 시스템 | 스폰, 데미지, 사망 |
| 4주 | 스킬 시스템 (기본 5종) | 레벨업, 스킬 선택 |

### 8.2 Phase 2 - 4주

| 주차 | 작업 항목 | 산출물 |
|------|----------|--------|
| 5주 | 캐릭터 시스템, 장비 | 성급, 장비 장착 |
| 6주 | 장비 강화/합성 | 레벨업, 등급 합성 |
| 7주 | 도전 콘텐츠 | 도전 스테이지 |
| 8주 | 순찰 시스템, 상점 | 방치형 보상, 상점 |

### 8.3 Phase 3 - 4주

| 주차 | 작업 항목 | 산출물 |
|------|----------|--------|
| 9주 | 펫 시스템 | 펫 공격, 패시브 |
| 10주 | 스킬 진화 | 돌파 조합 |
| 11주 | 시즌 패스 | 배틀패스 |
| 12주 | 길드 시스템 | 길드 생성, 광산 원정 |

### 8.4 체크리스트

#### MVP 필수 기능
- [ ] 화면 시스템 (해상도 대응, SafeArea)
- [ ] 플레이어 이동 (조이스틱)
- [ ] 자동 공격 시스템
- [ ] 몬스터 스폰 시스템
- [ ] 데미지 계산 및 적용
- [ ] 경험치 시스템
- [ ] 레벨업 스킬 선택
- [ ] 기본 스킬 5종
- [ ] 보스 전투
- [ ] 스테이지 클리어

---

**문서 끝**
