import 'package:flutter/material.dart';
import 'package:manatsume/ui/motion.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final text = theme.colorScheme.onBackground;
    final muted = theme.colorScheme.onBackgroundVariant;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Reveal(
                beginOffset: const Offset(0.0, 0.12),
                child: Text(
                  'About',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Reveal(
                delay: 60,
                beginOffset: const Offset(0.0, 0.1),
                child: Text(                  'A music app built to study a reverse-engineered search pipeline.',              style: theme.textTheme.bodyMedium?.copyWith(
                      color: muted,
                      height: 1.4,
                    ),
                ),
              ),
              const SizedBox(height: 24),

              // one-line summary
              Reveal(
                delay: 90,
                beginOffset: const Offset(0.0, 0.1),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accent.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Manatsume uses youtube_explode_dart to search YouTube and '
                          'obtain audio stream URLs without an official YouTube API key.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: text,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // what it does
              Reveal(
                delay: 130,
                beginOffset: const Offset(0.0, 0.1),
                child: _AboutCard(
                  icon: Icons.search,
                  title: 'Reverse-engineered search',
                  body: 'The app does not rely on a public YouTube API key. Instead it '
                      'uses an extractor package to get search results, video metadata, and '
                      'audio stream URLs at runtime.',
                ),
              ),
              const SizedBox(height: 12),

              // what it is not
              Reveal(
                delay: 170,
                beginOffset: const Offset(0.0, 0.1),
                child: _AboutCard(
                  icon: Icons.warning_amber,
                  title: 'What it is not',
                  body: 'It is not an official YouTube app. It does not host music and it does '
                      'not claim rights to any content it plays. Extractor-based access is '
                      'inherently fragile and can change over time.',
                ),
              ),
              const SizedBox(height: 12),

              // local files
              Reveal(
                delay: 210,
                beginOffset: const Offset(0.0, 0.1),
                child: _AboutCard(
                  icon: Icons.folder_open,
                  title: 'Local files',
                  body: 'You can add your own audio files to your library. They stay on your '
                      'device and play through the same player used for searched tracks.',
                ),
              ),
              const SizedBox(height: 12),

              // motion
              Reveal(
                delay: 250,
                beginOffset: const Offset(0.0, 0.1),
                child: _AboutCard(
                  icon: Icons.animation,
                  title: 'Motion system',
                  body: 'Each major action has its own animation signature: play/pause, like, '
                      'search, queue changes, dialogs, and file add. They share the same night-'
                      'theme motion language, but feel distinct on purpose.',
                ),
              ),
              const SizedBox(height: 22),

              // build the APK
              Reveal(
                delay: 290,
                beginOffset: const Offset(0.0, 0.1),
                child: _AboutCard(
                  icon: Icons.build,
                  title: 'Build the APK',
                  body: 'Install Flutter, then run: flutter pub get && flutter build apk --release. '
                      'The APK is produced at build/app/outputs/flutter-apk/app-release.apk. You can '
                      'then share it from the repo or upload it to GitHub.',
                ),
              ),
              const SizedBox(height: 22),

              // license
              Reveal(
                delay: 330,
                beginOffset: const Offset(0.0, 0.1),
                child: _AboutCard(
                  icon: Icons.code,
                  title: 'License',
                  body: 'The app code is MIT. Music sourcing is a separate matter: the app streams '
                      'from runtime URLs and does not bundle audio. Use it responsibly.',
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final border = theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
