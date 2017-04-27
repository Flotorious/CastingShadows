import controlP5.*;
import processing.serial.*;
  
import processing.sound.*;
SoundFile file;
  
// Arduino Kommunikation
Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
boolean ArduinoIsConnected = false;
int index = 0; // fuer die Kommunikation mit dem Arduino
char[] buffer = new char[20];

ControlP5 cp5; // user input/interaction
boolean buttonsActive = false;
boolean looping = true;

boolean isPlaying = false;

// Die TänzerInnen und andere Objekte die gerendert werden sollen
Body b1;
Body b2;
Body b3;
Body b4;
Body b5;
Body b6;
Decoration stage;
Decoration stripes = new Decoration();
Decoration fader;
Conductor conductor = new Conductor();

// Für die Wellen-Visualisierung
Beat1 b = null;
Wave wave1 = null;
Wave wave2 = null;
Wave wave3 = null;
Wave wave4 = null;
Wave wave5 = null;
Wave wave6 = null;
int thikness = 1;
float scale = 1f;
float angle = 0f;
int wave2Height = 200;
Generator generator1 = null;
Generator generator2 = null;
Generator generator3 = null;
Generator generator4 = null;
Generator generator5 = null;
Generator generator6 = null;
int scene4Begins = -1;
int scene7Begins = -1;


Decoration decor = new Decoration();
FrameManager fm_scene4aka5;
FrameManager fm_scene7aka9;
Defibrillator defi = new Defibrillator(); // Lässt die Herzen schlagen, zur Not auch wenn das Xbee Signal ausfällt
int frameCounter = 0; // Dies sind die Frames aus dem Editor von uns und hat nichts mit den Frames von Processing zu tun!

long timeStamp;
long timer;
long startNow = 0;
boolean okGo = false; // start draw loop
int lastFrame = -1;
boolean showCircleShow = false;

// ### ### SOME PARAMETERS THAT CAN BE ADJUSTED ### ###
// ####################################################
// mit diesen Variablen kann die virtuelle Performance beamergerecht verschoben werden
float transX = 240; 
float transY = 80;
float scalar = 6;
String loadFile = "/Users/florianguldenpfennig/Desktop/savefile.csv";
int fRate = 25; // n frames per Sekunde sollen angzeigt werden
// ####################################################
// ### ### ### ### ### ###  ### ### ### ### ### ### ###

void setup() {
  // fullScreen();
  cp5 = new ControlP5(this);

  size(1200, 800);
  stage = new Decoration();
  stage.setScale(scalar);
  stage.setTranslation(transX, transY);

  fader = new Decoration();
  fader.setScale(scalar);
  fader.setTranslation(transX, transY);

  frameRate(fRate);
  background(0);

  //fm.loadFile(loadFile);
  file = new SoundFile(this, "/Users/florianguldenpfennig/Desktop/mukke.mp3");


  cp5.addBang("Load")
    .setValue(0)
    .setPosition(width-95, height-40)
    .setSize(80, 25)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER) 
    ;   
  buttonsActive = true;

  // Fuer die Kommunikation mit dem Arduino notwendig  
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.  
  println("Gefundene Geraete: ");
  printArray(Serial.list());
  try {
    String portName = Serial.list()[3]; // index anpassen!
    myPort = new Serial(this, portName, 9600);
    //myPort.bufferUntil(33);
    ArduinoIsConnected = true;
  } 
  catch (Exception e) {
    ArduinoIsConnected = false;
  }
}

void serialEvent(Serial p) {
  verarbeiteXbeeNachricht(p.readString());
}

void verarbeiteXbeeNachricht(String s) {
  //Parsen. 
  try {
    // Was auch immer vom Xbee geschickt wird 
    if (s.equals("A"))
      if (showCircleShow) 
        defi.pokeBody(1, 0.05);
      else  
      defi.pokeWave(1, 0.05);
    if (s.equals("B"))
      if (showCircleShow) 
        defi.pokeBody(2, 0.05);
      else  
      defi.pokeWave(2, 0.05);
    if (s.equals("C"))
      if (showCircleShow) 
        defi.pokeBody(3, 0.05);
      else  
      defi.pokeWave(3, 0.05);
    if (s.equals("D"))
      if (showCircleShow) 
        defi.pokeBody(4, 0.05);
      else  
      defi.pokeWave(4, 0.05);
    if (s.equals("E"))
      if (showCircleShow) 
        defi.pokeBody(5, 0.05);
      else  
      defi.pokeWave(5, 0.05);
    if (s.equals("F"))
      if (showCircleShow) 
        defi.pokeBody(6, 0.05);
      else  
      defi.pokeWave(6, 0.05);
    fill(255,0,0);
    text("HEARTBEAT DETECTED", width-250, height-20);
  } 
  catch (Exception e) {
    println("Fehler.");
  }
}

// ### ### ### ### ### ### ### ### BEGIN DRAW METHOD ### ### ### ### ### ### ### ###
// Es wäre natürlich super cool, wenn man eine generisches Objekt hätte - einen Dirigenten - bei welchem man Szenen registieren kann und diese dann 
// koordiniert abgespielt werden. Aber ich denke, dies sprengt unsere zeitlichen Mittel und daher habe ich die Abfolge der Show hier in der Draw 
// Methode händisch hardcodiert 
void draw() {
  background(0);
  // Zeige den Umriss der Bühne zur Orientierung
  showMetaData(false);

  stripes.displayStripes();
  stage.displayStage(2);
  


  if (okGo) {   

    defi.onDuty(showCircleShow);
    defi.setGeneralActivityLevel(conductor.getPhysical((int)(millis()-startNow)));
    
    if (!isPlaying) {
      file.play();
      isPlaying = true;
    }

    //stripes.reset();
    // Alle Sekunde gibts ein Update - 100m0 ms vorläufig hard coded.
    // if ( (millis() - timer >= 1000) && frameCounter<fm.getNumberOfFrames()-1) {

    // Jede Sekunde updaten bis zum Ende  
    //if ( frameCount%fRate==0 && frameCounter<fm_scene4aka5.getNumberOfFrames()-1 && okGo) {
    
    if ( frameCount%fRate==0 && okGo) {

      // Einstellen, je nach Szene, 'wer' alles sichtbar ist
      int con = conductor.whichSceneIsIt((int)(millis()-startNow)); // Szene 5 und 9 sollen als Kreise gerendert werden. Alle anderen Graphen.
      //println("Scence: "+con);
      switch (con) {
      case 1: 
        wave1.setVisibility(true); 
        wave2.setVisibility(false); 
        wave3.setVisibility(false); 
        wave4.setVisibility(false); 
        wave5.setVisibility(false); 
        wave6.setVisibility(false);
        showCircleShow = false;
        break;
      case 2: 
        wave1.setVisibility(true); 
        wave2.setVisibility(false); 
        wave3.setVisibility(false); 
        wave4.setVisibility(false); 
        wave5.setVisibility(false); 
        wave6.setVisibility(false);
        showCircleShow = false;
        break;    
      case 3: 
        wave1.setVisibility(true); 
        wave2.setVisibility(true); 
        wave3.setVisibility(false); 
        wave4.setVisibility(false); 
        wave5.setVisibility(false); 
        wave6.setVisibility(false);
        showCircleShow = false;        
        break;     
      case 4: 
        wave1.setVisibility(true); 
        wave2.setVisibility(true); 
        wave3.setVisibility(false); 
        wave4.setVisibility(false); 
        wave5.setVisibility(false); 
        wave6.setVisibility(false);
        showCircleShow = false;        
        break;     
      case 5:
        showCircleShow = true;
        if (scene4Begins==-1)
          scene4Begins = frameCounter + 1;
        break;
      case 6: 
        wave1.setVisibility(false); 
        wave2.setVisibility(false); 
        wave3.setVisibility(true); 
        wave4.setVisibility(true); 
        wave5.setVisibility(false); 
        wave6.setVisibility(false);
        showCircleShow = false;
        break;        
      case 7: 
        wave1.setVisibility(false); 
        wave2.setVisibility(false); 
        wave3.setVisibility(false); 
        wave4.setVisibility(false); 
        wave5.setVisibility(true); 
        wave6.setVisibility(true);
        showCircleShow = false;        
        break;   
      case 8: 
        wave1.setVisibility(true); 
        wave2.setVisibility(true); 
        wave3.setVisibility(false); 
        wave4.setVisibility(false); 
        wave5.setVisibility(false); 
        wave6.setVisibility(true);
        showCircleShow = false;        
        break;        
      case 9:
        showCircleShow = true;
        if (scene7Begins==-1)
          scene7Begins = frameCounter + 1;        
        break;
      case 10: 
        wave1.setVisibility(false); 
        wave2.setVisibility(false); 
        wave3.setVisibility(true); 
        wave4.setVisibility(false); 
        wave5.setVisibility(false); 
        wave6.setVisibility(false);
        showCircleShow = false;        
        break;      
      case 11: 
        wave1.setVisibility(false); 
        wave2.setVisibility(false); 
        wave3.setVisibility(true); 
        wave4.setVisibility(true); 
        wave5.setVisibility(false); 
        wave6.setVisibility(false);
        showCircleShow = false;        
        break;     
      case 12: 
        wave1.setVisibility(false); 
        wave2.setVisibility(false); 
        wave3.setVisibility(false); 
        wave4.setVisibility(false); 
        wave5.setVisibility(true); 
        wave6.setVisibility(false);
        showCircleShow = false;   
        break;        
      }
      timer = millis();
      background(0);
      stripes.displayStripes();
      stage.displayStage(2); 
      showMetaData(true);

      // reset bewirkt, dass die Parameter neu berechnet werden
      // somit erfolgt hierdurch also ein update der Grafik
      b1.reset();
      b2.reset();
      b3.reset();
      b4.reset();
      b5.reset();
      b6.reset();
      frameCounter++;  // ACHTUNG!: Schlechte Wortwahl von mir - frameCount und frameConunter
      // sind verschiedene Dinge. frameCounter bezieht sich auf eine Zeile in Attilas Koordinaten CSV File
      // und entspricht einer Sekunde. Wie lange ein frameCount dauert hängt von der Framerate ab
      //println("framecounter: "+frameCounter);
    }



    // Die Darstellung, bei welcher alle 6 TänzerInnen auf der Bühne sind
    if (showCircleShow) {
      int con = conductor.whichSceneIsIt((int)(millis()-startNow)); // Szene 5 und 9 sollen als Kreise gerendert werden. Alle anderen Graphen.

      float[] tmp1 = new float[] {-1, -1};
      float[] tmp2 = new float[] {-1, -1};
      float[] tmp3 = new float[] {-1, -1};
      float[] tmp4 = new float[] {-1, -1};
      float[] tmp5 = new float[] {-1, -1};
      float[] tmp6 = new float[] {-1, -1};

      if (con == 5) {
        try {
          tmp1 = fm_scene4aka5.getPos(frameCounter-scene4Begins, 1);   
          tmp2 = fm_scene4aka5.getPos(frameCounter-scene4Begins, 2);
          tmp3 = fm_scene4aka5.getPos(frameCounter-scene4Begins, 3);
          tmp4 = fm_scene4aka5.getPos(frameCounter-scene4Begins, 4);
          tmp5 = fm_scene4aka5.getPos(frameCounter-scene4Begins, 5);
          tmp6 = fm_scene4aka5.getPos(frameCounter-scene4Begins, 6);
        } catch (Exception e) {
          println("Framemanager4 wollte mehr Frames laden als vorhanden: "+(frameCounter-scene4Begins+1));
        }
      }
      if (con == 9) {
        try {
          tmp1 = fm_scene7aka9.getPos(frameCounter-scene7Begins, 1);
          tmp2 = fm_scene7aka9.getPos(frameCounter-scene7Begins, 2); 
          tmp3 = fm_scene7aka9.getPos(frameCounter-scene7Begins, 3);    
          tmp4 = fm_scene7aka9.getPos(frameCounter-scene7Begins, 4);  
          tmp5 = fm_scene7aka9.getPos(frameCounter-scene7Begins, 5);      
          tmp6 = fm_scene7aka9.getPos(frameCounter-scene7Begins, 6);
        } catch (Exception e) {
          println("Framemanager7 wollte mehr Frames laden als vorhanden: "+(frameCounter-scene7Begins+1));
        }          
      }
      b1.danceToPos(tmp1[0], tmp1[1]);
      b2.danceToPos(tmp2[0], tmp2[1]);
      b3.danceToPos(tmp3[0], tmp3[1]);
      b4.danceToPos(tmp4[0], tmp4[1]); 
      b5.danceToPos(tmp5[0], tmp5[1]);
      b6.danceToPos(tmp6[0], tmp6[1]);

      // Muss mit jedem Frame ausgeführt werden, denn hier werden die 
      // Objekte inklusive deren Koordinaten letztendlich geupdated und geredndert.
      if (tmp1[0]!=-1)
        b1.display();
      if (tmp2[0]!=-1)
        b2.display();
      if (tmp3[0]!=-1)
        b3.display();
      if (tmp4[0]!=-1)
        b4.display();
      if (tmp5[0]!=-1)
        b5.display(); 
      if (tmp6[0]!=-1)
        b6.display();
    } else {
      // Normalen Graphen anzeigen
      wave1.addValueAndDisplay(8*generator1.update());
      wave2.addValueAndDisplay(8*generator2.update());
      wave3.addValueAndDisplay(8*generator3.update());
      wave4.addValueAndDisplay(8*generator4.update());
      wave5.addValueAndDisplay(8*generator5.update());
      wave6.addValueAndDisplay(8*generator6.update());
    }
    
    boolean resetFader = true;
    if (frameCounter>scene4Begins-3&&frameCounter<scene4Begins) {
      fader.activateFader(5);
      resetFader = false;
    }
    if (frameCounter>scene7Begins-3&&frameCounter<scene7Begins) {
      fader.activateFader(5);
      resetFader = false;
    }
    if (frameCounter>224-3&&frameCounter<224) {
      fader.activateFader(5);
      resetFader = false;
    }    
    if (frameCounter>397-3&&frameCounter<397) {
      fader.activateFader(5);
      resetFader = false;
    }    
    if (resetFader)
      fader.resetFader();
  }
}

// Debugging und vor allem Timing darstellen
void showMetaData(boolean newFrame) {
  if (newFrame) 
    fill(0, 255, 0);
  else  
  fill(255);
  text("Time: "+ Float.toString((millis()-startNow)/1000f)+"   Framecount: "+ frameCount + "    Accomplished Framerate: "+frameRate, 20, height-20);
}

// Falls ein Load Button zum Debuggen angezeigt werden soll (für den Developer Mode)
public void Load(int theValue) {
  if (buttonsActive) {
    selectInput("Select a file to process:", "fileSelected");
  }
}
void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    fm_scene4aka5 = new FrameManager();
    fm_scene4aka5.loadFile(selection.getAbsolutePath());

    // Quick n Dirty zum Debuggen: Ein und das selbe File für beide Szenen verwenden
    fm_scene7aka9 = new FrameManager();
    fm_scene7aka9.loadFile(selection.getAbsolutePath());


    initializeStuff();
    startNow = millis();
    frameCounter = 0;
    okGo = true;
  }
}

// Alles Zeug, was irgendwie initialisiert werden muss
void initializeStuff() {
  float[] tmp1 = fm_scene4aka5.getPos(0, 1);
  float[] tmp2 = fm_scene4aka5.getPos(0, 2);
  float[] tmp3 = fm_scene4aka5.getPos(0, 3);
  float[] tmp4 = fm_scene4aka5.getPos(0, 4);
  float[] tmp5 = fm_scene4aka5.getPos(0, 5);
  float[] tmp6 = fm_scene4aka5.getPos(0, 6);  
  int bodySize = 15;
  b1 = new Body(tmp1[0], tmp1[1], bodySize, decor.getColor(1));
  b2 = new Body(tmp2[0], tmp2[1], bodySize, decor.getColor(2));
  b3 = new Body(tmp3[0], tmp3[1], bodySize, decor.getColor(3));
  b4 = new Body(tmp4[0], tmp4[1], bodySize, decor.getColor(4));
  b5 = new Body(tmp5[0], tmp5[1], bodySize, decor.getColor(5));
  b6 = new Body(tmp6[0], tmp6[1], bodySize, decor.getColor(6));
  b1.setTranslation(transX, transY);
  b2.setTranslation(transX, transY);
  b3.setTranslation(transX, transY);
  b4.setTranslation(transX, transY);
  b5.setTranslation(transX, transY);
  b6.setTranslation(transX, transY);
  b1.setID("dancer1");
  b1.setScale(scalar);
  b2.setScale(scalar);
  b3.setScale(scalar);
  b4.setScale(scalar);
  b5.setScale(scalar);
  b6.setScale(scalar);
  defi.switchOnDefi(true); // Wenn das Signal abreist, Fake signal senden
  defi.registerDancer(b1);
  defi.registerDancer(b2);
  defi.registerDancer(b3);
  defi.registerDancer(b4);
  defi.registerDancer(b5);
  defi.registerDancer(b6);

  // Graph-Visualisierung
  b = new Beat1(width/2, height/2, 1);
  generator1 = new Generator(20);
  generator2 = new Generator(20);
  generator3 = new Generator(20);
  generator4 = new Generator(20);
  generator5 = new Generator(20);
  generator6 = new Generator(20);

  int waveLength = (int) (110f*scalar);
  wave1 = new Wave((int)transX, (int)transY+200, waveLength);
  wave1.setColor(color(decor.getColor(1), 200));
  wave2 = new Wave((int)transX, (int)transY+275, waveLength);
  wave2.setColor(color(decor.getColor(2), 200));
  wave3 = new Wave((int)transX, (int)transY+350, waveLength);
  wave3.setColor(color(decor.getColor(3), 200));
  wave4 = new Wave((int)transX, (int)transY+425, waveLength);
  wave4.setColor(color(decor.getColor(4), 200));
  wave5 = new Wave((int)transX, (int)transY+500, waveLength);
  wave5.setColor(color(decor.getColor(5), 200));
  wave6 = new Wave((int)transX, (int)transY+575, waveLength);
  wave6.setColor(color(decor.getColor(6), 200));
  defi.registerWave(generator1);
  defi.registerWave(generator2);
  defi.registerWave(generator3);
  defi.registerWave(generator4);
  defi.registerWave(generator5);
  defi.registerWave(generator6);

  wave1.setVisibility(false); 
  wave2.setVisibility(false); 
  wave3.setVisibility(false); 
  wave4.setVisibility(false); 
  wave5.setVisibility(true); 
  wave6.setVisibility(false);
  showCircleShow = false;   

  timeStamp = millis();
  stripes.reset();
}

// User Input durch die Tastatur
// -------------------------------------------------------------
void keyPressed() {
  if (key == 'p') { //Pause
    if (looping) {  
      noLoop();
      looping = false;
    } else {
      loop();
      looping = true;
    }
  }
  // Herzschlag durch Key triggern/faken (zum Debuggen);
  if (key == '1')
    if (showCircleShow) 
      defi.pokeBody(1, 0.05);
    else  
    defi.pokeWave(1, 0.05);
  if (key == '2')
    if (showCircleShow) 
      defi.pokeBody(2, 0.05);
    else  
    defi.pokeWave(2, 0.05);
  if (key == '3')
    if (showCircleShow) 
      defi.pokeBody(3, 0.05);
    else  
    defi.pokeWave(3, 0.05);
  if (key == '4')
    if (showCircleShow) 
      defi.pokeBody(4, 0.05);
    else  
    defi.pokeWave(4, 0.05);
  if (key == '5')
    if (showCircleShow) 
      defi.pokeBody(5, 0.05);
    else  
    defi.pokeWave(5, 0.05);
  if (key == '6')
    if (showCircleShow) 
      defi.pokeBody(6, 0.05);
    else  
    defi.pokeWave(6, 0.05);  

  if (key == 't') {
    thikness++;
    wave1.setThikness(thikness);
    wave2.setThikness(thikness);
    wave3.setThikness(thikness);
    wave4.setThikness(thikness);
    wave5.setThikness(thikness);
    wave6.setThikness(thikness);
  }
  if (key == 'g') {
    thikness--;
    wave1.setThikness(thikness);
    wave2.setThikness(thikness);
    wave3.setThikness(thikness);
    wave4.setThikness(thikness);
    wave5.setThikness(thikness);
    wave6.setThikness(thikness);
  }
  if (key == 'z') {
    scale = scale+0.1;
    wave1.setScale(scale);
    wave2.setScale(scale);
    wave3.setScale(scale);
    wave4.setScale(scale);
    wave5.setScale(scale);
    wave6.setScale(scale);
  }
  if (key == 'h') {
    scale = scale-0.1;
    wave1.setScale(scale);
    wave2.setScale(scale);
    wave3.setScale(scale);
    wave4.setScale(scale);
    wave5.setScale(scale);
    wave6.setScale(scale);
  }
  if (key == 'a') {
    angle = angle+0.02;
    wave1.setAngle(angle);
  }
  if (key == 'l') {
    wave2Height = wave2Height+1;
    wave2.setYTranslate(wave2Height);
  }
}