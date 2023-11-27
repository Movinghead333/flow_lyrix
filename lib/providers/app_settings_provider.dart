import 'dart:convert';

import 'package:flow_lyrix/models/app_settings.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rxdart/rxdart.dart';

class AppSettingsProvider {
  AppSettingsProvider() {
    loadAppSettings();
  }

  final BehaviorSubject<AppSettings> _appSettingsSubject =
      BehaviorSubject.seeded(AppSettings());

  set appSettings(AppSettings newAppSettings) {
    _appSettingsSubject.add(newAppSettings);
  }

  AppSettings get appSettings => _appSettingsSubject.value;

  Stream<AppSettings> get appSettingsStream => _appSettingsSubject.stream;

  final GetStorage _getStorage = GetStorage();

  final String _appSettingsStorageKey = 'appSettings';

  void loadAppSettings() {
    String? appSettingsJsonText = _getStorage.read(_appSettingsStorageKey);

    // If we never stored app settings we just use the default settings and do
    // not load anything here.
    if (appSettingsJsonText != null &&
        appSettingsJsonText.contains('textDefaultColor')) {
      Map<String, dynamic> appSettingsJson = jsonDecode(appSettingsJsonText);
      appSettings = AppSettings.fromJson(appSettingsJson);
    }
  }

  void saveAppSettings() {
    Map<String, dynamic> appSettingsJson = appSettings.toJson();
    String appSettingsJsonText = jsonEncode(appSettingsJson);
    _getStorage.write(_appSettingsStorageKey, appSettingsJsonText);
  }
}
