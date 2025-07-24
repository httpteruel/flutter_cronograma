import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_class_schedule/providers/schedule_provider.dart';
import 'package:my_class_schedule/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScheduleProvider(),
      child: MaterialApp(
        title: 'Meu Cronograma de Estudos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
          ),
          // --- CORRIGIR AQUI ---
          tabBarTheme: const TabBarThemeData( 
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),

        ),
        home: HomeScreen(),
      ),
    );
  }
}