import 'package:flutter/material.dart';
import 'package:manatsume/app.dart';
import 'package:manatsume/core/services.dart';

void main() {
  runApp(const _AppBoot());
}

class _AppBoot extends StatefulWidget {
  const _AppBoot();

  @override
  State<_AppBoot> createState() => _AppBootState();
}

class _AppBootState extends State<_AppBoot> {
  late final SettingsService _settings;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // Use the same instance the rest of the app reads through
    // ServiceLocator, so persisted theme/settings stay consistent.
    _settings = ServiceLocator.settings;
    _settings.init().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ready
        ? ManatsumeApp(settings: _settings)
        : const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
