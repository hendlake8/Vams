# 스프라이트 리소스 시스템 설계

> 작성일: 2024-12-06
> 버전: 1.0

---

## 1. 개요

게임에서 사용할 스프라이트 리소스 관리 시스템 설계.
원본 리소스와 빌드용 리소스를 분리하여 관리한다.

---

## 2. 폴더 구조

### 2.1 전체 구조

```
프로젝트/
├── OriginRes/                    # 원본 리소스 (빌드 제외, Git 포함)
│   ├── Actor/
│   │   ├── Heroes/
│   │   │   └── hero_0.png
│   │   ├── Monsters/
│   │   │   ├── monster_0.png
│   │   │   └── monster_1.png
│   │   └── Bosses/
│   │       └── boss_0.png
│   └── InGameBG/
│       └── bg_0.png
│
├── assets/                       # 빌드 포함 리소스
│   └── images/
│       ├── actors/
│       │   ├── heroes/           # hero_0.png, hero_1.png ...
│       │   ├── monsters/         # monster_0.png, monster_1.png ...
│       │   └── bosses/           # boss_0.png ...
│       ├── backgrounds/          # bg_0.png ...
│       ├── effects/              # (향후 확장)
│       └── ui/                   # (향후 확장)
```

### 2.2 빌드 포함/제외 정책

| 폴더 | Git | Flutter 빌드 | 용도 |
|------|-----|-------------|------|
| `OriginRes/` | O | X | 원본 리소스 보관 (편집용) |
| `assets/` | O | O | 실제 게임에서 사용 |

- pubspec.yaml의 assets 섹션에 `OriginRes/`가 없으므로 빌드에서 자동 제외됨
- .gitignore 설정 불필요 (Git에는 포함)

---

## 3. 네이밍 규칙

### 3.1 파일 네이밍

| 카테고리 | 패턴 | 예시 |
|----------|------|------|
| 영웅 | `hero_{index}.png` | `hero_0.png`, `hero_1.png` |
| 몬스터 | `monster_{index}.png` | `monster_0.png`, `monster_1.png` |
| 보스 | `boss_{index}.png` | `boss_0.png`, `boss_1.png` |
| 배경 | `bg_{index}.png` | `bg_0.png`, `bg_1.png` |
| 이펙트 | `fx_{name}.png` | `fx_explosion.png`, `fx_heal.png` |
| UI | `ui_{name}.png` | `ui_button.png`, `ui_frame.png` |

### 3.2 인덱스 매핑

| 원본 경로 | 빌드 경로 | 인덱스 |
|----------|----------|--------|
| `OriginRes/Actor/Heroes/hero_0.png` | `assets/images/actors/heroes/hero_0.png` | 0 |
| `OriginRes/Actor/Monsters/monster_0.png` | `assets/images/actors/monsters/monster_0.png` | 0 |
| `OriginRes/Actor/Monsters/monster_1.png` | `assets/images/actors/monsters/monster_1.png` | 1 |
| `OriginRes/Actor/Bosses/boss_0.png` | `assets/images/actors/bosses/boss_0.png` | 0 |
| `OriginRes/InGameBG/bg_0.png` | `assets/images/backgrounds/bg_0.png` | 0 |

---

## 4. 코드 구조

### 4.1 파일 구조

```
lib/
├── core/
│   └── resources/
│       ├── sprite_paths.dart      # 경로 상수 정의
│       └── sprite_manager.dart    # 스프라이트 로딩/캐싱
│
├── game/
│   └── components/
│       └── actors/
│           ├── player.dart        # SpriteComponent 적용
│           ├── monster.dart       # SpriteComponent 적용
│           └── ...
```

### 4.2 SpritePaths (경로 상수)

```dart
/// 스프라이트 리소스 경로 상수
class SpritePaths {
  // 기본 경로
  static const String BASE = 'images/';

  // 액터 경로
  static const String HEROES = '${BASE}actors/heroes/';
  static const String MONSTERS = '${BASE}actors/monsters/';
  static const String BOSSES = '${BASE}actors/bosses/';

  // 배경 경로
  static const String BACKGROUNDS = '${BASE}backgrounds/';

  // 이펙트 경로
  static const String EFFECTS = '${BASE}effects/';

  // UI 경로
  static const String UI = '${BASE}ui/';

  // 헬퍼 메서드
  static String Hero(int index) => '${HEROES}hero_$index.png';
  static String Monster(int index) => '${MONSTERS}monster_$index.png';
  static String Boss(int index) => '${BOSSES}boss_$index.png';
  static String Background(int index) => '${BACKGROUNDS}bg_$index.png';
  static String Effect(String name) => '${EFFECTS}fx_$name.png';
}
```

### 4.3 SpriteManager (로딩/캐싱)

```dart
/// 스프라이트 로딩 및 캐싱 관리
class SpriteManager {
  static final SpriteManager instance = SpriteManager._();
  SpriteManager._();

  final Map<String, Sprite> _cache = {};
  late Images _images;
  bool _initialized = false;

  /// 초기화
  Future<void> Initialize(FlameGame game) async {
    _images = game.images;
    _initialized = true;
  }

  /// 스프라이트 가져오기 (캐싱)
  Future<Sprite> GetSprite(String path) async {
    if (!_initialized) {
      throw StateError('SpriteManager not initialized');
    }

    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }

    final image = await _images.load(path);
    final sprite = Sprite(image);
    _cache[path] = sprite;
    return sprite;
  }

  /// 영웅 스프라이트
  Future<Sprite> GetHeroSprite(int index) => GetSprite(SpritePaths.Hero(index));

  /// 몬스터 스프라이트
  Future<Sprite> GetMonsterSprite(int index) => GetSprite(SpritePaths.Monster(index));

  /// 보스 스프라이트
  Future<Sprite> GetBossSprite(int index) => GetSprite(SpritePaths.Boss(index));

  /// 배경 스프라이트
  Future<Sprite> GetBackgroundSprite(int index) => GetSprite(SpritePaths.Background(index));

  /// 사전 로딩 (로딩 화면에서 사용)
  Future<void> Preload(List<String> paths) async {
    for (final path in paths) {
      await GetSprite(path);
    }
  }

  /// 캐시 클리어
  void ClearCache() {
    _cache.clear();
  }
}
```

---

## 5. 데이터 모델 연동

### 5.1 CharacterData 수정

```dart
class CharacterData {
  final String id;
  final String name;
  final int spriteIndex;      // hero_0.png → 0
  final ActorStats baseStats;
  final String baseSkillId;
  // ...

  const CharacterData({
    required this.id,
    required this.name,
    required this.spriteIndex,  // 추가
    required this.baseStats,
    required this.baseSkillId,
    // ...
  });
}
```

### 5.2 MonsterData 수정 (향후)

```dart
class MonsterData {
  final String id;
  final String name;
  final int spriteIndex;      // monster_0.png → 0
  final bool isBoss;          // boss 폴더 사용 여부
  final ActorStats stats;
  // ...
}
```

---

## 6. 컴포넌트 적용

### 6.1 Player 수정

```dart
class Player extends SpriteComponent with HasGameReference<VamGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 캐릭터 데이터에서 스프라이트 인덱스 가져오기
    final spriteIndex = game.mCharacterData.spriteIndex;
    sprite = await SpriteManager.instance.GetHeroSprite(spriteIndex);

    // 크기 설정
    size = Vector2(48, 48);
    anchor = Anchor.center;

    // ...기존 로직
  }
}
```

### 6.2 Monster 수정 (향후)

```dart
class Monster extends SpriteComponent {
  final MonsterData data;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (data.isBoss) {
      sprite = await SpriteManager.instance.GetBossSprite(data.spriteIndex);
    } else {
      sprite = await SpriteManager.instance.GetMonsterSprite(data.spriteIndex);
    }
  }
}
```

---

## 7. 초기화 흐름

```
앱 시작
    ↓
VamGame.onLoad()
    ↓
SpriteManager.Initialize(this)
    ↓
[선택적] SpriteManager.Preload([...])  // 로딩 화면에서
    ↓
컴포넌트 로딩 시 GetSprite() 호출
    ↓
캐시에서 반환 또는 새로 로드
```

---

## 8. 구현 체크리스트

- [ ] assets 폴더 구조 생성
- [ ] OriginRes → assets 리소스 복사
- [ ] `sprite_paths.dart` 구현
- [ ] `sprite_manager.dart` 구현
- [ ] CharacterData에 spriteIndex 추가
- [ ] Player 컴포넌트 스프라이트 적용
- [ ] TiledBackground 배경 이미지 적용
- [ ] Monster 컴포넌트 스프라이트 적용 (향후)

---

## 9. 향후 확장

### 9.1 애니메이션 지원
```dart
// 스프라이트 시트 지원
Future<SpriteAnimation> GetAnimation(String path, int frames, double stepTime);
```

### 9.2 다해상도 지원
```
assets/images/1x/  # 저해상도
assets/images/2x/  # 중해상도
assets/images/3x/  # 고해상도
```

### 9.3 동적 로딩
```dart
// 스테이지별 리소스 로딩/언로딩
void LoadStageResources(int stageId);
void UnloadStageResources(int stageId);
```
