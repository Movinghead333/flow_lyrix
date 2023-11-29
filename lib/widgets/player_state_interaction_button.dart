import 'package:christian_lyrics/christian_lyrics.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../providers/song_provider.dart';

class PlayerStateInteractionButton extends StatelessWidget {
  const PlayerStateInteractionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SongProvider songProvider = Provider.of<SongProvider>(context);
    AudioPlayer player = songProvider.player;
    ChristianLyrics christianLyrics = songProvider.christianLyrics;

    const double iconSize = 40;

    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            width: iconSize,
            height: iconSize,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return IconButton(
            icon: const Icon(Icons.play_arrow),
            iconSize: iconSize,
            onPressed: () {
              christianLyrics.resetLyric();
              player.play();
            },
            color: Theme.of(context).colorScheme.onBackground,
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: const Icon(Icons.pause),
            iconSize: iconSize,
            onPressed: player.pause,
            color: Theme.of(context).colorScheme.onBackground,
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.replay),
            iconSize: iconSize,
            onPressed: () => player.seek(Duration.zero),
            color: Theme.of(context).colorScheme.onBackground,
          );
        }
      },
    );
  }
}
