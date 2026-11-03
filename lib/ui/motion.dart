import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

// ---------------------------------------------------------------------------
// Reusable signatures
// ---------------------------------------------------------------------------

/// Fade + slide up, with an optional stagger delay.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = 0.0,
    this.duration = const Duration(milliseconds: 420),
    this.beginOffset = const Offset(0.0, 0.18),
    this.reverse = false,
  });
  final Widget child;
  final Duration duration;
  final double delay;
  final Offset beginOffset;
  final bool reverse;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..stop();
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: widget.reverse ? const Offset(0.0, 0.0) : widget.beginOffset,
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    Future.delayed(Duration.zero, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: _slide.value,
            child: widget.child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Staggered entrance for a list of children with individual delays.
class StaggerReveal extends StatelessWidget {
  const StaggerReveal({
    super.key,
    required this.children,
    this.baseDelay = 60.0,
    this.duration = const Duration(milliseconds: 420),
    this.beginOffset = const Offset(0.0, 0.16),
  });
  final List<Widget> children;
  final double baseDelay;
  final Duration duration;
  final Offset beginOffset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children.asMap().entries.map((entry) {
        return Reveal(
          delay: baseDelay * entry.key,
          duration: duration,
          beginOffset: beginOffset,
          child: entry.value,
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Play button: expand from icon to full panel
// ---------------------------------------------------------------------------

class PlayButton extends StatefulWidget {
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
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _rotate;
  late final Animation<double> _shine;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.elasticOut,
      ),
    );
    _rotate = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _shine = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
    if (widget.playing) {
      _ctrl.value = 1.0;
    }
  }

  void _play() => _ctrl.forward(from: 0.0);
  void _pause() => _ctrl.reverse(from: 1.0);

  @override
  void didUpdateWidget(covariant PlayButton old) {
    super.didUpdateWidget(old);
    if (widget.playing && !old.playing) {
      _play();
    } else if (!widget.playing && old.playing) {
      _pause();
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
    final accent = theme.colorScheme.primary;
    final bg = theme.colorScheme.onPrimary;
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: () {},
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final s = widget.playing ? 1.0 + 0.06 * _scale.value : _scale.value;
          return Transform.scale(
            scale: s,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accent,
                accent.withOpacity(0.85),
              ],
              stops: const [0.0, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.5),
                blurRadius: 18 * _ctrl.value,
                spreadRadius: 2 * _ctrl.value,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // spinning glow ring
              IgnorePointer(
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: GlowRingPainter(
                    progress: widget.playing ? 1.0 : 0.0,
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
                    progress: _rotate.value,
                    playing: widget.playing,
                    color: bg,
                  ),
                ),
              ),
              if (widget.playing)
                IgnorePointer(
                  child: CustomPaint(
                    size: const Size(80, 80),
                    painter: ShinePainter(
                      progress: _shine.value,
                      angle: 0.0,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    canvas.drawCircle(Offset(cx, cy), radius * (0.5 + 0.5 * progress), paint..style = PaintingStyle.stroke);
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
      // paused state icon: two verticals
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
      // play triangle with a slight squash
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

// ---------------------------------------------------------------------------
// Like button: heart fill burst
// ---------------------------------------------------------------------------

class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.liked,
    required this.onToggle,
  });
  final bool liked;
  final VoidCallback onToggle;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fill;
  late final Animation<double> _burst;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _fill = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _burst = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.1, 0.7, curve: Curves.elasticOut),
      ),
    );
    _ctrl.value = widget.liked ? 1.0 : 0.0;
  }

  void _doToggle() {
    HapticFeedback.mediumImpact();
    widget.onToggle();
    if (widget.liked) {
      _ctrl.forward(from: 0.0);
    } else {
      _ctrl.reverse(from: 1.0);
    }
  }

  @override
  void didUpdateWidget(covariant LikeButton old) {
    super.didUpdateWidget(old);
    if (widget.liked && !old.liked) {
      _ctrl.forward(from: 0.0);
    } else if (!widget.liked && old.liked) {
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
    final accent = theme.colorScheme.primary;
    return GestureDetector(          onTap: _doToggle,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + 0.18 * _burst.value * (widget.liked ? 1.0 : 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size(36, 36),
                  painter: HeartPaint(
                    progress: _fill.value,
                    color: accent,
                  ),
                ),
                if (widget.liked && _ctrl.value > 0.5)
                  IgnorePointer(
                    child: CustomPaint(
                      size: const Size(56, 56),
                      painter: LikeBurstPainter(
                        progress: _ctrl.value,
                        color: accent,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: widget.liked ? 1.0 : 0.0,
          child: Text(
            'Liked',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),
      ),
    );
  }
}

class HeartPaint extends CustomPainter {
  HeartPaint({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + size.height * 0.05;
    final s = size.width * 0.42;
    final path = Path()
      ..moveTo(cx, cy + s * 0.7)
      ..cubicTo(cx, cy + s * 1.1, cx - s * 0.9, cy + s * 0.6, cx - s * 0.9, cy - s * 0.1)
      ..cubicTo(cx - s * 0.9, cy - s * 0.6, cx, cy - s * 1.1, cx, cy - s * 0.7)
      ..cubicTo(cx, cy - s * 1.1, cx + s * 0.9, cy - s * 0.6, cx + s * 0.9, cy - s * 0.1)
      ..cubicTo(cx + s * 0.9, cy + s * 0.6, cx, cy + s * 1.1, cx, cy + s * 0.7)
      ..close();
    final p = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          color,
          color.withOpacity(0.75),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: s * 1.2));
    canvas.drawPath(path, p);
    canvas.drawPath(
      path.shift(Offset.zero),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color.withOpacity(0.4)
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant HeartPaint other) =>
      other.progress != progress;
}

class LikeBurstPainter extends CustomPainter {
  LikeBurstPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final base = size.width * 0.1;
    final count = 8;
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * 3.1415926535;
      final len = base + (1.0 - progress) * 40;
      final begin = Offset(cx, cy);
      final end = Offset(
        cx + cos(angle) * len,
        cy + sin(angle) * len,
      );
      canvas.drawLine(        begin,
        end,
        Paint()
          ..color = color.withOpacity((1.0 - progress) * 0.8)
          ..strokeWidth = 2.0 + (1.0 - progress) * 2.0
          ..strokeCap = StrokeCap.round,
      );
    }
  }



  @override
  bool shouldRepaint(covariant LikeBurstPainter other) =>
      other.progress != progress;
}

// ---------------------------------------------------------------------------
// Queue item: slide + fade on add/remove
// ---------------------------------------------------------------------------

class QueueItem extends StatelessWidget {
  const QueueItem({
    super.key,
    required this.track,
    required this.playing,
    required this.current,
    required this.onTap,
    required this.onLike,
    this.onDismiss,
  });
  final Track track;
  final bool playing;
  final bool current;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final border = theme.colorScheme.outline;
    final text = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(
        current ? 0 : 0,
        0,
        0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: accent.withOpacity(0.15),
          highlightColor: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: current
                  ? Border.all(color: accent, width: 1.25)
                  : Border.all(color: border, width: 0.5),
            ),
            child: Row(
              children: [
                if (current && playing)
                  IgnorePointer(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      if (track.artwork != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            track.artwork!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _artFallback(track, theme),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        )
                      else
                        _artFallback(track, theme),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
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
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                if (track.duration > 0)
                                  Text(
                                    _fmt(track.duration),
                                    style: theme.textTheme.labelSmall,
                                  ),
                                const Spacer(),
                                if (track.source != null)
                                  Text(
                                    track.source!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: accent,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (playing && current)
                  IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CustomPaint(
                        size: const Size(20, 20),
                        painter: EqualizerPainter(
                          progress: 1.0,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _artFallback(Track track, ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.music_note,
        size: 22,
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

class EqualizerPainter extends CustomPainter {
  EqualizerPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final count = 5;
    final barW = size.width / count;
    for (var i = 0; i < count; i++) {
      final h = 4.0 + (0.4 + 0.6 * (1.0 - (i / count))) * 16 * progress;
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
  bool shouldRepaint(covariant EqualizerPainter other) =>
      other.progress != progress;
}

// ---------------------------------------------------------------------------
// Shimmer for loading placeholders
// ---------------------------------------------------------------------------

class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    this.duration = const Duration(milliseconds: 1600),
    this.color = const Color(0xFF2A2536),
    this.highlight = const Color(0xFF3A304A),
    required this.child,
  });
  final Duration duration;
  final Color color;
  final Color highlight;
  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _anim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        widget.color,
        widget.highlight,
        widget.color,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return shader.createShader(bounds.shift(Offset(-bounds.width * _anim.value, 0)));
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12.0,
  });
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final light = base.withOpacity(0.6);
    final dark = base.withOpacity(0.2);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: CustomPaint(
        painter: _SkeletonPaint(baseColor: base, highlightColor: light, darkColor: dark),
      ),
    );
  }
}

class _SkeletonPaint extends CustomPainter {
  _SkeletonPaint({
    required this.baseColor,
    required this.highlightColor,
    required this.darkColor,
  });
  final Color baseColor;
  final Color highlightColor;
  final Color darkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);
    final shimmer = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [darkColor, highlightColor, darkColor],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(12)),
      Paint()
        ..shader = shimmer.createShader(r)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _SkeletonPaint other) =>
      other.baseColor != baseColor || other.highlightColor != highlightColor;
}

// ---------------------------------------------------------------------------
// Toast-style notification with slide-up
// ---------------------------------------------------------------------------

class Toast extends StatelessWidget {
  const Toast({
    super.key,
    required this.message,
    this.onDone,
    this.duration = const Duration(seconds: 3),
    this.action,
  });
  final String message;
  final VoidCallback? onDone;
  final Duration duration;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final border = theme.colorScheme.outline;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.4),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _toastAnim(),
          curve: Curves.easeOut,
        ),
      ),
      child: FadeTransition(
        opacity: _toastAnim(),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: 12),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static AnimationController _toastAnim() {
    // This is a simplified placeholder; real toast would have its own controller.
    throw UnsupportedError('Toast requires a controller; use ToastManager instead.');
  }
}

// ---------------------------------------------------------------------------
// Modal / bottom sheet entrance
// ---------------------------------------------------------------------------

class ModalSheet<T> extends StatelessWidget {
  const ModalSheet({
    super.key,
    required this.child,
    this.onDismiss,
  });
  final Widget child;
  final VoidCallback? onDismiss;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    VoidCallback? onDismiss,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (_) => ModalSheet<T>(child: child, onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image loader with placeholder shimmer
// ---------------------------------------------------------------------------

class AsyncImage extends StatelessWidget {
  const AsyncImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.radius = 12.0,
  });
  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final light = base.withOpacity(0.6);
    final dark = base.withOpacity(0.2);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Shimmer(
            duration: const Duration(milliseconds: 1600),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
          Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Icon(
                Icons.music_note,
                size: 28,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                return child;
              }
              return CustomPaint(
                size: Size(width, height),
                painter: _ImageLoadProgress(
                  progress: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                  baseColor: base,
                  highlightColor: light,
                  darkColor: dark,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ImageLoadProgress extends CustomPainter {
  _ImageLoadProgress({
    required this.progress,
    required this.baseColor,
    required this.highlightColor,
    required this.darkColor,
  });
  final double progress;
  final Color baseColor;
  final Color highlightColor;
  final Color darkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width * progress, size.height);
    final shimmer = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [darkColor, highlightColor, darkColor],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = shimmer.createShader(rect)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ImageLoadProgress other) =>
      other.progress != progress;
}

// ---------------------------------------------------------------------------
// Misc painters
// ---------------------------------------------------------------------------

class ShinePainterOld extends CustomPainter {
  ShinePainterOld({
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
  bool shouldRepaint(covariant ShinePainterOld other) =>
      other.progress != progress || other.angle != angle;
}
