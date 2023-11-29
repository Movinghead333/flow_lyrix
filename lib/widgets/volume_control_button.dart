import 'package:flow_lyrix/providers/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import 'show_slider_dialog.dart';

/// This StreamBuilder rebuilds whenever the player state changes, which
/// includes the playing/paused state and also the
/// loading/buffering/ready state. Depending on the state we show the
/// appropriate button or loading indicator.
class VolumeControlButton extends StatelessWidget {
  const VolumeControlButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SongProvider songProvider = Provider.of<SongProvider>(context);
    AudioPlayer player = songProvider.player;

    return IconButton(
      icon: Icon(
        Icons.volume_up,
        color: Theme.of(context).colorScheme.onBackground,
      ),
      onPressed: () {
        showSliderDialog(
          context: context,
          title: "Adjust volume",
          divisions: 10,
          min: 0.0,
          max: 1.0,
          value: player.volume,
          stream: player.volumeStream,
          onChanged: player.setVolume,
        );
      },
    );
  }
}
