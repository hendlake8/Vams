# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

Flutter 멀티플랫폼 애플리케이션 (Android, iOS, Web, Windows, Linux, macOS 지원)

- **프레임워크**: Flutter
- **Dart SDK**: ^3.10.1
- **린터**: flutter_lints ^6.0.0

## 주요 명령어

```bash
# 의존성 설치
flutter pub get

# 개발 실행
flutter run                    # 기본 디바이스
flutter run -d chrome          # 웹 브라우저
flutter run -d windows         # Windows 앱
flutter run -d android         # Android 에뮬레이터/기기

# 빌드
flutter build apk              # Android APK
flutter build ios              # iOS
flutter build web              # Web
flutter build windows          # Windows

# 테스트
flutter test                   # 전체 테스트
flutter test test/widget_test.dart  # 단일 테스트 파일

# 코드 분석
flutter analyze                # 린트 검사
dart format lib/               # 코드 포맷팅
```

## 코드 아키텍처

### 권장 폴더 구조
```
lib/
├── main.dart           # 앱 진입점
├── screens/            # UI 화면
├── widgets/            # 재사용 위젯
├── models/             # 데이터 모델
├── services/           # API/비즈니스 로직
└── utils/              # 유틸리티 함수
```

### 플랫폼별 네이티브 코드
- `android/` - Gradle Kotlin DSL (.kts)
- `ios/` - Xcode/CocoaPods
- `web/` - index.html, PWA manifest
- `windows/`, `linux/`, `macos/` - CMake

## 작업 규칙

### 빌드 정책
- **빌드는 사용자가 명시적으로 요청할 때만 수행한다**
- 코드 수정 후 자동으로 빌드하지 않는다
- 빌드 필요 여부가 불명확할 경우 사용자에게 확인한다

### 문서 저장 정책
- **문서는 사용자가 명시적으로 요청할 때만 저장한다**
- 조사, 기획, 구현 설계, 구현 문서 등 모든 문서 저장은 사용자 요청 시에만 수행
- 문서 저장 위치:
  ```
  Report/
  ├── Research/     # 조사 문서
  ├── 기획서/        # 기획 문서
  ├── 설계/          # 구현 설계 문서
  └── 구현/          # 구현 문서
  ```

## 코딩 규칙

### Dart 명명 규칙
```dart
// 클래스, 위젯: PascalCase
class UserProfile extends StatelessWidget { }

// 함수, 변수: camelCase
void getUserData() { }
String userName;

// 상수: UPPER_SNAKE_CASE
const int MAX_RETRY_COUNT = 3;

// Private 멤버: 언더스코어 접두사
String _privateData;
void _internalMethod() { }
```

### Widget 작성
- 불변 위젯에 `const` 생성자 사용
- `super.key` 포함
- StatelessWidget 우선 사용, 필요시에만 StatefulWidget

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
```
