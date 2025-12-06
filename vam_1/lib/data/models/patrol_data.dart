/// 순찰 시스템 데이터 모델
/// 방치형 보상 시스템 - 오프라인 시간 동안 골드/경험치/장비 획득

/// 순찰 지역 정의
enum PatrolZone {
  forest,       // 숲 (초보자)
  cave,         // 동굴
  ruins,        // 폐허
  volcano,      // 화산
  abyss,        // 심연 (최상위)
}

/// 순찰 지역 데이터
class PatrolZoneData {
  final PatrolZone zone;
  final String name;
  final String description;
  final int unlockLevel;          // 해금 레벨
  final int goldPerMinute;        // 분당 골드 획득량
  final int expPerMinute;         // 분당 경험치 획득량
  final double equipDropChance;   // 장비 드롭 확률 (시간당)
  final List<String> possibleEquipments;  // 드롭 가능 장비 ID 목록

  const PatrolZoneData({
    required this.zone,
    required this.name,
    required this.description,
    required this.unlockLevel,
    required this.goldPerMinute,
    required this.expPerMinute,
    required this.equipDropChance,
    this.possibleEquipments = const [],
  });
}

/// 기본 순찰 지역 정의
class DefaultPatrolZones {
  DefaultPatrolZones._();

  static const PatrolZoneData FOREST = PatrolZoneData(
    zone: PatrolZone.forest,
    name: '평화로운 숲',
    description: '약한 몬스터가 서식하는 숲. 초보자에게 적합합니다.',
    unlockLevel: 1,
    goldPerMinute: 2,
    expPerMinute: 1,
    equipDropChance: 0.05,  // 시간당 5% 확률
    possibleEquipments: ['equip_starter_wand', 'equip_iron_sword', 'equip_leather_armor', 'equip_speed_boots'],
  );

  static const PatrolZoneData CAVE = PatrolZoneData(
    zone: PatrolZone.cave,
    name: '어두운 동굴',
    description: '동굴 깊숙이 숨어있는 몬스터들이 있습니다.',
    unlockLevel: 3,
    goldPerMinute: 5,
    expPerMinute: 2,
    equipDropChance: 0.08,  // 시간당 8% 확률
    possibleEquipments: ['equip_iron_sword', 'equip_leather_armor', 'equip_speed_boots', 'equip_poison_bow'],
  );

  static const PatrolZoneData RUINS = PatrolZoneData(
    zone: PatrolZone.ruins,
    name: '고대 폐허',
    description: '고대 문명의 유적. 강력한 적과 보물이 공존합니다.',
    unlockLevel: 5,
    goldPerMinute: 10,
    expPerMinute: 4,
    equipDropChance: 0.12,  // 시간당 12% 확률
    possibleEquipments: ['equip_flame_blade', 'equip_poison_bow', 'equip_knight_plate', 'equip_critical_ring'],
  );

  static const PatrolZoneData VOLCANO = PatrolZoneData(
    zone: PatrolZone.volcano,
    name: '불타는 화산',
    description: '극한의 환경. 강력한 화염 몬스터가 서식합니다.',
    unlockLevel: 8,
    goldPerMinute: 18,
    expPerMinute: 7,
    equipDropChance: 0.18,  // 시간당 18% 확률
    possibleEquipments: ['equip_flame_blade', 'equip_thunder_staff', 'equip_knight_plate', 'equip_life_pendant'],
  );

  static const PatrolZoneData ABYSS = PatrolZoneData(
    zone: PatrolZone.abyss,
    name: '끝없는 심연',
    description: '세계의 끝자락. 최강의 몬스터가 도사립니다.',
    unlockLevel: 12,
    goldPerMinute: 30,
    expPerMinute: 12,
    equipDropChance: 0.25,  // 시간당 25% 확률
    possibleEquipments: ['equip_thunder_staff', 'equip_dragon_scale', 'equip_life_pendant', 'equip_critical_ring'],
  );

  static List<PatrolZoneData> get all => [FOREST, CAVE, RUINS, VOLCANO, ABYSS];

  static PatrolZoneData? GetByZone(PatrolZone zone) {
    try {
      return all.firstWhere((z) => z.zone == zone);
    } catch (_) {
      return null;
    }
  }

  static PatrolZoneData? GetByName(String zoneName) {
    try {
      final zone = PatrolZone.values.firstWhere((z) => z.name == zoneName);
      return GetByZone(zone);
    } catch (_) {
      return null;
    }
  }
}

/// 순찰 진행 데이터 (영구 저장용)
class PatrolProgressData {
  final PatrolZone? activeZone;         // 현재 순찰 중인 지역
  final String? patrolStartTime;        // 순찰 시작 시간 (ISO8601)
  final String? lastCollectTime;        // 마지막 보상 수령 시간 (ISO8601)
  final int pendingGold;                // 대기 중인 골드
  final int pendingExp;                 // 대기 중인 경험치
  final List<String> pendingEquipments; // 대기 중인 장비 ID 목록

  const PatrolProgressData({
    this.activeZone,
    this.patrolStartTime,
    this.lastCollectTime,
    this.pendingGold = 0,
    this.pendingExp = 0,
    this.pendingEquipments = const [],
  });

  /// 순찰 중인지 여부
  bool get isPatrolling => activeZone != null && patrolStartTime != null;

  /// 순찰 시간 계산 (분 단위)
  int GetPatrolMinutes() {
    if (!isPatrolling) return 0;

    final startTime = DateTime.tryParse(patrolStartTime!);
    if (startTime == null) return 0;

    final now = DateTime.now();
    return now.difference(startTime).inMinutes;
  }

  /// 마지막 수령 이후 경과 시간 (분 단위)
  int GetMinutesSinceLastCollect() {
    if (lastCollectTime == null) return GetPatrolMinutes();

    final collectTime = DateTime.tryParse(lastCollectTime!);
    if (collectTime == null) return GetPatrolMinutes();

    final now = DateTime.now();
    return now.difference(collectTime).inMinutes;
  }

  /// 순찰 시작
  PatrolProgressData StartPatrol(PatrolZone zone) {
    final now = DateTime.now().toIso8601String();
    return PatrolProgressData(
      activeZone: zone,
      patrolStartTime: now,
      lastCollectTime: now,
      pendingGold: 0,
      pendingExp: 0,
      pendingEquipments: const [],
    );
  }

  /// 순찰 중지
  PatrolProgressData StopPatrol() {
    return const PatrolProgressData();
  }

  /// 보상 업데이트 (누적)
  PatrolProgressData UpdateRewards({
    int addGold = 0,
    int addExp = 0,
    List<String> addEquipments = const [],
  }) {
    return PatrolProgressData(
      activeZone: activeZone,
      patrolStartTime: patrolStartTime,
      lastCollectTime: DateTime.now().toIso8601String(),
      pendingGold: pendingGold + addGold,
      pendingExp: pendingExp + addExp,
      pendingEquipments: [...pendingEquipments, ...addEquipments],
    );
  }

  /// 보상 수령 완료 후 클리어
  PatrolProgressData ClearRewards() {
    return PatrolProgressData(
      activeZone: activeZone,
      patrolStartTime: patrolStartTime,
      lastCollectTime: DateTime.now().toIso8601String(),
      pendingGold: 0,
      pendingExp: 0,
      pendingEquipments: const [],
    );
  }

  /// 지역 변경
  PatrolProgressData ChangeZone(PatrolZone newZone) {
    return PatrolProgressData(
      activeZone: newZone,
      patrolStartTime: DateTime.now().toIso8601String(),
      lastCollectTime: DateTime.now().toIso8601String(),
      pendingGold: pendingGold,
      pendingExp: pendingExp,
      pendingEquipments: pendingEquipments,
    );
  }

  Map<String, dynamic> ToJson() {
    return {
      'activeZone': activeZone?.name,
      'patrolStartTime': patrolStartTime,
      'lastCollectTime': lastCollectTime,
      'pendingGold': pendingGold,
      'pendingExp': pendingExp,
      'pendingEquipments': pendingEquipments,
    };
  }

  factory PatrolProgressData.FromJson(Map<String, dynamic> json) {
    PatrolZone? zone;
    final zoneName = json['activeZone'] as String?;
    if (zoneName != null) {
      try {
        zone = PatrolZone.values.firstWhere((z) => z.name == zoneName);
      } catch (_) {
        zone = null;
      }
    }

    return PatrolProgressData(
      activeZone: zone,
      patrolStartTime: json['patrolStartTime'] as String?,
      lastCollectTime: json['lastCollectTime'] as String?,
      pendingGold: json['pendingGold'] as int? ?? 0,
      pendingExp: json['pendingExp'] as int? ?? 0,
      pendingEquipments: (json['pendingEquipments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }
}

/// 순찰 지역 확장
extension PatrolZoneExtension on PatrolZone {
  String get displayName {
    switch (this) {
      case PatrolZone.forest:
        return '평화로운 숲';
      case PatrolZone.cave:
        return '어두운 동굴';
      case PatrolZone.ruins:
        return '고대 폐허';
      case PatrolZone.volcano:
        return '불타는 화산';
      case PatrolZone.abyss:
        return '끝없는 심연';
    }
  }

  String get icon {
    switch (this) {
      case PatrolZone.forest:
        return '🌲';
      case PatrolZone.cave:
        return '🕳️';
      case PatrolZone.ruins:
        return '🏛️';
      case PatrolZone.volcano:
        return '🌋';
      case PatrolZone.abyss:
        return '🌀';
    }
  }
}
