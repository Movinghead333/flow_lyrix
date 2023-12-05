## 0.11.0

- Added error handling in case a mp3 file is opened which does not contain SYLT lyrics data.

## 0.10.0

- Added switch to turn of lyrics line animation in the settings screen.
- Made settings screen a SingleChildScrollView so large fonts will not cause the screen to overflow and thus cause an error.

## 0.9.0

- Factored out widgets into separate files.
- Added theme to the app and started customizing the colors via theme.
- Moved the control buttons into the app bar.
- Moved the timeline slider to the top.
- Added default text when no song has been loaded yet.
- Removed speed control button from control buttons.

## 0.8.0

- Split text color into default and hightlight text color, which can be edited in the app settings.

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