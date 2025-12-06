import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/logger.dart';
import '../../data/models/equipment_data.dart';
import '../../data/models/patrol_data.dart';
import '../../data/models/progress_data.dart';
import '../../data/models/shop_data.dart';

/// 영구 진행 시스템
/// SharedPreferences를 통해 계정 레벨, 재화, 도전 기록을 저장/불러오기
class ProgressSystem {
  static const String _SAVE_KEY = 'vam_progress_data';

  static ProgressSystem? _instance;
  static ProgressSystem get instance => _instance ??= ProgressSystem._();

  ProgressSystem._();

  ProgressData _data = const ProgressData();
  bool _isLoaded = false;

  // 마지막 게임 결과 (결과창 표시용)
  GameEndResult? mLastGameResult;

  // Getters
  ProgressData get data => _data;
  bool get isLoaded => _isLoaded;
  int get playerLevel => _data.accountLevel.level;
  int get gold => _data.currency.gold;
  int get gems => _data.currency.gems;

  /// 초기화 - 앱 시작 시 호출
  Future<void> Initialize() async {
    if (_isLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_SAVE_KEY);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _data = ProgressData.FromJson(json);
        Logger.game('Progress loaded: Level ${_data.accountLevel.level}, Gold ${_data.currency.gold}, Gems ${_data.currency.gems}');
        Logger.game('Challenge records loaded: ${_data.challengeRecords.keys.toList()}');
        for (final entry in _data.challengeRecords.entries) {
          Logger.game('  ${entry.key}: isCleared=${entry.value.isCleared}, bestWave=${entry.value.bestWave}');
        }
      } else {
        _data = const ProgressData();
        Logger.game('No saved progress found, starting fresh');
      }

      _isLoaded = true;
    } catch (e) {
      Logger.game('Failed to load progress: $e');
      _data = const ProgressData();
      _isLoaded = true;
    }
  }

  /// 저장
  Future<void> Save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_data.ToJson());
      await prefs.setString(_SAVE_KEY, jsonString);
      Logger.game('Progress saved');
    } catch (e) {
      Logger.game('Failed to save progress: $e');
    }
  }

  /// 게임 종료 시 호출 - 통계 및 보상 처리
  Future<void> OnGameEnd({
    required int playTime,
    required int kills,
    required bool isVictory,
    String? challengeId,
    int wave = 0,
    int bossKills = 0,
  }) async {
    // 경험치 계산: 기본 + 처치 보너스 + 승리 보너스
    int expGained = 10;  // 기본
    expGained += kills ~/ 10;  // 10킬당 1exp
    expGained += playTime ~/ 60;  // 1분당 1exp
    if (isVictory) expGained += 50;  // 승리 보너스

    // 골드 계산: 처치당 + 시간 보너스
    int goldGained = kills * 2;  // 처치당 2골드
    if (isVictory) goldGained += 100;  // 승리 보너스

    // 이전 레벨 기록
    final previousLevel = _data.accountLevel.level;

    // 통계 업데이트
    _data = _data.UpdateGameStats(
      playTime: playTime,
      kills: kills,
      expGained: expGained,
      goldGained: goldGained,
    );

    // 레벨업 확인
    final leveledUp = _data.accountLevel.level > previousLevel;
    if (leveledUp) {
      final levelsGained = _data.accountLevel.level - previousLevel;
      Logger.game('Level Up! $previousLevel → ${_data.accountLevel.level} (+$levelsGained)');
    }

    // 마지막 게임 결과 저장 (결과창 표시용)
    mLastGameResult = GameEndResult(
      expGained: expGained,
      goldGained: goldGained,
      previousLevel: previousLevel,
      newLevel: _data.accountLevel.level,
      leveledUp: leveledUp,
      currentExp: _data.accountLevel.currentExp,
      requiredExp: _data.accountLevel.requiredExp,
    );

    // 도전 기록 업데이트
    if (challengeId != null) {
      final existingRecord = _data.challengeRecords[challengeId];
      Logger.game('Challenge record before update: ${existingRecord?.isCleared ?? "null"}');
      final newRecord = (existingRecord ?? ChallengeRecordData(challengeId: challengeId))
          .UpdateRecord(
        cleared: isVictory,
        wave: wave,
        kills: kills,
        time: playTime,
      );
      Logger.game('Challenge record after UpdateRecord: isCleared=${newRecord.isCleared}');
      _data = _data.UpdateChallengeRecord(newRecord);
      Logger.game('Challenge record in _data: ${_data.challengeRecords[challengeId]?.isCleared}');
    }

    await Save();
    Logger.game('Data saved. Verifying: challengeRecords[${challengeId ?? "null"}]?.isCleared = ${_data.challengeRecords[challengeId ?? '']?.isCleared}');

    Logger.game('Game end processed: +$expGained exp, +$goldGained gold');
  }

  /// 도전 기록 조회
  ChallengeRecordData? GetChallengeRecord(String challengeId) {
    return _data.challengeRecords[challengeId];
  }

  /// 도전 클리어 여부
  bool IsChallengeCleared(String challengeId) {
    return _data.challengeRecords[challengeId]?.isCleared ?? false;
  }

  /// 재화 추가
  Future<void> AddCurrency({int gold = 0, int gems = 0}) async {
    _data = _data.copyWith(
      currency: _data.currency.AddGold(gold).AddGems(gems),
    );
    await Save();
  }

  /// 재화 사용
  Future<bool> SpendCurrency({int gold = 0, int gems = 0}) async {
    if (!_data.currency.CanAffordGold(gold) ||
        !_data.currency.CanAffordGems(gems)) {
      return false;
    }

    _data = _data.copyWith(
      currency: _data.currency.SpendGold(gold).SpendGems(gems),
    );
    await Save();
    return true;
  }

  /// 경험치 추가
  Future<void> AddExp(int exp) async {
    _data = _data.copyWith(
      accountLevel: _data.accountLevel.AddExp(exp),
    );
    await Save();
  }

  /// 데이터 초기화 (디버그용)
  Future<void> ResetProgress() async {
    _data = const ProgressData();
    await Save();
    Logger.game('Progress reset');
  }

  /// 디버그용 레벨 설정
  Future<void> DebugSetLevel(int level) async {
    _data = _data.copyWith(
      accountLevel: AccountLevel(
        level: level,
        currentExp: 0,
        totalExp: _data.accountLevel.totalExp,
      ),
    );
    await Save();
    Logger.game('Debug: Level set to $level');
  }

  // ==================== 장비 관리 ====================

  /// 장비 데이터 getter
  EquipmentProgressData get equipment => _data.equipment;

  /// 장비 인벤토리
  List<EquipmentInstanceData> get equipmentInventory => _data.equipment.inventory;

  /// 장착된 장비 ID 맵
  Map<String, String?> get equippedIds => _data.equipment.equippedIds;

  /// 장착된 무기의 장비 ID
  String? get equippedWeaponId => _data.equipment.GetEquippedWeaponId();

  /// 장비 추가
  Future<void> AddEquipment(String equipmentId) async {
    _data = _data.UpdateEquipment(_data.equipment.AddEquipment(equipmentId));
    await Save();
    Logger.game('Equipment added: $equipmentId');
  }

  /// 장비 제거
  Future<void> RemoveEquipment(String instanceId) async {
    _data = _data.UpdateEquipment(_data.equipment.RemoveEquipment(instanceId));
    await Save();
    Logger.game('Equipment removed: $instanceId');
  }

  /// 장비 장착
  Future<void> EquipItem(String instanceId, EquipmentSlot slot) async {
    _data = _data.UpdateEquipment(_data.equipment.EquipItem(instanceId, slot));
    await Save();
    Logger.game('Equipment equipped: $instanceId to ${slot.name}');
  }

  /// 장비 해제
  Future<void> UnequipItem(EquipmentSlot slot) async {
    _data = _data.UpdateEquipment(_data.equipment.UnequipItem(slot));
    await Save();
    Logger.game('Equipment unequipped from ${slot.name}');
  }

  /// 장비 강화
  Future<void> UpgradeEquipment(String instanceId) async {
    _data = _data.UpdateEquipment(_data.equipment.UpgradeEquipment(instanceId));
    await Save();
    Logger.game('Equipment upgraded: $instanceId');
  }

  /// 인스턴스 ID로 장비 조회
  EquipmentInstanceData? GetEquipmentByInstanceId(String instanceId) {
    return _data.equipment.GetByInstanceId(instanceId);
  }

  /// 슬롯별 장착된 장비 조회
  EquipmentInstanceData? GetEquippedItem(EquipmentSlot slot) {
    final instanceId = _data.equipment.equippedIds[slot.name];
    if (instanceId == null) return null;
    return _data.equipment.GetByInstanceId(instanceId);
  }

  /// 장착된 무기의 스킬 ID 반환
  String? GetEquippedWeaponSkillId() {
    final weaponEquipmentId = _data.equipment.GetEquippedWeaponId();
    if (weaponEquipmentId == null) return null;

    final weaponData = DefaultEquipments.GetById(weaponEquipmentId);
    return weaponData?.skillId;
  }

  /// 초기 장비 설정 (신규 계정용)
  Future<void> InitializeStarterEquipment() async {
    // 이미 장비가 있으면 스킵
    if (_data.equipment.inventory.isNotEmpty) return;

    // 기본 무기 추가 및 장착
    _data = _data.UpdateEquipment(_data.equipment.AddEquipment('equip_starter_wand'));
    final starterInstance = _data.equipment.inventory.first;
    _data = _data.UpdateEquipment(_data.equipment.EquipItem(starterInstance.instanceId, EquipmentSlot.weapon));

    await Save();
    Logger.game('Starter equipment initialized');
  }

  // ==================== 순찰 관리 ====================

  /// 순찰 데이터 getter
  PatrolProgressData get patrol => _data.patrol;

  /// 순찰 중인지 여부
  bool get isPatrolling => _data.patrol.isPatrolling;

  /// 현재 순찰 지역
  PatrolZone? get activePatrolZone => _data.patrol.activeZone;

  /// 순찰 지역 해금 여부
  bool IsPatrolZoneUnlocked(PatrolZone zone) {
    final zoneData = DefaultPatrolZones.GetByZone(zone);
    if (zoneData == null) return false;
    return playerLevel >= zoneData.unlockLevel;
  }

  /// 순찰 시작
  Future<void> StartPatrol(PatrolZone zone) async {
    if (!IsPatrolZoneUnlocked(zone)) return;

    _data = _data.UpdatePatrol(_data.patrol.StartPatrol(zone));
    await Save();
    Logger.game('Patrol started: ${zone.name}');
  }

  /// 순찰 중지
  Future<void> StopPatrol() async {
    _data = _data.UpdatePatrol(_data.patrol.StopPatrol());
    await Save();
    Logger.game('Patrol stopped');
  }

  /// 순찰 지역 변경
  Future<void> ChangePatrolZone(PatrolZone zone) async {
    if (!IsPatrolZoneUnlocked(zone)) return;

    _data = _data.UpdatePatrol(_data.patrol.ChangeZone(zone));
    await Save();
    Logger.game('Patrol zone changed: ${zone.name}');
  }

  /// 순찰 보상 계산 (마지막 수령 이후)
  PatrolRewardResult CalculatePatrolRewards() {
    if (!isPatrolling) {
      return const PatrolRewardResult(gold: 0, exp: 0, equipmentIds: []);
    }

    final zoneData = DefaultPatrolZones.GetByZone(_data.patrol.activeZone!);
    if (zoneData == null) {
      return const PatrolRewardResult(gold: 0, exp: 0, equipmentIds: []);
    }

    final minutes = _data.patrol.GetMinutesSinceLastCollect();
    final gold = minutes * zoneData.goldPerMinute;
    final exp = minutes * zoneData.expPerMinute;

    // 장비 드롭 계산 (시간당 확률)
    final hours = minutes / 60.0;
    final dropCount = (hours * zoneData.equipDropChance).floor();
    final random = Random();

    List<String> droppedEquipments = [];
    for (int i = 0; i < dropCount; i++) {
      if (zoneData.possibleEquipments.isNotEmpty) {
        final randomIndex = random.nextInt(zoneData.possibleEquipments.length);
        droppedEquipments.add(zoneData.possibleEquipments[randomIndex]);
      }
    }

    // 추가 랜덤 드롭 체크 (남은 확률)
    final remainingChance = (hours * zoneData.equipDropChance) - dropCount;
    if (random.nextDouble() < remainingChance && zoneData.possibleEquipments.isNotEmpty) {
      final randomIndex = random.nextInt(zoneData.possibleEquipments.length);
      droppedEquipments.add(zoneData.possibleEquipments[randomIndex]);
    }

    return PatrolRewardResult(
      gold: gold,
      exp: exp,
      equipmentIds: droppedEquipments,
      minutes: minutes,
    );
  }

  /// 순찰 보상 수령
  Future<PatrolRewardResult> CollectPatrolRewards() async {
    final rewards = CalculatePatrolRewards();

    if (rewards.gold > 0 || rewards.exp > 0) {
      // 골드와 경험치 추가
      _data = _data.copyWith(
        currency: _data.currency.AddGold(rewards.gold),
        accountLevel: _data.accountLevel.AddExp(rewards.exp),
      );
    }

    // 장비 추가
    for (final equipId in rewards.equipmentIds) {
      _data = _data.UpdateEquipment(_data.equipment.AddEquipment(equipId));
    }

    // 보상 수령 시간 업데이트
    _data = _data.UpdatePatrol(_data.patrol.ClearRewards());

    await Save();
    Logger.game('Patrol rewards collected: ${rewards.gold} gold, ${rewards.exp} exp, ${rewards.equipmentIds.length} equipment(s)');

    return rewards;
  }

  // ==================== 상점 관리 ====================

  /// 상점 데이터 getter
  ShopProgressData get shop => _data.shop;

  /// 아이템 구매 가능 여부
  bool CanPurchaseItem(ShopItemData item) {
    // 구매 횟수 제한 체크
    if (!_data.shop.CanPurchase(item)) return false;

    // 재화 체크
    switch (item.priceType) {
      case PriceType.gold:
        return _data.currency.CanAffordGold(item.price);
      case PriceType.gems:
        return _data.currency.CanAffordGems(item.price);
      case PriceType.free:
        return true;
    }
  }

  /// 남은 구매 횟수
  int GetRemainingPurchases(ShopItemData item) {
    return _data.shop.GetRemainingPurchases(item);
  }

  /// 아이템 구매
  Future<ShopPurchaseResult> PurchaseItem(ShopItemData item) async {
    // 구매 가능 여부 체크
    if (!CanPurchaseItem(item)) {
      return ShopPurchaseResult(
        success: false,
        message: _data.shop.CanPurchase(item) ? '재화가 부족합니다.' : '구매 한도에 도달했습니다.',
      );
    }

    // 재화 차감
    switch (item.priceType) {
      case PriceType.gold:
        _data = _data.copyWith(
          currency: _data.currency.SpendGold(item.price),
        );
        break;
      case PriceType.gems:
        _data = _data.copyWith(
          currency: _data.currency.SpendGems(item.price),
        );
        break;
      case PriceType.free:
        break;
    }

    // 아이템 효과 적용
    String message = '';
    switch (item.type) {
      case ShopItemType.equipment:
        if (item.equipmentId != null) {
          _data = _data.UpdateEquipment(_data.equipment.AddEquipment(item.equipmentId!));
          message = '${item.name}을(를) 획득했습니다!';
        }
        break;

      case ShopItemType.currency:
        if (item.goldAmount != null && item.goldAmount! > 0) {
          _data = _data.copyWith(
            currency: _data.currency.AddGold(item.goldAmount!),
          );
          message = '골드 ${item.goldAmount}을(를) 획득했습니다!';
        }
        if (item.gemsAmount != null && item.gemsAmount! > 0) {
          _data = _data.copyWith(
            currency: _data.currency.AddGems(item.gemsAmount!),
          );
          message = '보석 ${item.gemsAmount}개를 획득했습니다!';
        }
        break;

      case ShopItemType.special:
        if (item.expAmount != null && item.expAmount! > 0) {
          _data = _data.copyWith(
            accountLevel: _data.accountLevel.AddExp(item.expAmount!),
          );
          message = '경험치 ${item.expAmount}을(를) 획득했습니다!';
        }
        // 랜덤 장비 상자 처리
        if (item.id == 'random_equipment') {
          final result = _getRandomEquipment(false);
          _data = _data.UpdateEquipment(_data.equipment.AddEquipment(result));
          final equipData = DefaultEquipments.GetById(result);
          message = '${equipData?.name ?? '장비'}을(를) 획득했습니다!';
        }
        if (item.id == 'rare_equipment_box') {
          final result = _getRandomEquipment(true);
          _data = _data.UpdateEquipment(_data.equipment.AddEquipment(result));
          final equipData = DefaultEquipments.GetById(result);
          message = '${equipData?.name ?? '희귀 장비'}을(를) 획득했습니다!';
        }
        break;
    }

    // 구매 기록 저장
    _data = _data.UpdateShop(_data.shop.RecordPurchase(item.id));

    await Save();
    Logger.game('Item purchased: ${item.id}');

    return ShopPurchaseResult(success: true, message: message);
  }

  /// 랜덤 장비 획득
  String _getRandomEquipment(bool rareOrHigher) {
    final random = Random();
    List<EquipmentData> candidates;

    if (rareOrHigher) {
      candidates = DefaultEquipments.all.where((e) =>
        e.rarity == EquipmentRarity.rare ||
        e.rarity == EquipmentRarity.epic ||
        e.rarity == EquipmentRarity.legendary
      ).toList();
    } else {
      candidates = DefaultEquipments.all;
    }

    if (candidates.isEmpty) {
      return DefaultEquipments.all.first.id;
    }

    return candidates[random.nextInt(candidates.length)].id;
  }
}

/// 게임 종료 결과 (결과창 표시용)
class GameEndResult {
  final int expGained;
  final int goldGained;
  final int previousLevel;
  final int newLevel;
  final bool leveledUp;
  final int currentExp;
  final int requiredExp;

  const GameEndResult({
    required this.expGained,
    required this.goldGained,
    required this.previousLevel,
    required this.newLevel,
    required this.leveledUp,
    required this.currentExp,
    required this.requiredExp,
  });
}

/// 순찰 보상 결과
class PatrolRewardResult {
  final int gold;
  final int exp;
  final List<String> equipmentIds;
  final int minutes;

  const PatrolRewardResult({
    required this.gold,
    required this.exp,
    required this.equipmentIds,
    this.minutes = 0,
  });

  bool get hasRewards => gold > 0 || exp > 0 || equipmentIds.isNotEmpty;
}

/// 상점 구매 결과
class ShopPurchaseResult {
  final bool success;
  final String message;

  const ShopPurchaseResult({
    required this.success,
    required this.message,
  });
}
