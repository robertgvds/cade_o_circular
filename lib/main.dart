import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/bus_stops_data.dart';
import 'pages/home_screen.dart';
import 'providers/map_provider.dart';
import 'theme/theme.dart';
import 'theme/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => MapProvider(busStopsJsonData),
        ),
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