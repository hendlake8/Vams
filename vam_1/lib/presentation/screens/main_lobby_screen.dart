import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../core/constants/game_constants.dart';
import '../../data/models/progress_data.dart';
import '../../game/systems/challenge_system.dart';
import '../../game/systems/progress_system.dart';
import '../../game/vam_game.dart';
import 'character_select_screen.dart';
import 'challenge_screen.dart';

/// 메인 로비 화면
class MainLobbyScreen extends StatefulWidget {
  const MainLobbyScreen({super.key});

  @override
  State<MainLobbyScreen> createState() => _MainLobbyScreenState();
}

class _MainLobbyScreenState extends State<MainLobbyScreen> {
  // 도전 시스템 (임시 - 실제로는 게임 전체에서 공유)
  late ChallengeSystem mChallengeSystem;
  bool mIsLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeProgress();
  }

  Future<void> _initializeProgress() async {
    // ProgressSystem 초기화 (저장된 데이터 불러오기)
    await ProgressSystem.instance.Initialize();

    // 임시 게임 인스턴스로 ChallengeSystem 생성 (기록 확인용)
    final tempGame = VamGame();
    mChallengeSystem = ChallengeSystem(tempGame);

    setState(() {
      mIsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (mIsLoading) {
      return const Scaffold(
        backgroundColor: DesignConstants.COLOR_BACKGROUND,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DesignConstants.COLOR_BACKGROUND,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 정보 바
            _buildTopBar(),

            // 메인 컨텐츠
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 게임 타이틀
                    const Text(
                      '뱀서라이크\n슈팅',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'v${GameConstants.GAME_VERSION}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: DesignConstants.FONT_SIZE_SMALL,
                      ),
                    ),

                    const SizedBox(height: 64),

                    // 시작 버튼
                    SizedBox(
                      width: 240,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CharacterSelectScreen(),
                            ),
                          ).then((_) {
                            // 게임에서 돌아오면 UI 갱신
                            setState(() {});
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignConstants.COLOR_PRIMARY,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
                          ),
                        ),
                        child: const Text(
                          '게임 시작',
                          style: TextStyle(
                            fontSize: DesignConstants.FONT_SIZE_LARGE,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 도전 모드 버튼
                    SizedBox(
                      width: 240,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChallengeScreen(
                                challengeSystem: mChallengeSystem,
                                onChallengeSelected: (challengeId) {
                                  // 도전 선택 후 캐릭터 선택 화면으로 이동
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CharacterSelectScreen(
                                        challengeId: challengeId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ).then((_) {
                            // 게임에서 돌아오면 UI 갱신
                            setState(() {});
                          });
                        },
                        icon: const Icon(Icons.emoji_events, color: Colors.amber),
                        label: const Text(
                          '도전 모드',
                          style: TextStyle(
                            fontSize: DesignConstants.FONT_SIZE_LARGE,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignConstants.COLOR_SURFACE,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DesignConstants.CORNER_RADIUS),
                            side: const BorderSide(color: Colors.amber, width: 2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),

                    // 안내 텍스트
                    const Text(
                      '조이스틱으로 이동\n공격은 자동!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: DesignConstants.FONT_SIZE_MEDIUM,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상단 정보 바 (레벨, 재화)
  Widget _buildTopBar() {
    final progress = ProgressSystem.instance;
    final accountLevel = progress.data.accountLevel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: DesignConstants.COLOR_SURFACE,
        border: Border(
          bottom: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        children: [
          // 레벨 표시
          _buildLevelBadge(accountLevel.level, accountLevel.progress),

          const SizedBox(width: 16),

          // 경험치 바
          Expanded(
            child: _buildExpBar(accountLevel),
          ),

          const SizedBox(width: 16),

          // 재화 표시
          _buildCurrencyDisplay(Icons.monetization_on, progress.gold, Colors.amber),
          const SizedBox(width: 12),
          _buildCurrencyDisplay(Icons.diamond, progress.gems, Colors.cyanAccent),
        ],
      ),
    );
  }

  /// 레벨 뱃지
  Widget _buildLevelBadge(int level, double progress) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Lv',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$level',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 경험치 바
  Widget _buildExpBar(AccountLevel accountLevel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'EXP: ${accountLevel.currentExp} / ${accountLevel.requiredExp}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: accountLevel.progress,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.purple.shade400,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// 재화 표시
  Widget _buildCurrencyDisplay(IconData icon, int amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            _formatNumber(amount),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 숫자 포맷팅 (1000 → 1K)
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
