import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: ThemeData.dark().colorScheme.copyWith(
        primary: Colors.orange.shade700,
        onBackground: Colors.orange,
      ),
  elevatedButtonTheme: ThemeData.dark().elevatedButtonTheme,
);
