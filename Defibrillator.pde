// Diese Klasse simuliert den Herzschlag, falls das live-Signal ausfallen sollte
// Wenn dies der Fall ist, wird vom Defibriallator gepoket und nicht vom echten Signal
// Die Klasse ist ein wenig organisch gewachsen und daher irgendwie blöd redundant geworden, aber wurscht jetzt.

class Defibrillator {
  
  boolean defiActive = false;
  
  // Bodies sind die Kreise bzw. Kreiskörper
  ArrayList<Body> allBodies = new ArrayList<Body>();
  int bodyCount = 0;
  ArrayList<Long> lastLifeSignBody = new ArrayList<Long>();
  //ArrayList<Integer> physicalActivityBody = new ArrayList<Integer>();
  
  // Waves sind die Wellen bzw. Graphen
  ArrayList<Generator> allWaves = new ArrayList<Generator>();
  int waveCount = 0;
  ArrayList<Long> lastLifeSignWave = new ArrayList<Long>();
  //ArrayList<Integer> physicalActivityWave = new ArrayList<Integer>();
  
  int generalActivityLevel = 3;
  
  void registerDancer(Body b) {
    allBodies.add(b);
    lastLifeSignBody.add((long)millis()+(long)random(0,800));
    //physicalActivityBody.add(3); // TODO Ausprogrammieren, wenn Attila die Einschätzungen geschickt hat.
    //physicalActivityBody.add(3);
    bodyCount++;
  }
  
  void registerWave(Generator wave) {
    allWaves.add(wave);
    lastLifeSignWave.add((long)millis()+(long)random(0,800));
    //physicalActivityWave.add(3); // TODO Ausprogrammieren, wenn Attila die Einschätzungen geschickt hat.
    //physicalActivityWave.add(3);    
    waveCount++;
  }
  
  void pokeBody(int id, float intensity) {
    if (bodyCount>=id) {
      allBodies.get(id-1).poke(intensity);
      lastLifeSignBody.set(id-1, (long)millis());
    }
  }
  
  void pokeWave(int id, float intensity) {
    if (bodyCount>=id) {
      allWaves.get(id-1).poke();
      lastLifeSignWave.set(id-1, (long)millis());
    }
  }  
  
  
  // Mit dieser Funktion kann das Clockwork steuern, wann die TänzerInnen wie stark 'außer Atem' sind
  void setPhysicalActivityBody(int id, int a) {
    if (bodyCount>=id) {
      //physicalActivityBody.set(id-1, a);
    }
  }
  
  // Mit dieser Funktion kann das Clockwork steuern, wann die TänzerInnen wie stark 'außer Atem' sind
  void setPhysicalActivityWave(int id, int a) {
    if (waveCount>=id) {
      //physicalActivityWave.set(id-1, a);
    }
  }  
  
  void setGeneralActivityLevel(int l) {
    generalActivityLevel = l;
  }
  
  // TODO
  int getCurrentActivityLevelBody(int id) {
    if (bodyCount>=id) {
      //return physicalActivityBody.get(id-1);
      return 1;
    }
    else
      return 1;
  }
  /*
  int getCurrentActivityLevelWave(int id) {
    if (waveCount>=id) {
      return physicalActivityWave.get(id-1);
    }
    else
      return 1;
  }  */
  
  
  // hat das Herz kürzlich geschlagen oder ist das Signal abgerissen?
  boolean isAliveBody(int id) {
    boolean isAlive = true;
    if (bodyCount>=id) {
      // schon x ms kein Lebenszeichen erhalten
      // 750ms entspricht einem Pulse von 60. 300ms ist ein super schneller Puls von 200
      //int a = (int) map(getCurrentActivityLevelBody(id),1,10,900,190);
      int a = (int) map(generalActivityLevel,1,10,900,190);
      if (abs(millis()-lastLifeSignBody.get(id-1))>a) {
        isAlive = false;
      } else
        isAlive = true;
    }
     return isAlive;
  }
  
  // hat das Herz kürzlich geschlagen oder ist das Signal abgerissen?
  boolean isAliveWave(int id) {
    boolean isAlive = true;
    if (waveCount>=id) {
      // schon x ms kein Lebenszeichen erhalten
      // 750ms entspricht einem Pulse von 60. 300ms ist ein super schneller Puls von 200
      //int a = (int) map(getCurrentActivityLevelWave(id),1,10,900,190);
      int a = (int) map(generalActivityLevel,1,10,900,190);

      if (abs(millis()-lastLifeSignWave.get(id-1))>a && defiActive) {
        isAlive = false;
      } else
        isAlive = true;
    }
     return isAlive;
  }  
  
  // Diese Funktion in draw() aufrufen
  void onDuty(boolean showBodyShow) {
    if (showBodyShow) {
      for (int i=0; i<bodyCount; i++) {
        if (isAliveBody(i+1)==false) {
          //pokeBody(i+1, (getCurrentActivityLevelBody(i+1)/100f)*2f);
          pokeBody(i+1, (generalActivityLevel/100f)*2f);
        }
      }
    } else {
      for (int i=0; i<waveCount; i++) {
        if (isAliveWave(i+1)==false) {
          //pokeWave(i+1, (getCurrentActivityLevelWave(i+1)/100f)*2f);
          pokeWave(i+1, (generalActivityLevel/100f)*2f); 
        }
      }    
    }
  }
  
  void switchOnDefi(boolean b) {
    defiActive = b;
  }

}