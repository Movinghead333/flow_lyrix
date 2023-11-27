## 0.7.0

- Corrected `AndroidManifest.xml` so only `.mp3`-files can be opened with the `Flow Lyrix` app.

## 0.6.0

- Songs are now automatically started when the app is opened from an intent.
- When a song finishes, the app automatically closes (into background).

## 0.5.0

- Added app settings where the user can set the fontSize for the lyrics text, the background color of the lyrics panel as well as the text color of the lyrics text itself.
- The updates live in case any settings change.
- The app settings are also persisted on disk.
- Added folder struture to better manage the `.dart` files since the codebase is growing.

## 0.4.0

- Changed text and background coloring

## 0.3.0

- Added Streambuilder so the lyrics updated on screen, when a new song is loaded.
- Updated `sylt_parser` package to version 0.1.1, resolving a bug in loading songs with empty line lyrics.