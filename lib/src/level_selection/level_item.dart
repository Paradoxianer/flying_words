import 'package:flutter/material.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../jokers/joker_type.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';
import 'joker_picker.dart';
import 'wax_seal.dart';

/// One verse in the level selection: a parchment card with the verse,
/// the three wax seals (difficulties), the earned stars and best times.
/// The eye toggle starts the next run with the verse text hidden, so the
/// blind bonus can be chosen before the clock runs (#27 follow-up).
class LevelItem extends StatefulWidget {
  final Lesson level;
  const LevelItem(this.level, {super.key});

  @override
  State<LevelItem> createState() => _LevelItemState();
}

class _LevelItemState extends State<LevelItem> {
  bool _blind = false;
  final Set<JokerType> _selectedJokers = {};

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;
    final progress = context
        .watch<PlayerProgress>()
        .progressForVerse(verseProgressKey(widget.level));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: palette.parchmentLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: palette.inkFullOpacity.withValues(alpha: 0.18),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.level.verse,
                    style: ScriptoriumText.verseRef
                        .copyWith(color: palette.inkFullOpacity),
                  ),
                ),
                // Choose the blind run here, before the clock is ticking.
                Tooltip(
                  message: _blind ? l10n.blindOn : l10n.blindOff,
                  child: InkWell(
                    onTap: () => setState(() => _blind = !_blind),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        _blind ? Icons.visibility_off : Icons.visibility,
                        key: Key(
                            'blind-${widget.level.number}-${_blind ? 'on' : 'off'}'),
                        size: 24,
                        color: _blind ? palette.gold : palette.inkFaded,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.level.text,
              style: ScriptoriumText.verse
                  .copyWith(fontSize: 14, color: palette.inkFaded),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final difficulty in Difficulty.values)
                  WaxSeal(
                    key: Key('seal-${widget.level.number}-${difficulty.name}'),
                    difficulty: difficulty,
                    progress: progress,
                    onPressed: () {
                      final audioController = context.read<AudioController>();
                      audioController.playSfx(SfxType.buttonTap);
                      final query = <String, String>{
                        if (_blind) 'blind': '1',
                        if (_selectedJokers.isNotEmpty)
                          'jokers': _selectedJokers.map((j) => j.name).join(','),
                      };
                      final queryString = query.isEmpty
                          ? ''
                          : '?${query.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
                      GoRouter.of(context).go(
                          '/play/session/${widget.level.number}/${difficulty.name}'
                          '$queryString');
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 1,
              color: palette.gold.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 10),
            // Jokers are chosen here, before the round starts (#53) - there
            // is no time to activate them once the words start flying.
            JokerPicker(
              selected: _selectedJokers,
              onToggle: (type) => setState(() {
                if (!_selectedJokers.remove(type)) {
                  _selectedJokers.add(type);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
