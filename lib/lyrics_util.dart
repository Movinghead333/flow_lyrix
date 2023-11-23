import 'package:flutter/material.dart';

class LyricsUtil {
  static int fromSyncEncoding(int i1, int i2, int i3, int i4) {
    return i1 << 21 | i2 << 14 | i3 << 7 | i4;
  }

  static int fourBytesToInt(int b1, int b2, int b3, int b4) {
    return b1 << 24 | b2 << 16 | b3 << 8 | b4;
  }

  static String lineDataToLrcString(List<int> lineData) {
    int l = lineData.length;
    int timeStampInMs = fourBytesToInt(
        lineData[l - 4], lineData[l - 3], lineData[l - 2], lineData[l - 1]);

    String text = '';
    for (int i = 0; i < l - 4; i++) {
      text += String.fromCharCode(lineData[i]);
    }

    int timeStampInSeconds = timeStampInMs ~/ 1000;
    int timeStampInMinutes = timeStampInSeconds ~/ 60;

    String milliSeconds = (timeStampInMs % 1000).toString().padLeft(3, '0');
    String seconds = (timeStampInSeconds % 60).toString().padLeft(2, '0');
    String minutes = (timeStampInMinutes % 60).toString().padLeft(2, '0');
    String formattedTimeStamp = '[$minutes:$seconds,$milliSeconds]';

    return '$formattedTimeStamp: $text';
  }

  /// Determine the byte offset where the sylt header starts
  static int findSyltFrameStartingOffset(List<int> mp3Bytes) {
    int s = 83; // S
    int y = 89; // Y
    int l = 76; // L
    int t = 84; // T

    int syltHeaderStartingOffset = -1;

    for (int i = 0; i < mp3Bytes.length - 3; i++) {
      if (mp3Bytes[i] == s &&
          mp3Bytes[i + 1] == y &&
          mp3Bytes[i + 2] == l &&
          mp3Bytes[i + 3] == t) {
        syltHeaderStartingOffset = i;
        break;
      }
    }

    return syltHeaderStartingOffset;
  }

  static List<String> getSYLTEditorLyricsFromMp3Bytes(List<int> mp3Bytes) {
    int headerLength =
        fromSyncEncoding(mp3Bytes[6], mp3Bytes[7], mp3Bytes[8], mp3Bytes[9]);
    debugPrint('Header length: $headerLength');

    int syltFrameStartingOffset = findSyltFrameStartingOffset(mp3Bytes);
    debugPrint('SYLT frame starting offset: $syltFrameStartingOffset');

    int cursor = syltFrameStartingOffset;
    cursor += 4; // Move to frame size offset
    int frameSize = fourBytesToInt(mp3Bytes[cursor], mp3Bytes[cursor + 1],
        mp3Bytes[cursor + 2], mp3Bytes[cursor + 3]);

    // Add 10 for the 10 bytes of frame header not accounted in the frameSize
    int frameEnd = syltFrameStartingOffset + 10 + frameSize;

    cursor += 4; // Skip frame size
    cursor += 2; // Skip frame header flags

    cursor += 1; // Skip text encoding
    cursor += 3; // Skip language code
    cursor += 1; // Skip time stamp format
    cursor += 1; // Skip content type

    // Skip all chars of the content descriptor string until we find the null
    // termination character
    String contentDescriptor = '';
    while (mp3Bytes[cursor] != 0) {
      contentDescriptor += String.fromCharCode(mp3Bytes[cursor]);
      cursor += 1;
    }
    debugPrint('Content descriptor: $contentDescriptor');

    cursor += 1; // Skip content descriptor string null termination character

    List<List<int>> linesData = [];
    List<int> currentLine = [];
    while (cursor != frameEnd) {
      if (mp3Bytes[cursor] == 10) {
        if (currentLine.isNotEmpty) {
          linesData.add(currentLine);
        }
        currentLine = [];
      } else {
        currentLine.add(mp3Bytes[cursor]);
      }
      cursor++;
    }
    linesData.add(currentLine);

    List<String> lyricsLines = [];
    for (List<int> lineData in linesData) {
      lyricsLines.add(lineDataToLrcString(lineData));
    }

    for (int i = 0; i < frameEnd; i++) {
      debugPrint(
          'C${i.toString().padLeft(3, ' ')}: (${String.fromCharCode(mp3Bytes[i])}) or ${mp3Bytes[i]}');
    }

    return lyricsLines;
  }

  static List<String> getMiniLyricsGeneratedLyricsFromMp3Bytes(
      List<int> mp3Bytes) {
    int headerLength =
        fromSyncEncoding(mp3Bytes[6], mp3Bytes[7], mp3Bytes[8], mp3Bytes[9]);
    //debugPrint('Header length: $headerLength');

    int syltFrameStartingOffset = findSyltFrameStartingOffset(mp3Bytes);
    debugPrint('SYLT frame starting offset: $syltFrameStartingOffset');

    int cursor = syltFrameStartingOffset;
    cursor += 4; // Move to frame size offset
    int frameSize = fourBytesToInt(mp3Bytes[cursor], mp3Bytes[cursor + 1],
        mp3Bytes[cursor + 2], mp3Bytes[cursor + 3]);

    // Add 10 for the 10 bytes of frame header not accounted in the frameSize
    int frameEnd = syltFrameStartingOffset + 10 + frameSize;

    //debugPrint('Num bytes: ${mp3Bytes.length}');

    // for (int i = syltFrameStartingOffset; i < frameEnd; i++) {
    //   debugPrint(mp3Bytes[i].toString());
    //   debugPrint(
    //       'C${i.toString().padLeft(3, ' ')}: (${String.fromCharCode(mp3Bytes[i])}) or ${mp3Bytes[i]}');
    // }

    cursor += 4; // Skip frame size
    cursor += 2; // Skip frame header flags

    cursor += 1; // Skip text encoding
    cursor += 3; // Skip language code
    cursor += 1; // Skip time stamp format
    cursor += 1; // Skip content type

    // Skip all chars of the content descriptor string until we find the null
    // termination character
    String contentDescriptor = '';
    while (mp3Bytes[cursor] != 0) {
      contentDescriptor += String.fromCharCode(mp3Bytes[cursor]);
      cursor += 1;
    }
    //debugPrint('Content descriptor: $contentDescriptor');

    cursor += 1; // Skip content descriptor string null termination character

    List<List<int>> linesData = [];
    List<int> currentLine = [];
    while (cursor < frameEnd) {
      if (mp3Bytes[cursor] == 0) {
        if (currentLine.isNotEmpty) {
          cursor++; // Skip lyrics line null termination character
          for (int i = 0; i < 4; i++) {
            currentLine.add(mp3Bytes[cursor]);
            cursor++;
          }
          linesData.add(currentLine);
          currentLine = [];
        }
      } else {
        currentLine.add(mp3Bytes[cursor]);
        cursor++;
      }
    }

    List<String> lyricsLines = [];
    for (List<int> lineData in linesData) {
      lyricsLines.add(lineDataToLrcString(lineData));
    }

    return lyricsLines;
  }

  /// Convert to format
  /// 1\r\n00:00:01,000 --> 00:00:29,950\r\nHere goes the lyrics\r\n\r\n...
  static String syltLyricsToSrtLyrics(List<String> syltLyrics) {
    int counter = 1;
    String lastTimestamp = '00:00:00,000';
    String lyrics = '';
    for (String line in syltLyrics) {
      String timeStamp = '00:${line.substring(1, 10)}';
      String text = line.substring(12, line.length);
      String newLine =
          '$counter\r\n$lastTimestamp --> $timeStamp\r\n$text\r\n\r\n';
      lyrics += newLine;

      lastTimestamp = timeStamp;
      counter++;
    }

    return lyrics;
  }
}
