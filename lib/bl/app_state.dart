import 'package:flutter/material.dart';
import 'note.dart';
import 'note_store.dart';

class AppState extends ChangeNotifier {
  Note _current;
  bool _edit = false;
  final NoteStore store;

  Note get current => _current;

  set current(Note n) {
    _current = n;
    notifyListeners();
  }

  get edit => _edit;

  AppState(this.store);

  toggleEdit() {
    if (edit) {
      // if we were currently editing, save file before existing edit mode
      _saveCurrent();
    }
    _edit = !_edit;
    notifyListeners();
  }

  /// update WITHOUT notifying listeners, useful as textfields maintain their own
  /// state of the text so we don't want to keep rebuilding them as the content is edited
  /// due to them listening to changes to the app state
  updateCurrentContent(String text) {
    _current = _current.copyWith(content: text);
  }

  void _saveCurrent() {
    store.saveFile(_current.filename, _current.content);
  }
}