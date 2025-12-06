/// 스프라이트 리소스 경로 상수
/// Flame.images.load()는 assets/images/ 폴더를 루트로 사용
class SpritePaths {
  // 액터 경로 (assets/images/ 기준)
  static const String HEROES = 'actors/heroes/';
  static const String MONSTERS = 'actors/monsters/';
  static const String BOSSES = 'actors/bosses/';

  // 배경 경로
  static const String BACKGROUNDS = 'backgrounds/';

  // 이펙트 경로
  static const String EFFECTS = 'effects/';

  // UI 경로
  static const String UI = 'ui/';

  // 헬퍼 메서드
  static String Hero(int index) => '${HEROES}hero_$index.png';
  static String Monster(int index) => '${MONSTERS}monster_$index.png';
  static String Boss(int index) => '${BOSSES}boss_$index.png';
  static String Background(int index) => '${BACKGROUNDS}bg_$index.png';
  static String Effect(String name) => '${EFFECTS}fx_$name.png';
}
