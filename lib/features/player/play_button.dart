import 'package:flutter/material.dart';
import 'package:manatsume/ui/motion.dart';

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
      duration: const Duration(milliseconds: 450),
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
          final s = widget.playing
              ? 1.0 + 0.06 * _scale.value
              : _scale.value;
          return Transform.scale(
            scale: s,
            child: child,
          );
        },
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [accent, accent.withOpacity(0.85)],
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
