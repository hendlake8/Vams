import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/resources/sprite_manager.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/actor_stats.dart';
import '../../vam_game.dart';
import '../effects/damage_text.dart';
import '../items/exp_gem.dart';
import 'player.dart';

/// 몬스터 컴포넌트
class Monster extends PositionComponent with HasGameReference<VamGame>, CollisionCallbacks {
  final String mMonsterId;
  final bool isElite;
  final bool isBoss;

  // 스탯
  late ActorStats mStats;
  int mCurrentHp = 0;
  bool mIsAlive = true;

  // 드롭 정보
  int mExpDrop = 1;
  int mGoldDrop = 1;

  // 시각적 요소
  SpriteComponent? mSprite;
  RectangleComponent? mFallbackBody;

  // 콜백
  VoidCallback? mOnRemoveCallback;

  Monster({
    required String monsterId,
    required Vector2 position,
    this.isElite = false,
    this.isBoss = false,
  })  : mMonsterId = monsterId,
        super(
          position: position,
          size: _getSize(isElite, isBoss),
          anchor: Anchor.center,
        );

  static Vector2 _getSize(bool isElite, bool isBoss) {
    if (isBoss) return Vector2(96, 96);
    if (isElite) return Vector2(64, 64);
    return Vector2(40, 40);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 스탯 설정
    _initStats();

    // 스프라이트 로드 시도
    try {
      final sprite = await _loadSprite();
      mSprite = SpriteComponent(
        sprite: sprite,
        size: size,
      );
      add(mSprite!);
      Logger.game('Monster sprite loaded: ${_getSpriteType()}');
    } catch (e) {
      // 스프라이트 로드 실패 시 폴백
      Logger.game('Monster sprite load failed, using fallback: $e');
      mFallbackBody = RectangleComponent(
        size: size,
        paint: Paint()..color = _getColor(),
      );
      add(mFallbackBody!);
    }

    // 히트박스
    add(CircleHitbox(radius: size.x / 2 - 4));
  }

  /// 몬스터 타입에 따른 스프라이트 로드
  Future<Sprite> _loadSprite() async {
    if (isBoss) {
      return SpriteManager.instance.GetBossSprite(0);
    } else if (isElite) {
      return SpriteManager.instance.GetMonsterSprite(1);  // monster_1 = 엘리트/중간보스
    } else {
      return SpriteManager.instance.GetMonsterSprite(0);  // monster_0 = 기본 잡몹
    }
  }

  /// 디버그용 스프라이트 타입 문자열
  String _getSpriteType() {
    if (isBoss) return 'boss_0';
    if (isElite) return 'monster_1 (elite)';
    return 'monster_0';
  }

  void _initStats() {
    if (isBoss) {
      mStats = const ActorStats(
        hp: 5000,
        atk: 50,
        def: 20,
        spd: 1.0,
        critRate: 0,
        critDmg: 0,
      );
      mExpDrop = 500;
      mGoldDrop = 1000;
    } else if (isElite) {
      mStats = const ActorStats(
        hp: 50,
        atk: 10,
        def: 5,
        spd: 1.5,
        critRate: 0,
        critDmg: 0,
      );
      mExpDrop = 10;
      mGoldDrop = 20;
    } else {
      mStats = const ActorStats(
        hp: 10,
        atk: 5,
        def: 1,
        spd: 2.0,
        critRate: 0,
        critDmg: 0,
      );
      mExpDrop = 1;
      mGoldDrop = 1;
    }

    mCurrentHp = mStats.hp;
  }

  Color _getColor() {
    if (isBoss) return Colors.purple;
    if (isElite) return Colors.orange;
    return Colors.red;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!mIsAlive) return;

    // 플레이어 추적
    _chasePlayer(dt);
  }

  void _chasePlayer(double dt) {
    final playerPos = game.player.position;
    final direction = (playerPos - position).normalized();

    position += direction * mStats.spd * 60 * dt;
  }

  /// 피해 받기
  void TakeDamage(int damage, {bool isCritical = false}) {
    if (!mIsAlive) return;

    mCurrentHp -= damage;

    // 데미지 텍스트 표시
    final damageText = DamageText(
      position: position.clone() + Vector2(0, -size.y / 2),
      damage: damage,
      isCritical: isCritical,
    );
    game.world.add(damageText);

    // 피격 이펙트 (깜빡임)
    if (mSprite != null) {
      mSprite!.opacity = 0.5;
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mIsAlive && mSprite != null) {
          mSprite!.opacity = 1.0;
        }
      });
    } else if (mFallbackBody != null) {
      mFallbackBody!.paint.color = Colors.white;
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mIsAlive && mFallbackBody != null) {
          mFallbackBody!.paint.color = _getColor();
        }
      });
    }

    if (mCurrentHp <= 0) {
      Die();
    }
  }

  /// 사망
  void Die() {
    mIsAlive = false;

    // 사망 시각 효과
    if (mSprite != null) {
      mSprite!.opacity = 0.5;
    } else if (mFallbackBody != null) {
      mFallbackBody!.paint.color = Colors.grey;
    }

    // 경험치 젬 드롭
    _spawnDrops();

    // 킬 카운트 증가
    game.AddKill();

    Logger.combat('Monster $mMonsterId died');

    // 잠시 후 제거
    Future.delayed(const Duration(milliseconds: 200), () {
      mOnRemoveCallback?.call();
      removeFromParent();
    });
  }

  void _spawnDrops() {
    // 경험치 젬 드롭
    final gem = ExpGem(
      position: position.clone(),
      expAmount: mExpDrop,
    );
    game.world.add(gem);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Player && mIsAlive) {
      // 플레이어에게 접촉 데미지
      final result = game.combatSystem.CalculateDamage(
        attacker: mStats,
        defender: other.stats,
      );
      other.TakeDamage(result.damage);
    }
  }
}
