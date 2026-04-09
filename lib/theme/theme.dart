import 'package:flutter/material.dart';

// --- CONFIGURAÇÕES GERAIS DE DESIGN ---
// Edite aqui para mudar todas as bordas do app de uma vez!
const double kAppCornerRadius = 35.0; 

// Formato padrão "Squircle" (estilo Apple/OneUI) reutilizável
const ShapeBorder kAppShape = ContinuousRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(kAppCornerRadius * 2)), 
  // Multiplicamos por 2 pq o ContinuousRectangleBorder visualmente parece menor
);

// Cores
const Color primaryRed = Color(0xFFD50000); // Vermelho FORTE (Vibrante)
const Color primaryOrange = Color(0xFFFF3D00);
const Color darkSurface = Color(0xFF1C1C1E); 
const Color lightSurface = Color(0xFFF2F2F7); 

final Gradient mainGradient = LinearGradient(
  colors: [primaryRed, Color(0xFFFF1744)], // Gradiente bem vivo
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Sombra padrão
List<BoxShadow> get appShadows => [
  BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 15,
    offset: const Offset(0, 8),
    spreadRadius: 0,
  ),
];

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: primaryRed, // Força o vermelho principal
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryRed,
    primary: primaryRed, // Garante que componentes usem o vermelho forte
    brightness: Brightness.light,
    surface: lightSurface,
    surfaceContainer: Colors.white,
  ),
  scaffoldBackgroundColor: lightSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.black,
    elevation: 0,
    centerTitle: true,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: primaryRed,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryRed,
    primary: primaryRed,
    brightness: Brightness.dark,
    surface: Colors.black,
    surfaceContainer: darkSurface,
  ),
  scaffoldBackgroundColor: Colors.black, 
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
);