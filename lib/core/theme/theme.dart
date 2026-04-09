import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';

// --- CONFIGURAÇÕES GERAIS DE DESIGN (BORDAS E ESPAÇAMENTOS) ---
const double kAppCornerRadius = 35.0; // Fica bem arredondado
const double kSmoothness = 1; // Controle exato do Squircle (0.0 a 1.0)

const double kRadiusMedium = 16.0;
const double kRadiusSmall = 12.0;
const double kRadiusPill = 30.0;

// Formato padrão "Squircle Customizado" reutilizável
final ShapeBorder kAppShape = SmoothRectangleBorder(
  borderRadius: SmoothBorderRadius(
    cornerRadius: kAppCornerRadius,
    cornerSmoothing: kSmoothness,
  ),
);

// Formato com Squircle variado (apenas topo, para BottomSheets)
final ShapeBorder kAppShapeTop = SmoothRectangleBorder(
  borderRadius: SmoothBorderRadius.only(
    topLeft: SmoothRadius(
      cornerRadius: kAppCornerRadius,
      cornerSmoothing: kSmoothness,
    ),
    topRight: SmoothRadius(
      cornerRadius: kAppCornerRadius,
      cornerSmoothing: kSmoothness,
    ),
  ),
);

// --- CORES ---
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
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 15,
    offset: const Offset(0, 0),
  ),
];

// --- TEMAS (LIGHT / DARK) ---
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: primaryRed,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryRed,
    primary: primaryRed,
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
