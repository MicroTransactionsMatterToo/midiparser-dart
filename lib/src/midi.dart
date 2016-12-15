
import "events.dart";
import "parse.dart";


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
  Iterator<dynamic> get iterator {
    return this.events.iterator;
  }


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
    } else {
      this.events.add(item);
    }
  }

  String toString() => this.events.toString();
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
    this.data = new List.from(data, growable: true);
    this.state = LexState.EXPECT_HEADER;
    this.parsed = new MIDIData();
    this.currentIndex = 0;
    this.originalData = new List.from(data, growable: false);
  }

  // Actual Parsing function
  /// Parses using current internal data
  parse() {
    while (this.data.length > 1) {
      switch (this.state) {
        case LexState.EXPECT_HEADER:
          this.parsed.fileHeader = parse_file_header(this.data);
          this.state = LexState.EXPECT_CHUNK;
          break;
        case LexState.EXPECT_CHUNK:
          this.parsed.tracks.add(parse_track_header(this.data));
          this.nextHeaderOffset =
              this.parsed.tracks.last.length + this.getCurrentIndex();
          this.state = LexState.EXPECT_TRACK_EVENT;
          break;
        case LexState.EXPECT_TRACK_EVENT:
          this.parseTrackEvent();
          break;
        case LexState.DONE:
          break;
      }
    }
  }

  /// Called internally, when parsing an ambiguous in-track event
  parseTrackEvent() {
    int time = parse_variable_length(this.data);
    int currentByte = this.data[0];
    int currentMessage = currentByte & 0xF0;
    int currentChannel = currentByte & 0x0F;
    switch (currentMessage) {
      // NoteOff
      case 0x80:
        var data = parse_two_uint7(this.data);

        // New NoteOff
        NoteOff note = new NoteOff(data[1], data[0], time, currentChannel);
        // Write into this
        this.parsed.add(note);
        break;
      // NoteOn
      case 0x90:
        var data = parse_two_uint7(this.data);
        // New NoteOn
        NoteOn note = new NoteOn(data[1], data[0], time, currentChannel);
        // Write
        this.parsed.add(note);
        break;
      // PolyphonicAfterTouch
      case 0xA0:
        int pitch = parse_uint7(this.data);
        int pressure = parse_uint7(this.data);

        PolyPhonicAfterTouch pressureEvent = new PolyPhonicAfterTouch(pressure, pitch, time, currentChannel);
        this.parsed.add(pressureEvent);
        break;
      // Pitch Wheel
      case 0xE0:
        PitchWheelEvent pitchWheelEvent = parse_pitch_wheel(this.data, currentChannel);
        this.parsed.add(pitchWheelEvent);
        break;
      default:
        break;
    }
  }


  /// Get offset from origin of file
  int getCurrentIndex () {
    int diff = (this.originalData.length - this.data.length);
    return diff;
  }
}
