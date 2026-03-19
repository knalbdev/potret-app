import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../provider/auth_provider.dart';
import '../screen/auth/login_screen.dart';
import '../screen/auth/register_screen.dart';
import '../screen/map/location_picker_screen.dart';
import '../screen/splash_screen.dart';
import '../screen/story/add_story_screen.dart';
import '../screen/story/story_detail_screen.dart';
import '../screen/story/story_list_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      refreshListenable: authProvider,
      initialLocation: '/splash',
      redirect: (context, state) {
        final authState = authProvider.state;
        final loc = state.matchedLocation;

        // Show splash only during initial state (first session check)
        if (authState == AuthState.initial) {
          return loc == '/splash' ? null : '/splash';
        }

        // During loading (login/register actions), don't redirect —
        // let the screen's own loading indicator handle UX
        if (authState == AuthState.loading) {
          return null;
        }

        final isLoggedIn = authProvider.isLoggedIn;
        final isAuthPage = loc == '/login' || loc == '/register';

        if (!isLoggedIn && !isAuthPage) return '/login';
        if (isLoggedIn && (isAuthPage || loc == '/splash')) return '/stories';
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/stories',
          builder: (context, state) => const StoryListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddStoryScreen(),
              routes: [
                GoRoute(
                  path: 'location-picker',
                  builder: (context, state) {
                    final initial = state.extra as LatLng?;
                    return LocationPickerScreen(initialLocation: initial);
                  },
                ),
              ],
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return StoryDetailScreen(storyId: id);
              },
            ),
          ],
        ),
      ],
    );
  }
}
