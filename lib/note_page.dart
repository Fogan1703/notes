import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notes/custom_app_bar.dart';
import 'package:notes/database.dart';
import 'package:notes/elevated_icon_button.dart';
import 'package:notes/note.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class NotePage extends StatefulWidget {
  final Note? note;

  const NotePage({
    this.note,
    Key? key,
  }) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final FocusNode _textFocusNode = FocusNode();

  late final TextEditingController _titleController;
  late final TextEditingController _textController;

  late Color _color;
  late bool _pinned;

  late bool _unsavedChanges;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note?.title);
    _textController = TextEditingController(text: widget.note?.content);
    _color = widget.note?.color ?? defaultNoteColor;
    _pinned = widget.note?.pinned ?? false;

    _unsavedChanges = widget.note == null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final now = DateTime.now();
    final date = widget.note?.editTime ?? now;
    final difference = now.difference(date);
    final lastChanges = DateFormat((difference.inDays >= 365
                ? 'MMMM d, y - '
                : difference.inDays >= 7
                    ? 'MMMM d - '
                    : difference.inDays > 0
                        ? 'EEE, '
                        : '') +
            'kk:mm')
        .format(date);

    return Scaffold(
      bottomSheet: BottomAppBar(
        color: theme.colorScheme.secondary,
        child: Row(
          children: [
            IconButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setStateSheet) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                localizations.color,
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: noteColors.map((color) {
                                  return ColorRadioButton(
                                    color: color,
                                    groupColor: _color,
                                    onSelected: (color) {
                                      setStateSheet(() {
                                        setState(() {
                                          _color = color;
                                          _unsavedChanges = true;
                                        });
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              icon: const Icon(Icons.palette_outlined),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _pinned = !_pinned;
                  _unsavedChanges = true;
                });
              },
              icon: _pinned
                  ? const Icon(Icons.star)
                  : const Icon(Icons.star_border),
            ),
            Expanded(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: localizations.lastChanges,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: lastChanges,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete_outlined),
                          title: Text(localizations.delete),
                          onTap: () {
                            if (widget.note?.id != null) {
                              Provider.of<DatabaseModel>(
                                context,
                                listen: false,
                              ).deleteNote(widget.note!);
                            }
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.copy),
                          title: Text(localizations.createCopy),
                          onTap: () async {
                            final database = Provider.of<DatabaseModel>(
                              context,
                              listen: false,
                            );
                            final note = Note(
                              title: _titleController.text,
                              content: _textController.text,
                              color: _color,
                              editTime: DateTime.now(),
                              pinned: _pinned,
                            );
                            database.saveNote(note.copyWith(
                              id: widget.note?.id,
                            ));
                            Navigator.of(context).pop();
                            final newNote = note.copyWith(
                              id: await database.insertNote(note),
                            );
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NotePage(note: newNote)),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.share),
                          title: Text(localizations.share),
                          onTap: () {
                            Navigator.of(context).pop();
                            Share.share(_textController.text);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
      body: Container(
        color: _color,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            CustomAppBar(
              leading: ElevatedIconButton(
                onPressed: () {
                  if (_unsavedChanges) {
                    showDialog<bool>(
                      context: context,
                      builder: (context) => const SaveChangesDialog(),
                    ).then((save) {
                      if (save != null) {
                        if (save) {
                          onSave();
                        }
                        Navigator.of(context).pop();
                      }
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.arrow_back),
              ),
              actions: [
                ElevatedIconButton(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_outlined),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _unsavedChanges = true;
                        });
                      },
                      controller: _titleController,
                      autofocus: true,
                      style: GoogleFonts.nunito(
                        fontSize: 30,
                        height: 1.3,
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: localizations.title,
                      ),
                      maxLines: null,
                      onSubmitted: (value) => _textFocusNode.requestFocus(),
                    ),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _unsavedChanges = true;
                        });
                      },
                      controller: _textController,
                      focusNode: _textFocusNode,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        height: 1.3,
                      ),
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: localizations.text,
                      ),
                      maxLines: null,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onSave() {
    if (_unsavedChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          content: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.noteSaved,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar,
                child: const Text('OK'),
              )
            ],
          ),
        ),
      );

      Provider.of<DatabaseModel>(context, listen: false).saveNote(
        Note(
          id: widget.note?.id,
          title: _titleController.text,
          content: _textController.text,
          color: _color,
          editTime: DateTime.now(),
          pinned: _pinned,
        ),
      );
    }

    setState(() {
      _unsavedChanges = false;
    });
  }
}

class ColorRadioButton extends StatelessWidget {
  final Color color;
  final Color groupColor;
  final Function(Color) onSelected;

  const ColorRadioButton({
    required this.color,
    required this.groupColor,
    required this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          if (color != groupColor) {
            onSelected(color);
          }
        },
        child: Container(
          width: 40,
          height: 40,
          child: color == groupColor ? const Icon(Icons.done) : null,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white60,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class SaveChangesDialog extends StatelessWidget {
  const SaveChangesDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info),
            const SizedBox(height: 20),
            Text(
              localizations.saveChanges,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 23,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 110,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop<bool>(false),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.red,
                      ),
                    ),
                    child: Text(
                      localizations.discard,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop<bool>(true),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF30BE71),
                      ),
                    ),
                    child: Text(
                      localizations.save,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
