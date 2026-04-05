import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_mob/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend_mob/features/goals/presentation/screens/goals_screen.dart';
import 'package:frontend_mob/features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import 'package:frontend_mob/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:frontend_mob/shared/widgets/main_shell.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../network/auth_event_bus.dart';

@singleton
class AppRouter {
  final FlutterSecureStorage _storage;
  late final GoRouter router;
  StreamSubscription? _authSubscription;

  AppRouter(this._storage) {
    router = GoRouter(
      initialLocation: '/splash',
      redirect: _guard,
      refreshListenable: _AuthListenable(),
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (ctx, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/auth/login',
          name: 'login',
          builder: (ctx, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/auth/register',
          name: 'register',
          builder: (ctx, state) => const RegisterScreen(),
        ),
        ShellRoute(
          builder: (ctx, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (ctx, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/transactions',
              name: 'transactions',
              builder: (ctx, state) => const TransactionListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'add-transaction',
                  builder: (ctx, state) => const AddEditTransactionScreen(),
                ),
                GoRoute(
                  path: ':id/edit',
                  name: 'edit-transaction',
                  builder: (ctx, state) {
                    final id = state.pathParameters['id']!;
                    return AddEditTransactionScreen(transactionId: id);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/goals',
              name: 'goals',
              builder: (ctx, state) => const GoalsScreen(),
            ),
          ],
        ),
      ],
    );

    _listenToAuthEvents();
  }

  void _listenToAuthEvents() {
    _authSubscription = AuthEventBus.instance.stream.listen((event) {
      if (event == AuthEvent.sessionExpired || event == AuthEvent.loggedOut) {
        router.go('/auth/login');
      }
    });
  }

  Future<String?> _guard(BuildContext ctx, GoRouterState state) async {
    final onSplash = state.matchedLocation == '/splash';
    if (onSplash) return null;

    final token = await _storage.read(key: 'access_token');
    final onAuth = state.matchedLocation.startsWith('/auth');

    if (token == null && !onAuth) return '/auth/login';
    if (token != null && onAuth) return '/home';
    return null;
  }

  void dispose() {
    _authSubscription?.cancel();
  }
}

class _AuthListenable extends ChangeNotifier {
  late final StreamSubscription _sub;

  _AuthListenable() {
    _sub = AuthEventBus.instance.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
