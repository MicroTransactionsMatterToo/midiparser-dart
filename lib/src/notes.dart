enum TransposeValues {
  C,
  CS,
  D,
  DS,
  E,
  F,
  FS,
  G,
  GS,
  A,
  AS,
  B
}

enum BaseNotes {
  C,
  CS,
  D,
  DS,
  E,
  FS,
  G,
  GS,
  A,
  AS,
  B
}

EvaluateNote(int noteValue, TransposeValues keySig) {
  // Ensure note is within valid range
  assert(noteValue >= 0 && noteValue <= 127);
}