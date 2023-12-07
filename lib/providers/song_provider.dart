import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:christian_lyrics/christian_lyrics.dart';
import 'package:flow_lyrix/models/song_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sylt_parser/sylt_parser.dart';
import 'package:uri_to_file/uri_to_file.dart';

import '../models/position_data.dart';

class SongProvider {
  SongProvider() {
    player.playbackEventStream.listen((PlaybackEvent event) {
      if (event.processingState == ProcessingState.completed) {
        SystemNavigator.pop();
      }
    }, onError: (Object e, StackTrace stackTrace) {
      debugPrint('A stream error occurred: $e');
    });

    mp3FilepathStream.listen((newMp3Filepath) async {
      if (newMp3Filepath == null) {
        return;
      }

      try {
        await _loadSongIntoPlayer(mp3Filepath!);

        File file = await toFile(newMp3Filepath);

        Metadata metadata = await MetadataRetriever.fromFile(file);
        SongInfo newSongInfo = SongInfo(
            albumName: metadata.albumName ?? 'No album name found',
            songName: metadata.trackName ?? ' No song name found');
        songInfo = newSongInfo;
        print('Album: ${metadata.albumName}, Title: ${metadata.trackName}');

        List<int> mp3Bytes = file.readAsBytesSync();
        debugPrint('length: ${mp3Bytes.length}');

        SyltLyricsData syltLyricsData =
            SyltLyricsFromMp3Parser.parseMp3BytesToSyltLyricsData(mp3Bytes);

        String newLyrics = syltLyricsData.toSrt();

        christianLyrics.setLyricContent(newLyrics);

        lyrics = newLyrics;

        player.play();
      } on NoSyltFrameFoundException catch (_) {
        List<String> pathStrings = mp3Filepath!.split('/');
        _lyricsSubject.addError('Could not parse file ${pathStrings.last}');
      } on UnsupportedError catch (e) {
        debugPrint(e.message);
      } on IOException catch (e) {
        debugPrint(e.toString());
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  final BehaviorSubject<String?> _mp3FilepathSubject =
      BehaviorSubject<String?>();

  set mp3Filepath(String? newMp3Filepath) {
    _mp3FilepathSubject.add(newMp3Filepath);
  }

  String? get mp3Filepath => _mp3FilepathSubject.valueOrNull;

  Stream<String?> get mp3FilepathStream => _mp3FilepathSubject.stream;

  final BehaviorSubject<SongInfo> _songInfoSubject =
      BehaviorSubject<SongInfo>.seeded(
          SongInfo(albumName: '-- Album name --', songName: '-- Song name --'));

  set songInfo(SongInfo newSongInfo) {
    _songInfoSubject.add(newSongInfo);
  }

  SongInfo get songInfo => _songInfoSubject.value;

  Stream<SongInfo> get songInfoStream => _songInfoSubject.stream;

  final BehaviorSubject<String?> _lyricsSubject = BehaviorSubject<String?>();

  set lyrics(String? newlyrics) {
    _lyricsSubject.add(newlyrics);
  }

  String? get lyrics => _lyricsSubject.valueOrNull;

  Stream<String?> get lyricsStream => _lyricsSubject.stream;

  final AudioPlayer player = AudioPlayer();

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  final christianLyrics = ChristianLyrics();

  Future<Duration?> _loadSongIntoPlayer(String mp3Filepath) async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    return player.setAudioSource(AudioSource.uri(Uri.parse(mp3Filepath)));
  }
}
