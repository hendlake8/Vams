# VAM 프로젝트 아키텍처

## 프로젝트 개요
- **타입**: 뱀서라이크 슈팅 게임 (Vampire Survivors 스타일)
- **프레임워크**: Flutter + Flame 게임 엔진
- **플랫폼**: Android, iOS, Web, Windows

## 핵심 시스템 구조

### 게임 시스템 (`lib/game/systems/`)
- `challenge_system.dart` - 도전 모드 관리, 클리어 조건, 보상 처리
- `progress_system.dart` - 영구 진행 데이터 저장 (SharedPreferences)
- `skill_system.dart` - 스킬 발동 및 관리
- `spawn_system.dart` - 몬스터 스폰 관리
- `wave_system.dart` - 웨이브 관리
- `combat_system.dart` - 전투 계산

### 데이터 모델 (`lib/data/models/`)
- `challenge_data.dart` - 도전 정의 (ChallengeData, ChallengeCondition)
- `progress_data.dart` - 저장 데이터 (ProgressData, CurrencyData, ChallengeRecordData)
- `skill_data.dart` - 스킬 정의 (SkillData, DefaultSkills)
- `equipment_data.dart` - 장비 정의

### 화면 (`lib/presentation/screens/`)
- `game_screen.dart` - 게임 플레이 화면
- `challenge_screen.dart` - 도전 모드 선택 화면
- `character_select_screen.dart` - 캐릭터 선택
- `main_lobby_screen.dart` - 메인 로비

## 도전 모드 흐름

```
메인 로비
  ↓ (도전 모드 버튼)
ChallengeScreen
  ↓ (도전 선택 → onChallengeSelected 콜백)
CharacterSelectScreen (challengeId 전달)
  ↓ (캐릭터 선택)
GameScreen (challengeId 전달)
  ↓ (initState에서 StartChallenge 호출)
VamGame.challengeSystem.StartChallenge()
  ↓ (게임 플레이)
challengeSystem.Update() 매 프레임 호출
  ↓ (클리어 조건 달성)
_checkClearCondition() → _onChallengeCleared()
  ↓
_saveProgressWithId() → ProgressSystem.OnGameEnd()
_grantRewardsFrom() → ProgressSystem.AddCurrency()
mGame.Victory()
```

## 코딩 컨벤션
- 멤버 변수: `m` 접두사 (mCurrentWave, mIsAlive)
- 상수: UPPER_SNAKE_CASE (WAVE_INTERVAL, BOSS_CHARGE_SPEED)
- 함수/메서드: PascalCase (StartChallenge, GetStatus)
- 한국어 주석 사용

## 주요 파일 수정 이력 (이번 세션)
1. `challenge_system.dart` - 비동기 안전성, 중복 처리 방지, 디버그 로그
2. `progress_system.dart` - 디버그 로그 추가
3. `game_screen.dart` - StartChallenge 결과 확인 로그
