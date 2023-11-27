import 'package:flow_lyrix/providers/app_settings_provider.dart';
import 'package:flow_lyrix/screens/app_settings_screen.dart';
import 'package:flow_lyrix/screens/show_lyrics_screen.dart';
import 'package:flow_lyrix/providers/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

void main() async {
  await GetStorage.init();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SongProvider>(create: (_) => SongProvider()),
        Provider<AppSettingsProvider>(create: (_) => AppSettingsProvider()),
      ],
      child: MaterialApp(
        initialRoute: ShowLyricsScreen.routeName,
        routes: {
          ShowLyricsScreen.routeName: (context) => const ShowLyricsScreen(),
          AppSettingsScreen.routeName: (context) => const AppSettingsScreen(),
        },
      ),
    );
  }
}
