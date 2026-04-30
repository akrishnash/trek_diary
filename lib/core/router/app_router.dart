import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/auth_provider.dart';
import '../../features/auth/screens/auth_landing_screen.dart';
import '../../features/auth/screens/auth_email_screen.dart';
import '../../features/auth/screens/auth_pin_screen.dart';
import '../../features/auth/screens/auth_phone_screen.dart';
import '../../features/auth/screens/auth_otp_screen.dart';
import '../../features/auth/screens/auth_profile_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/create_trek/screens/create_trek_screen.dart';
import '../../features/trek_detail/screens/trek_detail_screen.dart';
import '../../features/stop_detail/screens/stop_detail_screen.dart';
import '../../features/add_stop/screens/add_stop_screen.dart';
import '../../features/trek_path/screens/trek_path_screen.dart';
import '../../features/summary/screens/summary_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/edit_trek/screens/edit_trek_screen.dart';
import '../../features/diary/screens/diary_entry_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

// RouterNotifier — bridges Riverpod auth state to GoRouter's refreshListenable.
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

    redirect: (context, state) {
      final auth         = ref.read(authProvider);
      final sessionGuest = ref.read(sessionGuestProvider);
      final loggedIn     = auth.isLoggedIn || sessionGuest;
      final profileDone  = auth.profileComplete || sessionGuest;
      final atAuth       = state.matchedLocation.startsWith('/auth');
      final atProfile    = state.matchedLocation == '/auth/profile';

      if (!loggedIn && !atAuth) return '/auth';
      if (loggedIn && !profileDone && !atProfile) return '/auth/profile';
      if (loggedIn && profileDone && atAuth) return '/';
      return null;
    },

    routes: [
      // ── Auth flow ──────────────────────────────────────────────────────────
      GoRoute(path: '/auth',         builder: (_, __) => const AuthLandingScreen()),
      GoRoute(path: '/auth/email',   builder: (_, __) => const AuthEmailScreen()),
      GoRoute(path: '/auth/pin',     builder: (_, __) => const AuthPinScreen()),
      GoRoute(path: '/auth/phone',   builder: (_, __) => const AuthPhoneScreen()),
      GoRoute(path: '/auth/otp',     builder: (_, __) => const AuthOtpScreen()),
      GoRoute(path: '/auth/profile', builder: (_, __) => const AuthProfileScreen()),

      // ── Main app ───────────────────────────────────────────────────────────
      GoRoute(path: '/',           builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/create',     builder: (_, __) => const CreateTrekScreen()),
      GoRoute(path: '/settings',   builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/profile',    builder: (_, __) => const ProfileScreen()),
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
      GoRoute(
        path: '/trek/:id/edit',
        builder: (_, state) => EditTrekScreen(
          trekId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/trek/:id/diary/:dayNum',
        builder: (_, state) => DiaryEntryScreen(
          trekId: state.pathParameters['id']!,
          dayNum: int.parse(state.pathParameters['dayNum']!),
        ),
      ),
    ],
  );
});
