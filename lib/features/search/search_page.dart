import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manatsume/core/services.dart';
import 'package:manatsume/models/models.dart';
import 'package:manatsume/ui/motion.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _queryController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Rebuild whenever the text changes so the Search button enables itself.
    _queryController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _runSearch() {
    HapticFeedback.lightImpact();
    FocusManager.instance.primaryFocus?.unfocus();
    ServiceLocator.music.search(_queryController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Rebuild the whole page whenever MusicService notifies: searching spinners,
    // errors, results and per-tile play state all live on the service.
    return ListenableBuilder(
      listenable: ServiceLocator.music,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                          color: theme.colorScheme.onSurfaceVariant,
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
                      textInputAction: TextInputAction.search,
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
                        // Live search is intentionally not triggered on every
                        // keystroke; the listener above only repaints buttons.
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
                        onPressed: _queryController.text.trim().isEmpty
                            ? null
                            : _runSearch,
                        icon: ServiceLocator.music.searching
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search, size: 18),
                        label: Text(
                          ServiceLocator.music.searching
                              ? 'Searching…'
                              : 'Search',
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
                child: _StatusView(music: ServiceLocator.music),
              ),

              const Divider(height: 1),

              // results
              Expanded(
                child: _ResultsView(music: ServiceLocator.music),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({required this.music});
  final MusicService music;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (music.searching) {
      return SizedBox(
        height: 24,
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              'Searching…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    if (music.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.error.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber,
                  size: 20, color: theme.colorScheme.error),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  music.error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
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
  const _ResultsView({required this.music});
  final MusicService music;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tracks = music.results;
    final hasResults = tracks.isNotEmpty;

    if (!music.hasSearched && !music.searching) {
      return Center(
        child: Reveal(
          beginOffset: const Offset(0.0, 0.12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search,
                size: 56,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Search to find music',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Results come from the extractor pipeline.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (music.searching && tracks.isEmpty) {
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          for (var i = 0; i < 6; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Skeleton(height: 72, borderRadius: 14),
            ),
        ],
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
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'No results',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try a different query.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isCurrent = music.currentTrack?.id == track.id;
        final playing = isCurrent && music.playing;
        final delay = (40.0 * (index % 10)).clamp(0.0, 360.0);
        return Reveal(
          delay: delay,
          beginOffset: const Offset(0.0, 0.14),
          duration: const Duration(milliseconds: 360),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SearchResultTile(
              track: track,
              playing: playing,
              current: isCurrent,
            ),
          ),
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.track,
    required this.playing,
    required this.current,
  });
  final Track track;
  final bool playing;
  final bool current;

  void _togglePlay(MusicService music) {
    HapticFeedback.mediumImpact();
    if (current) {
      music.togglePlay();
    } else {
      music.play(track);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final border = theme.colorScheme.outline;
    final text = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final music = ServiceLocator.music;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _togglePlay(music),
        splashColor: accent.withOpacity(0.12),
        highlightColor: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: current ? accent.withOpacity(0.10) : surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: current ? accent.withOpacity(0.6) : border,
              width: current ? 1.0 : 0.5,
            ),
          ),
          child: Row(
            children: [
              // artwork
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: track.artwork != null && track.artwork!.isNotEmpty
                      ? AsyncImage(
                          url: track.artwork!,
                          width: 52,
                          height: 52,
                          radius: 10,
                        )
                      : _artFallback(theme),
                ),
              ),
              const SizedBox(width: 12),
              // info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: current ? accent : text,
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
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: muted,
                            ),
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
              const SizedBox(width: 8),
              // like (persisted through LikeService)
              ListenableBuilder(
                listenable: ServiceLocator.likes,
                builder: (context, _) {
                  final liked = ServiceLocator.likes.isLiked(track.id);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ServiceLocator.likes.toggle(track.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: liked
                            ? accent.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? accent : muted,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
              // play affordance
              GestureDetector(
                onTap: () => _togglePlay(music),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) {
                    return ScaleTransition(scale: anim, child: child);
                  },
                  child: music.buffering && current
                      ? SizedBox(
                          key: const ValueKey('buffer'),
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: accent,
                          ),
                        )
                      : Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                          key: ValueKey(playing),
                          color: accent,
                          size: playing ? 26 : 22,
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
