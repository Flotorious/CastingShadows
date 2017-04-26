/*
Übersicht des gesamten Stückes
==============================

01  Sz1  intro      0:00    1
02  Sz2  choosing   0:58    1
03  Sz3  1st pdd    1:19    1,2 
04  Sz4  party      3:00    1,2  
05  Sz4  party      3:05    1,2,3,4,5,6   185
06  Sz4  party      3:44    3,4
07  Sz5  2nd pdd    3:56    5,6
08  Sz6  trio       4:53    6,1,2
09  Sz7  party r.   5:48    1,2,3,4,5,6   348
10  Sz7  party r.   6:37    3
11  Sz8  3rd pdd    7:01    3,4
12  Sz9  outro      8:14    5
13  ENDE           10:00 Keine Ahnung wann das endet
*/

// TODO: Irgendeinen Callback Mechanismus für das Hauptprogramm implementieren


class Conductor {
  long timeStarted = 0; 
  int[] cruicalMoments =  new int[] {0, 58, 79, 180, 185, 224, 236, 293, 348, 397, 421, 494, 600};
  // Dieser Vektor wird Werte von Attila beeinhalten mit denen er schätzt wie stark der Tänzer aktiv ist körperlich
  int[] physicalActivity = new int[] {2, 3, 4, 3, 3, 3, 3, 4, 4, 2, 3, 4, 5, 6, 7, 8, 9,7,7,7,7,6,7,7,7,6,6,6,6,6,5,5,5,5,6,7,8,3,4,5,5,6,7,8,8,4,5,4,3,5,6};

  void startPerformance() {
    timeStarted = millis();
  }
  
  int whichSceneIsIt(int time_) {
    int returnVal = -1;
    for (int i=0; i<cruicalMoments.length-1; i++) {
      if (time_/1000>=cruicalMoments[i] && time_/1000<cruicalMoments[i+1]) returnVal = i;
    }
     return returnVal+1;
   }
   
  // ToDo ausprogrammieren, dass wirklich eine Einschätzung zurück kommt 
  int getPhysical(int time_) {
    time_ = time_/10000;
    //println(physicalActivity[time_]);
    int returnVal = physicalActivity[time_];
    return returnVal;
  }

}