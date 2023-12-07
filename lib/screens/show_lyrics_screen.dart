import 'dart:async';

import 'package:flow_lyrix/models/app_settings.dart';
import 'package:flow_lyrix/models/song_info.dart';
import 'package:flow_lyrix/providers/app_settings_provider.dart';
import 'package:flow_lyrix/providers/song_provider.dart';
import 'package:flow_lyrix/theme.dart';
import 'package:flow_lyrix/widgets/player_state_interaction_button.dart';
import 'package:flow_lyrix/widgets/volume_control_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../models/position_data.dart';
import '../widgets/seek_bar.dart';
import '../widgets/settings_button.dart';

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
  List<String> lines = [];

  Color appBarColor = Colors.grey.shade800;

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
        backgroundColor: appBarColor,
        title: StreamBuilder(
          stream: _songProvider.songInfoStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            SongInfo songInfo = _songProvider.songInfo;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(songInfo.albumName, style: appBarSmallTextStyle),
                Text(songInfo.songName, style: appBarSmallTextStyle),
              ],
            );
          },
        ),
        actions: const <Widget>[
          SettingsButton(),
          VolumeControlButton(),
          PlayerStateInteractionButton(),
        ],
      ),
      body: StreamBuilder<AppSettings>(
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
                  if (snapshot.hasError) {
                    String errorMessage = snapshot.error as String;
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          errorMessage,
                          style: largeTextStyle,
                        ),
                      ),
                    );
                  }

                  if (snapshot.data == null) {
                    return const Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          'No mp3 loaded yet.',
                          style: largeTextStyle,
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Display seek bar. Using StreamBuilder, this widget rebuilds
                      // each time the position, buffered position or duration changes.
                      StreamBuilder<PositionData>(
                        stream: _songProvider.positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;

                          if (positionData != null) {
                            _songProvider.christianLyrics.setPositionWithOffset(
                                position: positionData.position.inMilliseconds,
                                duration: positionData.duration.inMilliseconds);
                          }

                          return SeekBar(
                            duration: positionData?.duration ?? Duration.zero,
                            position: positionData?.position ?? Duration.zero,
                            bufferedPosition:
                                positionData?.bufferedPosition ?? Duration.zero,
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
                        },
                      ),
                      const SizedBox(height: 5),
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
                                textHighlightColor:
                                    appSettings.textHighlightColor,
                                textDefaultColor: appSettings.textDefaultColor,
                                fontSize: appSettings.fontSize,
                                animateLyricLines:
                                    appSettings.animateLyricsLines,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                });
          }),
    );
  }
}
