import 'package:flutter/material.dart';
import 'package:manatsume/ui/motion.dart';
import '../services/service_locator.dart';
import 'package:manatsume/features/player/play_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final text = theme.colorScheme.onBackground;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // --- header
                StaggerReveal(
                  baseDelay: 40,
                  beginOffset: const Offset(0.0, 0.12),
                  children: [
                    _eyebrow('Free music player'),
                    const SizedBox(height: 12),
                    _headline(
                      'Your music,',
                      accent,
                      text,
                    ),
                    _headline(
                      'your night.',
                      accent,
                      accent,
                    ),
                    const SizedBox(height: 16),
                    _subtext(
                      'Search and play music through a reverse-engineered '
                      'YouTube pipeline built for study. Add your own files '
                      'for offline listening that stays on your device.',
                    ),
                    const SizedBox(height: 22),
                    _actionRow(),
                    const SizedBox(height: 26),
                    _previewCard(),
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(height: 24),

                // --- features
                const SizedBox(height: 8),
                StaggerReveal(
                  baseDelay: 90,
                  beginOffset: const Offset(0.0, 0.14),
                  children: [
                    _sectionTitle('Why Manatsume'),
                    const SizedBox(height: 16),
                    _featuresGrid(),
                  ],
                ),
                const SizedBox(height: 40),

                // --- bottom credits
                StaggerReveal(
                  baseDelay: 140,
                  beginOffset: const Offset(0.0, 0.0),
                  children: [
                    _bottomRow(),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _eyebrow(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _headline(String text, Color base, Color accent) {
    return Text(
      text,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        color: text,
        height: 1.05,
      ),
    );
  }

  Widget _subtext(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.onBackgroundVariant,
        height: 1.5,
      ),
    );
  }

  Widget _actionRow() {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('Start listening'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.search, size: 20),
            label: const Text('Search music'),
          ),
        ),
      ],
    );
  }

  Widget _previewCard() {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withOpacity(0.15),
                    Colors.transparent,
                    const Color(0xFFC75B26).withOpacity(0.12),
                  ],
                ),
              ),
            ),
            // moon glow
            IgnorePointer(
              child: CustomPaint(
                size: const Size(320, 320),
                painter: MoonGlowPainter(
                  progress: 0.85,
                  color: accent,
                ),
              ),
            ),
            // center fox mark
            IgnorePointer(
              child: Transform.scale(
                scale: 2.2,
                child: CustomPaint(
                  size: const Size(64, 64),
                  painter: FoxMarkPainter(
                    color: accent,
                    earColor: const Color(0xFFC75B26),
                  ),
                ),
              ),
            ),
            // bottom info
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.colorScheme.outline, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.music_note,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Long Summer Night',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'via YouTube',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        letterSpacing: 1.5,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _featuresGrid() {
    final theme = Theme.of(context);
    final items = [
      _FeatureCard(
        icon: Icons.search,
        title: 'Search without an API key',
        body: 'YouTube search and stream URLs are obtained through an extractor, '
            'so the app can be studied without depending on an official API.',
      ),
      _FeatureCard(
        icon: Icons.music_note,
        title: 'Your own files',
        body: 'Add local music to your library. It stays on your device and plays '
            'through the same player.',
      ),
      _FeatureCard(
        icon: Icons.playlist_play,
        title: 'Playlists that persist',
        body: 'Build playlists, reorder tracks, and keep them on the device so they '
            'survive restarts.',
      ),
      _FeatureCard(
        icon: Icons.favorite,
        title: 'Likes that stick',
        body: 'Mark tracks you like and keep that list around. The heart burst animation '
            'is its own little signature.',
      ),
      _FeatureCard(
        icon: Icons.animation,
        title: 'Motion for each action',
        body: 'Play, like, search, queue, and dialogs each have their own animation '
            'signature — but they all share the same night-theme motion language.',
      ),
      _FeatureCard(
        icon: Icons.open_in_new,
        title: 'Study it from GitHub',
        body: 'Build an APK from the repo and send it around. The README explains how '
            'to get the APK and what the extractor layer does.',
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      childAspectRatio: 1.1,
      children: items,
    );
  }

  Widget _bottomRow() {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Study the code • Build the APK • Share it',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onBackgroundVariant,
          ),
        ),
        Text(
          'MIT',
          style: theme.textTheme.bodySmall?.copyWith(
            color: accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline, width: 0.5),
      ),
      child: Column(
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
          const SizedBox(height: 10),
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
              height: 1.4,
              color: theme.colorScheme.onBackgroundVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom painters for the home hero
// ---------------------------------------------------------------------------

class MoonGlowPainter extends CustomPainter {
  MoonGlowPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;
    final cx = size.width * 0.5;
    final cy = size.height * 0.25;
    final outer = size.width * 0.5 * progress;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.35 * progress),
          color.withOpacity(0.10 * progress),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: outer));
    canvas.drawCircle(Offset(cx, cy), outer, paint);
  }

  @override
  bool shouldRepaint(covariant MoonGlowPainter other) =>
      other.progress != progress || other.color != color;
}

class FoxMarkPainter extends CustomPainter {
  FoxMarkPainter({
    required this.color,
    required this.earColor,
  });
  final Color color;
  final Color earColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ears
    final earPath = Path()
      ..moveTo(cx - 20, cy + 6)
      ..lineTo(cx - 10, cy - 20)
      ..lineTo(cx - 2, cy + 4)
      ..close();
    canvas.drawPath(
      earPath,
      Paint()
        ..color = earColor
        ..style = PaintingStyle.fill,
    );
    final earPath2 = Path()
      ..moveTo(cx + 20, cy + 6)
      ..lineTo(cx + 10, cy - 20)
      ..lineTo(cx + 2, cy + 4)
      ..close();
    canvas.drawPath(
      earPath2,
      Paint()
        ..color = earColor
        ..style = PaintingStyle.fill,
    );

    // face
    final face = Path()
      ..moveTo(cx - 22, cy + 10)
      ..quadraticBezierTo(cx - 18, cy - 8, cx, cy - 10)
      ..quadraticBezierTo(cx + 18, cy - 8, cx + 22, cy + 10)
      ..close();
    canvas.drawPath(
      face,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // eyes
    canvas.drawCircle(
      Offset(cx - 8, cy + 2),
      2.0,
      Paint()..color = const Color(0xFF3A2A18)..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx + 8, cy + 2),
      2.0,
      Paint()..color = const Color(0xFF3A2A18)..style = PaintingStyle.fill,
    );

    // nose
    canvas.drawCircle(
      Offset(cx, cy + 6),
      1.8,
      Paint()..color = const Color(0xFF3A2A18)..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant FoxMarkPainter other) =>
      other.color != color || other.earColor != earColor;
}
