import 'dart:async';

import 'package:flow_lyrix/models/app_settings.dart';
import 'package:flow_lyrix/providers/app_settings_provider.dart';
import 'package:flow_lyrix/widgets/christian_lyrics_widgets.dart';
import 'package:flow_lyrix/screens/app_settings_screen.dart';
import 'package:flow_lyrix/providers/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShowLyricsScreen extends StatefulWidget {
  const ShowLyricsScreen({Key? key}) : super(key: key);
  static const String routeName = '/show_lyrics';

  @override
  State<ShowLyricsScreen> createState() => _ShowLyricsScreenState();
}

class _ShowLyricsScreenState extends State<ShowLyricsScreen>
    with WidgetsBindingObserver {
  late SongProvider _songProvider;
  late AppSettingsProvider _appSettingsProvider;

  StreamSubscription<String>? intentSubscription;
  String text = 'Initial text';
  List<String> lines = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _songProvider = Provider.of<SongProvider>(context);
    _appSettingsProvider = Provider.of<AppSettingsProvider>(context);

    // Set mp3Filepath when the app is launch from closed state via an intent
    ReceiveSharingIntent.getInitialText().then((String? filepath) {
      _songProvider.mp3Filepath = filepath;
    });

    // Set mp3Filepath when the app is launch from opened state via an intent
    intentSubscription =
        ReceiveSharingIntent.getTextStream().listen((String filepath) {
      _songProvider.mp3Filepath = filepath;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    intentSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _songProvider.player.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Lyrix'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, AppSettingsScreen.routeName);
            },
          )
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<AppSettings>(
            stream: _appSettingsProvider.appSettingsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading app settings data'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              AppSettings appSettings = _appSettingsProvider.appSettings;

              return StreamBuilder<String?>(
                  stream: _songProvider.lyricsStream,
                  builder: (context, snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            color: appSettings.backgroundColor,
                            child: StreamBuilder<PlayerState>(
                              stream: _songProvider.player.playerStateStream,
                              builder: (context, snapshot) {
                                final playerState = snapshot.data;
                                final playing = playerState?.playing ?? false;
                                return _songProvider.christianLyrics.getLyric(
                                    context,
                                    isPlaying: playing,
                                    textColor: appSettings.textColor,
                                    fontSize: appSettings.fontSize);
                              },
                            ),
                          ),
                        ),

                        // Display play/pause button and volume/speed sliders.
                        ControlButtons(_songProvider.player,
                            _songProvider.christianLyrics),
                        // Display seek bar. Using StreamBuilder, this widget rebuilds
                        // each time the position, buffered position or duration changes.
                        StreamBuilder<PositionData>(
                            stream: _songProvider.positionDataStream,
                            builder: (context, snapshot) {
                              final positionData = snapshot.data;

                              if (positionData != null) {
                                _songProvider.christianLyrics
                                    .setPositionWithOffset(
                                        position: positionData
                                            .position.inMilliseconds,
                                        duration: positionData
                                            .duration.inMilliseconds);
                              }

                              return SeekBar(
                                duration:
                                    positionData?.duration ?? Duration.zero,
                                position:
                                    positionData?.position ?? Duration.zero,
                                bufferedPosition:
                                    positionData?.bufferedPosition ??
                                        Duration.zero,
                                onChangeEnd: (Duration d) {
                                  _songProvider.christianLyrics.resetLyric();
                                  _songProvider.christianLyrics
                                      .setPositionWithOffset(
                                          position: d.inMilliseconds,
                                          duration: positionData!
                                              .duration.inMilliseconds);
                                  _songProvider.player.seek(d);
                                },
                              );
                            }),
                      ],
                    );
                  });
            }),
      ),
    );
  }
}
