enum HeaderType {
  FILE_HEADER,
  TRACK_HEADER
}

enum FileType {
  SINGLE_TRACK,
  MULTI_TRACK,
  MULTI_FILE
}

enum TimeFormat {
  METRIC_TIME_FORMAT,
  SMPTE_TIME_FORMAT
}

class PitchWheelEvent {
  int relative;
  int absolute;
  int time;

  PitchWheelEvent(this.relative, this.absolute);
}

class MIDIHeader {
  int length;
  int timeDivision;
  int tracks;
  int ticksPerQuarterNote;
  TimeFormat timeFormat;
  FileType type;

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

class TrackHeader {
  int length;
  HeaderType type;

  TrackHeader(this.length, this.type);

  String toString() {
    var rval = "Length: $length; Type: ${type.runtimeType}";
    return rval;
  }
}