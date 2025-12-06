/// 게임 상수 정의
class GameConstants {
  GameConstants._();

  // 게임 기본 설정
  static const String GAME_TITLE = '뱀서라이크 슈팅';
  static const String GAME_VERSION = '0.1.0';

  // 플레이어 기본값
  static const int DEFAULT_PLAYER_HP = 100;
  static const int DEFAULT_PLAYER_ATK = 10;
  static const int DEFAULT_PLAYER_DEF = 5;
  static const double DEFAULT_PLAYER_SPD = 5.0;
  static const double DEFAULT_PLAYER_CRIT_RATE = 5.0;
  static const double DEFAULT_PLAYER_CRIT_DMG = 150.0;

  // 스킬 시스템
  static const int MAX_SKILL_SLOTS = 6;
  static const int MAX_SKILL_LEVEL = 5;
  static const int SKILL_CHOICES_COUNT = 3;

  // 경험치 시스템
  static const int BASE_EXP_REQUIRED = 10;
  static const int EXP_INCREMENT = 10;

  // 젬 경험치
  static const int EXP_GEM_SMALL = 1;
  static const int EXP_GEM_MEDIUM = 5;
  static const int EXP_GEM_LARGE = 20;

  // 젬 드롭 확률
  static const double DROP_RATE_SMALL = 0.70;
  static const double DROP_RATE_MEDIUM = 0.25;
  static const double DROP_RATE_LARGE = 0.05;

  // 젬 자석 범위
  static const double DEFAULT_MAGNET_RADIUS = 1.5;
  static const double MAX_MAGNET_RADIUS = 5.0;
  static const double MAGNET_RADIUS_PER_LEVEL = 0.5;

  // 전투 시스템
  static const double INVINCIBILITY_DURATION = 0.5;
  static const double DEFAULT_CRIT_MULTIPLIER = 1.5;
  static const double MAX_CRIT_MULTIPLIER = 3.0;

  // 스테이지
  static const double STAGE_DURATION = 180.0; // 3분
  static const double WAVE1_DURATION = 60.0;
  static const double MID_BOSS_DURATION = 30.0;
  static const double WAVE2_DURATION = 70.0;

  // 몬스터 스폰
  static const double DEFAULT_SPAWN_INTERVAL = 0.5;
  static const int MAX_MONSTERS_ON_SCREEN = 200;
  static const double SPAWN_DISTANCE_FROM_SCREEN = 2.0;

  // 체력 회복
  static const double HEAL_PERCENT_ON_MASS_EXP = 0.05;
}
