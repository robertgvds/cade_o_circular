import 'package:flutter/material.dart';

// Cores do degradê
const Color redOrange = Color(0xFFFF4500); // vermelho alaranjado
const Color brightRed = Color(0xFFFF0000); // vermelho puro
const Color orangeRed = Color(0xFFFF6347); // vermelho tomate (laranja avermelhado)

final Gradient mainGradient = LinearGradient(
  colors: [redOrange, brightRed, orangeRed],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: brightRed,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: brightRed,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  colorScheme: ColorScheme.light(
    primary: brightRed,
    secondary: orangeRed,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: redOrange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);

// Tema escuro
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: orangeRed,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: orangeRed,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  colorScheme: ColorScheme.dark(
    primary: orangeRed,
    secondary: redOrange,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: brightRed,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);
