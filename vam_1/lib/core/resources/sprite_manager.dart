import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'sprite_paths.dart';

/// 스프라이트 로딩 및 캐싱 관리
class SpriteManager {
  static final SpriteManager instance = SpriteManager._();
  SpriteManager._();

  final Map<String, Sprite> _cache = {};
  bool _initialized = false;

  /// 초기화
  Future<void> Initialize(FlameGame game) async {
    if (_initialized) return;
    _initialized = true;
  }

  /// 스프라이트 가져오기 (캐싱)
  Future<Sprite> GetSprite(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }

    final image = await Flame.images.load(path);
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

  /// 초기화 여부
  bool get isInitialized => _initialized;
}
