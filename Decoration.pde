class Decoration {
  
  float xPosTranslation = 0; // Falls die Darstellung translatiert werden soll, um den Beamer-Screen besser auszufüllen
  float yPosTranslation = 0;  
  float randoms[][] = new float[7][30];
  
  int faderCounter = 0; // Hilfsvariable für Übergänge

  boolean recalculateParameters = true;
  
  Decoration() {
    populateRandoms();
  }
  
  // Hier werden die Farben codiert
  // Muss wahrscheinlich noch angepasst werden der Schminke entsprechend
  // ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
  color getColor(int id) {
    color c = color(0,0,0);
    switch (id) {
      case 0:
        c = color(120,120,120);
      break;
      case 1:
        c = color(255,0,0);
      break;
      case 2:
        c = color(0,255,0);
      break;
      case 3:
        c = color(0,0,255);
      break;
      case 4:
        c = color(255,255,0);
      break;
      case 5:
        c = color(255,0,255);
      break;
      case 6:
        c = color(0,255,255);
      break;
       case 7:
        c = color(11,120,0);
      break;
      case 8:
        c = color(255,120,0);
      break;   
      case 9:
        c = color(0,0,0);
      break;          
    }
    
    return c;
  }
  
  // Diese Funktion nur aufrufen, falls die Body Instanz eine Stage darstellen soll 
  void displayStage(int mode) {
    pushMatrix();
    translate(xPosTranslation, yPosTranslation);
    scale(scalar); 
    if (mode ==1) { // orangener Kreis
      noFill();
      stroke(204, 102, 0);
      strokeWeight(2);
    } else { // schwarzer semi-transparenter Kasten==Bühne
      noStroke();
      fill(0,0,0,200);
      rect(0,0,110,110);
    }
    
    popMatrix(); 
    
    /*
    if (recalculateParameters) {
      recalculateParameters = false;
      for (int i=0; i<200; i++) {
        noStroke();
        fill(random(0,100));
        ellipse(random(0,width), random(0,height), random(0,100), random(0,100));
      }
    }
    */
  }
  
  void resetFader() {
    faderCounter = 0;
  }
  
  // Diese Funktion wenn zwischen 2 Szenen übergeblendet werden soll
  void activateFader(int stepSize) {
    pushMatrix();
    translate(xPosTranslation, yPosTranslation);
    scale(scalar); 
    noStroke();  
    fill(0,0,0,stepSize*faderCounter); 
    rect(0,0,110,110);
    faderCounter++;
    //println(faderCounter);  
    popMatrix();  
  }  
  
  
  
  // Diese Funktion nur aufrufen, falls die Body Instanz eine Stage darstellen soll 
  void displayStripes() {     
    if (recalculateParameters) {
        recalculateParameters = false;
        populateRandoms();
    }

    for (int j=0; j<30; j++) {
      //noStroke();
      strokeWeight(randoms[0][j]);
      stroke(randoms[1][j],randoms[2][j],randoms[3][j],randoms[4][j]*(1/randoms[0][j])*10);
      line(randoms[5][j], 0, randoms[6][j], height);
    }  
    
  } 
  
  // Für die Striche im Hintergrund
  void populateRandoms(){
    for (int i=0; i<7; i++) {
      for (int j=0; j<30; j++) {
        if (i==0) // strokeWeight
          randoms[i][j] = random(1,30);
        if (i==1) // color
          randoms[i][j] = random(1,100);  
        if (i==2) // color
          randoms[i][j] = random(1,100);  
        if (i==3) // color
          randoms[i][j] = random(1,100); 
        if (i==4) // alpa
          randoms[i][j] = random(1,100);    
        if (i==5) // 
          randoms[i][j] = random(1,width); 
        if (i==6) // 
          randoms[i][j] = random(1,width);             
      }
    }
  
  }
  
  
  void reset() {
    recalculateParameters = true;
  }  
  
  // Für die Anpassung an den Beamer-Ausschnitt
  void setTranslation(float x_, float y_) {
    xPosTranslation = x_;
    yPosTranslation = y_;
  }
  void setScale(float s) {
    scalar = s;
  }
  

}