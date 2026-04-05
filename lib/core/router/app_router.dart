import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../network/auth_event_bus.dart';

@singleton
class AppRouter {
  final FlutterSecureStorage _storage;
  late final GoRouter router;
  StreamSubscription? _authSubscription;

  AppRouter(this._storage) {
    router = GoRouter(
      initialLocation: '/home',
      redirect: _guard,
      refreshListenable: _AuthListenable(),
      routes: [
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
