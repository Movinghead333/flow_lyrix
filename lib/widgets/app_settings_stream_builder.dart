import 'package:flutter/material.dart';
import 'package:flow_lyrix/models/app_settings.dart';
import 'package:flow_lyrix/providers/app_settings_provider.dart';
import 'package:provider/provider.dart';

/// A utility widget that provides automatic rebuilding when AppSettings change.
///
/// This widget uses a StreamBuilder internally to listen to the AppSettingsStream
/// from the AppSettingsProvider and automatically rebuilds the child widget whenever
/// the settings change.
///
/// Example usage:
/// ```dart
/// AppSettingsStreamBuilder(
///   builder: (context, appSettings) => Text(
///     'Font size: ${appSettings.fontSize}',
///   ),
/// )
/// ```
class AppSettingsStreamBuilder extends StatelessWidget {
  /// A builder function that receives the current AppSettings and returns a widget.
  final Widget Function(BuildContext context, AppSettings appSettings) builder;

  const AppSettingsStreamBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appSettingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);

    return StreamBuilder<AppSettings>(
      stream: appSettingsProvider.appSettingsStream,
      initialData: appSettingsProvider.appSettings,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading app settings: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return builder(context, snapshot.data!);
      },
    );
  }
}
