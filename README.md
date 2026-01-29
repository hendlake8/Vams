# VAM - 뱀서라이크 슈팅 게임

---

## 1. 프로젝트 개요

### 1.1 게임 소개

**VAM**은 Vampire Survivors 장르에서 영감을 받은 뱀서라이크 슈팅 게임입니다.
플레이어는 끊임없이 몰려오는 몬스터들 사이에서 생존하며, 레벨업을 통해 다양한 스킬을 획득하고 강해집니다.

| 항목 | 내용 |
|------|------|
| **장르** | 뱀서라이크 슈팅 (Roguelike Shooter) |
| **플랫폼** | Android, iOS, Web, Windows |
| **개발 프레임워크** | Flutter + Flame Engine |
| **상태 관리** | Riverpod |
| **로컬 저장소** | SharedPreferences, Hive |

### 1.2 핵심 특징

- **5종 플레이어블 캐릭터**: 각 캐릭터별 고유 스탯과 전용 스킬
- **8종 스킬 시스템**: 투사체, 범위, 회전, 연쇄, 패시브 등 다양한 유형
- **도전 모드**: 무한 웨이브, 타임어택, 서바이벌 3가지 모드
- **엘리트/보스 시스템**: 특수 패턴을 가진 강화 몬스터
- **영구 진행 시스템**: 골드, 보석, 장비 수집 및 성장

---

## 2. 시스템 아키텍처

### 2.1 전체 구조

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐│
│  │   Screens   │ │  Overlays   │ │        Widgets          ││
│  │ • MainLobby │ │ • HUD       │ │ • Common  • HUD         ││
│  │ • GameScreen│ │ • Pause     │ │ • Dialogs • Lobby       ││
│  │ • Challenge │ │ • GameOver  │ │                         ││
│  │ • Shop      │ │ • SkillSelect│ │                        ││
│  └─────────────┘ └─────────────┘ └─────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Game Layer                            │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                      VamGame                             ││
│  │  (FlameGame - 메인 게임 루프, 입력 처리, 상태 관리)       ││
│  └─────────────────────────────────────────────────────────┘│
│                              │                               │
│       ┌──────────────────────┼──────────────────────┐       │
│       ▼                      ▼                      ▼       │
│  ┌─────────┐          ┌─────────────┐         ┌─────────┐  │
│  │ Systems │          │ Components  │         │  Input  │  │
│  │•Challenge│         │ • Player    │         │•Joystick│  │
│  │•Skill    │         │ • Monster   │         │         │  │
│  │•Spawn    │         │ • Projectile│         │         │  │
│  │•Wave     │         │ • ExpGem    │         │         │  │
│  │•Level    │         │ • Effects   │         │         │  │
│  │•Combat   │         │ • Weapons   │         │         │  │
│  │•Progress │         │             │         │         │  │
│  └─────────┘          └─────────────┘         └─────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐│
│  │   Models    │ │   Tables    │ │      Repositories       ││
│  │ • Character │ │ • MonsterDB │ │ • ProgressRepository    ││
│  │ • Skill     │ │ • SkillDB   │ │ • EquipmentRepository   ││
│  │ • Challenge │ │             │ │                         ││
│  │ • Equipment │ │             │ │                         ││
│  │ • Progress  │ │             │ │                         ││
│  └─────────────┘ └─────────────┘ └─────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### 2.2 폴더 구조

```
lib/
├── main.dart                    # 앱 진입점
├── core/                        # 핵심 유틸리티
│   ├── constants/               # 게임 상수 정의
│   ├── resources/               # 스프라이트 관리
│   └── utils/                   # 유틸리티 함수
├── data/                        # 데이터 레이어
│   ├── models/                  # 데이터 모델 정의
│   ├── tables/                  # 정적 데이터 테이블
│   └── repositories/            # 데이터 접근 계층
├── game/                        # 게임 로직
│   ├── vam_game.dart            # 메인 게임 클래스
│   ├── systems/                 # 게임 시스템
│   ├── components/              # 게임 오브젝트
│   │   ├── actors/              # 플레이어, 몬스터
│   │   ├── projectiles/         # 투사체
│   │   ├── effects/             # 이펙트
│   │   ├── items/               # 아이템 (경험치 젬)
│   │   └── weapons/             # 무기 (회전형)
│   ├── camera/                  # 카메라 시스템
│   └── input/                   # 입력 처리
└── presentation/                # UI 레이어
    ├── screens/                 # 화면 위젯
    ├── overlays/                # 게임 오버레이
    └── widgets/                 # 재사용 위젯
```

---

## 3. 핵심 시스템 설계

### 3.1 스킬 시스템

게임의 핵심인 스킬 시스템은 5가지 카테고리로 구분됩니다.

#### 스킬 카테고리

| 카테고리 | 설명 | 예시 |
|----------|------|------|
| **Projectile** | 적을 향해 투사체 발사 | 에너지 볼트, 독 화살 |
| **Area** | 주변 적에게 범위 피해 | 화염 폭발 |
| **Orbit** | 플레이어 주변 회전 공격 | 회전 검 |
| **Passive** | 영구적 스탯 강화 | 이동속도, 체력, 공격력 증가 |
| **Chaining** | 적 사이를 연쇄 타격 | 번개 연쇄 |

#### 스킬 데이터 모델

```dart
class SkillData {
  final String id;
  final String name;
  final SkillCategory category;
  final SkillRarity rarity;
  final int maxLevel;
  final double baseDamage;
  final double cooldown;
  final double range;
  final double projectileSpeed;
  final int projectileCount;
  final bool piercing;          // 관통 여부
  final int pierceCount;        // 관통 횟수
  final bool chaining;          // 연쇄 여부
  final int chainCount;         // 연쇄 횟수
  final double chainRange;      // 연쇄 탐색 범위
  // ...
}
```

#### 레벨별 스케일링 시스템

스킬은 레벨업 시 다양한 요소가 강화됩니다:

```dart
/// 레벨별 데미지 계산
double GetDamageAtLevel(int level) {
  // 레벨별 배율: 1.0, 1.3, 1.6, 2.0, 2.5
  const multipliers = [1.0, 1.0, 1.3, 1.6, 2.0, 2.5];
  return baseDamage * multipliers[level.clamp(0, 5)];
}

/// 레벨별 쿨다운 감소
double GetCooldownAtLevel(int level) {
  if (level >= 5) return cooldown * 0.7;   // 30% 감소
  if (level >= 3) return cooldown * 0.85;  // 15% 감소
  return cooldown;
}

/// 레벨별 투사체 증가
int GetProjectileCountAtLevel(int level) {
  int count = projectileCount;
  if (level >= 2) count++;
  if (level >= 4) count++;
  return count;
}
```

### 3.2 도전 모드 시스템

게임에 다양성을 부여하는 도전 모드 시스템입니다.

#### 도전 타입

| 타입 | 설명 | 클리어 조건 |
|------|------|-------------|
| **Endless** | 무한 웨이브 | 목표 웨이브 도달 |
| **TimeAttack** | 타임어택 | 제한 시간 내 목표 처치 |
| **Survival** | 서바이벌 | 강화된 적 사이에서 생존 |

#### 난이도 변수 시스템 (Modifier)

각 도전은 게임 규칙을 변경하는 변수를 가집니다:

```dart
class ChallengeModifier {
  final double enemyHpMultiplier;      // 적 체력 배율
  final double enemyDamageMultiplier;  // 적 공격력 배율
  final double spawnRateMultiplier;    // 스폰 속도 배율
  final double expMultiplier;          // 경험치 배율
  final bool noHealing;                // 회복 불가
  final bool eliteOnly;                // 엘리트만 출현
}
```

#### 도전 예시: 악몽의 밤

```dart
static const ChallengeData SURVIVAL_NIGHTMARE = ChallengeData(
  id: 'challenge_survival_nightmare',
  name: '악몽의 밤',
  description: '최악의 조건에서 살아남으세요.',
  type: ChallengeType.survival,
  difficulty: ChallengeDifficulty.nightmare,
  unlockLevel: 10,
  prerequisiteId: 'challenge_survival_normal',  // 선행 조건
  condition: ChallengeCondition(targetTime: 180),
  rewards: [
    ChallengeReward(type: ChallengeRewardType.gold, amount: 2000),
    ChallengeReward(type: ChallengeRewardType.gem, amount: 50),
    ChallengeReward(
      type: ChallengeRewardType.equipment,
      itemId: 'equip_dragon_scale',
      amount: 1,
    ),
  ],
  modifier: ChallengeModifier(
    enemyHpMultiplier: 2.0,       // 적 체력 200%
    enemyDamageMultiplier: 2.0,   // 적 공격력 200%
    spawnRateMultiplier: 1.5,     // 스폰 속도 150%
    noHealing: true,              // 회복 불가
    eliteOnly: true,              // 엘리트만 출현
  ),
);
```

### 3.3 몬스터 AI 시스템

몬스터는 타입에 따라 다른 행동 패턴을 가집니다.

#### 몬스터 타입별 행동

| 타입 | 이동 | 특수 능력 |
|------|------|-----------|
| **Normal** | 플레이어 추적 | 없음 |
| **Elite** | 플레이어 추적 | 원거리 투사체 발사 |
| **Boss** | 플레이어 추적 | 돌진 공격 (차지 패턴) |

#### 보스 AI 상태 머신

```dart
enum BossAttackState {
  idle,       // 대기 - 플레이어 추적
  preparing,  // 준비 - 돌진 방향 표시
  charging,   // 돌진 - 직선 이동 + 범위 피해
}

void _updateBossAttack(double dt) {
  switch (mBossState) {
    case BossAttackState.idle:
      _updateBossIdle(dt);      // 쿨다운 체크 → preparing 전환
      break;
    case BossAttackState.preparing:
      _updateBossPreparing(dt); // 방향 표시 → charging 전환
      break;
    case BossAttackState.charging:
      _updateBossCharging(dt);  // 돌진 실행 → idle 전환
      break;
  }
}
```

### 3.4 스폰 시스템

웨이브 기반 스폰과 특수 몬스터 출현 로직을 관리합니다.

#### 엘리트 스폰 조건

```dart
// 웨이브 기반 엘리트 스폰
void CheckEliteSpawnByWave(int currentWave) {
  if (currentWave - mLastEliteWave >= ELITE_WAVE_INTERVAL) {
    mLastEliteWave = currentWave;
    SpawnElite();
  }
}

// 킬 수 기반 엘리트 스폰 (확률 증가)
void CheckEliteSpawnByKill(int totalKills) {
  if (totalKills - mLastKillCheck >= ELITE_KILL_INTERVAL) {
    mLastKillCheck = totalKills;
    mEliteSpawnChance += ELITE_CHANCE_INCREMENT;

    if (Random().nextDouble() < mEliteSpawnChance) {
      SpawnElite();
      mEliteSpawnChance = ELITE_BASE_CHANCE;  // 확률 리셋
    }
  }
}
```

---

## 4. 캐릭터 시스템

### 4.1 캐릭터 목록

| 캐릭터 | 등급 | 특징 | 기본 스킬 |
|--------|------|------|-----------|
| **특공대원** | Common | 균형 잡힌 스탯 | 에너지 볼트 |
| **검사** | Common | 고공격력, 고크리티컬 | 회전 검 |
| **화염 마법사** | Rare | 강력한 범위 공격 | 화염 폭발 |
| **궁수** | Rare | 빠른 이동, 관통 공격 | 독 화살 |
| **번개 마법사** | Epic | 다중 타겟 연쇄 공격 | 번개 연쇄 |

### 4.2 캐릭터 스탯 구조

```dart
class ActorStats {
  final double hp;        // 체력
  final double atk;       // 공격력
  final double def;       // 방어력
  final double spd;       // 이동 속도
  final double critRate;  // 크리티컬 확률 (%)
  final double critDmg;   // 크리티컬 데미지 (%)
}

// 예시: 번개 마법사
static const CharacterData STORMCALLER = CharacterData(
  id: 'char_stormcaller',
  name: '번개 마법사',
  rarity: CharacterRarity.epic,
  baseStats: ActorStats(
    hp: 65,          // 낮은 체력
    atk: 20,         // 높은 공격력
    def: 2,          // 낮은 방어력
    spd: 2.8,        // 보통 이동속도
    critRate: 12.0,  // 높은 크리티컬 확률
    critDmg: 200.0,  // 높은 크리티컬 데미지
  ),
  baseSkillId: 'skill_chain_lightning',
);
```

---

## 5. 게임 루프 및 핵심 코드

### 5.1 메인 게임 클래스

```dart
class VamGame extends FlameGame
    with HasCollisionDetection, DragCallbacks {

  // 게임 시스템
  late final CombatSystem combatSystem;
  late final SpawnSystem spawnSystem;
  late final WaveSystem waveSystem;
  late final LevelSystem levelSystem;
  late final SkillSystem skillSystem;
  late final ChallengeSystem challengeSystem;

  // 게임 상태
  double mElapsedTime = 0;
  bool mIsPaused = false;
  bool mIsGameOver = false;
  int mKillCount = 0;

  @override
  void update(double dt) {
    if (mIsPaused || mIsGameOver) return;
    super.update(dt);

    mElapsedTime += dt;

    // 시스템 업데이트
    spawnSystem.Update(dt);
    waveSystem.Update(dt);
    skillSystem.Update(dt);
    challengeSystem.Update(dt);
  }
}
```

### 5.2 스킬 발사 로직

```dart
void _fireProjectileSkill(EquippedSkill equipped) {
  final skill = equipped.skillData;
  final player = mGame.player;

  // 가장 가까운 몬스터 탐색
  final target = _findNearestMonster(player.position, skill.range);
  if (target == null) return;

  // 발사 방향 계산
  final direction = (target.position - player.position).normalized();

  // 투사체 수만큼 생성
  final count = skill.GetProjectileCountAtLevel(equipped.level);
  final spreadAngle = skill.spreadAngle;

  for (int i = 0; i < count; i++) {
    // 확산 각도 적용
    final angle = spreadAngle * (i - (count - 1) / 2);
    final rotatedDir = _rotateVector(direction, angle);

    // 투사체 생성
    mGame.add(SkillProjectile(
      skillData: skill,
      level: equipped.level,
      startPosition: player.position,
      direction: rotatedDir,
      damageBonus: mDamageBonus,
    ));
  }
}
```

### 5.3 연쇄 번개 시스템

```dart
void _chainToNextTarget() {
  if (mChainCount <= 0 || !mIsActive) return;

  // 이미 맞은 몬스터 제외하고 범위 내 다음 타겟 탐색
  Monster? nextTarget;
  double minDistance = mSkillData.chainRange;

  for (final component in mGame.children) {
    if (component is Monster &&
        component.mIsAlive &&
        !mHitMonsters.contains(component)) {
      final distance = (component.position - position).length;
      if (distance < minDistance) {
        minDistance = distance;
        nextTarget = component;
      }
    }
  }

  if (nextTarget != null) {
    // 다음 타겟으로 이동
    mHitMonsters.add(nextTarget);
    mChainCount--;
    position = nextTarget.position;
    nextTarget.TakeDamage(mDamage);
  } else {
    Destroy();  // 더 이상 타겟 없으면 소멸
  }
}
```

---

## 6. 기술적 특징 및 문제 해결

### 6.1 비동기 안전성 처리

도전 모드 클리어 시 중복 처리 방지:

```dart
class ChallengeSystem {
  bool mIsProcessingResult = false;  // 결과 처리 중 플래그

  void _onChallengeCleared() async {
    // 중복 처리 방지
    if (mIsProcessingResult) return;
    mIsProcessingResult = true;

    try {
      await _saveProgressWithId(mCurrentChallenge!.id);
      await _grantRewardsFrom(mCurrentChallenge!);
      mGame.Victory();
    } finally {
      mIsProcessingResult = false;
    }
  }
}
```

### 6.2 멀티플랫폼 입력 처리

조이스틱 기반 이동 시스템:

```dart
class JoystickController {
  Vector2 mDirection = Vector2.zero();
  bool mIsActive = false;

  void OnDragStart(DragStartDetails details) {
    mIsActive = true;
  }

  void OnDragUpdate(DragUpdateDetails details) {
    // 드래그 방향을 정규화된 벡터로 변환
    final delta = details.localPosition - mCenterPosition;
    if (delta.length > mDeadZone) {
      mDirection = Vector2(delta.dx, delta.dy).normalized();
    }
  }

  void OnDragEnd() {
    mIsActive = false;
    mDirection = Vector2.zero();
  }
}
```

### 6.3 성능 최적화

- **오브젝트 풀링**: 투사체, 이펙트 재사용으로 GC 부담 감소
- **공간 분할**: 충돌 검사 최적화
- **비동기 로딩**: 스프라이트 사전 로딩으로 게임 중 끊김 방지

---

## 7. 사용 기술 스택

### 7.1 프레임워크 및 라이브러리

| 분류 | 기술 | 용도 |
|------|------|------|
| **프레임워크** | Flutter 3.10+ | 멀티플랫폼 UI |
| **게임 엔진** | Flame 1.14 | 게임 루프, 충돌 처리 |
| **오디오** | Flame Audio 2.1 | BGM, 효과음 |
| **상태 관리** | Riverpod 2.4 | 앱 상태 관리 |
| **로컬 저장** | SharedPreferences | 설정, 진행 데이터 |
| **로컬 DB** | Hive 2.2 | 복잡한 데이터 저장 |

### 7.2 개발 환경

- **IDE**: Android Studio / VS Code
- **버전 관리**: Git
- **빌드**: Flutter CLI, Gradle (Android), Xcode (iOS)

---

## 8. 프로젝트 구조 통계

| 항목 | 수치 |
|------|------|
| **총 Dart 파일** | ~50개 |
| **시스템 클래스** | 7개 |
| **데이터 모델** | 10개 |
| **UI 화면** | 7개 |
| **게임 컴포넌트** | 15개 |
| **캐릭터 종류** | 5종 |
| **스킬 종류** | 8종 |
| **도전 모드** | 6개 |
| **몬스터 타입** | 3종 (일반/엘리트/보스) |
