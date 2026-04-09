import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_screen.dart';
import 'providers/map_provider.dart';
import 'providers/location_provider.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_provider.dart';
import 'data/repositories/mock_bus_repository.dart';

void main() {
  final repository = MockBusRepository(); // Injeta o repo

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider(repository)), // Mudou aqui
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cadê o Circular?',
          themeMode: themeProvider.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: const HomeScreen(),
        );
      },
    );
  }
}