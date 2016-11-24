import "dart:io";

import "package:midiparser/src/parse.dart";
import "package:midiparser/src/events.dart";


// Lexer State enum
enum LexState {
  EXPECT_HEADER,
  EXPECT_CHUNK,
  EXPECT_TRACK_EVENT,
  DONE
}

class MIDIData {
  List<PitchWheelEvent> wheelEvents;
  MIDIHeader fileHeader;
  List<TrackHeader> tracks;
  List<NoteEvent> notes;
  List<dynamic> events;
  List<PolyPhonicAfterTouch> pressureChanges;

  MIDIData() {
    this.wheelEvents = new List<PitchWheelEvent>();
    this.tracks = new List<TrackHeader>();
    this.notes = new List<NoteEvent>();
    this.events = new List<dynamic>();
    this.pressureChanges = new List<PolyPhonicAfterTouch>();
  }

  void add(dynamic item) {
    // Type Checking
    if (item is NoteEvent) {
      this.notes.add(item);
      this.events.add(item);
    }
    else if (item is PolyPhonicAfterTouch) {
      this.pressureChanges.add(item);
      this.events.add(item);
    }
  }
}

// The Parser itself
/// MIDI Parser
///
/// `state` is this instances current point of parsing
/// `data` is the raw bytes read from the file
/// `nextHeaderOffset` is the amount of bytes till the next
/// expected header
/// `parsed` is all `TrackEvents` that have been parsed so far
/// `currentIndex` is the current byte being parsed relative to the first byte of the file
/// `originalData` is an ungrowable list based on the original data passed. This is used to calculate offsets
class Parser {
  LexState state;
  List<int> data;
  int nextHeaderOffset;
  MIDIData parsed;
  int currentIndex;
  List<int> originalData;

  // Constructor
  /// Constructor
  Parser(List<int> data) {
    this.data = data;
    this.state = LexState.EXPECT_HEADER;
    this.parsed = new MIDIData();
    this.currentIndex = 0;
    this.originalData = new List.from(data, growable: false);
  }

  // Actual Parsing function
  /// Parses using current internal data
  Parse() {
    switch (this.state) {
      case LexState.EXPECT_HEADER:
        this.parsed.fileHeader = parse_file_header(this.data);
        this.state = LexState.EXPECT_CHUNK;
        break;
      case LexState.EXPECT_CHUNK:
        this.parsed.tracks.add(parse_track_header(this.data));
        this.nextHeaderOffset = this.parsed.tracks.last.length + this.GetCurrentIndex();
        this.state = LexState.EXPECT_TRACK_EVENT;
        break;
      case LexState.EXPECT_TRACK_EVENT:
        this.ParseTrackEvent();
        break;
      case LexState.DONE:
        break;
    }
  }

  /// Called internally, when parsing an ambiguous in-track event
  ParseTrackEvent() {
    int time = parse_variable_length(this.data);
    int currentByte = this.data[0];
    switch (currentByte) {
      // NoteOff
      case 0x8:
        int pitch = parse_uint7(this.data);
        int velocity = parse_uint7(this.data);
        // New NoteOff
        NoteOff note = new NoteOff(pitch, velocity, time);
        // Write into this
        this.parsed.add(note);
        break;
      // NoteOn
      case 0x9:
        int pitch = parse_uint7(this.data);
        int velocity = parse_uint7(this.data);
        // New NoteOn
        NoteOn note = new NoteOn(pitch, velocity, time);
        // Write
        this.parsed.add(note);
        break;
      // PolyphonicAfterTouch
      case 0xA:
        int pitch = parse_uint7(this.data);
        int pressure = parse_uint7(this.data);

        PolyPhonicAfterTouch pressureEvent = new PolyPhonicAfterTouch(pressure, pitch, time);
        this.parsed.add(pressureEvent);
        break;
      // Pitch Wheel
      case 0xE:
        PitchWheelEvent pitchWheelEvent = parse_pitch_wheel(this.data);
        this.parsed.add(pitchWheelEvent);
        break;
      default:
        break;
    }
  }


  /// Get offset from origin of file
  int GetCurrentIndex () {
    int diff = (this.originalData.length - this.data.length);
    return diff;
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
  print(parse_variable_length(contents));
  gg = new NoteOn(3, 3, 3);
}