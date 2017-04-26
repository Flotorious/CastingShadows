class FrameManager {
  int currentFrame = 0;
  int frameNumber = 0;

ArrayList<FrameData> allFrames = null;

  FrameManager() {
    allFrames = new ArrayList<FrameData>();
    allFrames.add(new FrameData());
    currentFrame = 0;
    frameNumber++;
  }

  void addFrame(int frameIDToBeAdded) {
    if (frameIDToBeAdded+1 > frameNumber) {
      allFrames.add(new FrameData());
      frameNumber++;
    }
    currentFrame++;
    
  }
  
  int getNumberOfFrames() {
    return frameNumber;
  }
  
  void addCell(int x, int y, int rawX, int rawY, int ind, int owner) {
    allFrames.get(currentFrame).addData(x,y,rawX,rawY,ind,owner);
  }

  int getCurrentFrameID() {
    return currentFrame;
  }
     
  // Alle Zellen die eingefärbt werden sollen
  int[] getCurrentDataX() {
    return allFrames.get(currentFrame).getX();
  }
  
  int[] getPreviousDataX() {
    return allFrames.get(currentFrame-1).getX();
  }  
  
  int[] getCurrentDataY() { 
    return allFrames.get(currentFrame).getY();
  }  

  int[] getPreviousDataY() { 
    return allFrames.get(currentFrame-1).getY();
  }    
  
  int[] getCurrentOwners() { 
    return allFrames.get(currentFrame).getOwners();
  }   
  
  int[] getPreviousOwners() { 
    return allFrames.get(currentFrame-1).getOwners();
  }   
  
  int getCurrentNumberOfElements() {
    return allFrames.get(currentFrame).getNumberOfElements();
  }
  
    int getPreviousNumberOfElements() {
    return allFrames.get(currentFrame-1).getNumberOfElements();
  }
  
  boolean isCurrentOccupied(int ind) {
    return allFrames.get(currentFrame).isOccupied(ind);
  }
  
  int gotoFrame(int i) {
    currentFrame = i;
    return currentFrame;
  }
  
  void removeData(int ind) {
    // locate ind in List
    int ind_ = allFrames.get(currentFrame).findPosition(ind);
    // remove ind_ from list
    allFrames.get(currentFrame).removeElement(ind_);
  }
  
  void setCurrentOwner(int id) {
    allFrames.get(currentFrame).setOwner(id);
  }
  
  // zum debuggen, alle daten in der Konsole ausgeben
  void printAll(int offset, String savePath) {
    int laufnummer = 0;
    for (int i=0; i<frameNumber; i++) {
      FrameData f = allFrames.get(i);
      int n = f.getNumberOfElements();
      int x[] = f.getX();
      int y[] = f.getY();
      int o[] = f.getOwners();
      int ind[] = f.getInd();
      for (int j=0; j<n; j++) {
        // Format:
        // Laufnummer, FrameId, X, Y, Index, Owner
        println(laufnummer + "," +(i+offset)+ "," + x[j] + "," + y[j] + "," + ind+ "," + o[j]);
        laufnummer++;
      }
      println("");
    }
    String[] exportThis = new String[laufnummer];
    laufnummer = 0;
    for (int i=0; i<frameNumber; i++) {
      FrameData f = allFrames.get(i);
      int n = f.getNumberOfElements();
      int x[] = f.getX();
      int y[] = f.getY();
      int o[] = f.getOwners();
      int ind[] = f.getInd();     
      
      for (int j=0; j<n; j++) {
        // Format:
        // Laufnummer, FrameId, X, Y, Owner
        exportThis[laufnummer] = (laufnummer + "," +(i+offset)+ "," + x[j] + "," + y[j] + "," + ind[j] + "," + o[j]);
        laufnummer++;
      }
  }
    saveStrings(savePath, exportThis);
  }
  
  void loadFile(String toBeLoaded) {   
    // Alte Daten raushauen
    currentFrame = 0;
    frameNumber = 0;
    allFrames = new ArrayList<FrameData>();
    allFrames.add(new FrameData());
    currentFrame = 0;
    frameNumber++;
    // Neu Befüllen
    
    // Erst einmal den Offset für die Frames herausfinden
    String[] lines = loadStrings(toBeLoaded);
    String tmp = lines[0];
    int[] a = parseLine(tmp);   
    /*println("Offset: "+ a[0]);
    println("x: "+ a[1]);
    println("y: "+ a[2]);
    println("owner: "+ a[3]);*/
    int offset = a[0];
    
    // Zeile für Zeile die Daten in das System einfüttern  
       
    //println("there are " + lines.length + " lines");
    for (int i = 0 ; i < lines.length; i++) {
      //println(lines[i]);
      a = parseLine(lines[i]); 
      
      /*
      println("Frame: "+ (a[0]-offset));
      println("x: "+ a[1]);
      println("y: "+ a[2]);
      println("index: "+ a[3]); 
      println("owner: "+ a[4]); */
      
      if ((a[0]-offset)>=frameNumber) {
        addFrame((a[0]-offset+1));
      }
      
      allFrames.get((a[0]-offset)).addData(a[1],a[2],0,0,a[3],a[4]);   
    }    
  }
  
  // Hilfsfunktion um die Koordinaten aus den Textfile zurück zu gewinnen
  int[] parseLine(String tmp) {
    int[] all = new int[5];
    tmp = tmp.substring(tmp.indexOf(",")+1, tmp.length());
    int offset = Integer.valueOf(tmp.substring(0,tmp.indexOf(",")));
    tmp = tmp.substring(tmp.indexOf(",")+1, tmp.length());
    int x = Integer.valueOf(tmp.substring(0,tmp.indexOf(",")));
    tmp = tmp.substring(tmp.indexOf(",")+1, tmp.length());
    int y = Integer.valueOf(tmp.substring(0,tmp.indexOf(",")));
    tmp = tmp.substring(tmp.indexOf(",")+1, tmp.length());
    int ind = Integer.valueOf(tmp.substring(0,tmp.indexOf(",")));    
    tmp = tmp.substring(tmp.indexOf(",")+1, tmp.length());
    int o = Integer.valueOf(tmp.substring(0,tmp.length()));
    
    all[0] = offset;
    all[1] = x;
    all[2] = y;
    all[3] = ind;  
    all[4] = o;    

    // frameID  x  y  ind  owner
    return all;
  }

  // Funktion speziell für die Visualisierugs-App
  float[] getPos(int frameID, int dancerID) {
    //print("dancer: "+dancerID+ " --- frame: "+ frameID);
    float[] all = new float[2];
    all[0] = -1;
    all[1] = -1;
    gotoFrame(frameID);
    int n = getCurrentNumberOfElements();
    int[] x = getCurrentDataX();
    int[] y = getCurrentDataY();
    int[] o = getCurrentOwners();
    for (int i=0; i<n; i++) {
      if (o[i] == dancerID) {
        all[0] = (float) (x[i]*5+2.5)/1;
        all[1] = (float) ((22*5) - (y[i]*5+2.5))/1;
        //println(" --- x: "+ x[i] + " --- y: "+y[i]); 
      }
    }
    //println("");
    
    return all;
  }
}