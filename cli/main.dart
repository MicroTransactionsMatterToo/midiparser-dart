import 'dart:io';

import '../lib/midiparser.dart';

main() {
  var file = new File("../Chrono Trigger - 1000 AD.mid");
  List<int> contents;

  contents = file.readAsBytesSync();
  contents = new List.from(contents);
  Parser parser = new Parser(contents);
  parser.parse();
  var gg = parser.parsed.iterator;
  while(gg.moveNext()) {
    print(gg.current);
  }
}