import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/design_constants.dart';
import 'core/utils/screen_utils.dart';
import 'presentation/screens/main_lobby_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 세로 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 풀스크린 몰입 모드
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const VamApp());
}

class VamApp extends StatelessWidget {
  const VamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '뱀서라이크 슈팅',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: DesignConstants.COLOR_PRIMARY,
        scaffoldBackgroundColor: DesignConstants.COLOR_BACKGROUND,
        colorScheme: const ColorScheme.dark(
          primary: DesignConstants.COLOR_PRIMARY,
          secondary: DesignConstants.COLOR_SECONDARY,
          surface: DesignConstants.COLOR_SURFACE,
          error: DesignConstants.COLOR_ERROR,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const InitializerScreen(),
    );
  }
}

/// 초기화 화면 (ScreenUtils 초기화용)
class InitializerScreen extends StatefulWidget {
  const InitializerScreen({super.key});

  @override
  State<InitializerScreen> createState() => _InitializerScreenState();
}

class _InitializerScreenState extends State<InitializerScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      // 화면 유틸리티 초기화
      ScreenUtils.init(context);
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const MainLobbyScreen();
  }
}
