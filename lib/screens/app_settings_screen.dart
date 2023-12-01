import 'package:flow_lyrix/models/app_settings.dart';
import 'package:flow_lyrix/providers/app_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);
  static const String routeName = '/app_settings';

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  /// Used within the color picker dialog
  Color _newBackgroundColor = Colors.black;

  /// Used within the color picker dialog
  Color _newTextDefaultColor = Colors.grey;

  /// Used within the color picker dialog
  Color _newTextHighlightColor = Colors.lightBlue;

  static const TextStyle uiTextStyle = TextStyle(fontSize: 24);

  late final AppSettingsProvider _appSettingsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _appSettingsProvider = Provider.of<AppSettingsProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Settings',
            style: uiTextStyle,
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onBackground,
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: StreamBuilder<AppSettings>(
              stream: _appSettingsProvider.appSettingsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading settings data.'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                AppSettings appSettings = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Animate lyric lines:', style: uiTextStyle),
                        Switch(
                          value: appSettings.animateLyricsLines,
                          onChanged: ((bool switchState) {
                            _appSettingsProvider.appSettings = appSettings
                                .copyWith(animateLyricsLines: switchState);
                            _appSettingsProvider.saveAppSettings();
                          }),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2, height: 30),
                    const Text(
                      'Font size:',
                      style: uiTextStyle,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _appSettingsProvider.appSettings = appSettings
                                .copyWith(fontSize: appSettings.fontSize - 1);
                            _appSettingsProvider.saveAppSettings();
                          },
                          child: const Text(
                            '-',
                            style: uiTextStyle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          appSettings.fontSize.toString(),
                          style: mediumTextStyle,
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            _appSettingsProvider.appSettings = appSettings
                                .copyWith(fontSize: appSettings.fontSize + 1);
                            _appSettingsProvider.saveAppSettings();
                          },
                          child: const Text(
                            '+',
                            style: uiTextStyle,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2, height: 30),
                    const Text(
                      'Colors:',
                      style: uiTextStyle,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Choose a new background color:'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: appSettings.backgroundColor,
                                onColorChanged: (Color newColor) {
                                  _newBackgroundColor = newColor;
                                },
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Save'),
                                onPressed: () {
                                  _appSettingsProvider.appSettings =
                                      appSettings.copyWith(
                                          backgroundColor: _newBackgroundColor);
                                  _appSettingsProvider.saveAppSettings();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Change background color',
                        style: mediumTextStyle,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title:
                                const Text('Choose a new default text color:'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: appSettings.textDefaultColor,
                                onColorChanged: (Color newColor) {
                                  _newTextDefaultColor = newColor;
                                },
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Save'),
                                onPressed: () {
                                  _appSettingsProvider.appSettings =
                                      appSettings.copyWith(
                                          textDefaultColor:
                                              _newTextDefaultColor);
                                  _appSettingsProvider.saveAppSettings();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Change default text color',
                        style: mediumTextStyle,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                                'Choose a new highlight text color:'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: appSettings.textHighlightColor,
                                onColorChanged: (Color newColor) {
                                  _newTextHighlightColor = newColor;
                                },
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Save'),
                                onPressed: () {
                                  _appSettingsProvider.appSettings =
                                      appSettings.copyWith(
                                          textHighlightColor:
                                              _newTextHighlightColor);
                                  _appSettingsProvider.saveAppSettings();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Change highlight text color',
                        style: mediumTextStyle,
                      ),
                    ),
                    const Divider(thickness: 2, height: 30),
                    const Text('Preview:', style: uiTextStyle),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: appSettings.backgroundColor,
                      child: Column(
                        children: [
                          Text(
                            'Text default color on background',
                            style: TextStyle(
                                color: appSettings.textDefaultColor,
                                fontSize: appSettings.fontSize),
                          ),
                          Text(
                            'Text highlight color on background',
                            style: TextStyle(
                                color: appSettings.textHighlightColor,
                                fontSize: appSettings.fontSize),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
