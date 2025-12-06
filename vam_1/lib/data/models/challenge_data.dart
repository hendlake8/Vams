import 'package:flutter/material.dart';

/// 도전 모드 타입
enum ChallengeType {
  endless,      // 무한 웨이브 - 최대한 오래 생존
  bossRush,     // 보스 러시 - 연속 보스 처치
  timeAttack,   // 타임어택 - 제한 시간 내 처치 수
  survival,     // 서바이벌 - 강화된 적, 제한 시간 생존
}

/// 도전 난이도
enum ChallengeDifficulty {
  normal,
  hard,
  nightmare,
}

/// 도전 클리어 상태
enum ChallengeStatus {
  locked,       // 잠김 (선행 조건 미충족)
  available,    // 도전 가능
  cleared,      // 클리어됨
}

/// 도전 스테이지 데이터
class ChallengeData {
  final String id;
  final String name;
  final String description;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final int unlockLevel;                    // 해금에 필요한 플레이어 레벨
  final String? prerequisiteId;             // 선행 도전 ID (있을 경우)
  final ChallengeCondition condition;       // 클리어 조건
  final List<ChallengeReward> rewards;      // 클리어 보상
  final ChallengeModifier modifier;         // 게임 변경자

  const ChallengeData({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.unlockLevel,
    this.prerequisiteId,
    required this.condition,
    required this.rewards,
    required this.modifier,
  });
}

/// 클리어 조건
class ChallengeCondition {
  final int? targetTime;           // 목표 시간 (초) - 타임어택/서바이벌
  final int? targetKills;          // 목표 처치 수 - 타임어택
  final int? targetWave;           // 목표 웨이브 - 무한 웨이브
  final int? targetBossKills;      // 보스 처치 수 - 보스 러시

  const ChallengeCondition({
    this.targetTime,
    this.targetKills,
    this.targetWave,
    this.targetBossKills,
  });

  String GetDescription() {
    if (targetTime != null && targetKills != null) {
      return '${targetTime}초 내 ${targetKills}마리 처치';
    } else if (targetTime != null) {
      return '${targetTime}초 생존';
    } else if (targetWave != null) {
      return '웨이브 $targetWave 도달';
    } else if (targetBossKills != null) {
      return '보스 ${targetBossKills}마리 처치';
    }
    return '클리어';
  }
}

/// 게임 변경자 (난이도 조절)
class ChallengeModifier {
  final double enemyHpMultiplier;      // 적 체력 배율
  final double enemyDamageMultiplier;  // 적 공격력 배율
  final double spawnRateMultiplier;    // 스폰 속도 배율
  final double expMultiplier;          // 경험치 배율
  final bool noHealing;                // 회복 불가
  final bool eliteOnly;                // 엘리트만 출현

  const ChallengeModifier({
    this.enemyHpMultiplier = 1.0,
    this.enemyDamageMultiplier = 1.0,
    this.spawnRateMultiplier = 1.0,
    this.expMultiplier = 1.0,
    this.noHealing = false,
    this.eliteOnly = false,
  });

  List<String> GetModifierTexts() {
    final List<String> texts = [];
    if (enemyHpMultiplier != 1.0) {
      texts.add('적 체력 ${(enemyHpMultiplier * 100).toInt()}%');
    }
    if (enemyDamageMultiplier != 1.0) {
      texts.add('적 공격력 ${(enemyDamageMultiplier * 100).toInt()}%');
    }
    if (spawnRateMultiplier != 1.0) {
      texts.add('스폰 속도 ${(spawnRateMultiplier * 100).toInt()}%');
    }
    if (expMultiplier != 1.0) {
      texts.add('경험치 ${(expMultiplier * 100).toInt()}%');
    }
    if (noHealing) texts.add('회복 불가');
    if (eliteOnly) texts.add('엘리트만 출현');
    return texts;
  }
}

/// 도전 보상
class ChallengeReward {
  final ChallengeRewardType type;
  final String? itemId;            // 아이템 ID (장비 등)
  final int amount;

  const ChallengeReward({
    required this.type,
    this.itemId,
    required this.amount,
  });
}

enum ChallengeRewardType {
  gold,         // 골드
  gem,          // 보석
  equipment,    // 장비
  exp,          // 경험치
}

/// 도전 기록
class ChallengeRecord {
  final String challengeId;
  bool isCleared;
  int bestWave;              // 최고 웨이브 (무한 웨이브)
  int bestKills;             // 최고 처치 수
  int bestTime;              // 최고 시간 (초)
  DateTime? clearedAt;

  ChallengeRecord({
    required this.challengeId,
    this.isCleared = false,
    this.bestWave = 0,
    this.bestKills = 0,
    this.bestTime = 0,
    this.clearedAt,
  });
}

/// 기본 도전 정의
class DefaultChallenges {
  DefaultChallenges._();

  // ========== 무한 웨이브 ==========

  static const ChallengeData ENDLESS_NORMAL = ChallengeData(
    id: 'challenge_endless_normal',
    name: '무한의 시련',
    description: '끝없이 밀려오는 적들을 상대하세요. 얼마나 오래 버틸 수 있나요?',
    type: ChallengeType.endless,
    difficulty: ChallengeDifficulty.normal,
    unlockLevel: 1,
    condition: ChallengeCondition(targetWave: 10),
    rewards: [
      ChallengeReward(type: ChallengeRewardType.gold, amount: 500),
      ChallengeReward(type: ChallengeRewardType.gem, amount: 10),
    ],
    modifier: ChallengeModifier(
      expMultiplier: 1.5,
    ),
  );

  static const ChallengeData ENDLESS_HARD = ChallengeData(
    id: 'challenge_endless_hard',
    name: '무한의 시련 II',
    description: '더 강해진 적들이 밀려옵니다.',
    type: ChallengeType.endless,
    difficulty: ChallengeDifficulty.hard,
    unlockLevel: 5,
    prerequisiteId: 'challenge_endless_normal',
    condition: ChallengeCondition(targetWave: 15),
    rewards: [
      ChallengeReward(type: ChallengeRewardType.gold, amount: 1000),
      ChallengeReward(type: ChallengeRewardType.gem, amount: 25),
    ],
    modifier: ChallengeModifier(
      enemyHpMultiplier: 1.5,
      enemyDamageMultiplier: 1.3,
      expMultiplier: 2.0,
    ),
  );

  // ========== 보스 러시 ==========

  static const ChallengeData BOSS_RUSH_NORMAL = ChallengeData(
    id: 'challenge_boss_rush_normal',
    name: '보스 러시',
    description: '연속으로 보스를 처치하세요!',
    type: ChallengeType.bossRush,
    difficulty: ChallengeDifficulty.normal,
    unlockLevel: 3,
    condition: ChallengeCondition(targetBossKills: 3),
    rewards: [
      ChallengeReward(type: ChallengeRewardType.gold, amount: 800),
      ChallengeReward(
        type: ChallengeRewardType.equipment,
        itemId: 'equip_flame_blade',
        amount: 1,
      ),
    ],
    modifier: ChallengeModifier(
      expMultiplier: 2.0,
    ),
  );

  static const ChallengeData BOSS_RUSH_HARD = ChallengeData(
    id: 'challenge_boss_rush_hard',
    name: '보스 러시 II',
    description: '더 많은 보스를 상대하세요!',
    type: ChallengeType.bossRush,
    difficulty: ChallengeDifficulty.hard,
    unlockLevel: 8,
    prerequisiteId: 'challenge_boss_rush_normal',
    condition: ChallengeCondition(targetBossKills: 5),
    rewards: [
      ChallengeReward(type: ChallengeRewardType.gold, amount: 1500),
      ChallengeReward(
        type: ChallengeRewardType.equipment,
        itemId: 'equip_thunder_staff',
        amount: 1,
      ),
    ],
    modifier: ChallengeModifier(
      enemyHpMultiplier: 1.8,
      expMultiplier: 2.5,
    ),
  );

  // ========== 타임어택 ==========

  static const ChallengeData TIME_ATTACK_NORMAL = ChallengeData(
    id: 'challenge_time_attack_normal',
    name: '스피드 헌터',
    description: '제한 시간 내에 최대한 많은 적을 처치하세요!',
    type: ChallengeType.timeAttack,
    difficulty: ChallengeDifficulty.normal,
    unlockLevel: 2,
    condition: ChallengeCondition(targetTime: 60, targetKills: 100),
    rewards: [
      ChallengeReward(type: ChallengeRewardType.gold, amount: 600),
      ChallengeReward(type: ChallengeRewardType.gem, amount: 15),
    ],
    modifier: ChallengeModifier(
      spawnRateMultiplier: 2.0,
      expMultiplier: 1.2,
    ),
  );

  static const ChallengeData TIME_ATTACK_HARD = ChallengeData(
    id: 'challenge_time_attack_hard',
    name: '스피드 헌터 II',
    description: '더 빠르게, 더 많이!',
    type: ChallengeType.timeAttack,
    difficulty: ChallengeDifficulty.hard,
    unlockLevel: 6,
    prerequisiteId: 'challenge_time_attack_normal',
    condition: ChallengeCondition(targetTime: 60, targetKills: 200),
    rewards: [
      ChallengeReward(type: ChallengeRewardType.gold, amount: 1200),
      ChallengeReward(type: ChallengeRewardType.gem, amount: 30),
    ],
    modifier: ChallengeModifier(
      spawnRateMultiplier: 3.0,
      enemyHpMultiplier: 0.8,
      expMultiplier: 1.5,
    ),
  );

  // ========== 서바이벌 ==========

  static const ChallengeData SURVIVAL_NORMAL = ChallengeData(
    id: 'challenge_survival_normal',
    name: '극한 생존',
    description: '강화된 적들 사이에서 생존하세요.',
    type: ChallengeType.survival,
    difficulty: ChallengeDifficulty.normal,
    unlockLevel: 4,
    condition: ChallengeCondition(targetTime: 120),
    rewards: [
      ChallengeReward(type: ChallengeRewardType.gold, amount: 700),
      ChallengeReward(
        type: ChallengeRewardType.equipment,
        itemId: 'equip_knight_plate',
        amount: 1,
      ),
    ],
    modifier: ChallengeModifier(
      enemyHpMultiplier: 1.5,
      enemyDamageMultiplier: 1.5,
      noHealing: true,
    ),
  );

  static const ChallengeData SURVIVAL_NIGHTMARE = ChallengeData(
    id: 'challenge_survival_nightmare',
    name: '악몽의 밤',
    description: '최악의 조건에서 살아남으세요.',
    type: ChallengeType.survival,
    difficulty: ChallengeDifficulty.nightmare,
    unlockLevel: 10,
    prerequisiteId: 'challenge_survival_normal',
    condition: ChallengeCondition(targetTime: 180),
    rewards: [
      ChallengeReward(type: ChallengeRewardType.gold, amount: 2000),
      ChallengeReward(type: ChallengeRewardType.gem, amount: 50),
      ChallengeReward(
        type: ChallengeRewardType.equipment,
        itemId: 'equip_dragon_scale',
        amount: 1,
      ),
    ],
    modifier: ChallengeModifier(
      enemyHpMultiplier: 2.0,
      enemyDamageMultiplier: 2.0,
      spawnRateMultiplier: 1.5,
      noHealing: true,
      eliteOnly: true,
    ),
  );

  static List<ChallengeData> get all => [
    ENDLESS_NORMAL,
    ENDLESS_HARD,
    BOSS_RUSH_NORMAL,
    BOSS_RUSH_HARD,
    TIME_ATTACK_NORMAL,
    TIME_ATTACK_HARD,
    SURVIVAL_NORMAL,
    SURVIVAL_NIGHTMARE,
  ];

  static ChallengeData? GetById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<ChallengeData> GetByType(ChallengeType type) {
    return all.where((c) => c.type == type).toList();
  }

  static List<ChallengeData> GetByDifficulty(ChallengeDifficulty difficulty) {
    return all.where((c) => c.difficulty == difficulty).toList();
  }
}

/// 도전 타입 확장
extension ChallengeTypeExtension on ChallengeType {
  String get displayName {
    switch (this) {
      case ChallengeType.endless:
        return '무한 웨이브';
      case ChallengeType.bossRush:
        return '보스 러시';
      case ChallengeType.timeAttack:
        return '타임어택';
      case ChallengeType.survival:
        return '서바이벌';
    }
  }

  IconData get icon {
    switch (this) {
      case ChallengeType.endless:
        return Icons.all_inclusive;
      case ChallengeType.bossRush:
        return Icons.whatshot;
      case ChallengeType.timeAttack:
        return Icons.timer;
      case ChallengeType.survival:
        return Icons.shield;
    }
  }

  Color get color {
    switch (this) {
      case ChallengeType.endless:
        return Colors.blue;
      case ChallengeType.bossRush:
        return Colors.red;
      case ChallengeType.timeAttack:
        return Colors.orange;
      case ChallengeType.survival:
        return Colors.purple;
    }
  }
}

/// 난이도 확장
extension ChallengeDifficultyExtension on ChallengeDifficulty {
  String get displayName {
    switch (this) {
      case ChallengeDifficulty.normal:
        return '보통';
      case ChallengeDifficulty.hard:
        return '어려움';
      case ChallengeDifficulty.nightmare:
        return '악몽';
    }
  }

  Color get color {
    switch (this) {
      case ChallengeDifficulty.normal:
        return Colors.green;
      case ChallengeDifficulty.hard:
        return Colors.orange;
      case ChallengeDifficulty.nightmare:
        return Colors.red;
    }
  }

  int get stars {
    switch (this) {
      case ChallengeDifficulty.normal:
        return 1;
      case ChallengeDifficulty.hard:
        return 2;
      case ChallengeDifficulty.nightmare:
        return 3;
    }
  }
}
