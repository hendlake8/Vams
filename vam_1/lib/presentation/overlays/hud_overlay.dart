import 'package:flutter/material.dart';

import '../../core/constants/design_constants.dart';
import '../../core/utils/screen_utils.dart';
import '../../game/vam_game.dart';

/// 게임 HUD 오버레이
class HudOverlay extends StatelessWidget {
  final VamGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: ScreenUtils.uiPadding,
        child: Column(
          children: [
            // 상단 HUD
            _buildTopHud(),

            const Spacer(),

            // 하단 HUD
            _buildBottomHud(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHud() {
    return Row(
      children: [
        // 일시정지 버튼
        IconButton(
          icon: const Icon(Icons.pause, color: Colors.white, size: 32),
          onPressed: () {
            game.PauseGame();
            game.overlays.add('Pause');
          },
        ),

        const Spacer(),

        // 경과 시간
        _TimerDisplay(game: game),

        const SizedBox(width: 16),

        // 킬 카운트
        _KillDisplay(game: game),
      ],
    );
  }

  Widget _buildBottomHud() {
    return Column(
      children: [
        // HP 바
        _HpBar(game: game),

        const SizedBox(height: 8),

        // EXP 바
        _ExpBar(game: game),

        const SizedBox(height: 8),

        // 레벨 표시
        _LevelDisplay(game: game),

        // 조이스틱 영역 확보
        SizedBox(height: ScreenUtils.h(180)),
      ],
    );
  }
}

class _TimerDisplay extends StatefulWidget {
  final VamGame game;

  const _TimerDisplay({required this.game});

  @override
  State<_TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<_TimerDisplay> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {});
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.game.formattedTime,
        style: const TextStyle(
          color: Colors.white,
          fontSize: DesignConstants.FONT_SIZE_LARGE,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _KillDisplay extends StatefulWidget {
  final VamGame game;

  const _KillDisplay({required this.game});

  @override
  State<_KillDisplay> createState() => _KillDisplayState();
}

class _KillDisplayState extends State<_KillDisplay> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {});
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.dangerous, color: Colors.red, size: 18),
          const SizedBox(width: 4),
          Text(
            '${widget.game.mKillCount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: DesignConstants.FONT_SIZE_MEDIUM,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HpBar extends StatefulWidget {
  final VamGame game;

  const _HpBar({required this.game});

  @override
  State<_HpBar> createState() => _HpBarState();
}

class _HpBarState extends State<_HpBar> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {});
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.game.player;
    final hpPercent = player.hpPercent;

    Color barColor;
    if (hpPercent > 0.6) {
      barColor = DesignConstants.COLOR_HP_HIGH;
    } else if (hpPercent > 0.3) {
      barColor = DesignConstants.COLOR_HP_MEDIUM;
    } else {
      barColor = DesignConstants.COLOR_HP_LOW;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HP: ${player.mCurrentHp}/${player.mMaxHp}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: DesignConstants.FONT_SIZE_SMALL,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: hpPercent,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpBar extends StatefulWidget {
  final VamGame game;

  const _ExpBar({required this.game});

  @override
  State<_ExpBar> createState() => _ExpBarState();
}

class _ExpBarState extends State<_ExpBar> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {});
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.game.player;

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: player.expPercent,
          backgroundColor: Colors.transparent,
          valueColor: const AlwaysStoppedAnimation<Color>(
            DesignConstants.COLOR_EXP,
          ),
          minHeight: 8,
        ),
      ),
    );
  }
}

class _LevelDisplay extends StatefulWidget {
  final VamGame game;

  const _LevelDisplay({required this.game});

  @override
  State<_LevelDisplay> createState() => _LevelDisplayState();
}

class _LevelDisplayState extends State<_LevelDisplay> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {});
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'LV. ${widget.game.player.mLevel}',
      style: const TextStyle(
        color: Colors.yellow,
        fontSize: DesignConstants.FONT_SIZE_MEDIUM,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
