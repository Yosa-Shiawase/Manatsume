import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manatsume/theme.dart';
import 'package:manatsume/services/settings_service.dart';
import 'package:manatsume/services/playlist_service.dart';
import 'package:manatsume/services/like_service.dart';
import 'package:manatsume/services/library_service.dart';
import 'package:manatsume/features/search/search_page.dart';
import 'package:manatsume/features/library/library_page.dart';
import 'package:manatsume/features/home/home_page.dart';
import 'package:manatsume/features/player/player_page.dart';
import 'package:manatsume/features/settings/settings_page.dart';
import 'package:manatsume/features/about/about_page.dart';

class ManatsumeApp extends StatefulWidget {
  const ManatsumeApp({super.key, required this.settings});
  final SettingsService settings;

  @override
  State<ManatsumeApp> createState() => _ManatsumeAppState();
}

class _ManatsumeAppState extends State<ManatsumeApp> {
  late final PlaylistService playlists;
  late final LikeService likes;
  late final LibraryService library;

  @override
  void initState() {
    super.initState();
    playlists = PlaylistService();
    likes = LikeService();
    library = LibraryService();
  }

  @override
  void dispose() {
    playlists.dispose();
    likes.dispose();
    library.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the settings service so a theme change made on the
    // Settings page rebuilds the MaterialApp (and thus re-themes the
    // whole app) immediately, not just after an app restart.
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) => MaterialApp(
        title: 'Manatsume',
        debugShowCheckedModeBanner: false,
        themeMode: widget.settings.readTheme(),
        theme: ManatsumeTheme.light,
        darkTheme: ManatsumeTheme.dark,
        home: const ManatsumeShell(),
      ),
    );
  }
}

class ManatsumeShell extends StatefulWidget {
  const ManatsumeShell({super.key});

  @override
  State<ManatsumeShell> createState() => _ManatsumeShellState();
}

class _ManatsumeShellState extends State<ManatsumeShell> {
  int _tab = 0;

  void _setTab(int tab) {
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          HomePage(
            onStart: () => _setTab(3),
            onSearch: () => _setTab(1),
          ),
          const SearchPage(),
          const LibraryPage(),
          const PlayerPage(),
          const SettingsPage(),
          const AboutPage(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        current: _tab,
        onTap: _setTab,
        accent: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _BottomNav extends StatefulWidget {
  const _BottomNav({
    super.key,
    required this.current,
    required this.onTap,
    required this.accent,
  });
  final int current;
  final void Function(int) onTap;
  final Color accent;

  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = const [
      (icon: Icons.home_outlined, active: Icons.home, label: 'Home'),
      (icon: Icons.search_outlined, active: Icons.search, label: 'Search'),
      (icon: Icons.library_music_outlined, active: Icons.library_music, label: 'Library'),
      (icon: Icons.play_arrow, active: Icons.play_arrow, label: 'Player'),
      (icon: Icons.settings_outlined, active: Icons.settings, label: 'Settings'),
      (icon: Icons.info_outlined, active: Icons.info, label: 'About'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final selected = index == widget.current;
              return _NavButton(
                icon: items[index].icon,
                activeIcon: items[index].active,
                label: items[index].label,
                selected: selected,
                accent: widget.accent,
                surface: theme.colorScheme.surface,
                onTap: () => widget.onTap(index),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.surface,
    required this.onTap,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final Color accent;
  final Color surface;
  final VoidCallback onTap;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    if (widget.selected) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _NavButton old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      _ctrl.forward(from: 0.0);
    } else if (!widget.selected && old.selected) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: GestureDetector(
        onTapDown: (_) {
          if (!widget.selected) {
            HapticFeedback.lightImpact();
          }
        },
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final scale = 1.0 + (widget.selected ? 0.08 * _ctrl.value : 0.0);
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.selected
                  ? widget.accent.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.selected)
                  IgnorePointer(
                    child: CustomPaint(
                      size: const Size(56, 56),
                      painter: _NavGlow(
                        progress: _ctrl.value,
                        color: widget.accent,
                      ),
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) {
                    return ScaleTransition(scale: anim, child: child);
                  },
                  child: Icon(
                    widget.selected ? widget.activeIcon : widget.icon,
                    key: ValueKey(widget.selected),
                    size: 24,
                    color: widget.selected
                        ? widget.accent
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavGlow extends CustomPainter {
  _NavGlow({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.6;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.5 * progress),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _NavGlow other) =>
      other.progress != progress || other.color != color;
}
