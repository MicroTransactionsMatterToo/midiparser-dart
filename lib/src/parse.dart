import "dart:convert";

import "events.dart";

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

int parse_uint24(List<int> fileArray) {
  var bytes = fileArray.sublist(0, 3); // Extract 3 bytes from file
  fileArray.removeRange(0, 3); // Drop those bytes

  var rval = 0x00;
  rval |= bytes[0] << 16;
  rval |= bytes[1] << 8;
  rval |= bytes[2] << 0;

  return rval;
}

int parse_uint16(List<int> fileArray) {
  var bytes = fileArray.sublist(0, 2); // Extract 2 bytes from file
  fileArray.removeRange(0, 2); // Drop those bytes

  var rval = 0x00;
  rval |= bytes[0] << 8;
  rval |= bytes[1] << 0;

  return rval;
}

int parse_uint7(List<int> fileArray) {
  var bytes = fileArray.sublist(0,1);
  fileArray.removeAt(0);

  var rval = bytes[0];
  rval &= 0x7F;

  return rval;
}

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

int parse_variable_length(List<int> fileArray) {
  var bytes = fileArray.sublist(0,1);
  fileArray.removeRange(0,1);

  int return_count = 1;
  var result = 0x00;

  var firstRun = true;
  while ((firstRun || (bytes[0] & 0x80 == 0x80)) && (return_count > 0)) {
    result <<= 7;
    return_count = fileArray[0];
    fileArray.removeAt(0);
  }
}