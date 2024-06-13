// Use to test Swift-t during image build

app (void signal) runscript (string a) {
    "echo" "run #" a ; 
}

foreach version in [1:5] {
  void signal = runscript(fromint(version));
  // Wait on output signal so that trace occurs after echo
  wait(signal) {
    trace("Test " + fromint(version));
  }
}
