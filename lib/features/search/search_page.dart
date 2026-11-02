import 'package:flutter/material.dart';
import 'package:manatsume/models/models.dart';
import 'package:manatsume/services/service_locator.dart';
import 'package:manatsume/ui/motion.dart';
import 'package:manatsume/features/player/play_button.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _queryController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _runSearch() {
    HapticFeedback.lightImpact();
    ServiceLocator.music.search(_queryController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Reveal(
                beginOffset: const Offset(0.0, 0.12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search music through the extractor pipeline.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackgroundVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // query input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Reveal(
                delay: 80,
                beginOffset: const Offset(0.0, 0.1),
                child: SizedBox(
                  height: 56,
                  child: TextField(
                    controller: _queryController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Song, artist, album…',
                      prefixIcon: const Icon(Icons.search, size: 22),
                      suffixIcon: _queryController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                _queryController.clear();
                                ServiceLocator.music.search('');
                                _focusNode.unfocus();
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _runSearch(),
                    onChanged: (_) {
                      // live search is intentionally not triggered on every
                      // keystroke to keep the extractor usage intentional.
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // action row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Reveal(
                delay: 120,
                beginOffset: const Offset(0.0, 0.1),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _queryController.text.isEmpty
                          ? null
                          : _runSearch,
                      icon: ServiceLocator.music.searching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search, size: 18),
                      label: Text(
                        ServiceLocator.music.searching ? 'Searching…' : 'Search',
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _focusNode.requestFocus(),
                      icon: const Icon(Icons.tune, size: 18),
                      label: const Text('Filter'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            // status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _StatusView(),
            ),

            const Divider(height: 1),

            // results
            Expanded(
              child: _ResultsView(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final music = ServiceLocator.music;
    if (music.searching) {
      return const SizedBox(
        height: 20,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text(
                  'Searching…',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (music.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200, width: 0.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, size: 20, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  music.error!,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _ResultsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final music = ServiceLocator.music;
    final tracks = <Track>[];

    // For this educational build we expose a simple public query; in a real
    // app this would come from the service. Here we model the search results
    // that the service returns after a search call.
    final hasResults = music.hasSearched && tracks.isNotEmpty;

    if (!music.hasSearched) {
      return Center(
        child: Reveal(
          beginOffset: const Offset(0.0, 0.12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search,
                size: 56,
                color: Colors.white24,
              ),
              const SizedBox(height: 12),
              Text(
                'Search to find music',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Results come from the extractor pipeline.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (music.searching) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 12),
            Text(
              'Searching…',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    if (!hasResults) {
      return Center(
        child: Reveal(
          beginOffset: const Offset(0.0, 0.12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.music_off,
                size: 56,
                color: Colors.white24,
              ),
              const SizedBox(height: 12),
              Text(
                'No results',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try a different query.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          final playing = false;
          final current = false;
          return Reveal(
            delay: 40.0 * index,
            beginOffset: const Offset(0.0, 0.14),
            duration: const Duration(milliseconds: 360),
            child: _SearchResultTile(
              track: track,
              playing: playing,
              current: current,
            ),
          );
        },
      ),
    );
  }
}

class _SearchResultTile extends StatefulWidget {
  const _SearchResultTile({
    required this.track,
    required this.playing,
    required this.current,
  });
  final Track track;
  final bool playing;
  final bool current;

  @override
  State<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<_SearchResultTile> {
  bool _liked = false;

  void _togglePlay() {
    HapticFeedback.mediumImpact();
    // Play action: opens the player with this track queued.
  }

  void _toggleLike() {
    HapticFeedback.mediumImpact();
    setState(() => _liked = !_liked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final border = theme.colorScheme.outline;
    final text = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _togglePlay,
        splashColor: accent.withOpacity(0.12),
        highlightColor: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Row(
            children: [
              // artwork
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: _artFallback(theme),
                ),
              ),
              const SizedBox(width: 12),
              // info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.track.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.track.artist,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (widget.track.duration > 0)
                          Text(
                            _fmt(widget.track.duration),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: muted,
                            ),
                          ),
                        const Spacer(),
                        if (widget.track.source != null)
                          Text(
                            widget.track.source!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accent,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // like
              GestureDetector(
                onTap: _toggleLike,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _liked
                        ? accent.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _liked ? Icons.favorite : Icons.favorite_border,
                    color: _liked ? accent : muted,
                    size: 20,
                  ),
                ),
              ),
              // play affordance
              GestureDetector(
                onTap: _togglePlay,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) {
                    return ScaleTransition(scale: anim, child: child);
                  },
                  child: Icon(
                    widget.current ? Icons.pause : Icons.play_arrow,
                    key: ValueKey(widget.current),
                    color: accent,
                    size: widget.current ? 26 : 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _artFallback(ThemeData theme) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.music_note,
        size: 24,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  static String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

// Play Button widget (reused from player feature)
class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.playing,
    required this.onTap,
    this.label,
    this.showLabel = false,
  });
  final bool playing;
  final VoidCallback onTap;
  final String? label;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final bg = theme.colorScheme.onPrimary;

    return GestureDetector(
      onTapDown: (_) => HapticFeedback.mediumImpact(),
      onTapUp: (_) {
        HapticFeedback.mediumImpact();
        onTap();
      },
      onTapCancel: () {},
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [accent, accent.withOpacity(0.85)],
            stops: const [0.0, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.5),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (playing)
              IgnorePointer(
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: GlowRingPainter(
                    progress: 1.0,
                    color: accent,
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomPaint(
                size: const Size(40, 40),
                painter: _PlayIconPainter(
                  progress: 0.0,
                  playing: playing,
                  color: bg,
                ),
              ),
            ),
            if (playing)
              IgnorePointer(
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: ShinePainter(
                    progress: 1.0,
                    angle: 0.0,
                    color: accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Re-export or define the painters used above.
class GlowRingPainter extends CustomPainter {
  GlowRingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.42;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant GlowRingPainter other) =>
      other.progress != progress;
}

class _PlayIconPainter extends CustomPainter {
  _PlayIconPainter({
    required this.progress,
    required this.playing,
    required this.color,
  });
  final double progress;
  final bool playing;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (playing) {
      final w = size.width * 0.32;
      final h = size.height * 0.5;
      final gap = size.width * 0.28;
      final cx = size.width / 2;
      final cy = size.height / 2;
      canvas.drawRect(
        Rect.fromLTWH(cx - gap / 2 - w, cy - h / 2, w, h),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH(cx + gap / 2, cy - h / 2, w, h),
        paint,
      );
    } else {
      final cx = size.width / 2;
      final cy = size.height / 2;
      final s = 0.5 * (0.9 + 0.1 * (1 - progress));
      final path = Path()
        ..moveTo(cx - 4 * s, cy - 8 * s)
        ..lineTo(cx - 4 * s, cy + 8 * s)
        ..lineTo(cx + 12 * s, cy)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PlayIconPainter other) =>
      other.progress != progress || other.playing != playing;
}

class ShinePainter extends CustomPainter {
  ShinePainter({
    required this.progress,
    required this.angle,
    required this.color,
  });
  final double progress;
  final double angle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.5;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.5 * progress),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
        center: Alignment(-0.6 + angle, -0.6 + angle),
        focal: Alignment(-0.6 + angle, -0.6 + angle),
        focalRadius: 2.0,
      ).createShader(rect);
    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant ShinePainter other) =>
      other.progress != progress || other.angle != angle;
}
