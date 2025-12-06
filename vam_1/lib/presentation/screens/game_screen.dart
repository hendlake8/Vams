import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../game/vam_game.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/pause_overlay.dart';
import '../overlays/skill_select_overlay.dart';
import '../overlays/game_over_overlay.dart';

/// 게임 화면
class GameScreen extends StatefulWidget {
  final String? characterId;

  const GameScreen({
    super.key,
    this.characterId,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late VamGame _game;

  @override
  void initState() {
    super.initState();
    _game = VamGame(characterId: widget.characterId);

    // 콜백 설정
    _game.onPauseRequested = _showPauseOverlay;
    _game.onLevelUp = _showSkillSelectOverlay;
    _game.onGameOver = _showGameOverOverlay;
    _game.onVictory = _showVictoryOverlay;
  }

  void _showPauseOverlay() {
    _game.overlays.add('Pause');
  }

  void _showSkillSelectOverlay() {
    _game.overlays.add('SkillSelect');
  }

  void _showGameOverOverlay() {
    _game.overlays.add('GameOver');
  }

  void _showVictoryOverlay() {
    _game.overlays.add('Victory');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'HUD': (context, game) => HudOverlay(game: game as VamGame),
          'Pause': (context, game) => PauseOverlay(game: game as VamGame),
          'SkillSelect': (context, game) => SkillSelectOverlay(game: game as VamGame),
          'GameOver': (context, game) => GameOverOverlay(
                game: game as VamGame,
                isVictory: false,
              ),
          'Victory': (context, game) => GameOverOverlay(
                game: game as VamGame,
                isVictory: true,
              ),
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}
