import 'package:flow_lyrix/screens/app_settings_screen.dart';
import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.settings,
        color: Theme.of(context).colorScheme.onBackground,
      ),
      tooltip: 'Settings',
      onPressed: () {
        Navigator.pushNamed(context, AppSettingsScreen.routeName);
      },
    );
  }
}
