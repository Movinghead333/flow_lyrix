import 'dart:async';

import 'package:flow_lyrix/christian_lyrics_widgets.dart';
import 'package:flow_lyrix/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShowLyricsScreen extends StatefulWidget {
  const ShowLyricsScreen();

  @override
  State<ShowLyricsScreen> createState() => _ShowLyricsScreenState();
}

class _ShowLyricsScreenState extends State<ShowLyricsScreen>
    with WidgetsBindingObserver {
  late SongProvider songProvider;

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

    songProvider = Provider.of<SongProvider>(context);

    // Set mp3Filepath when the app is launch from closed state via an intent
    ReceiveSharingIntent.getInitialText().then((String? filepath) {
      songProvider.mp3Filepath = filepath;
    });

    // Set mp3Filepath when the app is launch from opened state via an intent
    intentSubscription =
        ReceiveSharingIntent.getTextStream().listen((String filepath) {
      songProvider.mp3Filepath = filepath;
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
      songProvider.player.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Lyrix'),
      ),
      body: SafeArea(
        child: StreamBuilder<String?>(
            stream: songProvider.lyricsStream,
            builder: (context, snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Container(
                          color: Colors.brown,
                          child: StreamBuilder<PlayerState>(
                              stream: songProvider.player.playerStateStream,
                              builder: (context, snapshot) {
                                final playerState = snapshot.data;
                                final playing = playerState?.playing ?? false;
                                return songProvider.christianLyrics
                                    .getLyric(context, isPlaying: playing);
                              }))),

                  // Display play/pause button and volume/speed sliders.
                  ControlButtons(
                      songProvider.player, songProvider.christianLyrics),
                  // Display seek bar. Using StreamBuilder, this widget rebuilds
                  // each time the position, buffered position or duration changes.
                  StreamBuilder<PositionData>(
                      stream: songProvider.positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;

                        if (positionData != null) {
                          songProvider.christianLyrics.setPositionWithOffset(
                              position: positionData.position.inMilliseconds,
                              duration: positionData.duration.inMilliseconds);
                        }

                        return SeekBar(
                          duration: positionData?.duration ?? Duration.zero,
                          position: positionData?.position ?? Duration.zero,
                          bufferedPosition:
                              positionData?.bufferedPosition ?? Duration.zero,
                          onChangeEnd: (Duration d) {
                            songProvider.christianLyrics.resetLyric();
                            songProvider.christianLyrics.setPositionWithOffset(
                                position: d.inMilliseconds,
                                duration:
                                    positionData!.duration.inMilliseconds);
                            songProvider.player.seek(d);
                          },
                        );
                      }),
                ],
              );
            }),
      ),
    );
  }
}
