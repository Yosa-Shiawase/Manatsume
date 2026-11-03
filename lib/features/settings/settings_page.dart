import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manatsume/services/settings_service.dart';
import '../../services/service_locator.dart';
import 'package:manatsume/ui/motion.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final ScrollController _scroll;
  late final SettingsService _settings;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    _settings = ServiceLocator.settings;
    _themeMode = _settings.readTheme();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final text = theme.colorScheme.onBackground;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            physics: const BouncingScrollPhysics(),
          ),
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 12),
              // header
              Reveal(
                beginOffset: const Offset(0.0, 0.12),
                child: Text(
                  'Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Reveal(
                delay: 60,
                beginOffset: const Offset(0.0, 0.1),
                child: Text(
                  'Tweak the app and read about how it works.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: muted,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // appearance
              _SectionHeader(title: 'Appearance'),
              const SizedBox(height: 10),
              Reveal(
                delay: 90,
                beginOffset: const Offset(0.0, 0.1),
                child: _SettingTile(
                  icon: Icons.contrast,
                  title: 'Theme',
                  subtitle: 'Choose how Manatsume looks.',
                  child: Row(
                    children: [
                      _ThemeOption(
                        label: 'System',
                        icon: Icons.brightness_auto,
                        selected: _themeMode == ThemeMode.system,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _themeMode = ThemeMode.system);
                          _settings.setTheme(ThemeMode.system);
                        },
                      ),
                      _ThemeOption(
                        label: 'Light',
                        icon: Icons.light_mode,
                        selected: _themeMode == ThemeMode.light,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _themeMode = ThemeMode.light);
                          _settings.setTheme(ThemeMode.light);
                        },
                      ),
                      _ThemeOption(
                        label: 'Dark',
                        icon: Icons.dark_mode,
                        selected: _themeMode == ThemeMode.dark,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _themeMode = ThemeMode.dark);
                          _settings.setTheme(ThemeMode.dark);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // extractor
              _SectionHeader(title: 'How it works'),
              const SizedBox(height: 10),
              Reveal(
                delay: 130,
                beginOffset: const Offset(0.0, 0.1),
                child: _SettingTile(
                  icon: Icons.search,
                  title: 'Search pipeline',
                  subtitle: 'Music is found and streamed through an extractor.',
                  child: Column(
                    children: [
                      _InfoRow(label: 'Source', value: 'youtube_explode_dart'),
                      const Divider(height: 12),
                      _InfoRow(label: 'Audio playback', value: 'just_audio'),
                      const Divider(height: 12),
                      _InfoRow(
                        label: 'Note',
                        value: 'Extractor-based search can change over time.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // data
              _SectionHeader(title: 'Data'),
              const SizedBox(height: 10),
              Reveal(
                delay: 170,
                beginOffset: const Offset(0.0, 0.1),
                child: _SettingTile(
                  icon: Icons.storage,
                  title: 'Local data',
                  subtitle: 'Playlists, likes, and library live on this device.',
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showClearDataDialog();
                        },
                        child: const Text('Clear local data'),
                      ),
                      const Spacer(),
                      Text(
                        'Stored on device',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // about
              _SectionHeader(title: 'About'),
              const SizedBox(height: 10),
              Reveal(
                delay: 210,
                beginOffset: const Offset(0.0, 0.1),
                child: _SettingTile(
                  icon: Icons.info,
                  title: 'Manatsume',
                  subtitle: 'A music app built to study reverse-engineered search.',
                  child: Column(
                    children: [
                      _InfoRow(label: 'Version', value: '1.0.0+1'),
                      const Divider(height: 12),
                      _InfoRow(
                        label: 'License',
                        value: 'MIT for the app code',
                      ),
                      const Divider(height: 12),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          // open about page
                        },
                        child: const Text('Read more'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear local data'),
        content: const Text(
          'This removes playlists, likes, and library metadata stored on this '
          'device. Files you added are not removed from storage.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: muted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final border = theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? accent.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? accent : theme.colorScheme.outline,
              width: selected ? 1.25 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? accent : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? accent : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
