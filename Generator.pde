class Generator {
  
  float state = 0; // Der Generator muss 'wissen' wo er gerade steht. Irgendwo zwischen 0 und 2PI
  int samplingRate = 60;
  float stepSize = 0;
  boolean considerPoke = false;
  int pokeArray[] = {-1,-1,-2,-2,-3,-3,-8,-8,-12,-12,-8,-3,-3,-2,-2,-1,-1};
  int pokeCounter = -1;
  
  // Parameter: Wie soll der Sinus aussehen
  Generator(int samplingRate_) {
    samplingRate = samplingRate_;
    stepSize = 2*PI/samplingRate;
    reset();
  }
  
  
  void reset() {
    state = 0;
  }
  
  float update() {
    state = state + stepSize;
    if (!considerPoke)
      return sin(state);
    else {
      pokeCounter++;
      if (pokeCounter==pokeArray.length-1)
        considerPoke = false;
      return sin(state)+pokeArray[pokeCounter];
    }
        
  }
  
  void poke() {
    considerPoke = true;
    pokeCounter = -1;
  }

}