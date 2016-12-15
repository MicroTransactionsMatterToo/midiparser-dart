import 'package:midiparser/midiparser.dart';
import 'dart:io';

main() async {
  var outFile = new File("./MEMES.mid");
  var gg = new MIDIFile(480);
  gg.addNewTrack("h");
  gg.addNewTrack("S");
  print(gg.tracks);
  print(gg.trackNames["h"]);
  gg.tracks[0].add(new NoteOn(20, 30, 2, 1));
  gg.tracks[1].add(new NoteOn(20, 30, 2, 1));
  print(gg.tracks[0].toBytes());
  for (var byte in gg.toBytes()) {
    print(byte);
    outFile.writeAsBytes([byte], mode: FileMode.APPEND, flush: true);
  }
}


String binary(int n) {
  if(n<0) return "0";
  if(n==0) return "0";
  String res="";
  while(n>0) {
    res=(n%2).toString()+res;
    n= n~/2;
  }
  return res;
}
