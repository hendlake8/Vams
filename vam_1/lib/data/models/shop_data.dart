/// 상점 시스템 데이터 모델
/// 골드/보석으로 아이템 구매, 일일 상점 갱신

import 'package:flutter/material.dart';

/// 상점 아이템 타입
enum ShopItemType {
  equipment,    // 장비
  currency,     // 재화 (골드 ↔ 보석 교환)
  special,      // 특수 아이템
}

/// 구매 통화 타입
enum PriceType {
  gold,
  gems,
  free,  // 무료 (광고 시청 등)
}

/// 상점 아이템 데이터
class ShopItemData {
  final String id;
  final String name;
  final String description;
  final ShopItemType type;
  final PriceType priceType;
  final int price;
  final String? equipmentId;      // 장비 타입일 경우 장비 ID
  final int? goldAmount;          // 재화 타입일 경우 골드량
  final int? gemsAmount;          // 재화 타입일 경우 보석량
  final int? expAmount;           // 경험치량
  final int purchaseLimit;        // 구매 제한 (0 = 무제한)
  final bool isDailyReset;        // 일일 초기화 여부

  const ShopItemData({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.priceType,
    required this.price,
    this.equipmentId,
    this.goldAmount,
    this.gemsAmount,
    this.expAmount,
    this.purchaseLimit = 0,
    this.isDailyReset = false,
  });
}

/// 상점 탭 (카테고리)
enum ShopTab {
  featured,     // 추천
  equipment,    // 장비
  currency,     // 재화
  special,      // 특수
}

/// 기본 상점 아이템 정의
class DefaultShopItems {
  DefaultShopItems._();

  // ========== 추천 (일일 상점) ==========

  static const ShopItemData DAILY_FREE_GOLD = ShopItemData(
    id: 'daily_free_gold',
    name: '무료 골드',
    description: '매일 무료로 받을 수 있는 골드입니다.',
    type: ShopItemType.currency,
    priceType: PriceType.free,
    price: 0,
    goldAmount: 100,
    purchaseLimit: 1,
    isDailyReset: true,
  );

  static const ShopItemData DAILY_GOLD_PACK = ShopItemData(
    id: 'daily_gold_pack',
    name: '일일 골드 팩',
    description: '보석으로 구매하는 일일 한정 골드 팩입니다.',
    type: ShopItemType.currency,
    priceType: PriceType.gems,
    price: 10,
    goldAmount: 500,
    purchaseLimit: 3,
    isDailyReset: true,
  );

  static const ShopItemData DAILY_EXP_BOOST = ShopItemData(
    id: 'daily_exp_boost',
    name: '경험치 부스터',
    description: '즉시 경험치를 획득합니다.',
    type: ShopItemType.special,
    priceType: PriceType.gems,
    price: 20,
    expAmount: 100,
    purchaseLimit: 2,
    isDailyReset: true,
  );

  // ========== 장비 상점 ==========

  static const ShopItemData SHOP_STARTER_WAND = ShopItemData(
    id: 'shop_starter_wand',
    name: '초보자의 지팡이',
    description: '에너지 볼트를 발사하는 기본 지팡이입니다.',
    type: ShopItemType.equipment,
    priceType: PriceType.gold,
    price: 200,
    equipmentId: 'equip_starter_wand',
  );

  static const ShopItemData SHOP_IRON_SWORD = ShopItemData(
    id: 'shop_iron_sword',
    name: '철 검',
    description: '기본적인 철제 검입니다.',
    type: ShopItemType.equipment,
    priceType: PriceType.gold,
    price: 300,
    equipmentId: 'equip_iron_sword',
  );

  static const ShopItemData SHOP_LEATHER_ARMOR = ShopItemData(
    id: 'shop_leather_armor',
    name: '가죽 갑옷',
    description: '기본적인 가죽 갑옷입니다.',
    type: ShopItemType.equipment,
    priceType: PriceType.gold,
    price: 250,
    equipmentId: 'equip_leather_armor',
  );

  static const ShopItemData SHOP_SPEED_BOOTS = ShopItemData(
    id: 'shop_speed_boots',
    name: '신속의 부츠',
    description: '이동 속도를 높여주는 부츠입니다.',
    type: ShopItemType.equipment,
    priceType: PriceType.gold,
    price: 200,
    equipmentId: 'equip_speed_boots',
  );

  static const ShopItemData SHOP_FLAME_BLADE = ShopItemData(
    id: 'shop_flame_blade',
    name: '화염 검',
    description: '불꽃이 깃든 희귀 검입니다.',
    type: ShopItemType.equipment,
    priceType: PriceType.gems,
    price: 50,
    equipmentId: 'equip_flame_blade',
  );

  static const ShopItemData SHOP_KNIGHT_PLATE = ShopItemData(
    id: 'shop_knight_plate',
    name: '기사의 판금 갑옷',
    description: '튼튼한 판금 갑옷입니다.',
    type: ShopItemType.equipment,
    priceType: PriceType.gems,
    price: 45,
    equipmentId: 'equip_knight_plate',
  );

  static const ShopItemData SHOP_CRITICAL_RING = ShopItemData(
    id: 'shop_critical_ring',
    name: '치명의 반지',
    description: '크리티컬을 높여주는 반지입니다.',
    type: ShopItemType.equipment,
    priceType: PriceType.gems,
    price: 40,
    equipmentId: 'equip_critical_ring',
  );

  // ========== 재화 상점 ==========

  static const ShopItemData GOLD_PACK_SMALL = ShopItemData(
    id: 'gold_pack_small',
    name: '골드 팩 (소)',
    description: '소량의 골드를 획득합니다.',
    type: ShopItemType.currency,
    priceType: PriceType.gems,
    price: 10,
    goldAmount: 300,
  );

  static const ShopItemData GOLD_PACK_MEDIUM = ShopItemData(
    id: 'gold_pack_medium',
    name: '골드 팩 (중)',
    description: '중간량의 골드를 획득합니다.',
    type: ShopItemType.currency,
    priceType: PriceType.gems,
    price: 25,
    goldAmount: 800,
  );

  static const ShopItemData GOLD_PACK_LARGE = ShopItemData(
    id: 'gold_pack_large',
    name: '골드 팩 (대)',
    description: '대량의 골드를 획득합니다.',
    type: ShopItemType.currency,
    priceType: PriceType.gems,
    price: 50,
    goldAmount: 2000,
  );

  static const ShopItemData GEMS_PACK_STARTER = ShopItemData(
    id: 'gems_pack_starter',
    name: '보석 스타터 팩',
    description: '보석을 골드로 구매합니다.',
    type: ShopItemType.currency,
    priceType: PriceType.gold,
    price: 1000,
    gemsAmount: 10,
  );

  // ========== 특수 아이템 ==========

  static const ShopItemData RANDOM_EQUIPMENT = ShopItemData(
    id: 'random_equipment',
    name: '랜덤 장비 상자',
    description: '랜덤한 장비를 획득합니다.',
    type: ShopItemType.special,
    priceType: PriceType.gems,
    price: 30,
  );

  static const ShopItemData RARE_EQUIPMENT_BOX = ShopItemData(
    id: 'rare_equipment_box',
    name: '희귀 장비 상자',
    description: '희귀 등급 이상의 장비를 획득합니다.',
    type: ShopItemType.special,
    priceType: PriceType.gems,
    price: 80,
  );

  // 카테고리별 아이템 목록

  static List<ShopItemData> get featuredItems => [
    DAILY_FREE_GOLD,
    DAILY_GOLD_PACK,
    DAILY_EXP_BOOST,
  ];

  static List<ShopItemData> get equipmentItems => [
    SHOP_STARTER_WAND,
    SHOP_IRON_SWORD,
    SHOP_LEATHER_ARMOR,
    SHOP_SPEED_BOOTS,
    SHOP_FLAME_BLADE,
    SHOP_KNIGHT_PLATE,
    SHOP_CRITICAL_RING,
  ];

  static List<ShopItemData> get currencyItems => [
    GOLD_PACK_SMALL,
    GOLD_PACK_MEDIUM,
    GOLD_PACK_LARGE,
    GEMS_PACK_STARTER,
  ];

  static List<ShopItemData> get specialItems => [
    RANDOM_EQUIPMENT,
    RARE_EQUIPMENT_BOX,
  ];

  static List<ShopItemData> get all => [
    ...featuredItems,
    ...equipmentItems,
    ...currencyItems,
    ...specialItems,
  ];

  static ShopItemData? GetById(String id) {
    try {
      return all.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<ShopItemData> GetByTab(ShopTab tab) {
    switch (tab) {
      case ShopTab.featured:
        return featuredItems;
      case ShopTab.equipment:
        return equipmentItems;
      case ShopTab.currency:
        return currencyItems;
      case ShopTab.special:
        return specialItems;
    }
  }
}

/// 상점 구매 기록 (영구 저장용)
class ShopPurchaseRecord {
  final String itemId;
  final int purchaseCount;
  final String? lastPurchaseDate;  // ISO8601 (일일 리셋용)

  const ShopPurchaseRecord({
    required this.itemId,
    this.purchaseCount = 0,
    this.lastPurchaseDate,
  });

  /// 오늘 구매 횟수 (일일 리셋 아이템용)
  int GetTodayPurchaseCount() {
    if (lastPurchaseDate == null) return 0;

    final lastDate = DateTime.tryParse(lastPurchaseDate!);
    if (lastDate == null) return 0;

    final today = DateTime.now();
    if (lastDate.year == today.year &&
        lastDate.month == today.month &&
        lastDate.day == today.day) {
      return purchaseCount;
    }

    return 0;  // 날짜가 다르면 0
  }

  /// 구매 기록 추가
  ShopPurchaseRecord AddPurchase() {
    return ShopPurchaseRecord(
      itemId: itemId,
      purchaseCount: purchaseCount + 1,
      lastPurchaseDate: DateTime.now().toIso8601String(),
    );
  }

  /// 일일 리셋 (새로운 날)
  ShopPurchaseRecord ResetDaily() {
    return ShopPurchaseRecord(
      itemId: itemId,
      purchaseCount: 0,
      lastPurchaseDate: DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> ToJson() {
    return {
      'itemId': itemId,
      'purchaseCount': purchaseCount,
      'lastPurchaseDate': lastPurchaseDate,
    };
  }

  factory ShopPurchaseRecord.FromJson(Map<String, dynamic> json) {
    return ShopPurchaseRecord(
      itemId: json['itemId'] as String,
      purchaseCount: json['purchaseCount'] as int? ?? 0,
      lastPurchaseDate: json['lastPurchaseDate'] as String?,
    );
  }
}

/// 상점 진행 데이터 (영구 저장용)
class ShopProgressData {
  final Map<String, ShopPurchaseRecord> purchaseRecords;

  const ShopProgressData({
    this.purchaseRecords = const {},
  });

  /// 아이템 구매 가능 여부 확인
  bool CanPurchase(ShopItemData item) {
    if (item.purchaseLimit <= 0) return true;  // 무제한

    final record = purchaseRecords[item.id];
    if (record == null) return true;

    if (item.isDailyReset) {
      return record.GetTodayPurchaseCount() < item.purchaseLimit;
    }

    return record.purchaseCount < item.purchaseLimit;
  }

  /// 남은 구매 횟수
  int GetRemainingPurchases(ShopItemData item) {
    if (item.purchaseLimit <= 0) return -1;  // 무제한

    final record = purchaseRecords[item.id];
    if (record == null) return item.purchaseLimit;

    if (item.isDailyReset) {
      return item.purchaseLimit - record.GetTodayPurchaseCount();
    }

    return item.purchaseLimit - record.purchaseCount;
  }

  /// 구매 기록 추가
  ShopProgressData RecordPurchase(String itemId) {
    final existing = purchaseRecords[itemId];
    final newRecord = existing != null
        ? existing.AddPurchase()
        : ShopPurchaseRecord(itemId: itemId, purchaseCount: 1, lastPurchaseDate: DateTime.now().toIso8601String());

    final newRecords = Map<String, ShopPurchaseRecord>.from(purchaseRecords);
    newRecords[itemId] = newRecord;

    return ShopProgressData(purchaseRecords: newRecords);
  }

  Map<String, dynamic> ToJson() {
    return {
      'purchaseRecords': purchaseRecords.map(
        (key, value) => MapEntry(key, value.ToJson()),
      ),
    };
  }

  factory ShopProgressData.FromJson(Map<String, dynamic> json) {
    final recordsJson = json['purchaseRecords'] as Map<String, dynamic>? ?? {};
    final records = recordsJson.map(
      (key, value) => MapEntry(
        key,
        ShopPurchaseRecord.FromJson(value as Map<String, dynamic>),
      ),
    );

    return ShopProgressData(purchaseRecords: records);
  }
}

/// 상점 탭 확장
extension ShopTabExtension on ShopTab {
  String get displayName {
    switch (this) {
      case ShopTab.featured:
        return '추천';
      case ShopTab.equipment:
        return '장비';
      case ShopTab.currency:
        return '재화';
      case ShopTab.special:
        return '특수';
    }
  }

  IconData get icon {
    switch (this) {
      case ShopTab.featured:
        return Icons.star;
      case ShopTab.equipment:
        return Icons.shield;
      case ShopTab.currency:
        return Icons.monetization_on;
      case ShopTab.special:
        return Icons.card_giftcard;
    }
  }
}

/// 가격 타입 확장
extension PriceTypeExtension on PriceType {
  Color get color {
    switch (this) {
      case PriceType.gold:
        return Colors.amber;
      case PriceType.gems:
        return Colors.cyan;
      case PriceType.free:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case PriceType.gold:
        return Icons.monetization_on;
      case PriceType.gems:
        return Icons.diamond;
      case PriceType.free:
        return Icons.redeem;
    }
  }
}
