import 'dart:io';
import 'dart:async';

import 'package:midiparser/midiparser.dart';

main(List<String> args) async {
  bool debug = false;
  File midiFile;
  // File to parse should be first arg, all others will be ignored
  if (args.length > 1) {
    // A flag has been passed. If it is -d we will print verbosely
    if (args[0] == '-d') {
      debug = true;
    }

    midiFile = new File(args[1]);
  } else if (args.length < 1) {
    print("Please provide a file to parse");
    exit(1);
  } else {
    // We will assume that the first argument is the file
    midiFile = new File(args[0]);
  }


  // Check the file exists
  if (!await midiFile.exists()) {
    print("${args[0]} is not a file");
    exit(1);
  }

  // Read file data
  List<int> fileData = await midiFile.readAsBytes();

  // Create the parser
  final Parser parser = new Parser(fileData);

  // Parse the file
  parser.parse();

  // Print the data parsed
  print(parser.parsed.fileHeader);

  // If debug, print all note data
  if (debug) {
    for (var i in parser.parsed.events) {
      print(i);
    }
  }
}
