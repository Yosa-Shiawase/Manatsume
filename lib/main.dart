import 'package:flutter/material.dart';
import 'package:manatsume/app.dart';
import 'package:manatsume/services/settings_service.dart';

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
    _settings = SettingsService();
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
