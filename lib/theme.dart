import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: ThemeData.dark().colorScheme.copyWith(
        primary: Colors.orange.shade700,
        // This sets the color of switches to orange
        secondary: Colors.orange,
        onBackground: Colors.orange,
      ),
  elevatedButtonTheme: ThemeData.dark().elevatedButtonTheme,
);
