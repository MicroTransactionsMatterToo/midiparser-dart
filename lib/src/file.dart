import 'events.dart';
import 'midi.dart';
import 'parse.dart';
import 'notes.dart';


class MIDIFile {
  List<Track> tracks;
  Map<String, Track> trackNames;
  int PPQ;


  MIDIFile(int PPQ) {
    this.tracks = new List<Track>();
    this.trackNames = new Map<String, Track>();
    this.PPQ = PPQ;
  }

  void addNewTrack(String name) {
    Track temp = new Track();
    this.trackNames[name] = temp;
    this.tracks.add(this.trackNames[name]);
  }

  void deleteTrack(String name) {
    int trackIndex = this.tracks.indexOf(this.trackNames[name]);
    this.tracks.removeAt(trackIndex);
    this.trackNames.remove(name);
  }

  List<int> toBytes() {
    int headerBytes = 0;
    int type;

    List<int> tempUnits = "MThd".codeUnits;
    for (var byte in tempUnits) {
      headerBytes <<= 8;
      headerBytes += byte;
    }

    if (this.tracks.length > 1) {
      type = 1;
    } else {
      type = 2;
    }

    headerBytes <<= 32;
    headerBytes += 6;

    headerBytes <<= 16;
    headerBytes += type;

    headerBytes <<= 16;
    headerBytes += this.tracks.length;

    headerBytes <<= 16;
    headerBytes += this.PPQ;



    List<int> returnValues = new List<int>();

    returnValues.add(headerBytes);

    for (var track in this.tracks) {
      var temp = track.toBytes();
      for (var bytes in temp) {
        returnValues.add(bytes);
      }
    }

    return returnValues;
  }
}

class Track {
  List<dynamic> events;
  int byteLength;

  Track() {
    this.byteLength = 0;
    this.events = new List<dynamic>();
  }

  void add(dynamic item) {
    int tempLength = item.toBytes();
    tempLength = tempLength.toRadixString(16).length ~/ 2;
    this.byteLength += tempLength;
    this.events.add(item);
  }

  List<int> toBytes() {
    int rval = 0;
    List<int> type = "MTrk".codeUnits;
    for (var byte in type) {
      rval <<= 8;
      rval += byte;
    }
    rval <<= 32;
    rval += this.byteLength;
    List<int> returnValues = new List<int>();

    returnValues.add(rval);


    var eventIterator = events.iterator;
    while(eventIterator.moveNext()) {
      returnValues.add(eventIterator.current.toBytes());
    }

    return returnValues;
  }
}
