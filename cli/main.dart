import 'dart:io';

import 'package:midiparser/midiparser.dart';

main() {
  var file = new File("../Chrono Trigger - 1000 AD.mid");
  List<int> contents;

  contents = file.readAsBytesSync();
  contents = new List.from(contents);
  Parser parser = new Parser();
}