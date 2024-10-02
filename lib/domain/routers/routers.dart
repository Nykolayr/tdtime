import 'package:get/get.dart';
import 'package:tdtime/common/function.dart';
import 'package:tdtime/domain/repository/user_repository.dart';
import 'package:tdtime/presentation/screens/auth/auth_page.dart';
import 'package:tdtime/presentation/screens/main/main_page.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tdtime/presentation/screens/splash/splash.dart';

/// роутер приложения
final GoRouter router = GoRouter(
  // observers: [GoNavigatorObserver()],
  debugLogDiagnostics: true,
  initialLocation: Get.find<UserRepository>().isReg ? '/main' : '/splash',

  routes: <GoRoute>[
    GoRoute(
      name: 'Заставка',
      path: '/splash',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.fade,
        context: context,
        state: state,
        child: const SplashPage(),
      ),
    ),
    GoRoute(
      name: 'авторизация',
      path: '/auth',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.fade,
        context: context,
        state: state,
        child: const AuthPage(),
      ),
      routes: const [],
    ),
    GoRoute(
      name: 'Общая',
      path: '/main',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
        type: PageTransitionType.fade,
        context: context,
        state: state,
        child: const MainPage(),
      ),
      routes: const [],
    ),
  ],
);
