import 'package:flow_lyrix/show_lyrics_screen.dart';
import 'package:flow_lyrix/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
    return Provider<SongProvider>(
      create: (context) => SongProvider(),
      child: const MaterialApp(
        home: ShowLyricsScreen(),
      ),
    );
  }
}
