// Diese Klasse dient als Datenstruktur um pro Frame festzuhalten, was dort passiert
// xPositions
// yPositions
// xRaw
// yRaw
// owners


// ANMERKUNG Die Aufzeichnung der Rohdaten (wo genau mit der Mouse hingeklickt worden ist) habe ich doch nicht implementiert --> Brauch wahrscheinlich kein Mensch, spare ich mir daher.



class FrameData {
  
  ArrayList<Integer> xPositions = null;
  ArrayList<Integer> yPositions = null;
  ArrayList<Integer> xRaw = null;
  ArrayList<Integer> yRaw = null;
  ArrayList<Integer> ind = null;
  ArrayList<Integer> owners = null;
  int counter = 0;
  
  
  FrameData() {
    xPositions = new ArrayList<Integer>();
    yPositions = new ArrayList<Integer>();
    xRaw = new ArrayList<Integer>();
    yRaw = new ArrayList<Integer>();
    ind = new ArrayList<Integer>();
    owners = new ArrayList<Integer>();
    counter = 0;
  }
  
  void addData(int x, int y, int xRaw_, int yRaw_, int ind_, int owner) {
    xPositions.add(x);
    yPositions.add(y);
    xRaw.add(xRaw_);
    yRaw.add(yRaw_);
    ind.add(ind_);
    owners.add(owner);
    counter++;
  }
  
  int[] getX() {
    int []all = new int[xPositions.size()];
    for (int i = 0; i<xPositions.size(); i++) {
      all[i] = xPositions.get(i);
    } 
    return all;
  }

  int[] getY() {
    int []all = new int[yPositions.size()];
    for (int i = 0; i<yPositions.size(); i++) {
      all[i] = yPositions.get(i);
    } 
    return all;
  }
  
  // ANMERKUNG Die Aufzeichnung der Rohdaten habe ich doch nicht implementiert
  int[] getXRaw() {
    int []all = new int[xRaw.size()];
    for (int i = 0; i<xRaw.size(); i++) {
      all[i] = xRaw.get(i);
    } 
    return all;
  }  
  
  // ANMERKUNG Die Aufzeichnung der Rohdaten habe ich doch nicht implementiert  
  int[] getYRaw() {
    int []all = new int[yRaw.size()];
    for (int i = 0; i<yRaw.size(); i++) {
      all[i] = yRaw.get(i);
    } 
    return all;
  }  
  
  int[] getInd() {
    int []all = new int[ind.size()];
    for (int i = 0; i<ind.size(); i++) {
      all[i] = ind.get(i);
    } 
    return all;
  }  
  
  boolean isOccupied(int selected) { 
    boolean b = false;
    for (int i = 0; i<ind.size(); i++) {
      if (ind.get(i)==selected)
        b = true;
    } 
    return b;
  }
  
  int findPosition(int ind_) { 
    int pos = -1;
    for (int i = 0; i<ind.size(); i++) {
      if (ind.get(i)==ind_)
        pos = i;
    } 
    return pos;
  }
  
  int[] getOwners() {
    int []all = new int[owners.size()];
    for (int i = 0; i<owners.size(); i++) {
      all[i] = owners.get(i);
    } 
    return all;
  }   
  
  void setOwner(int id) {
    owners.remove(owners.size()-1);
    owners.add(id);
  }
  
  int getNumberOfElements() {
    return counter;
  }
  
  void removeElement(int index) {
    try {
      xPositions.remove(index);
      yPositions.remove(index);
      xRaw.remove(index);
      yRaw.remove(index);
      ind.remove(index);
      owners.remove(index);
      counter--; 
    } catch (Exception e) {}
  }
  
}