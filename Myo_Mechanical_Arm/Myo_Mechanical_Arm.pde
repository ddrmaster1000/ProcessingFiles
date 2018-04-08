import de.voidplus.myo.*;
import processing.serial.*;

Serial myPort;
Myo myo;
int x;
int y;
int state = 0;
int lengthArrY = 3;
int[] arrY = {90,90,90};
void setup() {
  //size(800, 400);
  background(255);
  String portName = Serial.list()[1];
  myPort = new Serial (this, portName, 9600);
  
  myo = new Myo(this);

}

void draw() {
  background(255);
      // println("Accelerometer Data" + myo.getAccelerometer()); //actually Gyroscope Data
       delay(20);

              println(myo.getPose().getType());

  
       switch (myo.getPose().getType()) {
         case REST:
           state = 0; //do nothing
           sendDatatoArduino();
           break;
           
        case FINGERS_SPREAD:
           state = 1;
           sendDatatoArduino();
           break;
           
         case FIST:
           state = 2;
           sendDatatoArduino();
           break;
           
         case WAVE_OUT:
           state = 3;
           sendDatatoArduino();
           break;
           
      }
      

}


void sendDatatoArduino()
{
          x = int(myo.getAccelerometer().y*100+65);
          if(x < 0){
            x=0;
          }
          else if(x > 80){
            x = 80;
          }

          
         y =  int(myo.getAccelerometer().x*100+90);
         if(y > 180)
         {
            y=180; 
         }
         else if(y <0)
         {
           y = 0;
         }
         
         int total = 0;
         for(int i =0; i < lengthArrY-1; i++)
         {
           arrY[i+1] = arrY[i];
         }
         arrY[0]=y;
         for(int i =0; i<lengthArrY; i++)
         {
            total = arrY[i] + total;  
         }
         y = total/lengthArrY;
         
         //if(y >= 0 && y <= 20){
         //   y = 1; 
         // }
         // else if(y > 20 && y <= 40){
         //   y = 2; 
         // }
         // else if(y > 60 && y <= 80){
         //   y = 3; 
         // }
         // else if(y > 80 && y <= 100){
         //   y = 4; 
         // }          
         // else if(y > 100 && y <= 120){
         //   y = 5; 
         // }
         // else if(y > 120 && y <= 140){
         //   y = 6; 
         // }
         // else if(y > 140 && y <= 160){
         //   y = 7; 
         // }
         // else if(y > 160 && y <= 180){
         //   y = 8; 
         // }
          
         
         
          println("Y values: " +y);
          //ground = 180, ceiling = 0.
          println("X vaules: " + x);
          //left = 80; right = 0;
          
           myPort.write('<');
           myPort.write(x);
           myPort.write(y);
           myPort.write(state);
           myPort.write('>');
}















// ==========================================================
// Executable commands:

void mousePressed() {
  if (myo.hasDevices()) {
    //myo.vibrate();
    //myo.requestRssi();
    //myo.requestBatteryLevel();
    
 //  println("Gyroscope" + myo.getGyroscope());
     println("Accelerometer" + myo.getAccelerometer());

  }
}


// ==========================================================
// Application lifecycle:

void myoOnPair(Device myo, long timestamp) {
  println("Sketch: myoOnPair() has been called"); 
  int deviceId             = myo.getId();
  int deviceBatteryLevel   = myo.getBatteryLevel();
  int deviceRssi           = myo.getRssi();
  String deviceFirmware    = myo.getFirmware();
}
void myoOnUnpair(Device myo, long timestamp) {
  println("Sketch: myoOnUnpair() has been called");
}

void myoOnConnect(Device myo, long timestamp) {
  println("Sketch: myoOnConnect() has been called");
  int deviceId             = myo.getId();
  int deviceBatteryLevel   = myo.getBatteryLevel();
  int deviceRssi           = myo.getRssi();
  String deviceFirmware    = myo.getFirmware();
}
void myoOnDisconnect(Device myo, long timestamp) {
  println("Sketch: myoOnDisconnect() has been called");
}

void myoOnWarmupCompleted(Device myo, long timestamp) {
  println("Sketch: myoOnWarmupCompleted() has been called");
}

void myoOnArmSync(Device myo, long timestamp, Arm arm) {
  println("Sketch: myoOnArmSync() has been called");

  switch (arm.getType()) {
  case LEFT:
    println("Left arm");
    break;
  case RIGHT:
    println("Right arm");
    break;
  default:
    println("Unknown arm");
    break;
  }
}

void myoOnArmUnsync(Device myo, long timestamp) {
  println("Sketch: myoOnArmUnsync()");
}

void myoOnLock(Device myo, long timestamp) {
  println("Sketch: myoOnLock() has been called");
}
  
void myoOnUnLock(Device myo, long timestamp) {
  println("Sketch: myoOnUnLock() has been called");
}


// ----------------------------------------------------------
// Gestures or poses:

void myoOnPose(Device myo, long timestamp, Pose pose) {
  println("Sketch: myoOnPose() has been called");
  switch (pose.getType()) {
    case REST:
      println("Pose: REST");
      break;
    case FIST:
      println("Pose: FIST");
      break;
    case FINGERS_SPREAD:
      println("Pose: FINGERS_SPREAD");
      break;
    case DOUBLE_TAP:
      println("Pose: DOUBLE_TAP");
      break;
    case WAVE_IN:
      println("Pose: WAVE_IN");
      break;
    case WAVE_OUT:
      println("Pose: WAVE_OUT");
      break;
  }
}


// ----------------------------------------------------------
// Additional information:

void myoOnRssi(Device myo, long timestamp, int rssi) {
  println("Sketch: myoOnRssi() has been called, rssi: " + rssi);
}

void myoOnBatteryLevelReceived(Device myo, long timestamp, int batteryLevel) {
  println("Sketch: myoOnBatteryLevel() has been called, batteryLevel: " + batteryLevel);
}


// ----------------------------------------------------------
// Data streams:

void myoOnOrientationData(Device myo, long timestamp, PVector orientation) {
  // println("Sketch: myoOnOrientationData() has been called");
}

void myoOnAccelerometerData(Device myo, long timestamp, PVector accelerometer) {
  // println("Sketch: myoOnAccelerometerData() has been called");
}

void myoOnGyroscopeData(Device myo, long timestamp, PVector gyroscope) {
  // println("Sketch: myoOnGyroscopeData() has been called");
}

void myoOnEmgData(Device myo, long timestamp, int[] data) {
  // println("Sketch: myoOnEmgData() has been called");
}


// ==========================================================
// Alternatively you can use a global callback:

void myoOn(Myo.Event event, Device myo, long timestamp) {  
  switch(event) {
  case PAIR:
    // println("Sketch: myoOn() of type 'PAIR' has been called");
    break;
  case UNPAIR:
    // println("Sketch: myoOn() of type 'UNPAIR' has been called");
    break;
  case CONNECT:
    // println("Sketch: myoOn() of type 'CONNECT' has been called");
    String firmware = myo.getFirmware();
    int deviceId = myo.getId();
    break;
  case DISCONNECT:
    // println("Sketch: myoOn() of type 'DISCONNECT' has been called");
    break;
  case ARM_SYNC:
    // println("Sketch: myoOn() of type 'ARM_SYNC' has been called");
    break;
  case ARM_UNSYNC:
    // println("Sketch: myoOn() of type 'ARM_UNSYNC' has been called");
    break;
  case WARMUP_COMPLETED:
    // println("Sketch: myoOn() of type 'WARMUP_COMPLETED' has been called");
    break;
  case POSE:
    switch (myo.getPose().getType()) {
    case FIST:
      // println("Pose: FIST");
      break;
    }
    // println("Sketch: myoOn() of type 'POSE' has been called");
    break;
  case LOCK:
    // println("Sketch: myoOn() of type 'LOCK' has been called");
  case UNLOCK:
    // println("Sketch: myoOn() of type 'UNLOCK' has been called");
    break;
  case BATTERY_LEVEL:
    // println("Sketch: myoOn() of type 'BATTERY_LEVEL' has been called");
    int batteryLevel = myo.getBatteryLevel();
    break;
  case RSSI:
    // println("Sketch: myoOn() of type 'RSSI' has been called");
    int rssi = myo.getRssi();
    break;
  case ORIENTATION_DATA:
    // println("Sketch: myoOn() of type 'ORIENTATION_DATA' has been called");
    PVector orientation = myo.getOrientation();
    break;
  case ACCELEROMETER_DATA:
    // println("Sketch: myoOn() of type 'ACCELEROMETER_DATA' has been called");
    PVector accelerometer = myo.getAccelerometer();
    break;
  case GYROSCOPE_DATA:
    // println("Sketch: myoOn() of type 'GYROSCOPE_DATA' has been called");
    PVector gyroscope = myo.getGyroscope();
    break;
  case EMG_DATA:
    // println("Sketch: myoOn() of type 'EMG_DATA' has been called");
    int[] data = myo.getEmg();
    break;
  }
}