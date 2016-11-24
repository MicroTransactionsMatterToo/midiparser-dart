/// Chunk Header Type
///
/// Consists of the 2 currently valid headers
enum HeaderType {
  FILE_HEADER,
  TRACK_HEADER
}

/// File structure
///
/// Whether this file consists of one track, multiple tracks, or
/// multiple files
enum FileType {
  SINGLE_TRACK,
  MULTI_TRACK,
  MULTI_FILE
}


/// Format of time
///
/// System used for MIDI delta values
enum TimeFormat {
  METRIC_TIME_FORMAT,
  SMPTE_TIME_FORMAT
}

/// A pitch wheel event
///
/// `this.relative` is the pitch value relative to the center value
/// `this.absolute` is the pitch value, regarding the lowest possible pitch as 0
class PitchWheelEvent {
  int relative;
  int absolute;
  int time;

  /// Generic Constructor
  PitchWheelEvent(this.relative, this.absolute);
}

/// Represents a MIDI File Header
///
/// Please refer to the SMF docs for more info on the structure
class MIDIHeader {
  int length;
  int timeDivision;
  int tracks;
  int ticksPerQuarterNote;
  TimeFormat timeFormat;
  FileType type;

  /// Constructor
  ///
  /// Writes defaults and emtpy arrays
  MIDIHeader(int length, FileType type, int timeDivision, int tracks) {
    // Write stuff
    this.length = length;
    this.tracks = tracks;

    // Proccess timeDivision
    if (timeDivision & 0x8000 == 0x0000) {
      this.timeFormat = TimeFormat.METRIC_TIME_FORMAT;
      this.ticksPerQuarterNote = timeDivision & 0x7FFF;
      this.timeDivision = timeDivision;
    } else {
      throw new UnsupportedError("SMPTE Timecodes are not currently supported");
    }

    // Write more stuff
    this.type = type;
  }

  String toString() {
    var rval = "Length: $length; Type: ${type}; Time: $timeDivision; Ticks per quarter note: $ticksPerQuarterNote; Time format: $timeFormat";
    return rval;
  }
}

/// Represents a Tracks header
///
/// `this.length` refers to the bytes in this tracks data
class TrackHeader {
  int length;
  HeaderType type;

  TrackHeader(this.length, this.type);

  /// Implements String conversion
  String toString() {
    var rval = "Length: $length; Type: ${type.runtimeType}";
    return rval;
  }
}

/// Generic for any event occuring in a track
class TrackEvent {
  int rawType;
  String evaluatedType;
  List<dynamic> fields;

  TrackEvent(int bytes) {
    switch (bytes) {
    // Note Events
      case 0x8:
        this.rawType = bytes;
        this.evaluatedType = "NoteOff";
    }
  }
}

// Generic for Notes
/// Generic for Notes
class NoteEvent {

}

/// NoteOn MIDI Message
class NoteOn extends NoteEvent {
  int pitch;
  int velocity;
  int time;

  NoteOn(this.pitch, this.velocity, this.time);
}


/// NoteOff MIDI Message
class NoteOff extends NoteEvent {
  int pitch;
  int velocity;
  int time;

  NoteOff(this.pitch, this.velocity, this.time);
}

// Polyphonic Event
class PolyPhonicAfterTouch {
  int time;
  int pressure;
  int pitch;

  PolyPhonicAfterTouch(this.pressure, this.pitch, this.time);
}

// Control Change

class ControlChange {
  int time;
  int controller;
  int value;

  ControlChange(this.controller, this.time, this.value);
}

class ChannelAfterTouch {
  int time;
  int pressure;
  int pitch;
  int controller;

  ChannelAfterTouch(this.controller, this.time, this.pitch, this.pressure);
}

