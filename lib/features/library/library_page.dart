import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manatsume/models/models.dart';
import 'package:manatsume/services/service_locator.dart';
import 'package:manatsume/ui/motion.dart';
import 'package:manatsume/features/player/play_button.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _adding = false;

  void _addFiles() async {
    HapticFeedback.mediumImpact();
    setState(() => _adding = true);
    try {
      // Placeholder for file picker integration.
      // In a complete build this would open the device file picker and call
      // ServiceLocator.library.addFile for each selected audio file.
    } finally {
      if (mounted) setState(() => _adding = false);
    }
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
                child: Row(
                  children: [
                    Text(
                      'Library',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your own files',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackgroundVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 4),

            // add button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Reveal(
                delay: 60,
                beginOffset: const Offset(0.0, 0.1),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _adding ? null : _addFiles,
                    icon: _adding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add, size: 18),
                    label: Text(_adding ? 'Adding…' : 'Add files'),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // list
            Expanded(
              child: _LibraryList(
                adding: _adding,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _adding
          ? null
          : FloatingActionButton(
              onPressed: _addFiles,
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _LibraryList extends StatelessWidget {
  const _LibraryList({this.adding = false});
  final bool adding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final tracks = ServiceLocator.library.list;

    if (tracks.isEmpty && !adding) {
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
                'Your library is empty',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add your own music files.',
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
          return Reveal(
            delay: 30.0 * index,
            beginOffset: const Offset(0.0, 0.14),
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.outline, width: 0.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        // thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: track.thumbnailPath != null
                              ? Image.file(
                                  File(track.thumbnailPath!),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _artFallback(theme),
                                )
                              : _artFallback(theme),
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
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                track.artist,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    track.formattedDuration(),
                                    style: theme.textTheme.labelSmall,
                                  ),
                                  const Spacer(),
                                  Text(
                                    track.formattedSize(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // play affordance
                        GestureDetector(
                          onTap: () {},
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, anim) {
                              return ScaleTransition(scale: anim, child: child);
                            },
                            child: Icon(
                              Icons.play_arrow,
                              key: ValueKey(track.id),
                              color: accent,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _artFallback(ThemeData theme) {
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
}
