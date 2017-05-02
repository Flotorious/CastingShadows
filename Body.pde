class Body {
  float xPos; // Current x-coordinate
  float yPos; // Current y-coordinate
  float diameter;  
  color col;
  float xPosTranslation = 0; // Falls die Darstellung translatiert werden soll, um den Beamer-Screen besser auszufüllen
  float yPosTranslation = 0;  
  float scalar = 1;

  float pulseDiameterMax;
  float currentPulseDiameter;
  boolean showHeartBeatAnimation = false;
  float heartBeatVelocity = 0.01f;

  String id ="noname";

  // Zeug, fuer die Bewegungsanimation
  // https://processing.org/examples/movingoncurves.html
  float beginX = -2222.0;  // Initial x-coordinate
  float beginY = -1111.0;  // Initial y-coordinate
  float endX = -1;   // Final x-coordinate
  float endY = -1;   // Final y-coordinate
  float distX;          // X-axis distance to move
  float distY;          // Y-axis distance to move
  float exponent = 4;   // Determines the curve   
  float step = 0.01;    // Size of each step along the path  
  // TODO: Die Stepsize muss ich so anpassen, dass der Body nach einer Sekunde an der nächsten Position ist jeweils
  // Wenn die Dauer eines Frames allerdings verstellt wird im Localizer, muss ich das auch hier umändern können.
  float pct = 0.0;      // Percentage traveled (0.0 to 1.0)
  boolean recalculateParameters = true;
  // ---------------------------------------------

  boolean isGrowing = true; // fuer das Pulsieren

  // Konstruktor falls eine Stage dargestellt bzw. Instanziert werden soll
  Body(float x, float y) {
    xPos = x;
    yPos = y;
  }

  // Einen Tänzer instanzieren
  Body(float x, float y, int d, color c) {
    xPos = x;
    yPos = y;
    diameter = d;
    col = c;
    currentPulseDiameter = diameter;
    pulseDiameterMax = diameter * 1.65;
  }

  // Für die Anpassung an den Beamer-Ausschnitt
  void setTranslation(float x_, float y_) {
    xPosTranslation = x_;
    yPosTranslation = y_;
  }
  void setScale(float s) {
    scalar = s;
  }

  void setID(String s) {
    id = s;
  }

  void reset() {
    recalculateParameters = true;
  }

  void debug(int id, int f, float x, float y) {
    println("FrameCounter: "+frameCounter+"    ID: "+id, "posX: "+x+"    posY: "+y+"    beginX: "+beginX+"   beginY: "+beginY);
  }

  void danceToPos(float x, float y) {
    //if (id.equals("dancer1"))
    //println(id+": dance to position: "+x+ " --- "+y);
    if (beginX==-2222) {
      beginX = x;
      beginY = y;
      xPos = x;
      yPos = y;
      endX = x;
      endY = y;
    } else {
      if (recalculateParameters) { 
        recalculateParameters = false;
        pct = 0.0;
        beginX = xPos;
        beginY = yPos;
        endX = x;
        endY = y;
        distX = endX - beginX;
        distY = endY - beginY;
      }

      pct += step;
      if (pct < 1.0) {
        xPos = beginX + (pct * distX);
        yPos = beginY + (pct * distY);
      }
      // Ziel erreicht
      //if (xPos==endX && yPos==endY) {
      //  recalculateParameters = true;
      //}
    }
  }

  // Diese Funktion jeweils in der Draw() Methode aufrufen
  void display() {
    noStroke();
    pushMatrix();
    translate(xPosTranslation, yPosTranslation);
    scale(scalar);
    beginShape();
    if (showHeartBeatAnimation) {
      fill(col, 50); // Das ist das Pulsieren des Kreises
      ellipse(xPos, yPos, currentPulseDiameter, currentPulseDiameter);
    }
    fill(col, 100);  
    ellipse(xPos, yPos, diameter, diameter); 
    //fill(255);
    //textSize(2);
    //text(round(xPos)+"/"+round(yPos), xPos,yPos);
    //ellipse(xPos, yPos, diameter*.50, diameter*.50); 
    //ellipse(xPos, yPos, diameter, diameter*.50); 


    endShape();
    popMatrix(); 

    if ((currentPulseDiameter<=pulseDiameterMax) && isGrowing) {
      currentPulseDiameter = currentPulseDiameter + random(0, 100)*heartBeatVelocity;
    } else {
      isGrowing = false;
      if (currentPulseDiameter>=diameter) {
        currentPulseDiameter = currentPulseDiameter -random(0, 100)*heartBeatVelocity;
      } else {
        isGrowing = true;
        showHeartBeatAnimation = false;
      }
    }
  }
  
  void resetBeginX(){
    beginX = -2222f;
  }

  // Diese Funktion stupst die Herzschlag-Visualisierung ein Mal an
  // urgent == die Geschwindikeit der Animation. 0.01 ist gemütlich
  void poke(float urgent) {
    heartBeatVelocity = urgent; // urgent oder auch acctivitylevel ... diese Werte müssen vielleicht noch überdacht werden
    showHeartBeatAnimation = true;
    currentPulseDiameter = diameter;
  }
}// end of class