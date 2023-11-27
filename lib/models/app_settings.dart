import 'dart:ui';

class AppSettings {
  double fontSize;
  Color backgroundColor;
  Color textDefaultColor;
  Color textHighlightColor;

  AppSettings({
    this.fontSize = 24,
    this.backgroundColor = const Color.fromARGB(255, 23, 22, 50),
    this.textDefaultColor = const Color.fromARGB(255, 126, 126, 126),
    this.textHighlightColor = const Color.fromARGB(255, 255, 222, 59),
  });

  AppSettings copyWith({
    double? fontSize,
    Color? backgroundColor,
    Color? textDefaultColor,
    Color? textHighlightColor,
  }) {
    return AppSettings(
      fontSize: fontSize ?? this.fontSize,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textDefaultColor: textDefaultColor ?? this.textDefaultColor,
      textHighlightColor: textHighlightColor ?? this.textHighlightColor,
    );
  }

  /// Json serialisation
  AppSettings.fromJson(Map<String, dynamic> json)
      : fontSize = json['fontSize'],
        backgroundColor = Color(json['backgroundColor']),
        textDefaultColor = Color(json['textDefaultColor']),
        textHighlightColor = Color(json['textHighlightColor']);

  /// Json deserialisation
  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'backgroundColor': backgroundColor.value,
      'textDefaultColor': textDefaultColor.value,
      'textHighlightColor': textHighlightColor.value,
    };
  }
}
