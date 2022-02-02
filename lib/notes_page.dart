import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/custom_app_bar.dart';
import 'package:notes/database.dart';
import 'package:notes/note.dart';
import 'package:notes/note_page.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const NotePage(),
          ));
        },
        child: const Icon(
          Icons.add,
          size: 32,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            CustomAppBar(
              leading: Text(
                localizations.notes,
                style: theme.textTheme.headline3,
              ),
              actions: [
                Hero(
                  tag: 'search',
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Material(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SizedBox(
                        child: IconButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SearchPage(),
                            ),
                          ),
                          icon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Note>>(
                future: Provider.of<DatabaseModel>(context).notes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Column(
                        children: [
                          const Spacer(flex: 1),
                          Image.asset('assets/no-notes.png'),
                          const SizedBox(height: 10),
                          Text(
                            localizations.createYourFirstNote,
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                            ),
                          ),
                          const Spacer(flex: 2),
                        ],
                      );
                    } else {
                      var notes = snapshot.data!;
                      notes.sort((a, b) => -a.editTime.compareTo(b.editTime));

                      final pinnedNotes = notes.where((note) => note.pinned);
                      final notPinnedNotes =
                          notes.where((note) => note.pinned == false);
                      notes = [...pinnedNotes, ...notPinnedNotes];

                      var notCardItemsPassed = 0;

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: pinnedNotes.isEmpty
                            ? notes.length
                            : notes.length + 2,
                        itemBuilder: (context, index) {
                          if (pinnedNotes.isNotEmpty) {
                            if (index == 0) {
                              notCardItemsPassed++;
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  top: 8,
                                  right: 8,
                                  bottom: 16,
                                ),
                                child: Text(
                                  localizations.pinned,
                                  style: GoogleFonts.nunito(),
                                ),
                              );
                            } else if (index == pinnedNotes.length - 1 + 2) {
                              notCardItemsPassed++;
                              return const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Divider(
                                  color: Colors.white54,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                              );
                            }
                          }
                          return NoteCard(
                            notes[index - notCardItemsPassed],
                            key: Key(notes[index - notCardItemsPassed]
                                .id
                                .toString()),
                          );
                        },
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteCard extends StatefulWidget {
  final Note note;

  const NoteCard(this.note, {Key? key}) : super(key: key);

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OpenContainer(
        tappable: false,
        middleColor: theme.scaffoldBackgroundColor,
        closedColor: widget.note.color,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        closedBuilder: (context, open) {
          return InkWell(
            onTap: () {
              if (_selected) {
                Provider.of<DatabaseModel>(
                  context,
                  listen: false,
                ).deleteNote(widget.note);
              } else {
                open();
              }
            },
            onLongPress: () {
              setState(() {
                _selected = !_selected;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _selected ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.delete,
                    size: 50,
                  ),
                ),
                AnimatedOpacity(
                  opacity: _selected ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.note.title.isNotEmpty)
                          Text(
                            widget.note.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              height: 1.5,
                            ),
                          ),
                        if (widget.note.content.isNotEmpty)
                          Text(
                            widget.note.content,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              height: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        openElevation: 0,
        openColor: theme.scaffoldBackgroundColor,
        openBuilder: (context, close) {
          return NotePage(note: widget.note);
        },
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = '';
  bool _showSearchBarContent = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _showSearchBarContent = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Hero(
                tag: 'search',
                child: SizedBox(
                  height: 50,
                  child: Material(
                    color: theme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: AnimatedOpacity(
                      opacity: _showSearchBarContent ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          const SizedBox(width: 40),
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              onChanged: (query) => setState(() {
                                _query = query;
                              }),
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: localizations.searchByTheKeyword,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: Navigator.of(context).pop,
                            icon: const Icon(
                              Icons.close,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Note>>(
                  future: Provider.of<DatabaseModel>(
                    context,
                    listen: true,
                  ).search(_query),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return const SizedBox();
                      case ConnectionState.done:
                        final notes = snapshot.data!;
                        notes.sort((a, b) => -a.editTime.compareTo(b.editTime));
                        if (notes.isNotEmpty) {
                          return ListView.builder(
                            padding: const EdgeInsets.only(top: 20),
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              return NoteCard(notes[index]);
                            },
                          );
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/note-not-found.png'),
                              const SizedBox(height: 5),
                              Text(
                                localizations.noteNotFoundTrySearchingAgain,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          );
                        }
                      default:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
