import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mknotes/bl/app_state.dart';
import 'package:mknotes/bl/pinboard_bookmarks.dart';
import 'package:mknotes/bl/pinboard_note_store.dart';
import 'package:mknotes/bl/reference_item.dart';
import 'package:mknotes/bl/localdir_note_store.dart';
import 'package:preferences/preference_service.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

import '../logging.dart';
import 'split_screen.dart';

class MainPage extends StatefulWidget {
  final String title;

  MainPage({@required this.title});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final AppState appState;

  // need to use factory constructor trick to initialise dependent finals
  // ref: https://stackoverflow.com/a/52964776/85472
  _MainPageState._(this.appState);

  factory _MainPageState() {
    // TODO: store as user pref and UI to  allow user to set
    final notesDir = Directory('./docs');
    final localStore = LocalDirNoteStore(notesDir: notesDir);
    final pinboardStore = PinboardNoteStore(
      username: PrefService.getString('pinboard_user'),
      token: PrefService.getString('pinboard_token'),
    );
    final bookmarks = PinboardBookmarks(
      username: PrefService.getString('pinboard_user'),
      token: PrefService.getString('pinboard_token'),
      cacheDir: notesDir,
    );
    final appState = AppState(localStore, bookmarks);
    appState.loadBookmarks();
    return _MainPageState._(appState);
  }

  @override
  void initState() {
    super.initState();
    _windowInfo();
    setWindowFrame(Rect.fromLTRB(1139.0, 517.0, 1861.0, 1125.0));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      builder: (BuildContext context, _) => Scaffold(
        appBar: AppBar(
          title: NoteTitle(
            title: (appState.current?.title ?? widget.title),
            editable: context.watch<AppState>().edit,
            onChanged: (text) =>
                context.read<AppState>().updateCurrentTitle(text),
          ),
          actions: [
            if (context.watch<AppState>().edit)
              IconButton(
                icon: Icon(Icons.save),
                onPressed: appState.toggleEdit,
              )
            else
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: appState.toggleEdit,
              )
          ],
        ),
        body: Center(
          child: SplitScreen(
            itemsList: appState.allItems,
            showItem: _showNote,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNote,
          tooltip: 'Add note',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void _addNote() {
    appState.newNote();
  }

  void _showNote(ReferenceItem selected) {
    Log().debug('SHOW: ${selected.title}');
    setState(() {
      appState.current = selected;
    });
  }

  void _windowInfo() async {
    final window = await getWindowInfo();
    Log().debug("initial window size: ${window.frame}");
  }
}

class NoteTitle extends StatelessWidget {
  final String title;
  final bool editable;
  final void Function(String) onChanged;

  const NoteTitle({Key key, this.editable, this.title, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return editable
        ? TextField(
            maxLines: 1,
            controller: TextEditingController()..text = title,
            onChanged: onChanged,
          )
        : Text(title);
  }
}
