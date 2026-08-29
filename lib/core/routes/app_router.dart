import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/main_layout/main_layout_screen.dart';
import '../../features/places/place_detail_screen.dart';
import '../../features/beaches/beaches_screen.dart';
import '../../features/mountains/mountains_screen.dart';
import '../../features/historical/historical_screen.dart';
import '../../features/restaurants/restaurants_screen.dart';
import '../../features/hotels/hotels_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/about/about_screen.dart';
import '../../features/emergency/emergency_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayoutScreen(initialIndex: 0),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const MainLayoutScreen(initialIndex: 1),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const MainLayoutScreen(initialIndex: 2),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainLayoutScreen(initialIndex: 3),
      ),
      GoRoute(
        path: '/place/:id',
        builder: (context, state) {
          final placeId = state.pathParameters['id'] ?? '';
          return PlaceDetailScreen(placeId: placeId);
        },
      ),
      GoRoute(
        path: '/beaches',
        builder: (context, state) => const BeachesScreen(),
      ),
      GoRoute(
        path: '/mountains',
        builder: (context, state) => const MountainsScreen(),
      ),
      GoRoute(
        path: '/historical',
        builder: (context, state) => const HistoricalScreen(),
      ),
      GoRoute(
        path: '/restaurants',
        builder: (context, state) => const RestaurantsScreen(),
      ),
      GoRoute(
        path: '/hotels',
        builder: (context, state) => const HotelsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyScreen(),
      ),
    ],
  );
}
