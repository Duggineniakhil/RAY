import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/features/auth/presentation/screens/login_screen.dart';
import 'package:reelify/features/auth/presentation/screens/signup_screen.dart';
import 'package:reelify/features/auth/presentation/screens/splash_screen.dart';
import 'package:reelify/features/comments/presentation/screens/comments_screen.dart';
import 'package:reelify/features/profile/presentation/screens/profile_screen.dart';
import 'package:reelify/features/qr_scanner/qr_scanner_screen.dart';
import 'package:reelify/features/upload_video/presentation/screens/upload_screen.dart';
import 'package:reelify/features/video_feed/presentation/screens/home_screen.dart';
import 'package:reelify/features/settings/settings_screen.dart';
import 'package:reelify/features/settings/terms_of_service_screen.dart';
import 'package:reelify/features/settings/privacy_policy_screen.dart';
import 'package:reelify/features/explore/presentation/screens/explore_screen.dart';
import 'package:reelify/features/messaging/presentation/screens/messaging_screen.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/features/video_feed/presentation/screens/single_video_screen.dart';
import 'package:riverpod/riverpod.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/splash';

      if (authState.isLoading) return null;

      if (!isAuthenticated && !isOnAuthPage) return '/login';
      if (isAuthenticated && isOnAuthPage && state.matchedLocation != '/splash') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'signup',
            name: 'signup',
            builder: (context, state) => const SignupScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'upload',
            name: 'upload',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const UploadScreen(),
              transitionsBuilder: _slideUpTransition,
            ),
          ),
          GoRoute(
            path: 'comments/:videoId',
            name: 'comments',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: CommentsScreen(
                  videoId: state.pathParameters['videoId']!),
              transitionsBuilder: _slideUpTransition,
            ),
          ),
          GoRoute(
            path: 'profile/:userId',
            name: 'profile',
            builder: (context, state) => ProfileScreen(
              userId: state.pathParameters['userId']!,
            ),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'terms',
                name: 'terms',
                builder: (context, state) => const TermsOfServiceScreen(),
              ),
              GoRoute(
                path: 'privacy',
                name: 'privacy',
                builder: (context, state) => const PrivacyPolicyScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'qr-scanner',
            name: 'qr-scanner',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const QrScannerScreen(),
              transitionsBuilder: _slideUpTransition,
            ),
          ),
          GoRoute(
            path: 'explore',
            name: 'explore',
            builder: (context, state) {
              final query = state.uri.queryParameters['query'];
              return ExploreScreen(initialQuery: query);
            },
          ),
          GoRoute(
            path: 'messaging',
            name: 'messaging',
            builder: (context, state) => const MessagingScreen(),
            routes: [
              GoRoute(
                path: 'chat/:convId',
                name: 'chat',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>? ?? {};
                  return ChatScreen(
                    conversationId: state.pathParameters['convId']!,
                    otherUserId: extra['otherUserId'] as String? ?? '',
                    otherName: extra['otherName'] as String? ?? 'User',
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'video',
            name: 'video',
            builder: (context, state) {
              final video = state.extra as VideoModel;
              return SingleVideoScreen(video: video);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Text(
          'Page not found: ${state.error}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
});

Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}
