import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/resources/sprite_manager.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/actor_stats.dart';
import '../../vam_game.dart';
import '../effects/charge_indicator.dart';
import '../effects/damage_text.dart';
import '../items/exp_gem.dart';
import '../projectiles/monster_projectile.dart';
import 'player.dart';

/// 보스 공격 상태
enum BossAttackState {
  idle,       // 대기 (추적 중)
  preparing,  // 돌진 준비 (전조 표시)
  charging,   // 돌진 중
}

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

  // === 엘리트 공격 관련 ===
  static const double ELITE_ATTACK_COOLDOWN = 0.8;
  static const double ELITE_PROJECTILE_SPEED = 300;
  static const int ELITE_PROJECTILE_DAMAGE = 8;
  double mEliteAttackTimer = 0;

  // === 보스 공격 관련 ===
  static const double BOSS_CHARGE_COOLDOWN = 15.0;
  static const double BOSS_PREPARE_TIME = 2.0;
  static const double BOSS_CHARGE_SPEED_MULTIPLIER = 6.0;  // 기본속도 x 6 (2.0 → 6.0)
  static const double BOSS_CHARGE_WIDTH = 200;
  static const double BOSS_CHARGE_LENGTH = 600;
  static const int BOSS_CHARGE_DAMAGE = 30;

  BossAttackState mBossState = BossAttackState.idle;
  double mBossChargeCooldown = 5.0;  // 초기 5초 후 첫 공격
  double mBossPrepareTimer = 0;
  double mBossChargeDistance = 0;
  Vector2? mBossChargeDirection;
  Vector2? mBossChargeStartPos;
  ChargeIndicator? mChargeIndicator;

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

    // 타입별 업데이트
    if (isBoss) {
      _updateBossAttack(dt);
    } else if (isElite) {
      _updateEliteAttack(dt);
      _chasePlayer(dt);
    } else {
      _chasePlayer(dt);
    }
  }

  void _chasePlayer(double dt) {
    final playerPos = game.player.position;
    final direction = (playerPos - position).normalized();

    position += direction * mStats.spd * 60 * dt;
  }

  // === 엘리트 공격 로직 ===

  void _updateEliteAttack(double dt) {
    mEliteAttackTimer -= dt;

    if (mEliteAttackTimer <= 0) {
      _fireProjectile();
      mEliteAttackTimer = ELITE_ATTACK_COOLDOWN;
    }
  }

  void _fireProjectile() {
    if (!game.player.mIsAlive) return;

    final playerPos = game.player.position;
    final direction = (playerPos - position).normalized();

    final projectile = MonsterProjectile(
      position: position.clone(),
      direction: direction,
      speed: ELITE_PROJECTILE_SPEED,
      damage: ELITE_PROJECTILE_DAMAGE,
    );
    game.world.add(projectile);
  }

  // === 보스 공격 로직 ===

  void _updateBossAttack(double dt) {
    switch (mBossState) {
      case BossAttackState.idle:
        _updateBossIdle(dt);
        break;
      case BossAttackState.preparing:
        _updateBossPreparing(dt);
        break;
      case BossAttackState.charging:
        _updateBossCharging(dt);
        break;
    }
  }

  void _updateBossIdle(double dt) {
    // 일반 추적
    _chasePlayer(dt);

    // 쿨다운 감소
    mBossChargeCooldown -= dt;

    if (mBossChargeCooldown <= 0 && game.player.mIsAlive) {
      _startChargePreparation();
    }
  }

  void _startChargePreparation() {
    mBossState = BossAttackState.preparing;
    mBossPrepareTimer = BOSS_PREPARE_TIME;

    // 돌진 방향 결정 (현재 플레이어 방향으로 고정)
    final playerPos = game.player.position;
    mBossChargeDirection = (playerPos - position).normalized();
    mBossChargeStartPos = position.clone();

    // 전조 표시 생성
    mChargeIndicator = ChargeIndicator(
      startPos: position.clone(),
      direction: mBossChargeDirection!,
      width: BOSS_CHARGE_WIDTH,
      length: BOSS_CHARGE_LENGTH,
    );
    game.world.add(mChargeIndicator!);

    Logger.game('Boss starting charge preparation');
  }

  void _updateBossPreparing(double dt) {
    mBossPrepareTimer -= dt;

    // 준비 중에는 이동하지 않음 (제자리에서 대기)

    if (mBossPrepareTimer <= 0) {
      _performCharge();
    }
  }

  void _performCharge() {
    mBossState = BossAttackState.charging;
    mBossChargeDistance = 0;

    // 전조 표시 제거
    mChargeIndicator?.removeFromParent();
    mChargeIndicator = null;

    Logger.game('Boss charging!');
  }

  void _updateBossCharging(double dt) {
    if (mBossChargeDirection == null) {
      _endCharge();
      return;
    }

    // 빠른 속도로 돌진
    final chargeSpeed = mStats.spd * 60 * BOSS_CHARGE_SPEED_MULTIPLIER;
    final movement = mBossChargeDirection! * chargeSpeed * dt;
    position += movement;
    mBossChargeDistance += movement.length;

    // 돌진 경로 내 플레이어 피격 체크
    _checkChargeHit();

    // 돌진 거리 도달 시 종료
    if (mBossChargeDistance >= BOSS_CHARGE_LENGTH) {
      _endCharge();
    }
  }

  void _checkChargeHit() {
    if (!game.player.mIsAlive || game.player.isInvincible) return;
    if (mBossChargeStartPos == null || mBossChargeDirection == null) return;

    final playerPos = game.player.position;

    // 돌진 경로 (시작점 ~ 현재 위치) 내에 플레이어가 있는지 확인
    // 간단한 거리 기반 체크 (돌진 폭 / 2 이내)
    final toPlayer = playerPos - position;
    final perpDistance = _perpendicularDistance(toPlayer, mBossChargeDirection!);

    if (perpDistance <= BOSS_CHARGE_WIDTH / 2) {
      // 플레이어가 돌진 경로 폭 내에 있음
      // 보스 현재 위치에서 플레이어까지의 거리가 충분히 가까운지 확인
      if (toPlayer.length <= size.x / 2 + 30) {
        game.player.TakeDamage(BOSS_CHARGE_DAMAGE);
        Logger.combat('Boss charge hit player for $BOSS_CHARGE_DAMAGE damage');
      }
    }
  }

  double _perpendicularDistance(Vector2 point, Vector2 direction) {
    // 방향 벡터에 수직인 성분의 크기
    final perpendicular = Vector2(-direction.y, direction.x);
    return (point.dot(perpendicular)).abs();
  }

  void _endCharge() {
    mBossState = BossAttackState.idle;
    mBossChargeCooldown = BOSS_CHARGE_COOLDOWN;
    mBossChargeDirection = null;
    mBossChargeStartPos = null;

    Logger.game('Boss charge ended, cooldown: ${BOSS_CHARGE_COOLDOWN}s');
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

    // 보스 전조 표시 정리
    if (isBoss && mChargeIndicator != null) {
      mChargeIndicator!.removeFromParent();
      mChargeIndicator = null;
    }

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
