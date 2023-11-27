import 'package:flow_lyrix/models/app_settings.dart';
import 'package:flow_lyrix/providers/app_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

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
  Color _newTextColor = Colors.lightBlue;

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
      ),
      body: Padding(
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
                  const Text(
                    'Font size:',
                    style: uiTextStyle,
                  ),
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
                        style: uiTextStyle,
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
                  const Divider(thickness: 2),
                  const Text(
                    'Colors:',
                    style: uiTextStyle,
                  ),
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
                    child: const Text('Change background color'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Choose a new text color:'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: appSettings.textColor,
                              onColorChanged: (Color newColor) {
                                _newTextColor = newColor;
                              },
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('Save'),
                              onPressed: () {
                                _appSettingsProvider.appSettings = appSettings
                                    .copyWith(textColor: _newTextColor);
                                _appSettingsProvider.saveAppSettings();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Change text color'),
                  ),
                  const Divider(thickness: 2),
                  const Text('Preview:', style: uiTextStyle),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: appSettings.backgroundColor,
                    child: Text(
                      'Text color on background',
                      style: TextStyle(
                          color: appSettings.textColor,
                          fontSize: appSettings.fontSize),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}