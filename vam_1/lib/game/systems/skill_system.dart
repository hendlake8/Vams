import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../../data/models/skill_data.dart';
import '../components/actors/monster.dart';
import '../components/weapons/orbit_weapon.dart';
import '../vam_game.dart';

/// 스킬 시스템 - 스킬 발동 및 관리
class SkillSystem {
  final VamGame mGame;

  // 장착된 스킬들
  final List<EquippedSkill> mEquippedSkills = [];

  // 패시브 효과
  double mSpeedBonus = 0;
  double mHealthBonus = 0;
  double mDamageBonus = 0;

  SkillSystem(this.mGame);

  /// 스킬 추가
  void AddSkill(String skillId, {int level = 1}) {
    final skillData = DefaultSkills.GetById(skillId);
    if (skillData == null) {
      Logger.e('Unknown skill: $skillId');
      return;
    }

    final existing = mEquippedSkills.firstWhere(
      (s) => s.skillData.id == skillId,
      orElse: () => EquippedSkill(skillData: skillData, level: 0),
    );

    if (existing.level == 0) {
      final newSkill = EquippedSkill(skillData: skillData, level: level);
      mEquippedSkills.add(newSkill);

      // 회전형 스킬은 오브젝트 생성
      if (skillData.category == SkillCategory.orbit) {
        _createOrbitWeapons(newSkill);
      }

      // 패시브 적용
      if (skillData.category == SkillCategory.passive) {
        _applyPassive(skillData, level);
      }

      Logger.game('Skill added: ${skillData.name} Lv.$level');
    } else {
      existing.level = level;

      // 회전형 스킬 업그레이드
      if (skillData.category == SkillCategory.orbit) {
        _updateOrbitWeapons(existing);
      }

      // 패시브 재적용
      if (skillData.category == SkillCategory.passive) {
        _applyPassive(skillData, level);
      }

      Logger.game('Skill upgraded: ${skillData.name} Lv.$level');
    }
  }

  /// 스킬 레벨업
  void UpgradeSkill(String skillId) {
    final skill = mEquippedSkills.firstWhere(
      (s) => s.skillData.id == skillId,
      orElse: () => EquippedSkill(
        skillData: DefaultSkills.ENERGY_BOLT,
        level: 0,
      ),
    );

    if (skill.level > 0 && skill.level < skill.skillData.maxLevel) {
      skill.level++;
      Logger.game('Skill upgraded: ${skill.skillData.name} Lv.${skill.level}');
    }
  }

  /// 시스템 업데이트
  void Update(double dt) {
    if (!mGame.player.mIsAlive) return;

    for (final skill in mEquippedSkills) {
      if (skill.skillData.category == SkillCategory.passive) continue;
      if (skill.skillData.category == SkillCategory.orbit) continue;

      skill.mCooldownTimer -= dt;

      if (skill.mCooldownTimer <= 0) {
        _fireSkill(skill);
        skill.mCooldownTimer = skill.skillData.GetCooldownAtLevel(skill.level);
      }
    }
  }

  /// 스킬 발동
  void _fireSkill(EquippedSkill skill) {
    switch (skill.skillData.category) {
      case SkillCategory.projectile:
        _fireProjectileSkill(skill);
        break;
      case SkillCategory.area:
        _fireAreaSkill(skill);
        break;
      case SkillCategory.summon:
        // TODO: 소환형 스킬 구현
        break;
      case SkillCategory.orbit:
      case SkillCategory.passive:
        // 별도 처리
        break;
    }
  }

  /// 투사체형 스킬 발동
  void _fireProjectileSkill(EquippedSkill skill) {
    final target = _findNearestMonster();
    if (target == null) return;

    final playerPos = mGame.player.position;
    final direction = (target.position - playerPos).normalized();

    final projectileCount = skill.skillData.GetProjectileCountAtLevel(skill.level);

    for (int i = 0; i < projectileCount; i++) {
      Vector2 adjustedDir = direction;
      if (projectileCount > 1) {
        final angleOffset = (i - (projectileCount - 1) / 2) * 0.15;
        adjustedDir = _rotateVector(direction, angleOffset);
      }

      final projectile = SkillProjectile(
        position: playerPos.clone(),
        direction: adjustedDir,
        skillData: skill.skillData,
        level: skill.level,
        damageBonus: mDamageBonus,
      );
      mGame.world.add(projectile);
    }
  }

  /// 범위형 스킬 발동
  void _fireAreaSkill(EquippedSkill skill) {
    final playerPos = mGame.player.position;
    final range = skill.skillData.GetRangeAtLevel(skill.level);
    final damage = skill.skillData.GetDamageAtLevel(skill.level) * (1 + mDamageBonus);

    // 범위 내 모든 몬스터에 데미지
    final monsters = mGame.world.children.whereType<Monster>().where((m) {
      return m.mIsAlive && (m.position - playerPos).length <= range;
    });

    for (final monster in monsters) {
      monster.TakeDamage(damage.round());
    }

    // 범위 이펙트 표시 (임시)
    _showAreaEffect(playerPos, range, skill.skillData.color);
  }

  /// 범위 이펙트 표시
  void _showAreaEffect(Vector2 position, double range, color) {
    final effect = AreaEffectComponent(
      position: position,
      radius: range,
      color: color,
      duration: 0.2,
    );
    mGame.world.add(effect);
  }

  /// 회전 무기 생성
  void _createOrbitWeapons(EquippedSkill skill) {
    final count = skill.skillData.GetProjectileCountAtLevel(skill.level);

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi / count) * i;
      final orbitWeapon = OrbitWeapon(
        skillData: skill.skillData,
        level: skill.level,
        orbitRadius: skill.skillData.range,
        startAngle: angle,
        damageBonus: mDamageBonus,
      );
      mGame.player.add(orbitWeapon);
    }
  }

  /// 회전 무기 업데이트
  void _updateOrbitWeapons(EquippedSkill skill) {
    // 기존 회전 무기 제거
    mGame.player.children
        .whereType<OrbitWeapon>()
        .where((w) => w.mSkillData.id == skill.skillData.id)
        .forEach((w) => w.removeFromParent());

    // 새로 생성
    _createOrbitWeapons(skill);
  }

  /// 패시브 적용
  void _applyPassive(SkillData skill, int level) {
    switch (skill.id) {
      case 'skill_swift_boots':
        mSpeedBonus = 0.05 * level; // 레벨당 5% 속도 증가
        break;
      case 'skill_vital_heart':
        mHealthBonus = 0.10 * level; // 레벨당 10% 체력 증가
        break;
      case 'skill_power_gauntlet':
        mDamageBonus = 0.08 * level; // 레벨당 8% 공격력 증가
        break;
    }
  }

  /// 가장 가까운 몬스터 찾기
  Monster? _findNearestMonster() {
    final playerPos = mGame.player.position;
    Monster? nearest;
    double minDist = double.infinity;

    for (final component in mGame.world.children) {
      if (component is Monster && component.mIsAlive) {
        final dist = (component.position - playerPos).length;
        if (dist < minDist) {
          minDist = dist;
          nearest = component;
        }
      }
    }

    return nearest;
  }

  /// 벡터 회전
  Vector2 _rotateVector(Vector2 v, double angle) {
    final cosA = cos(angle);
    final sinA = sin(angle);
    return Vector2(
      v.x * cosA - v.y * sinA,
      v.x * sinA + v.y * cosA,
    );
  }

  /// 리셋
  void Reset() {
    // 회전 무기 제거
    mGame.player.children
        .whereType<OrbitWeapon>()
        .forEach((w) => w.removeFromParent());

    mEquippedSkills.clear();
    mSpeedBonus = 0;
    mHealthBonus = 0;
    mDamageBonus = 0;
  }

  /// 장착된 스킬 목록
  List<EquippedSkill> get skills => mEquippedSkills;

  /// 패시브 보너스
  double get speedBonus => mSpeedBonus;
  double get healthBonus => mHealthBonus;
  double get damageBonus => mDamageBonus;
}

/// 장착된 스킬 정보
class EquippedSkill {
  final SkillData skillData;
  int level;
  double mCooldownTimer = 0;

  EquippedSkill({
    required this.skillData,
    required this.level,
  });
}

/// 스킬 투사체
class SkillProjectile extends PositionComponent with HasGameReference<VamGame>, CollisionCallbacks {
  final SkillData mSkillData;
  final Vector2 mDirection;
  final int mLevel;
  final double mDamage;
  final double mDamageBonus;

  double mDistanceTraveled = 0;
  int mPierceCount = 0;
  bool mIsActive = true;
  final Set<Monster> mHitMonsters = {};

  late RectangleComponent mBody;

  SkillProjectile({
    required Vector2 position,
    required Vector2 direction,
    required SkillData skillData,
    required int level,
    double damageBonus = 0,
  })  : mSkillData = skillData,
        mDirection = direction.normalized(),
        mLevel = level,
        mDamage = skillData.GetDamageAtLevel(level) * (1 + damageBonus),
        mDamageBonus = damageBonus,
        super(
          position: position,
          size: Vector2(14, 14),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    mBody = RectangleComponent(
      size: size,
      paint: Paint()..color = mSkillData.color,
    );
    add(mBody);

    add(CircleHitbox(radius: 7));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!mIsActive) return;

    final velocity = mDirection * mSkillData.projectileSpeed * dt;
    position += velocity;
    mDistanceTraveled += velocity.length;

    if (mDistanceTraveled >= mSkillData.GetRangeAtLevel(mLevel)) {
      Destroy();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (!mIsActive) return;

    if (other is Monster && other.mIsAlive) {
      if (mHitMonsters.contains(other)) return;

      other.TakeDamage(mDamage.round());
      mHitMonsters.add(other);

      if (mSkillData.piercing) {
        mPierceCount++;
        if (mPierceCount >= mSkillData.pierceCount) {
          Destroy();
        }
      } else {
        Destroy();
      }
    }
  }

  void Destroy() {
    mIsActive = false;
    removeFromParent();
  }
}

/// 범위 이펙트 컴포넌트
class AreaEffectComponent extends CircleComponent {
  final double mDuration;
  double mElapsedTime = 0;

  AreaEffectComponent({
    required Vector2 position,
    required double radius,
    required Color color,
    required double duration,
  })  : mDuration = duration,
        super(
          position: position,
          radius: radius,
          anchor: Anchor.center,
          paint: Paint()
            ..color = color.withValues(alpha: 0.5)
            ..style = PaintingStyle.fill,
        );

  @override
  void update(double dt) {
    super.update(dt);

    mElapsedTime += dt;

    // 페이드 아웃
    final alpha = (1 - (mElapsedTime / mDuration)).clamp(0.0, 1.0) * 0.5;
    paint.color = paint.color.withValues(alpha: alpha);

    if (mElapsedTime >= mDuration) {
      removeFromParent();
    }
  }
}
