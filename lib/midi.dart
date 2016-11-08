import "dart:io";

import "src/parse.dart";
import "src/events.dart";


// Lexer State enum
enum LexState {
  EXPECT_HEADER,
  EXPECT_CHUNK,
  EXPECT_TRACK_EVENT,
  DONE
}

class MIDIData {
  List<PitchWheelEvent> wheelEvents;
  ChunkHeader fileHeader;
  List<TrackHeader> tracks;

  MIDIData() {
    this.wheelEvents = new List<PitchWheelEvent>();
    this.tracks = new List<TrackHeader>();
  }
}

// The Parser itself
class Parser {
  LexState state;
  List<int> data;
  int nextHeaderOffset;
  MIDIData parsed;

  // Constructor
  Parser(List<int> data) {
    this.data = data;
    this.state = LexState.EXPECT_HEADER;
    this.parsed = new MIDIData();
  }

  // Actual Parsing function
  Parse() {
    switch (state) {
      case LexState.EXPECT_HEADER:
        this.parsed.fileHeader = parse_chunk_header(data);
        break;
      case LexState.EXPECT_CHUNK:
        this.parsed.tracks.add(parse_chunk_header(data));
    }
  }
}

// Entry point
main() async {
  var file = new File("../Chrono Trigger - 1000 AD.mid");
  var contents;

  contents = await file.readAsBytes();
  contents = new List.from(contents);
  var gg = new Parser(contents);
  print(gg.data);
  print(parse_file_header(contents));
  print(contents.runtimeType);
}