class Beat1 {
  float x, y; // X-coordinate, y-coordinate
  float angle; // Used to define the tilt
  float scalar; // Height of the egg
  
  Beat1(float xpos, float ypos, float s) {
    x = xpos;
    y = ypos;
    scalar = s / 100.0;
  }
  
  void display() {
    noStroke();
    fill(255);
    pushMatrix();
    translate(x, y);
    //rotate(tilt);
    //scale(scalar);
    noFill();
    beginShape();
    strokeWeight(2);
    stroke(255);
    curveVertex(-30, 50);
    curveVertex(-30, 50);
    curveVertex(-20, 50-10);
    curveVertex(-10, 50);
    curveVertex(0, 50-150);
    curveVertex(10, 50);
    curveVertex(20, 50-10);
    curveVertex(30, 50);
    curveVertex(30, 50);
    endShape();
    popMatrix();
  }
  
  

}