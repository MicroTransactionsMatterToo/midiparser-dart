import 'package:midiparser/midiparser.dart';

main() {
  var gg = new MIDIHeader(6, FileType.MULTI_TRACK, 90, 2);
  print(binary(gg.toBytes()));
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
