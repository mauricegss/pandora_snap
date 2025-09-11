import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/repositories/dog_repository.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/screens/auth_screen.dart';
import 'package:pandora_snap/ui/screens/day_details_screen.dart';
import 'package:pandora_snap/ui/screens/dog_details_screen.dart';
import 'package:pandora_snap/ui/screens/fullscreen_image_screen.dart';
import 'package:pandora_snap/ui/screens/home_screen.dart';
import 'package:pandora_snap/ui/screens/welcome_screen.dart';

enum AppRoutes {
  welcome,
  auth,
  home,
  dogDetails,
  dayDetails,
  fullscreenImage,
}

class AppRouter {
  static final UserRepository _userRepository = UserRepository();
  static final DogRepository _dogRepository = DogRepository();
  static final PhotoRepository _photoRepository = PhotoRepository();
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
        builder: (context, state) {
          return AuthScreen(userRepository: _userRepository);
        },
      ),
      GoRoute(
        path: '/home',
        name: AppRoutes.home.name,
        builder: (context, state) {
          return HomeScreen(
            dogRepository: _dogRepository,
            photoRepository: _photoRepository,
          );
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
    // Opcional: Adiciona uma tela de erro para rotas não encontradas
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Página não encontrada')),
      body: Center(
        child: Text('A rota ${state.uri} não foi encontrada.'),
      ),
    ),
  );
}