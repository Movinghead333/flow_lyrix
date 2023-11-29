import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../providers/song_provider.dart';
import 'show_slider_dialog.dart';

class SpeedControlButton extends StatefulWidget {
  const SpeedControlButton({Key? key}) : super(key: key);

  @override
  State<SpeedControlButton> createState() => _SpeedControlButtonState();
}

class _SpeedControlButtonState extends State<SpeedControlButton> {
  @override
  Widget build(BuildContext context) {
    SongProvider songProvider = Provider.of<SongProvider>(context);
    AudioPlayer player = songProvider.player;

    return StreamBuilder<double>(
      stream: player.speedStream,
      builder: (context, snapshot) => IconButton(
        color: Theme.of(context).colorScheme.onBackground,
        icon: Text(
          "${snapshot.data?.toStringAsFixed(1)}x",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          showSliderDialog(
            context: context,
            title: "Adjust speed",
            divisions: 10,
            min: 0.5,
            max: 1.5,
            value: player.speed,
            stream: player.speedStream,
            onChanged: player.setSpeed,
          );
        },
      ),
    );
  }
}
