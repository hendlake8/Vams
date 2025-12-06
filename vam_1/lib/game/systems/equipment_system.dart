import 'dart:math';

import '../../core/utils/logger.dart';
import '../../data/models/actor_stats.dart';
import '../../data/models/equipment_data.dart';
import '../vam_game.dart';

/// 장비 시스템 - 장비 관리, 장착, 스탯 계산
class EquipmentSystem {
  final VamGame mGame;

  // 보유 장비 목록
  final List<EquipmentInstance> mInventory = [];

  // 장착된 장비 (슬롯별)
  final Map<EquipmentSlot, EquipmentInstance?> mEquipped = {
    EquipmentSlot.weapon: null,
    EquipmentSlot.armor: null,
    EquipmentSlot.accessory: null,
  };

  // 인스턴스 ID 생성용
  int _nextInstanceId = 1;

  EquipmentSystem(this.mGame);

  /// 초기 장비 지급 (게임 시작 시)
  void InitializeStarterEquipment() {
    // 기본 장비 지급
    AddEquipment(DefaultEquipments.IRON_SWORD);
    AddEquipment(DefaultEquipments.LEATHER_ARMOR);
    AddEquipment(DefaultEquipments.SPEED_BOOTS);

    // 자동 장착
    final weapon = mInventory.firstWhere((e) => e.data.slot == EquipmentSlot.weapon);
    final armor = mInventory.firstWhere((e) => e.data.slot == EquipmentSlot.armor);
    final accessory = mInventory.firstWhere((e) => e.data.slot == EquipmentSlot.accessory);

    Equip(weapon);
    Equip(armor);
    Equip(accessory);

    Logger.game('Starter equipment initialized');
  }

  /// 장비 추가 (획득)
  EquipmentInstance AddEquipment(EquipmentData data, {int level = 1}) {
    final instance = EquipmentInstance(
      instanceId: 'equip_${_nextInstanceId++}',
      data: data,
      level: level,
    );
    mInventory.add(instance);
    Logger.game('Equipment acquired: ${data.name} Lv.$level');
    return instance;
  }

  /// 장비 장착
  bool Equip(EquipmentInstance equipment) {
    final slot = equipment.data.slot;

    // 기존 장비 해제
    final currentEquipped = mEquipped[slot];
    if (currentEquipped != null) {
      currentEquipped.isEquipped = false;
    }

    // 새 장비 장착
    mEquipped[slot] = equipment;
    equipment.isEquipped = true;

    Logger.game('Equipped: ${equipment.data.name} to ${slot.displayName}');
    return true;
  }

  /// 장비 해제
  void Unequip(EquipmentSlot slot) {
    final equipment = mEquipped[slot];
    if (equipment != null) {
      equipment.isEquipped = false;
      mEquipped[slot] = null;
      Logger.game('Unequipped from ${slot.displayName}');
    }
  }

  /// 장비 강화
  bool UpgradeEquipment(EquipmentInstance equipment) {
    if (!equipment.CanUpgrade()) {
      Logger.game('Equipment at max level');
      return false;
    }

    equipment.level++;
    Logger.game('Equipment upgraded: ${equipment.data.name} -> Lv.${equipment.level}');
    return true;
  }

  /// 장비 판매/삭제
  void RemoveEquipment(EquipmentInstance equipment) {
    if (equipment.isEquipped) {
      Unequip(equipment.data.slot);
    }
    mInventory.remove(equipment);
    Logger.game('Equipment removed: ${equipment.data.name}');
  }

  /// 장착된 장비의 총 보너스 스탯 계산
  ActorStats GetTotalEquipmentStats() {
    int totalHp = 0;
    int totalAtk = 0;
    int totalDef = 0;
    double totalSpd = 0;
    double totalCritRate = 0;
    double totalCritDmg = 0;

    for (final equipment in mEquipped.values) {
      if (equipment != null) {
        final stats = equipment.GetCurrentStats();
        totalHp += stats.hp;
        totalAtk += stats.atk;
        totalDef += stats.def;
        totalSpd += stats.spd;
        totalCritRate += stats.critRate;
        totalCritDmg += stats.critDmg;
      }
    }

    return ActorStats(
      hp: totalHp,
      atk: totalAtk,
      def: totalDef,
      spd: totalSpd,
      critRate: totalCritRate,
      critDmg: totalCritDmg,
    );
  }

  /// 특정 슬롯에 장착된 장비
  EquipmentInstance? GetEquipped(EquipmentSlot slot) => mEquipped[slot];

  /// 슬롯별 인벤토리
  List<EquipmentInstance> GetInventoryBySlot(EquipmentSlot slot) {
    return mInventory.where((e) => e.data.slot == slot).toList();
  }

  /// 등급별 인벤토리
  List<EquipmentInstance> GetInventoryByRarity(EquipmentRarity rarity) {
    return mInventory.where((e) => e.data.rarity == rarity).toList();
  }

  /// 랜덤 장비 드롭 (몬스터 처치 시)
  EquipmentInstance? TryDropEquipment(double dropChance, {EquipmentRarity? maxRarity}) {
    final random = Random();

    if (random.nextDouble() > dropChance) {
      return null;  // 드롭 실패
    }

    // 등급 결정
    final rarityRoll = random.nextDouble();
    EquipmentRarity rarity;
    if (rarityRoll < 0.6) {
      rarity = EquipmentRarity.common;
    } else if (rarityRoll < 0.85) {
      rarity = EquipmentRarity.uncommon;
    } else if (rarityRoll < 0.95) {
      rarity = EquipmentRarity.rare;
    } else if (rarityRoll < 0.99) {
      rarity = EquipmentRarity.epic;
    } else {
      rarity = EquipmentRarity.legendary;
    }

    // 최대 등급 제한
    if (maxRarity != null && rarity.index > maxRarity.index) {
      rarity = maxRarity;
    }

    // 해당 등급 장비 선택
    final candidates = DefaultEquipments.GetByRarity(rarity);
    if (candidates.isEmpty) {
      // 해당 등급이 없으면 common으로 fallback
      final fallback = DefaultEquipments.GetByRarity(EquipmentRarity.common);
      if (fallback.isEmpty) return null;
      return AddEquipment(fallback[random.nextInt(fallback.length)]);
    }

    return AddEquipment(candidates[random.nextInt(candidates.length)]);
  }

  /// 장비 합성 (동일 등급 3개 → 상위 등급 1개)
  /// 반환: 합성 결과 장비 (실패 시 null)
  EquipmentInstance? FuseEquipments(List<EquipmentInstance> materials) {
    // 검증: 정확히 3개 필요
    if (materials.length != 3) {
      Logger.game('Fusion failed: Need exactly 3 materials');
      return null;
    }

    // 검증: 모두 같은 슬롯
    final slot = materials.first.data.slot;
    if (!materials.every((e) => e.data.slot == slot)) {
      Logger.game('Fusion failed: All materials must be same slot');
      return null;
    }

    // 검증: 모두 같은 등급
    final rarity = materials.first.data.rarity;
    if (!materials.every((e) => e.data.rarity == rarity)) {
      Logger.game('Fusion failed: All materials must be same rarity');
      return null;
    }

    // 검증: Legendary는 합성 불가
    if (rarity == EquipmentRarity.legendary) {
      Logger.game('Fusion failed: Cannot fuse legendary equipment');
      return null;
    }

    // 검증: 장착 중인 장비는 합성 불가
    if (materials.any((e) => e.isEquipped)) {
      Logger.game('Fusion failed: Cannot fuse equipped items');
      return null;
    }

    // 상위 등급 결정
    final nextRarity = EquipmentRarity.values[rarity.index + 1];

    // 해당 슬롯 + 상위 등급 장비 후보
    final candidates = DefaultEquipments.all
        .where((e) => e.slot == slot && e.rarity == nextRarity)
        .toList();

    if (candidates.isEmpty) {
      Logger.game('Fusion failed: No higher rarity equipment available');
      return null;
    }

    // 재료 제거
    for (final material in materials) {
      mInventory.remove(material);
    }

    // 랜덤 선택
    final random = Random();
    final resultData = candidates[random.nextInt(candidates.length)];

    // 새 장비 생성 (레벨 1)
    final result = AddEquipment(resultData, level: 1);

    Logger.game('Fusion success: ${materials.map((e) => e.data.name).join(", ")} -> ${result.data.name}');
    return result;
  }

  /// 합성 가능한 장비 그룹 조회 (슬롯+등급별)
  Map<String, List<EquipmentInstance>> GetFusionCandidates() {
    final Map<String, List<EquipmentInstance>> groups = {};

    for (final equipment in mInventory) {
      // 장착 중이거나 Legendary는 제외
      if (equipment.isEquipped) continue;
      if (equipment.data.rarity == EquipmentRarity.legendary) continue;

      final key = '${equipment.data.slot.name}_${equipment.data.rarity.name}';
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(equipment);
    }

    // 3개 이상인 그룹만 반환
    groups.removeWhere((key, list) => list.length < 3);
    return groups;
  }

  /// 특정 슬롯+등급의 합성 가능 여부
  bool CanFuse(EquipmentSlot slot, EquipmentRarity rarity) {
    if (rarity == EquipmentRarity.legendary) return false;

    final count = mInventory
        .where((e) => e.data.slot == slot &&
                      e.data.rarity == rarity &&
                      !e.isEquipped)
        .length;
    return count >= 3;
  }

  /// 리셋
  void Reset() {
    for (final slot in EquipmentSlot.values) {
      mEquipped[slot] = null;
    }
    // 인벤토리는 유지 (영구 자원)
  }

  // Getters
  List<EquipmentInstance> get inventory => mInventory;
  Map<EquipmentSlot, EquipmentInstance?> get equipped => mEquipped;
}
