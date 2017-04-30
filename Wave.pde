class Wave {

  int wave[] = null;
  color col;
  int laneHeight = 0;
  int xStart = 0;
  int width_ = 0; // wie lange kann die Welle maximal werden...
  int thikness = 1;
  float angle = 0f;
  float zoom = 1f;
  float alpha = 255;

  boolean isActivated = true;

  Wave(int x_, int laneHeight_, int w) {
    width_ = w;
    xStart = x_;
    laneHeight = laneHeight_;
    wave = new int[width_];
    col =  color((int) random(0, 255), (int) random(0, 255), (int) random(0, 255));
    for (int i=0; i<width_; i++) {
      wave[i] = -6666;
    }
  }

  void addValueAndDisplay(float newVal) {
    
    if (isActivated) { // wenn man dieses if statement nach vor stroke zieht, dann kommen die wellen bündig eingefahren...
      for (int i=wave.length-1; i>=1; i--) {
        wave[i] = wave[i-1];                  // shift the bpm Y coordinates over one pixel to the left
      }

      //wave[width-1] = (int) newVal;
      wave[0] = (int) newVal;


      // GRAPH - THE HEART RATE WAVEFORM

      stroke(col,alpha);                          // color of heart rate graph
      strokeWeight(thikness);                          // thicker line is easier to read
      noFill();
      pushMatrix();
      translate(xStart, laneHeight);
      rotate(angle);
      scale(zoom);
      beginShape();
      for (int i=0; i < wave.length-1; i++) {    // variable 'i' will take the place of pixel x position
        if (wave[i]!=-6666) {
          //vertex(i, wave[i]+laneHeight);         // display history of heart rate datapoints 
          curveVertex(i, wave[i]);
        }
      }
      endShape();
      popMatrix();
    }
  }

  void setColor(color col_) {
    col = col_;
  }

  void setThikness(int t) {
    thikness = t;
  }

  void setAngle(float a) {
    angle = a;
  }

  void setAlpha(float a) {
    alpha = a;
  }

  void setScale(float s) {
    zoom = s;
  } 

  void setYTranslate (int t) {
    laneHeight = t;
  }

  void setVisibility(boolean b) {
    isActivated = b;
    if (isActivated == false) {
      wave = new int[width_];
      for (int i=0; i<width_; i++) {
        wave[i] = -6666;
      }
    }
  }
}