const UNTITLED = 'untitled';

abstract class ReferenceItem {
  String get title;
  List<String> get tags;
  String get content;
  bool get isUntitled;

  ReferenceItem copyWith({
    String content,
    String title,
    List<String> tags,
  });
}
