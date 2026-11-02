import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manatsume/models/models.dart';
import 'package:manatsume/services/service_locator.dart';
import 'package:manatsume/ui/motion.dart';
import 'package:manatsume/features/player/play_button.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _playCtrl;
  late final Animation<double> _playScale;
  late final Animation<double> _playShine;

  final _queue = <Track>[];
  int _index = 0;
  bool _playing = false;
  bool _liked = false;
  bool _shuffle = false;
  RepeatMode _repeat = RepeatMode.off;
  double _volume = 0.8;
  double _progress = 0.0;
  double _duration = 1.0;
  double _buffered = 0.0;

  Track? get current =>
      _index >= 0 && _index < _queue.length ? _queue[_index] : null;

  @override
  void initState() {
    super.initState();
    _playCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _playScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _playCtrl,
        curve: Curves.elasticOut,
      ),
    );
    _playShine = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _playCtrl,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
    if (_playing) {
      _playCtrl.value = 1.0;
    }
    _loadQueue();
  }

  void _loadQueue() {
    setState(() {
      _queue.clear();
      // In a complete build the queue would come from the player store and
      // the service. For this educational build we model a small demo queue
      // so the player page can be studied as-is.
      _queue.addAll(_demoQueue);
      if (_queue.isNotEmpty && _index < 0) _index = 0;
    });
  }

  void _togglePlay() {
    HapticFeedback.mediumImpact();
    setState(() {
      _playing = !_playing;
      if (_playing) {
        _playCtrl.forward(from: 0.0);
      } else {
        _playCtrl.reverse(from: 1.0);
      }
    });
  }

  void _toggleLike() {
    HapticFeedback.mediumImpact();
    setState(() => _liked = !_liked);
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_queue.isEmpty) return;
    final next = (_index + 1) % _queue.length;
    setState(() => _index = next);
  }

  void _prev() {
    HapticFeedback.lightImpact();
    if (_queue.isEmpty) return;
    final prev = (_index - 1 + _queue.length) % _queue.length;
    setState(() => _index = prev);
  }

  void _toggleShuffle() {
    HapticFeedback.lightImpact();
    setState(() => _shuffle = !_shuffle);
  }

  void _toggleRepeat() {
    HapticFeedback.lightImpact();
    final modes = [RepeatMode.off, RepeatMode.all, RepeatMode.one];
    final i = modes.indexOf(_repeat);
    setState(() => _repeat = modes[(i + 1) % modes.length]);
  }

  @override
  void dispose() {
    _playCtrl.dispose();
    super.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Reveal(
                beginOffset: const Offset(0.0, 0.12),
                child: Row(
                  children: [
                    Text(
                      'Now playing',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onBackgroundVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    if (current != null) ...[
                      Text(
                        current!.artist,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // artwork
            Expanded(
              child: Reveal(
                delay: 60,
                beginOffset: const Offset(0.0, 0.14),
                child: _ArtworkSection(
                  current: current,
                  playing: _playing,
                  liked: _liked,
                  onLike: _toggleLike,
                ),
              ),
            ),

            // progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Reveal(
                delay: 120,
                beginOffset: const Offset(0.0, 0.1),
                child: _ProgressSection(
                  progress: _progress,
                  buffered: _buffered,
                  duration: _duration,
                ),
              ),
            ),

            // controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Reveal(
                delay: 160,
                beginOffset: const Offset(0.0, 0.1),
                child: _ControlsSection(
                  playing: _playing,
                  shuffle: _shuffle,
                  repeat: _repeat,
                  volume: _volume,
                  onPlay: _togglePlay,
                  onNext: _next,
                  onPrev: _prev,
                  onShuffle: _toggleShuffle,
                  onRepeat: _toggleRepeat,
                  onVolume: (v) => setState(() => _volume = v),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // queue
            Expanded(
              child: Reveal(
                delay: 200,
                beginOffset: const Offset(0.0, 0.12),
                child: _QueueSection(
                  queue: _queue,
                  index: _index,
                  playing: _playing,
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ArtworkSection extends StatelessWidget {
  const _ArtworkSection({
    required this.current,
    required this.playing,
    required this.liked,
    required this.onLike,
  });
  final Track? current;
  final bool playing;
  final bool liked;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Container(
      height: 220,
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
            // background glow that breathes with playback
            IgnorePointer(
              child: CustomPaint(
                size: const Size(320, 320),
                painter: _ArtGlowPainter(
                  playing: playing,
                  color: accent,
                ),
              ),
            ),
            // artwork image
            if (current != null && current!.artwork != null)
              Image.network(
                current!.artwork!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _artFallback(theme),
              )
            else
              _artFallback(theme),
            // overlay gradient
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                    ],
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
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.music_note,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current?.title ?? '—',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            current?.artist ?? '—',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: accent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onLike,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) {
                          return ScaleTransition(scale: anim, child: child);
                        },
                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(liked),
                          color: liked ? accent : theme.colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _artFallback(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.music_note,
        size: 64,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ArtGlowPainter extends CustomPainter {
  _ArtGlowPainter({required this.playing, required this.color});
  final bool playing;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (!playing || size.width == 0 || size.height == 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width * 0.5;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.25),
          color.withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: outer));
    canvas.drawCircle(Offset(cx, cy), outer, paint);
  }

  @override
  bool shouldRepaint(covariant _ArtGlowPainter other) =>
      other.playing != playing || other.color != color;
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.progress,
    required this.buffered,
    required this.duration,
  });
  final double progress;
  final double buffered;
  final double duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final border = theme.colorScheme.outline;

    return Column(
      children: [
        // buffered + progress bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // buffered
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: buffered.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // progress
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fmt(progress * duration),
              style: theme.textTheme.labelSmall,
            ),
            Text(
              _fmt(duration),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _fmt(double seconds) {
    final s = seconds.round();
    final m = s ~/ 60;
    final r = s % 60;
    return '$m:${r.toString().padLeft(2, '0')}';
  }
}

class _ControlsSection extends StatelessWidget {
  const _ControlsSection({
    required this.playing,
    required this.shuffle,
    required this.repeat,
    required this.volume,
    required this.onPlay,
    required this.onNext,
    required this.onPrev,
    required this.onShuffle,
    required this.onRepeat,
    required this.onVolume,
  });
  final bool playing;
  final bool shuffle;
  final RepeatMode repeat;
  final double volume;
  final VoidCallback onPlay;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final void Function(double) onVolume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Column(
      children: [
        // main play button
        Center(
          child: PlayButton(
            key: const ValueKey('mainplay'),
            playing: playing,
            onTap: onPlay,
          ),
        ),
        const SizedBox(height: 24),

        // secondary controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // shuffle
            _ControlChip(
              icon: shuffle ? Icons.shuffle : Icons.shuffle,
              active: shuffle,
              activeColor: accent,
              onTap: onShuffle,
            ),
            const SizedBox(width: 10),
            // prev
            _ControlIcon(
              icon: Icons.skip_previous,
              onTap: onPrev,
            ),
            const SizedBox(width: 16),
            // next
            _ControlIcon(
              icon: Icons.skip_next,
              onTap: onNext,
            ),
            const SizedBox(width: 10),
            // repeat
            _ControlChip(
              icon: _repeatIcon(),
              active: repeat != RepeatMode.off,
              activeColor: accent,
              onTap: onRepeat,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // volume
        SizedBox(
          height: 48,
          child: Row(
            children: [
              const Icon(
                Icons.volume_down,
                size: 20,
                color: Colors.white54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  label: 'Volume',
                  child: Slider(
                    value: volume,
                    onChanged: onVolume,
                    activeColor: accent,
                    inactiveColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(volume * 100).round()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _repeatIcon() {
    if (repeat == RepeatMode.all) return Icons.repeat;
    if (repeat == RepeatMode.one) return Icons.repeat_one;
    return Icons.repeat;
  }
}

class _ControlChip extends StatefulWidget {
  const _ControlChip({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  State<_ControlChip> createState() => _ControlChipState();
}

class _ControlChipState extends State<_ControlChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOut,
      ),
    );
    if (widget.active) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _ControlChip old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _ctrl.forward(from: 0.0);
    } else if (!widget.active && old.active) {
      _ctrl.reverse(from: 1.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = widget.activeColor;
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        if (!widget.active) {
          _ctrl.forward(from: 0.0);
        }
      },
      onTapUp: (_) {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () {
        _ctrl.reverse(from: _ctrl.value);
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (widget.active ? 0.12 * _scale.value : 0.0),
            child: child,
          );
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: widget.active
                ? accent.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon,
            size: 22,
            color: widget.active ? accent : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon({
    required this.icon,
    required this.onTap,
  });
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 24,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _QueueSection extends StatelessWidget {
  const _QueueSection({
    required this.queue,
    required this.index,
    required this.playing,
  });
  final List<Track> queue;
  final int index;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final text = theme.colorScheme.onBackground;
    final muted = theme.colorScheme.onBackgroundVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Text(
                'Queue',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${queue.length} track${queue.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: queue.isEmpty
              ? Center(
                  child: Text(
                    'Queue is empty',
                    style: TextStyle(
                      color: muted,
                      fontSize: 14,
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: queue.length,
                    itemBuilder: (context, i) {
                      final track = queue[i];
                      final isCurrent = i == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Reveal(
                          delay: 20.0 * i,
                          beginOffset: const Offset(0.0, 0.12),
                          duration: const Duration(milliseconds: 260),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? accent.withOpacity(0.12)
                                  : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: isCurrent
                                  ? Border.all(color: accent, width: 1.0)
                                  : Border.all(
                                      color: theme.colorScheme.outline,
                                      width: 0.5,
                                    ),
                            ),
                            child: Row(
                              children: [
                                if (isCurrent && playing)
                                  IgnorePointer(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withOpacity(0.6),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track.title,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: text,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        track.artist,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: muted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrent && playing)
                                  IgnorePointer(
                                    child: CustomPaint(
                                      size: const Size(24, 16),
                                      painter: _MiniEqualizer(
                                        progress: 1.0,
                                        color: accent,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _MiniEqualizer extends CustomPainter {
  _MiniEqualizer({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final count = 4;
    final barW = size.width / count;
    for (var i = 0; i < count; i++) {
      final h = 3.0 + (0.5 + 0.5 * (1.0 - i / count)) * 10 * progress;
      final x = i * barW + (barW - 2) / 2;
      canvas.drawRect(
        Rect.fromLTWH(x, size.height / 2 - h / 2, 2, h),
        Paint()
          ..color = color.withOpacity(0.6 + 0.4 * (1.0 - i / count))
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniEqualizer other) =>
      other.progress != progress;
}

enum RepeatMode { off, all, one }

final List<Track> _demoQueue = [
  Track(
    id: 'd1',
    title: 'Long Summer Night',
    artist: 'Manatsume Demo',
    duration: 214,
    artwork: null,
    source: 'Demo',
    license: 'Demo',
  ),
  Track(
    id: 'd2',
    title: 'Paper Fox',
    artist: 'Manatsume Demo',
    duration: 188,
    artwork: null,
    source: 'Demo',
    license: 'Demo',
  ),
  Track(
    id: 'd3',
    title: 'Static Lullaby',
    artist: 'Manatsume Demo',
    duration: 243,
    artwork: null,
    source: 'Demo',
    license: 'Demo',
  ),
];
