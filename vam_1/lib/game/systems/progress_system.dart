import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/logger.dart';
import '../../data/models/progress_data.dart';

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
        Logger.game('Progress loaded: Level ${_data.accountLevel.level}, Gold ${_data.currency.gold}');
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
      final newRecord = (existingRecord ?? ChallengeRecordData(challengeId: challengeId))
          .UpdateRecord(
        cleared: isVictory,
        wave: wave,
        kills: kills,
        time: playTime,
      );
      _data = _data.UpdateChallengeRecord(newRecord);
    }

    await Save();

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
    _data = ProgressData(
      accountLevel: _data.accountLevel,
      currency: _data.currency.AddGold(gold).AddGems(gems),
      challengeRecords: _data.challengeRecords,
      totalPlayTime: _data.totalPlayTime,
      totalKills: _data.totalKills,
      totalGamesPlayed: _data.totalGamesPlayed,
    );
    await Save();
  }

  /// 재화 사용
  Future<bool> SpendCurrency({int gold = 0, int gems = 0}) async {
    if (!_data.currency.CanAffordGold(gold) ||
        !_data.currency.CanAffordGems(gems)) {
      return false;
    }

    _data = ProgressData(
      accountLevel: _data.accountLevel,
      currency: _data.currency.SpendGold(gold).SpendGems(gems),
      challengeRecords: _data.challengeRecords,
      totalPlayTime: _data.totalPlayTime,
      totalKills: _data.totalKills,
      totalGamesPlayed: _data.totalGamesPlayed,
    );
    await Save();
    return true;
  }

  /// 데이터 초기화 (디버그용)
  Future<void> ResetProgress() async {
    _data = const ProgressData();
    await Save();
    Logger.game('Progress reset');
  }

  /// 디버그용 레벨 설정
  Future<void> DebugSetLevel(int level) async {
    _data = ProgressData(
      accountLevel: AccountLevel(
        level: level,
        currentExp: 0,
        totalExp: _data.accountLevel.totalExp,
      ),
      currency: _data.currency,
      challengeRecords: _data.challengeRecords,
      totalPlayTime: _data.totalPlayTime,
      totalKills: _data.totalKills,
      totalGamesPlayed: _data.totalGamesPlayed,
    );
    await Save();
    Logger.game('Debug: Level set to $level');
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
