import "dart:convert";

import "package:midiparser/src/events.dart";

/// Parses a 32 bit unsigned value, dropping used indexes as needed
int parse_uint32(List<int> fileArray) {
  var bytes = fileArray.sublist(0, 4); // Extract 4 bytes from file
  fileArray.removeRange(0, 4);  // Drop those bytes

  var rval = 0x00;
  rval |= bytes[0] << 24;
  rval |= bytes[1] << 16;
  rval |= bytes[2] << 8;
  rval |= bytes[3] << 0;

  return rval;
}

/// Parses a 24 bit unsigned value, dropping used indexes as needed
int parse_uint24(List<int> fileArray) {
  var bytes = fileArray.sublist(0, 3); // Extract 3 bytes from file
  fileArray.removeRange(0, 3); // Drop those bytes

  var rval = 0x00;
  rval |= bytes[0] << 16;
  rval |= bytes[1] << 8;
  rval |= bytes[2] << 0;

  return rval;
}

/// Parses a 16 bit unsigned integer, dropping indexes as needed
int parse_uint16(List<int> fileArray) {
  var bytes = fileArray.sublist(0, 2); // Extract 2 bytes from file
  fileArray.removeRange(0, 2); // Drop those bytes

  var rval = 0x00;
  rval |= bytes[0] << 8;
  rval |= bytes[1] << 0;

  return rval;
}

/// Parses a 7 bit unsigned integer, dropping indexes as needed
int parse_uint7(List<int> fileArray) {
  var bytes = fileArray.sublist(0,1);
  fileArray.removeAt(0);

  var rval = bytes[0];
  rval &= 0x7F;

  return rval;
}

List<int> parse_two_uint7(List<int> fileArray) {
  var bytes = fileArray.sublist(0, 2);
  fileArray.removeRange(0, 2);


  var rval = [bytes[0] & 0x7F, bytes[1] & 0x7F];
  return rval;
}

/// Parses a pitch wheel value, dropping indexes as needed
PitchWheelEvent parse_pitch_wheel(List<int> fileArray) {
  var bytes = fileArray.sublist(0, 2);
  fileArray.removeRange(0, 2);

  int value = 0x00;
  value = (bytes[1] & 0x7F);
  value |= (bytes[0] & 0x7F << 7);

  int relative;
  relative = value - 0x2000;

  return new PitchWheelEvent(relative, value);
}

/// Parses a Track Header, dropping indexes as needed
TrackHeader parse_track_header(List<int> fileArray) {
  var bytes = fileArray.sublist(0,4);
  fileArray.removeRange(0, 4);

  var length = parse_uint32(fileArray);
  var type = ASCII.decode(bytes);

  if (type != "MTrk") {
    throw new TypeError();
  }

  return new TrackHeader(length, HeaderType.TRACK_HEADER);

}

/// Parses the file header, dropping indexes as needed
MIDIHeader parse_file_header(List<int> fileArray) {
  var headerType = fileArray.sublist(0, 4);
  fileArray.removeRange(0, 4);
  var length = parse_uint32(fileArray);
  var formatInt = parse_uint16(fileArray);
  var format = FileType.values[formatInt];
  var division = parse_uint16(fileArray);
  var trackNumber = parse_uint16(fileArray);
  var returnValue = new MIDIHeader(length, format, division, trackNumber);
  return returnValue;
}

/// Parses a MIDI variable length value
int parse_variable_length(List<int> fileArray) {
  var bytes = fileArray.elementAt(0);
  fileArray.removeAt(0);

  int return_count = 1;
  var result = 0x00;

  var firstRun = true;
  while ((firstRun || (bytes & 0x80 == 0x80)) && (return_count > 0) && (fileArray.length > 1)) {
    result <<= 7;
    bytes = fileArray.elementAt(0);
    fileArray.removeAt(0);
    return_count = bytes;


    result |= (bytes & 0x7F);

    firstRun = false;
  }

  if (num == 0 && !firstRun) {
    throw new Exception("Invalid variable length value");
  }

  return result;
}
