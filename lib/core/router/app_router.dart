import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/auth_provider.dart';
import '../../features/auth/screens/auth_landing_screen.dart';
import '../../features/auth/screens/auth_email_screen.dart';
import '../../features/auth/screens/auth_pin_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/create_trek/screens/create_trek_screen.dart';
import '../../features/trek_detail/screens/trek_detail_screen.dart';
import '../../features/stop_detail/screens/stop_detail_screen.dart';
import '../../features/add_stop/screens/add_stop_screen.dart';
import '../../features/trek_path/screens/trek_path_screen.dart';
import '../../features/summary/screens/summary_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RouterNotifier — bridges Riverpod auth state to GoRouter's refreshListenable.
// When authProvider OR sessionGuestProvider changes, GoRouter re-evaluates.
// ─────────────────────────────────────────────────────────────────────────────
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
    ref.listen<bool>(sessionGuestProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: ref.read(authProvider).isLoggedIn ? '/' : '/auth',
    refreshListenable: notifier,

    // Redirect: gate every non-auth route behind login.
    // sessionGuestProvider is session-only and not persisted to disk.
    redirect: (context, state) {
      final loggedIn = ref.read(authProvider).isLoggedIn || ref.read(sessionGuestProvider);
      final atAuth   = state.matchedLocation.startsWith('/auth');
      if (!loggedIn && !atAuth) return '/auth';
      if (loggedIn  &&  atAuth) return '/';
      return null;
    },

    routes: [
      // ── Auth flow ──────────────────────────────────────────────────────────
      GoRoute(path: '/auth',       builder: (_, __) => const AuthLandingScreen()),
      GoRoute(path: '/auth/email', builder: (_, __) => const AuthEmailScreen()),
      GoRoute(path: '/auth/pin',   builder: (_, __) => const AuthPinScreen()),

      // ── Main app ───────────────────────────────────────────────────────────
      GoRoute(path: '/',           builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/create',     builder: (_, __) => const CreateTrekScreen()),
      GoRoute(path: '/settings',   builder: (_, __) => const SettingsScreen()),
      GoRoute(
        path: '/trek/:id',
        builder: (_, state) => TrekDetailScreen(
          trekId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/trek/:id/stop/:dayNum/:stopId',
        builder: (_, state) => StopDetailScreen(
          trekId: state.pathParameters['id']!,
          dayNum: int.parse(state.pathParameters['dayNum']!),
          stopId: state.pathParameters['stopId']!,
        ),
      ),
      GoRoute(
        path: '/trek/:id/add-stop/:dayNum',
        builder: (_, state) => AddStopScreen(
          trekId: state.pathParameters['id']!,
          dayNum: int.parse(state.pathParameters['dayNum']!),
        ),
      ),
      GoRoute(
        path: '/trek/:id/path',
        builder: (_, state) => TrekPathScreen(
          trekId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/trek/:id/summary',
        builder: (_, state) => SummaryScreen(
          trekId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
