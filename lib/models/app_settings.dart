import 'dart:ui';

class AppSettings {
  double fontSize;
  Color backgroundColor;
  Color textColor;

  AppSettings({
    this.fontSize = 24,
    this.backgroundColor = const Color.fromARGB(255, 23, 22, 50),
    this.textColor = const Color.fromARGB(255, 255, 222, 59),
  });

  AppSettings copyWith({
    double? fontSize,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return AppSettings(
      fontSize: fontSize ?? this.fontSize,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
    );
  }

  /// Json serialisation
  AppSettings.fromJson(Map<String, dynamic> json)
      : fontSize = json['fontSize'],
        backgroundColor = Color(json['backgroundColor']),
        textColor = Color(json['textColor']);

  /// Json deserialisation
  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'backgroundColor': backgroundColor.value,
      'textColor': textColor.value,
    };
  }
}
