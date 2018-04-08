/**
  * An FFT object is used to convert an audio signal into its frequency domain representation. This representation
  * lets you see how much of each frequency is contained in an audio signal. Sometimes you might not want to 
  * work with the entire spectrum, so it's possible to have the FFT object calculate average frequency bands by 
  * simply averaging the values of adjacent frequency bands in the full spectrum. There are two different ways 
  * these can be calculated: <b>Linearly</b>, by grouping equal numbers of adjacent frequency bands, or 
  * <b>Logarithmically</b>, by grouping frequency bands by <i>octave</i>, which is more akin to how humans hear sound.
  * <br/>
  * This sketch illustrates the difference between viewing the full spectrum, 
  * linearly spaced averaged bands, and logarithmically spaced averaged bands.
  * <p>
  * From top to bottom:
  * <ul>
  *  <li>The full spectrum.</li>
  *  <li>The spectrum grouped into 30 linearly spaced averages.</li>
  *  <li>The spectrum grouped logarithmically into 10 octaves, each split into 3 bands.</li>
  * </ul>
  *
  * Moving the mouse across the sketch will highlight a band in each spectrum and display what the center 
  * frequency of that band is. The averaged bands are drawn so that they line up with full spectrum bands they 
  * are averages of. In this way, you can clearly see how logarithmic averages differ from linear averages.
  * <p>
  * For more information about Minim and additional features, visit http://code.compartmental.net/minim/
  */

import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*;

Serial arduinoPort;

Minim minim;
AudioPlayer jingle;
FFT fftLin;
FFT fftLog;

static float numSpectrumGroups = 4;    // 4 seems to isolate bass best
static String songName = "alive.mp3";  // Song from 'data/songs/' folder to play

ArrayList<String> songs = new ArrayList<String>();

float height3;
float height23;
float spectrumScale = 4;
float o_arduino = 0;
PFont font;

void setup() {
  File directory = new File(dataPath("songs/"));
  for (File file : directory.listFiles()) {
    songs.add(file.getName());
  }
  
  int songIndex = -1;
  if (songName != null && songs.indexOf(songName) >= 0) {
    songIndex = songs.indexOf(songName);
  } else if (songIndex < 0) {
    songIndex = (int) random(songs.size());
  }
  
  String portName = Serial.list()[0];                //Begin port for sending
  arduinoPort = new Serial(this, portName, 600);  //Sames
  
  size(512, 480);
  height3 = height / 3;
  height23 = 2 * height / 3;
 
  minim = new Minim(this);
  jingle = minim.loadFile("songs/" + songs.get(songIndex), 1024);
  
  // loop the file
  jingle.loop();
  
  // create an FFT object that has a time-domain buffer the same size as jingle's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be 1024. 
  // see the online tutorial for more info.
  fftLin = new FFT(jingle.bufferSize(), jingle.sampleRate());
  
  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  fftLin.linAverages(30);
  
  // create an FFT object for calculating logarithmically spaced averages
  fftLog = new FFT(jingle.bufferSize(), jingle.sampleRate());
  
  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages
  fftLog.logAverages(22, 3);
  
  rectMode(CORNERS);
  font = loadFont("ArialMT-12.vlw");
}

void draw() {
  background(0);
  
  textFont(font);
  textSize(18);
 
  float centerFrequency = 0;
  
  // perform a forward FFT on the samples in jingle's mix buffer
  // note that if jingle were a MONO file, this would be the same as using jingle.left or jingle.right
  fftLin.forward(jingle.mix);
  fftLog.forward(jingle.mix);

  
  // no more outline, we'll be doing filled rectangles from now
  noStroke();
  
  // draw the linear averages
  {
    // since linear averages group equal numbers of adjacent frequency bands
    // we can simply precalculate how many pixel wide each average's 
    // rectangle should be.
    int w = int(width/fftLin.avgSize());
    for (int i = 0; i < numSpectrumGroups; i++) {
      // if the mouse is inside the bounds of this average,
      // print the center frequency and fill in the rectangle with red
      if (mouseX >= i * w && mouseX < i * w + w) {
        centerFrequency = fftLin.getAverageCenterFrequency(i);
        
        fill(255, 128);
        text("Linear Average Center Frequency: " + o_arduino, 100, height23 - 25);
        
        fill(255, 0, 0);
      } else {
          fill(255);
      }
      
      o_arduino = fftLin.getAvg(i)*spectrumScale + o_arduino;
      // draw a rectangle for each average, multiply the value by spectrumScale so we can see it better
      rect(i * w, height23, i * w + w, height23 - fftLin.getAvg(i) * spectrumScale);
    }
  }
  
  text("Testing: " + o_arduino, 5, height23 + 25);
  delay(2);
  
  o_arduino = o_arduino / numSpectrumGroups;
  println(log(o_arduino) / log(1.05));
  arduinoPort.write((byte) (long) o_arduino);
}