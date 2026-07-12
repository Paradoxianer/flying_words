import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../game_internals/bible_reference.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/scriptorium_text.dart';
import 'bible_api_client.dart';
import 'bolls_books.dart';
import 'custom_verses_controller.dart';

/// Opens the "add your own verse" picker. Returns true if a verse was added.
Future<bool?> showVersePicker(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: context.read<CustomVersesController>()),
        ChangeNotifierProvider.value(value: context.read<PlayerProgress>()),
        Provider.value(value: context.read<Palette>()),
      ],
      child: const VersePickerDialog(),
    ),
  );
}

/// Lets the player choose a book, chapter and verse (range) and fetches the
/// text via the Bible API to add it as a custom verse (#15).
class VersePickerDialog extends StatefulWidget {
  const VersePickerDialog({super.key});

  @override
  State<VersePickerDialog> createState() => _VersePickerDialogState();
}

class _VersePickerDialogState extends State<VersePickerDialog> {
  // Book codes ordered by their canonical number (language-independent).
  static final List<String> _books = bollsBookNumbers.keys.toList()
    ..sort((a, b) => bollsBookNumbers[a]!.compareTo(bollsBookNumbers[b]!));

  String _book = 'JHN';
  final _chapter = TextEditingController(text: '3');
  final _from = TextEditingController(text: '16');
  final _to = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _chapter.dispose();
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  Future<void> _add(AppLocalizations l10n, Map<String, String> bookNames,
      Locale locale) async {
    final chapter = int.tryParse(_chapter.text.trim());
    final from = int.tryParse(_from.text.trim());
    final to = _to.text.trim().isEmpty ? null : int.tryParse(_to.text.trim());
    if (chapter == null || from == null || (to != null && to < from)) {
      setState(() => _error = l10n.invalidChapterVerse);
      return;
    }

    final reference = BibleReference(
        book: _book, chapter: chapter, verseStart: from, verseEnd: to);
    // English cites "Book Chapter:Verse", German "Book Chapter, Verse" (#2).
    final separator = locale.languageCode == 'en' ? ':' : ', ';
    final display = '${bookNames[_book]} $chapter$separator$from'
        '${to != null && to > from ? '-$to' : ''}';

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<CustomVersesController>().addFromReference(
            reference: reference,
            display: display,
            progress: context.read<PlayerProgress>(),
          );
      if (mounted) Navigator.pop(context, true);
    } on VerseFetchException catch (e) {
      setState(() => _error = l10n.verseFetchFailed(e.message));
    } catch (e) {
      setState(() => _error = l10n.genericError('$e'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final bookNames = bookNamesFor(locale);
    return AlertDialog(
      backgroundColor: palette.parchmentLight,
      title: Text(l10n.addOwnVerseTitle,
          style: ScriptoriumText.heading
              .copyWith(fontSize: 24, color: palette.inkFullOpacity)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            key: const Key('book-dropdown'),
            initialValue: _book,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.book),
            items: [
              for (final code in _books)
                DropdownMenuItem(value: code, child: Text(bookNames[code]!)),
            ],
            onChanged: _loading
                ? null
                : (value) => setState(() => _book = value ?? _book),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('chapter-field'),
                  controller: _chapter,
                  keyboardType: TextInputType.number,
                  enabled: !_loading,
                  decoration: InputDecoration(labelText: l10n.chapter),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const Key('from-field'),
                  controller: _from,
                  keyboardType: TextInputType.number,
                  enabled: !_loading,
                  decoration: InputDecoration(labelText: l10n.verseLabel),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const Key('to-field'),
                  controller: _to,
                  keyboardType: TextInputType.number,
                  enabled: !_loading,
                  decoration: InputDecoration(labelText: l10n.toOptional),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                key: const Key('picker-error'),
                style: ScriptoriumText.verse.copyWith(color: palette.sealRed)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _loading ? null : () => _add(l10n, bookNames, locale),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.add),
        ),
      ],
    );
  }
}
