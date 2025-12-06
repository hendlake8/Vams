/// 리소스 경로 상수
class AssetPaths {
  AssetPaths._();

  // 기본 경로
  static const String _images = 'assets/images';
  static const String _audio = 'assets/audio';
  static const String _data = 'assets/data';

  // Actor 경로
  static const String actors = '$_images/actors';
  static const String heroes = '$actors/heroes';
  static const String monsters = '$actors/monsters';
  static const String bosses = '$actors/bosses';
  static const String pets = '$actors/pets';

  // 배경 경로
  static const String backgrounds = '$_images/backgrounds';

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
  static const String uiBackgrounds = '$ui/backgrounds';

  // 맵 경로
  static const String maps = '$_images/maps';

  // 오디오 경로
  static const String bgm = '$_audio/bgm';
  static const String sfx = '$_audio/sfx';

  // 데이터 경로
  static const String dataCharacters = '$_data/characters.json';
  static const String dataEquipment = '$_data/equipment.json';
  static const String dataSkills = '$_data/skills.json';
  static const String dataMonsters = '$_data/monsters.json';
  static const String dataStages = '$_data/stages.json';

  // 동적 경로 생성
  static String heroSprite(String heroId, String state) =>
      '$heroes/hero_${heroId}_$state.png';

  static String monsterSprite(String monsterId, String state) =>
      '$monsters/mon_${monsterId}_$state.png';

  static String bossSprite(String bossId, String state) =>
      '$bosses/boss_${bossId}_$state.png';

  static String petSprite(String petId, String state) =>
      '$pets/pet_${petId}_$state.png';

  static String backgroundTile(String bgId) =>
      '$backgrounds/${bgId}_tile.png';

  static String weaponSprite(String weaponId) =>
      '$weapons/weapon_$weaponId.png';

  static String skillIcon(String skillId) =>
      '$icons/skill_$skillId.png';

  static String itemSprite(String itemId) =>
      '$items/item_$itemId.png';

  static String effectSprite(String effectId) =>
      '$effects/effect_$effectId.png';
}
