/// 영구 진행 데이터 모델
/// 계정 레벨, 누적 경험치, 재화, 도전 기록, 장비, 순찰, 상점 등을 관리

import 'equipment_data.dart';
import 'patrol_data.dart';
import 'shop_data.dart';

/// 계정 레벨 데이터
class AccountLevel {
  final int level;
  final int currentExp;
  final int totalExp;

  const AccountLevel({
    this.level = 1,
    this.currentExp = 0,
    this.totalExp = 0,
  });

  /// 다음 레벨까지 필요한 경험치
  int get requiredExp => GetRequiredExpForLevel(level);

  /// 레벨업 가능 여부
  bool get canLevelUp => currentExp >= requiredExp;

  /// 현재 레벨 진행률 (0.0 ~ 1.0)
  double get progress => requiredExp > 0 ? (currentExp / requiredExp).clamp(0.0, 1.0) : 0.0;

  /// 레벨별 필요 경험치 계산
  static int GetRequiredExpForLevel(int level) {
    // 공식: 100 + (레벨-1) * 50
    // Lv.1 → 100, Lv.2 → 150, Lv.3 → 200 ...
    return 100 + (level - 1) * 50;
  }

  /// 경험치 추가 후 새 상태 반환
  AccountLevel AddExp(int exp) {
    int newLevel = level;
    int newCurrentExp = currentExp + exp;
    int newTotalExp = totalExp + exp;

    // 레벨업 처리
    while (newCurrentExp >= GetRequiredExpForLevel(newLevel)) {
      newCurrentExp -= GetRequiredExpForLevel(newLevel);
      newLevel++;
    }

    return AccountLevel(
      level: newLevel,
      currentExp: newCurrentExp,
      totalExp: newTotalExp,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> ToJson() {
    return {
      'level': level,
      'currentExp': currentExp,
      'totalExp': totalExp,
    };
  }

  /// JSON 역직렬화
  factory AccountLevel.FromJson(Map<String, dynamic> json) {
    return AccountLevel(
      level: json['level'] as int? ?? 1,
      currentExp: json['currentExp'] as int? ?? 0,
      totalExp: json['totalExp'] as int? ?? 0,
    );
  }
}

/// 재화 데이터
class CurrencyData {
  final int gold;
  final int gems;

  const CurrencyData({
    this.gold = 0,
    this.gems = 0,
  });

  CurrencyData AddGold(int amount) {
    return CurrencyData(gold: gold + amount, gems: gems);
  }

  CurrencyData AddGems(int amount) {
    return CurrencyData(gold: gold, gems: gems + amount);
  }

  bool CanAffordGold(int amount) => gold >= amount;
  bool CanAffordGems(int amount) => gems >= amount;

  CurrencyData SpendGold(int amount) {
    if (!CanAffordGold(amount)) return this;
    return CurrencyData(gold: gold - amount, gems: gems);
  }

  CurrencyData SpendGems(int amount) {
    if (!CanAffordGems(amount)) return this;
    return CurrencyData(gold: gold, gems: gems - amount);
  }

  Map<String, dynamic> ToJson() {
    return {
      'gold': gold,
      'gems': gems,
    };
  }

  factory CurrencyData.FromJson(Map<String, dynamic> json) {
    return CurrencyData(
      gold: json['gold'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
    );
  }
}

/// 도전 기록 데이터 (영구 저장용)
class ChallengeRecordData {
  final String challengeId;
  final bool isCleared;
  final int bestWave;
  final int bestKills;
  final int bestTime;
  final String? clearedAt;  // ISO8601 문자열

  const ChallengeRecordData({
    required this.challengeId,
    this.isCleared = false,
    this.bestWave = 0,
    this.bestKills = 0,
    this.bestTime = 0,
    this.clearedAt,
  });

  ChallengeRecordData UpdateRecord({
    bool? cleared,
    int? wave,
    int? kills,
    int? time,
  }) {
    return ChallengeRecordData(
      challengeId: challengeId,
      isCleared: cleared ?? isCleared,
      bestWave: (wave ?? 0) > bestWave ? wave! : bestWave,
      bestKills: (kills ?? 0) > bestKills ? kills! : bestKills,
      bestTime: (time ?? 0) > bestTime ? time! : bestTime,
      clearedAt: (cleared == true && !isCleared)
          ? DateTime.now().toIso8601String()
          : clearedAt,
    );
  }

  Map<String, dynamic> ToJson() {
    return {
      'challengeId': challengeId,
      'isCleared': isCleared,
      'bestWave': bestWave,
      'bestKills': bestKills,
      'bestTime': bestTime,
      'clearedAt': clearedAt,
    };
  }

  factory ChallengeRecordData.FromJson(Map<String, dynamic> json) {
    return ChallengeRecordData(
      challengeId: json['challengeId'] as String,
      isCleared: json['isCleared'] as bool? ?? false,
      bestWave: json['bestWave'] as int? ?? 0,
      bestKills: json['bestKills'] as int? ?? 0,
      bestTime: json['bestTime'] as int? ?? 0,
      clearedAt: json['clearedAt'] as String?,
    );
  }
}

/// 장비 인스턴스 데이터 (저장용)
class EquipmentInstanceData {
  final String instanceId;
  final String equipmentId;  // EquipmentData.id
  final int level;
  final bool isEquipped;

  const EquipmentInstanceData({
    required this.instanceId,
    required this.equipmentId,
    this.level = 1,
    this.isEquipped = false,
  });

  Map<String, dynamic> ToJson() {
    return {
      'instanceId': instanceId,
      'equipmentId': equipmentId,
      'level': level,
      'isEquipped': isEquipped,
    };
  }

  factory EquipmentInstanceData.FromJson(Map<String, dynamic> json) {
    return EquipmentInstanceData(
      instanceId: json['instanceId'] as String,
      equipmentId: json['equipmentId'] as String,
      level: json['level'] as int? ?? 1,
      isEquipped: json['isEquipped'] as bool? ?? false,
    );
  }

  EquipmentInstanceData CopyWith({
    int? level,
    bool? isEquipped,
  }) {
    return EquipmentInstanceData(
      instanceId: instanceId,
      equipmentId: equipmentId,
      level: level ?? this.level,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}

/// 장비 데이터 (영구 저장)
class EquipmentProgressData {
  final List<EquipmentInstanceData> inventory;
  final Map<String, String?> equippedIds;  // slot name → instanceId
  final int nextInstanceId;

  const EquipmentProgressData({
    this.inventory = const [],
    this.equippedIds = const {},
    this.nextInstanceId = 1,
  });

  Map<String, dynamic> ToJson() {
    return {
      'inventory': inventory.map((e) => e.ToJson()).toList(),
      'equippedIds': equippedIds,
      'nextInstanceId': nextInstanceId,
    };
  }

  factory EquipmentProgressData.FromJson(Map<String, dynamic> json) {
    final inventoryJson = json['inventory'] as List<dynamic>? ?? [];
    final inventory = inventoryJson
        .map((e) => EquipmentInstanceData.FromJson(e as Map<String, dynamic>))
        .toList();

    final equippedJson = json['equippedIds'] as Map<String, dynamic>? ?? {};
    final equippedIds = equippedJson.map(
      (key, value) => MapEntry(key, value as String?),
    );

    return EquipmentProgressData(
      inventory: inventory,
      equippedIds: equippedIds,
      nextInstanceId: json['nextInstanceId'] as int? ?? 1,
    );
  }

  /// 장비 추가
  EquipmentProgressData AddEquipment(String equipmentId) {
    final newInstance = EquipmentInstanceData(
      instanceId: 'equip_$nextInstanceId',
      equipmentId: equipmentId,
      level: 1,
      isEquipped: false,
    );
    return EquipmentProgressData(
      inventory: [...inventory, newInstance],
      equippedIds: equippedIds,
      nextInstanceId: nextInstanceId + 1,
    );
  }

  /// 장비 제거
  EquipmentProgressData RemoveEquipment(String instanceId) {
    final newInventory = inventory.where((e) => e.instanceId != instanceId).toList();
    // 장착 해제
    final newEquipped = Map<String, String?>.from(equippedIds);
    newEquipped.removeWhere((key, value) => value == instanceId);
    return EquipmentProgressData(
      inventory: newInventory,
      equippedIds: newEquipped,
      nextInstanceId: nextInstanceId,
    );
  }

  /// 장비 장착
  EquipmentProgressData EquipItem(String instanceId, EquipmentSlot slot) {
    final slotName = slot.name;
    final oldEquippedId = equippedIds[slotName];

    // 기존 장착 해제
    var newInventory = inventory.map((e) {
      if (e.instanceId == oldEquippedId) {
        return e.CopyWith(isEquipped: false);
      }
      if (e.instanceId == instanceId) {
        return e.CopyWith(isEquipped: true);
      }
      return e;
    }).toList();

    final newEquipped = Map<String, String?>.from(equippedIds);
    newEquipped[slotName] = instanceId;

    return EquipmentProgressData(
      inventory: newInventory,
      equippedIds: newEquipped,
      nextInstanceId: nextInstanceId,
    );
  }

  /// 장비 해제
  EquipmentProgressData UnequipItem(EquipmentSlot slot) {
    final slotName = slot.name;
    final equippedId = equippedIds[slotName];
    if (equippedId == null) return this;

    final newInventory = inventory.map((e) {
      if (e.instanceId == equippedId) {
        return e.CopyWith(isEquipped: false);
      }
      return e;
    }).toList();

    final newEquipped = Map<String, String?>.from(equippedIds);
    newEquipped[slotName] = null;

    return EquipmentProgressData(
      inventory: newInventory,
      equippedIds: newEquipped,
      nextInstanceId: nextInstanceId,
    );
  }

  /// 장비 강화
  EquipmentProgressData UpgradeEquipment(String instanceId) {
    final newInventory = inventory.map((e) {
      if (e.instanceId == instanceId) {
        return e.CopyWith(level: e.level + 1);
      }
      return e;
    }).toList();

    return EquipmentProgressData(
      inventory: newInventory,
      equippedIds: equippedIds,
      nextInstanceId: nextInstanceId,
    );
  }

  /// 장착된 무기의 장비 ID 조회
  String? GetEquippedWeaponId() {
    final instanceId = equippedIds['weapon'];
    if (instanceId == null) return null;
    final instance = inventory.firstWhere(
      (e) => e.instanceId == instanceId,
      orElse: () => const EquipmentInstanceData(instanceId: '', equipmentId: ''),
    );
    return instance.equipmentId.isNotEmpty ? instance.equipmentId : null;
  }

  /// 인스턴스 ID로 장비 조회
  EquipmentInstanceData? GetByInstanceId(String instanceId) {
    try {
      return inventory.firstWhere((e) => e.instanceId == instanceId);
    } catch (_) {
      return null;
    }
  }
}

/// 전체 진행 데이터
class ProgressData {
  final AccountLevel accountLevel;
  final CurrencyData currency;
  final Map<String, ChallengeRecordData> challengeRecords;
  final EquipmentProgressData equipment;  // 장비 데이터
  final PatrolProgressData patrol;        // 순찰 데이터
  final ShopProgressData shop;            // 상점 데이터
  final int totalPlayTime;      // 총 플레이 시간 (초)
  final int totalKills;         // 총 처치 수
  final int totalGamesPlayed;   // 총 게임 횟수

  const ProgressData({
    this.accountLevel = const AccountLevel(),
    this.currency = const CurrencyData(),
    this.challengeRecords = const {},
    this.equipment = const EquipmentProgressData(),
    this.patrol = const PatrolProgressData(),
    this.shop = const ShopProgressData(),
    this.totalPlayTime = 0,
    this.totalKills = 0,
    this.totalGamesPlayed = 0,
  });

  /// 게임 종료 후 통계 업데이트
  ProgressData UpdateGameStats({
    required int playTime,
    required int kills,
    required int expGained,
    int goldGained = 0,
    int gemsGained = 0,
  }) {
    return copyWith(
      accountLevel: accountLevel.AddExp(expGained),
      currency: currency.AddGold(goldGained).AddGems(gemsGained),
      totalPlayTime: totalPlayTime + playTime,
      totalKills: totalKills + kills,
      totalGamesPlayed: totalGamesPlayed + 1,
    );
  }

  /// 도전 기록 업데이트
  ProgressData UpdateChallengeRecord(ChallengeRecordData record) {
    final newRecords = Map<String, ChallengeRecordData>.from(challengeRecords);
    newRecords[record.challengeId] = record;
    return copyWith(challengeRecords: newRecords);
  }

  /// 장비 데이터 업데이트
  ProgressData UpdateEquipment(EquipmentProgressData newEquipment) {
    return copyWith(equipment: newEquipment);
  }

  /// 순찰 데이터 업데이트
  ProgressData UpdatePatrol(PatrolProgressData newPatrol) {
    return copyWith(patrol: newPatrol);
  }

  /// 상점 데이터 업데이트
  ProgressData UpdateShop(ShopProgressData newShop) {
    return copyWith(shop: newShop);
  }

  /// copyWith 메서드
  ProgressData copyWith({
    AccountLevel? accountLevel,
    CurrencyData? currency,
    Map<String, ChallengeRecordData>? challengeRecords,
    EquipmentProgressData? equipment,
    PatrolProgressData? patrol,
    ShopProgressData? shop,
    int? totalPlayTime,
    int? totalKills,
    int? totalGamesPlayed,
  }) {
    return ProgressData(
      accountLevel: accountLevel ?? this.accountLevel,
      currency: currency ?? this.currency,
      challengeRecords: challengeRecords ?? this.challengeRecords,
      equipment: equipment ?? this.equipment,
      patrol: patrol ?? this.patrol,
      shop: shop ?? this.shop,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      totalKills: totalKills ?? this.totalKills,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
    );
  }

  Map<String, dynamic> ToJson() {
    return {
      'accountLevel': accountLevel.ToJson(),
      'currency': currency.ToJson(),
      'challengeRecords': challengeRecords.map(
        (key, value) => MapEntry(key, value.ToJson()),
      ),
      'equipment': equipment.ToJson(),
      'patrol': patrol.ToJson(),
      'shop': shop.ToJson(),
      'totalPlayTime': totalPlayTime,
      'totalKills': totalKills,
      'totalGamesPlayed': totalGamesPlayed,
    };
  }

  factory ProgressData.FromJson(Map<String, dynamic> json) {
    final recordsJson = json['challengeRecords'] as Map<String, dynamic>? ?? {};
    final records = recordsJson.map(
      (key, value) => MapEntry(
        key,
        ChallengeRecordData.FromJson(value as Map<String, dynamic>),
      ),
    );

    return ProgressData(
      accountLevel: json['accountLevel'] != null
          ? AccountLevel.FromJson(json['accountLevel'] as Map<String, dynamic>)
          : const AccountLevel(),
      currency: json['currency'] != null
          ? CurrencyData.FromJson(json['currency'] as Map<String, dynamic>)
          : const CurrencyData(),
      challengeRecords: records,
      equipment: json['equipment'] != null
          ? EquipmentProgressData.FromJson(json['equipment'] as Map<String, dynamic>)
          : const EquipmentProgressData(),
      patrol: json['patrol'] != null
          ? PatrolProgressData.FromJson(json['patrol'] as Map<String, dynamic>)
          : const PatrolProgressData(),
      shop: json['shop'] != null
          ? ShopProgressData.FromJson(json['shop'] as Map<String, dynamic>)
          : const ShopProgressData(),
      totalPlayTime: json['totalPlayTime'] as int? ?? 0,
      totalKills: json['totalKills'] as int? ?? 0,
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
    );
  }
}
