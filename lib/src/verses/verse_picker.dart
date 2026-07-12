import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  // Book codes ordered by their canonical number.
  static final List<String> _books = germanBookNames.keys.toList()
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

  Future<void> _add() async {
    final chapter = int.tryParse(_chapter.text.trim());
    final from = int.tryParse(_from.text.trim());
    final to = _to.text.trim().isEmpty ? null : int.tryParse(_to.text.trim());
    if (chapter == null || from == null || (to != null && to < from)) {
      setState(() => _error = 'Bitte gültige Kapitel-/Versangaben eingeben.');
      return;
    }

    final reference = BibleReference(
        book: _book, chapter: chapter, verseStart: from, verseEnd: to);
    final display = '${germanBookNames[_book]} $chapter, $from'
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
      setState(() => _error = 'Vers konnte nicht geladen werden: ${e.message}');
    } catch (e) {
      setState(() => _error = 'Fehler: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return AlertDialog(
      backgroundColor: palette.parchmentLight,
      title: Text('Eigenen Vers hinzufügen',
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
            decoration: const InputDecoration(labelText: 'Buch'),
            items: [
              for (final code in _books)
                DropdownMenuItem(
                    value: code, child: Text(germanBookNames[code]!)),
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
                  decoration: const InputDecoration(labelText: 'Kapitel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const Key('from-field'),
                  controller: _from,
                  keyboardType: TextInputType.number,
                  enabled: !_loading,
                  decoration: const InputDecoration(labelText: 'Vers'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const Key('to-field'),
                  controller: _to,
                  keyboardType: TextInputType.number,
                  enabled: !_loading,
                  decoration: const InputDecoration(labelText: 'bis (optional)'),
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
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _loading ? null : _add,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Hinzufügen'),
        ),
      ],
    );
  }
}
