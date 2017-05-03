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
boolean resetedYet = false; // Hilfsvariable, die Tänzerinnen wieder an den Bühnenrand verschiebt

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
int thikness = 3;
float alpha = 120;
float scale = 1f;
float angle = 0f;
int wave2Height = 200;
Generator generator1 = null;
Generator generator2 = null;
Generator generator3 = null;
Generator generator4 = null;
Generator generator5 = null;
Generator generator6 = null;

Decoration decor = new Decoration();
FrameManager fm_scene4aka5;
FrameManager fm_scene7aka9;
Defibrillator defi = new Defibrillator(); // Lässt die Herzen schlagen, zur Not auch wenn das Xbee Signal ausfällt
int frameCounter = -1; // Dies sind die Frames aus dem Editor von uns und hat nichts mit den Frames von Processing zu tun! In diesem Sketch werden wir später die Koordinaten aus dem Editor Frame by Frame bzw. Sekunde für Sekunde bzw. Blatt für Blatt wiedergeben.

//long timeStamp;
//long timer;
long startNow = 0; // Diese Variable speichert den Zeitpunkt an welchem die Show gestartet wurde. Ist sozusagen, der Nullpunkt oder Referenzwert für das gesamte Timing der Visualisierung
int lastFullSec = 0;
boolean okGo = false; // start draw loop
int lastFrame = -1;
boolean showCircleShow = false;
boolean processXbee = false;

// mit diesen Variablen kann die virtuelle Performance beamergerecht verschoben werden
float transX = 240; 
float transY = 80;
float scalar = 6;
String loadFile_Sc4 = "/Users/florianguldenpfennig/Desktop/volksoper_ballet/party_sc4_300-359.csv";
String loadFile_Sc7 = "/Users/florianguldenpfennig/Desktop/volksoper_ballet/party_sc7_548-636.csv";
int fRate = 60; // n frames per Sekunde sollen angzeigt werden


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

  // Mukke. Das HQ File geht auch ohne Verlust an Framerate
  file = new SoundFile(this, "/Users/florianguldenpfennig/Desktop/volksoper_ballet/mukke_hq.wav");


  cp5.addBang("Start")
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
} // end of setup

void serialEvent(Serial p) {
  if (processXbee)
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
    //fill(255, 0, 0);
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

  // Hintergrundverziehrung
  //stripes.displayStripes();
  // Deute den Umriss der Bühne an zur Orientierung
  //stage.displayStage(1);


  if (okGo) {   

    // zum Debuggen
    showMetaData(false);

    // Diese Zeile genauso reingeben, wenn Herzschläge imitiert werden sollen im Notfall. Parameter so beibehalten und nicht händisch auf true oder false setzen.
    defi.onDuty(showCircleShow);

    defi.setGeneralActivityLevel(conductor.getPhysical((int)(millis()-startNow)));

    // Musik anwerfen
    if (!isPlaying) {
      file.play();
      isPlaying = true;
    }

    //stripes.reset();
    // Alle Sekunde gibts ein Update - 100m0 ms vorläufig hard coded.
    // if ( (millis() - timer >= 1000) && frameCounter<fm.getNumberOfFrames()-1) {

    // Jede Sekunde updaten bis zum Ende  
    //if ( frameCount%fRate==0 && frameCounter<fm_scene4aka5.getNumberOfFrames()-1 && okGo) {


    // timing Entscheider: Immer wenn eine neue Sekunde anbricht, schauen welche Renderings dem Stück entsprechend aktiv sein sollen  
    // Jede Sekunde wird die Variable FrameCounter um 1 erhöht. FrameCounter ist sozusagen die Software Variante von Attila, der vorgibt, welcher Zeitpunkt gerade in der Choepographie ist.      
    if ((int)((millis()-startNow)/1000)>lastFullSec) {  
      lastFullSec = (int)((millis()-startNow)/1000);

      frameCounter++;  // ACHTUNG!: Schlechte Wortwahl von mir - frameCount und frameConunter
      // sind verschiedene Dinge. frameCounter bezieht sich auf eine Zeile in Attilas Koordinaten CSV File
      // und entspricht einer Sekunde. Wie lange ein frameCount dauert hängt von der Framerate ab
      //println("framecounter: "+frameCounter);      

      // Die ersten 12 Sekunden nur eine Linie ohne Heartbeat anzeigen laut Attila
      if (frameCounter>12) {
        defi.switchOnDefi(true);
        processXbee = true;
      }

      // Einstellen, je nach Szene, 'wer' alles sichtbar ist
      //int con = conductor.whichSceneIsIt((int)(millis()-startNow)); // Szene/Abschnitt 4,5 und 9 sollen als Kreise gerendert werden. Alle anderen Graphen.
      int con = conductor.whichSceneIsIt(frameCounter);
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
        showCircleShow = true;   
        break;     
      case 5: 
        wave1.setVisibility(false); 
        wave2.setVisibility(false); 
        wave3.setVisibility(true); 
        wave4.setVisibility(true); 
        wave5.setVisibility(false); 
        wave6.setVisibility(false);
        showCircleShow = false;
        break;        
      case 6: 
        wave1.setVisibility(false); 
        wave2.setVisibility(false); 
        wave3.setVisibility(false); 
        wave4.setVisibility(false); 
        wave5.setVisibility(true); 
        wave6.setVisibility(true);
        showCircleShow = false;        
        break;   
      case 7: 
        wave1.setVisibility(true); 
        wave2.setVisibility(true); 
        wave3.setVisibility(false); 
        wave4.setVisibility(false); 
        wave5.setVisibility(false); 
        wave6.setVisibility(true);
        showCircleShow = false;        
        break;        
      case 8:
        showCircleShow = true;    
        break;
      case 9: 
        wave1.setVisibility(false); 
        wave2.setVisibility(false); 
        wave3.setVisibility(true); 
        wave4.setVisibility(false); 
        wave5.setVisibility(false); 
        wave6.setVisibility(false);
        showCircleShow = false;        
        break;      
      case 10: 
        wave1.setVisibility(false); 
        wave2.setVisibility(false); 
        wave3.setVisibility(true); 
        wave4.setVisibility(true); 
        wave5.setVisibility(false); 
        wave6.setVisibility(false);
        showCircleShow = false;        
        break;     
      case 11: 
        wave1.setVisibility(false); 
        wave2.setVisibility(false); 
        wave3.setVisibility(false); 
        wave4.setVisibility(false); 
        wave5.setVisibility(true); 
        wave6.setVisibility(false);
        showCircleShow = false;   
        break;
      }
      //timer = millis();

      //background(0);
      //stripes.displayStripes();
      //stage.displayStage(1); 

      // reset bewirkt, dass die Parameter neu berechnet werden
      // somit erfolgt hierdurch also ein update der Grafik
      b1.reset();
      b2.reset();
      b3.reset();
      b4.reset();
      b5.reset();
      b6.reset();
    } // end of timing Entscheider



    // Kreis-Darstellung, bei welcher alle 6 TänzerInnen auf der Bühne sind
    if (showCircleShow) {
      //int con = conductor.whichSceneIsIt((int)(millis()-startNow)); // Abschnitt/Szene 5 und 9 sollen als Kreise gerendert werden. Alle anderen Graphen.
      int con = conductor.whichSceneIsIt(frameCounter);


      float[] tmp1 = new float[] {-1, -1};
      float[] tmp2 = new float[] {-1, -1};
      float[] tmp3 = new float[] {-1, -1};
      float[] tmp4 = new float[] {-1, -1};
      float[] tmp5 = new float[] {-1, -1};
      float[] tmp6 = new float[] {-1, -1};


      if (con == 4) {
        try {
          //println("COUNT: "+ (frameCounter-180));
          tmp1 = fm_scene4aka5.getPos(frameCounter-180, 1);   
          tmp2 = fm_scene4aka5.getPos(frameCounter-180, 2);
          tmp3 = fm_scene4aka5.getPos(frameCounter-180, 3);
          tmp4 = fm_scene4aka5.getPos(frameCounter-180, 4);
          tmp5 = fm_scene4aka5.getPos(frameCounter-180, 5);
          tmp6 = fm_scene4aka5.getPos(frameCounter-180, 6);
        } 
        catch (Exception e) {
          println("Framemanager4 wollte mehr Frames laden als vorhanden: "+(frameCounter));
        }
      }

/*
      if (con == 5) {
        try {
          //println("COUNT: "+ (frameCounter-180));
          tmp1 = fm_scene4aka5.getPos(frameCounter-185, 1);   
          tmp2 = fm_scene4aka5.getPos(frameCounter-185, 2);
          tmp3 = fm_scene4aka5.getPos(frameCounter-185, 3);
          tmp4 = fm_scene4aka5.getPos(frameCounter-185, 4);
          tmp5 = fm_scene4aka5.getPos(frameCounter-185, 5);
          tmp6 = fm_scene4aka5.getPos(frameCounter-185, 6);
        } 
        catch (Exception e) {
          println("Framemanager4 wollte mehr Frames laden als vorhanden: "+(frameCounter));
        }
      }*/
      if (con == 8) {
        if (!resetedYet) {
          resetedYet = true;
          b1.resetBeginX(); b2.resetBeginX(); b3.resetBeginX(); b4.resetBeginX(); b5.resetBeginX(); b6.resetBeginX();
        }
        
        try {
          tmp1 = fm_scene7aka9.getPos(frameCounter-348, 1);
          tmp2 = fm_scene7aka9.getPos(frameCounter-348, 2); 
          tmp3 = fm_scene7aka9.getPos(frameCounter-348, 3);    
          tmp4 = fm_scene7aka9.getPos(frameCounter-348, 4);  
          tmp5 = fm_scene7aka9.getPos(frameCounter-348, 5);      
          tmp6 = fm_scene7aka9.getPos(frameCounter-348, 6);
        } 
        catch (Exception e) {
          println("Framemanager7 wollte mehr Frames laden als vorhanden: "+(frameCounter));
        }
      }
      
      // Muss mit jedem Frame ausgeführt werden, denn hier werden die 
      // Objekte inklusive deren Koordinaten letztendlich geupdated und geredndert.
      if (tmp1[0]!=-1) {
        b1.danceToPos(tmp1[0], tmp1[1]);
        b1.display();
      }
      if (tmp2[0]!=-1) {
        b2.danceToPos(tmp2[0], tmp2[1]);
        b2.display();
      }
      if (tmp3[0]!=-1) {
        b3.danceToPos(tmp3[0], tmp3[1]);
        b3.display();//println("Frame: "+frameCounter+"   pos: "+tmp3[0]+" - "+tmp3[1]);  
        
      }
      if (tmp4[0]!=-1) {
        b4.danceToPos(tmp4[0], tmp4[1]); 
        b4.display();
      }
      if (tmp5[0]!=-1) {
        b5.danceToPos(tmp5[0], tmp5[1]);
        b5.display(); 

      }
      if (tmp6[0]!=-1)
      {
        //println("Frame: "+frameCounter+"   pos: "+tmp3[0]+" - "+tmp3[1]);  
        //b6.debug(6,frameCounter,tmp6[0], tmp6[1]);
        b6.danceToPos(tmp6[0], tmp6[1]);
        b6.display();
      }
    } else {

      // Normalen Graphen anzeigen
      wave1.addValueAndDisplay(8*generator1.update());
      wave2.addValueAndDisplay(8*generator2.update());
      wave3.addValueAndDisplay(8*generator3.update());
      wave4.addValueAndDisplay(8*generator4.update());
      wave5.addValueAndDisplay(8*generator5.update());
      wave6.addValueAndDisplay(8*generator6.update());
    }

    // Ein bißchen überblenden zwischen den Szenen ....
    // Die Werte sind Hard-codiert und können z.B. in der Conductor Klasse nachgelesen werden
    boolean resetFader = true;
    if (frameCounter>180-3&&frameCounter<180) {
      fader.activateFullFader(5);
      resetFader = false;
    }
    if (frameCounter>224-3&&frameCounter<224) {
      fader.activateFullFader(5);
      resetFader = false;
    }    
    if (frameCounter>348-3&&frameCounter<348) {
      fader.activateFullFader(5);
      resetFader = false;
    }
    if (frameCounter>398-3&&frameCounter<398) {
      fader.activateFullFader(5);
      resetFader = false;
    }     

    if (frameCounter>566) {
      fader.blackOut(5); // Ende der Show
      resetFader = false;
    }
    
    if (resetFader)
      fader.resetFader();
  }
} // end of draw()

// Debugging und vor allem Timing darstellen
void showMetaData(boolean newFrame) {
  if (newFrame) 
    fill(0, 255, 0);
  else  
  fill(255);
  text("Time: "+ Float.toString((millis()-startNow)/1000f)+"   Framecounter(Attila): "+ frameCounter + "   Framecount(processing): "+ frameCount +"    Accomplished Framerate: "+frameRate, 20, height-20);
}

// Falls ein Load Button zum Debuggen angezeigt werden soll (für den Developer Mode)
public void Start(int theValue) {
  if (buttonsActive) {
    // Manuell File auswählen
    //selectInput("Select a file to process:", "fileSelected");
    fileSelected(new File(loadFile_Sc4));
    fileSelected(new File(loadFile_Sc7));
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());

    // quick and dirty eine hard-coded Unterscheidung, ob es sich um das erste oder zweite CSV file handelt
    if (selection.getAbsolutePath().contains("sc4")) {
      fm_scene4aka5 = new FrameManager();
      fm_scene4aka5.loadFile(selection.getAbsolutePath());
    } else {
      // Quick n Dirty zum Debuggen: Ein und das selbe File für beide Szenen verwenden
      fm_scene7aka9 = new FrameManager();
      fm_scene7aka9.loadFile(selection.getAbsolutePath());
      initializeStuff();
      startNow = millis();
      frameCounter = 178; // Hier die werte verändern beim Debuggen
      okGo = true;
    }
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
  int bodySize = (int) (15*0.75); // 25% vom ursprünglichen Wert
  b1 = new Body(tmp1[0], tmp1[1], bodySize, decor.getColor(0));
  b2 = new Body(tmp2[0], tmp2[1], bodySize, decor.getColor(1));
  b3 = new Body(tmp3[0], tmp3[1], bodySize, decor.getColor(2));
  b4 = new Body(tmp4[0], tmp4[1], bodySize, decor.getColor(3));
  b5 = new Body(tmp5[0], tmp5[1], bodySize, decor.getColor(4));
  b6 = new Body(tmp6[0], tmp6[1], bodySize, decor.getColor(5));
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
  defi.switchOnDefi(false); // Wenn das Signal abreist, Fake signal senden
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

  int waveLength = (int) (110f*scalar); // xxx
  wave1 = new Wave((int)transX, (int)transY+200, waveLength);
  wave1.setColor(color(decor.getColor(0))); 
  wave1.setAlpha(alpha); 
  wave1.setThikness(thikness);
  wave2 = new Wave((int)transX, (int)transY+275, waveLength);
  wave2.setColor(color(decor.getColor(1))); 
  wave2.setAlpha(alpha); 
  wave2.setThikness(thikness);
  wave3 = new Wave((int)transX, (int)transY+350, waveLength);
  wave3.setColor(color(decor.getColor(2))); 
  wave3.setAlpha(alpha); 
  wave3.setThikness(thikness);
  wave4 = new Wave((int)transX, (int)transY+425, waveLength);
  wave4.setColor(color(decor.getColor(3))); 
  wave4.setAlpha(alpha); 
  wave4.setThikness(thikness);
  wave5 = new Wave((int)transX, (int)transY+500, waveLength);
  wave5.setColor(color(decor.getColor(4))); 
  wave5.setAlpha(alpha); 
  wave5.setThikness(thikness);
  wave6 = new Wave((int)transX, (int)transY+575, waveLength); 
  wave6.setColor(color(decor.getColor(5))); 
  wave6.setAlpha(alpha); 
  wave6.setThikness(thikness);
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
  wave5.setVisibility(false); 
  wave6.setVisibility(false);
  showCircleShow = false;   

  //timeStamp = millis();
  //stripes.reset();
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
  if (key == 's') {
    stripes.reset();
  }
  if (key == 'b') {
    Start(123);
  }
}