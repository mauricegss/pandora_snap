import 'package:flutter/material.dart';
import 'ui/screens/welcome_screen.dart';

class App extends StatelessWidget{
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      
      home: WelcomeScreen(),  
    );
  }
}