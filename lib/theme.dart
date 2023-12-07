import 'package:flutter/material.dart';

const TextStyle appBarSmallTextStyle = TextStyle(fontSize: 16);
const TextStyle largeTextStyle = TextStyle(fontSize: 24);
const TextStyle mediumTextStyle = TextStyle(fontSize: 20);
const TextStyle creditsTextStyle = TextStyle(fontSize: 12, color: Colors.grey);

ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: ThemeData.dark().colorScheme.copyWith(
        primary: Colors.orange.shade700,
        // This sets the color of switches to orange
        secondary: Colors.orange,
        onBackground: Colors.orange,
      ),
  elevatedButtonTheme: ThemeData.dark().elevatedButtonTheme,
);
