import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/ui/screens/auth/auth_screen.dart';
import 'package:pandora_snap/ui/screens/details/day_details_screen.dart';
import 'package:pandora_snap/ui/screens/details/dog_details_screen.dart';
import 'package:pandora_snap/ui/screens/details/fullscreen_image_screen.dart';
import 'package:pandora_snap/ui/screens/home/home_screen.dart';
import 'package:pandora_snap/ui/screens/auth/welcome_screen.dart';

enum AppRoutes {
  welcome,
  auth,
  home,
  dogDetails,
  dayDetails,
  fullscreenImage,
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.welcome.name,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: AppRoutes.auth.name,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoutes.home.name,
        builder: (context, state) {
          return const HomeScreen();
        },
        routes: [
          GoRoute(
            path: 'dog-details',
            name: AppRoutes.dogDetails.name,
            builder: (context, state) {
              final dog = state.extra as Dog;
              return DogDetailsScreen(dog: dog);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/day-details',
        name: AppRoutes.dayDetails.name,
        builder: (context, state) {
          final date = state.extra as DateTime;
          return DayDetailsScreen(date: date);
        },
      ),
      GoRoute(
        path: '/fullscreen-image',
        name: AppRoutes.fullscreenImage.name,
        builder: (context, state) {
          final imageUrl = state.extra as String;
          return FullscreenImageScreen(imageUrl: imageUrl);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Página não encontrada')),
      body: Center(
        child: Text('A rota ${state.uri} não foi encontrada.'),
      ),
    ),
  );
}