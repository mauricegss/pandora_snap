import 'package:flutter/material.dart';
import 'package:pandora_snap/configs/routes.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget{
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserRepository()),
      ],
      child: MaterialApp.router(
        title: 'UTFPR Snap',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.amber,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}