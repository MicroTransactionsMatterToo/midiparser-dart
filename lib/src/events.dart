/// Chunk Header Type
///
/// Consists of the 2 currently valid headers
enum HeaderType { FILE_HEADER, TRACK_HEADER }

/// File structure
///
/// Whether this file consists of one track, multiple tracks, or
/// multiple files
enum FileType { SINGLE_TRACK, MULTI_TRACK, MULTI_FILE }

/// Format of time
///
/// System used for MIDI delta values
enum TimeFormat { METRIC_TIME_FORMAT, SMPTE_TIME_FORMAT }

/// A pitch wheel event
///
/// `this.relative` is the pitch value relative to the center value
/// `this.absolute` is the pitch value, regarding the lowest possible pitch as 0
class PitchWheelEvent {
  int relative;
  int absolute;
  int time;
  int channel;

  /// Generic Constructor
  PitchWheelEvent(this.relative, this.absolute, this.channel);
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
    var rval =
        "Length: $length; Type: ${type}; Time: $timeDivision; Ticks per quarter note: $ticksPerQuarterNote; Time format: $timeFormat";
    return rval;
  }

  int toBytes() {
    var type = "MTrk".codeUnits;
    var length = this.length;
    var format = this.type.index;
    var ntracks = this.tracks;
    var division = this.timeDivision;
    var rval = 0;
    for (var byte in type) {
      rval <<= 8;
      rval += byte;
    }

    // Shift left 32 bits, then write the length
    rval <<= 32;
    rval += 6;

    // Shift left 16 and write the format
    rval <<= 16;
    rval += format;

    // Shift left 16 and write the number of tracks
    rval <<= 16;
    rval += ntracks;

    // Shift left 16 and right the timecode
    rval <<= 16;
    rval += division;


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

  int toBytes() {
    int rval = 0;
    List<int> type = "MTrk".codeUnits;
    for (var byte in type) {
      rval <<= 8;
      rval += byte;
    }
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

  String toString() => "Generic TrackEvent";
}

// Generic for Notes
/// Generic for Notes
abstract class NoteEvent {}

/// NoteOn MIDI Message
class NoteOn extends NoteEvent {
  int pitch;
  int velocity;
  int time;
  int channel;

  NoteOn(this.pitch, this.velocity, this.time, this.channel);

  String toString() =>
      "NoteOn Pitch: ${this.pitch}, Velocity: ${this.velocity}, Note Name: ${this.noteName()}";

  String noteName() {
    switch (this.pitch % 12) {
      case 0:
        return "C";
      case 1:
        return "C#";
      case 2:
        return "D";
      case 3:
        return "D#";
      case 4:
        return "E";
      case 5:
        return "F";
      case 6:
        return "F#";
      case 7:
        return "G";
      case 8:
        return "G#";
      case 9:
        return "A";
      case 10:
        return "A#";
      case 11:
        return "B";
      default:
        return "";
    }
  }

  /// Returns the correct bytes for use in a Standard MIDI File
  int toBytes() {
    if (channel > 15) {
      throw new ArgumentError.value(this.channel);
    }
    // Encode status bytes
    int statusByte = 8;
    statusByte <<= 4;
    statusByte += channel;
    // Encode data
    statusByte <<= 8;
    statusByte += this.pitch;
    statusByte <<= 8;
    statusByte += this.velocity;

    // Return it
    return statusByte;
  }
}

/// NoteOff MIDI Message
class NoteOff extends NoteEvent {
  int pitch;
  int velocity;
  int time;
  int channel;

  NoteOff(this.pitch, this.velocity, this.time, this.channel);

  String toString() =>
      "NoteOff Pitch: ${this.pitch}, Velocity: ${this.velocity}, Note Name: ${this.noteName()}";

  String noteName() {
    switch (this.pitch % 12) {
      case 0:
        return "C";
      case 1:
        return "C#";
      case 2:
        return "D";
      case 3:
        return "D#";
      case 4:
        return "E";
      case 5:
        return "F";
      case 6:
        return "F#";
      case 7:
        return "G";
      case 8:
        return "G#";
      case 9:
        return "A";
      case 10:
        return "A#";
      case 11:
        return "B";
      default:
        return "";
    }
  }

  /// Returns the correct bytes for use in a Standard MIDI File
  int toBytes() {
    if (channel > 15) {
      throw new ArgumentError.value(channel);
    }
    // Encode status bytes
    int statusByte = 9;
    statusByte <<= 4;
    statusByte += channel;
    // Encode data
    statusByte <<= 8;
    statusByte += this.pitch;
    statusByte <<= 8;
    statusByte += this.velocity;

    // Return it
    return statusByte;
  }
}

// Polyphonic Event
class PolyPhonicAfterTouch {
  int time;
  int pressure;
  int pitch;
  int channel;

  PolyPhonicAfterTouch(this.pressure, this.pitch, this.time, this.channel);

  String toString() =>
      "AfterTouch - Pressure: ${this.pressure}, Pitch: ${this.pitch}";

  /// Returns the correct bytes for use in a Standard MIDI File
  int toBytes() {
    if (channel > 15) {
      throw new ArgumentError.value(channel);
    }
    // Encode status bytes
    int statusByte = 9;
    statusByte <<= 4;
    statusByte += channel;
    // Encode data
    statusByte <<= 8;
    statusByte += this.pitch;
    statusByte <<= 8;
    statusByte += this.pressure;

    // Return it
    return statusByte;
  }
}

// Control Change

class ControlChange {
  int time;
  int controller;
  int value;
  int channel;

  ControlChange(this.controller, this.time, this.value, this.channel);

  String toString() =>
      "Control change from ${this.controller} to ${this.value}";

  /// Returns the correct bytes for use in a Standard MIDI File
  int toBytes() {
    if (channel > 15) {
      throw new ArgumentError.value(channel);
    }
    // Encode status bytes
    int statusByte = 11;
    statusByte <<= 4;
    statusByte += channel;
    // Encode data
    statusByte <<= 8;
    statusByte += this.controller;
    statusByte <<= 8;
    statusByte += this.value;

    // Return it
    return statusByte;
  }
}

class ChannelAfterTouch {
  int time;
  int pressure;
  int channel;

  ChannelAfterTouch(this.time, this.pressure, this.channel);

  String toString() =>
      "Channel AfterTouch: ${this.channel} to ${this.pressure}";

  int toBytes() {
    int statusByte = 13;
    statusByte <<= 4;
    statusByte += channel;
    statusByte <<= 8;
    statusByte += this.pressure;

    return statusByte;
  }
}
