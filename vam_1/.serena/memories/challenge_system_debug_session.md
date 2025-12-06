# 도전 모드 디버깅 세션 (2025-12-07)

## 문제 상황
- 도전 모드 클리어해도 보석 지급 안됨
- 도전 모드 클리어해도 다음 도전(무한의 시련 II) 해금 안됨
- 앱 재시작해도 클리어 전 수치 유지 (저장 문제)

## 발견된 버그들

### 1. 비동기 처리 중 데이터 참조 문제
**파일**: `lib/game/systems/challenge_system.dart`
**문제**: `await` 이후 `mCurrentChallenge`가 변경될 수 있음
**수정**: 
```dart
// 비동기 작업 전에 로컬 변수에 저장
final challenge = mCurrentChallenge!;
final challengeId = challenge.id;
final rewards = challenge.rewards;
await _saveProgressWithId(challengeId: challengeId, cleared: true);
await _grantRewardsFrom(rewards);  // 로컬 변수 사용
```

### 2. 중복 처리 문제
**문제**: 매 프레임 클리어 조건 체크로 `_onChallengeCleared()` 중복 호출 가능
**수정**: `mIsProcessingResult` 플래그 추가
```dart
if (mIsProcessingResult) return;
if (_checkClearCondition()) {
  mIsProcessingResult = true;
  _onChallengeCleared();
}
```

### 3. 호출 순서 문제
**문제**: `_grantRewards()` 호출 후 `_saveProgress()`가 데이터를 덮어씀
**수정**: 순서 변경 - `_saveProgress()` 먼저 → `_grantRewards()` 나중

### 4. await 누락
**문제**: `_saveProgress()`가 `void`로 선언되어 await 없이 호출됨
**수정**: `Future<void>`로 변경하고 await 추가

## 추가된 디버그 로그

### challenge_system.dart
- `StartChallenge()`: 도전 시작 성공/실패 상세 로그
- `_onChallengeCleared()`: 클리어 처리 흐름 로그
- `_grantRewardsFrom()`: 보상 지급 전/후 보석 수 로그

### progress_system.dart
- `OnGameEnd()`: 도전 기록 업데이트 전/후 `isCleared` 값 로그
- `Initialize()`: 앱 시작 시 불러온 도전 기록 로그

### game_screen.dart
- `StartChallenge()` 성공/실패 여부 로그

## 핵심 흐름 확인 포인트

1. 도전 시작: `StartChallenge called with id: challenge_endless_normal`
2. 도전 시작 성공: `Challenge started successfully: 무한의 시련`
3. 웨이브 증가: `Wave advanced: 10`
4. 클리어 처리: `Challenge cleared: 무한의 시련 (id: challenge_endless_normal)`
5. 기록 저장: `Challenge record after UpdateRecord: isCleared=true`
6. 보석 지급: `Currency granted: ... (gems: X -> X+10)`

## 미해결 의문점
- "웨이브 10 도달" 기록은 있지만 `isCleared`가 `true`가 아님
- 도전 모드가 정상 시작되었는지 로그로 확인 필요

## 다음 단계
1. 앱 실행 후 디버그 로그 확인
2. `StartChallenge` 성공 여부 확인
3. `_onChallengeCleared()` 호출 여부 확인
4. `isCleared=true` 저장 여부 확인
