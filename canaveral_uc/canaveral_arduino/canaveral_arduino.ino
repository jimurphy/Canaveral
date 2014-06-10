//Canaveral Arduino Code
//Reads messages in from ChucK Canaveral program.
//Intended to be used with an Arduino Mega or Mega 2560. 
//If used with a Due, check level shifting on pins
//Message structure: A X n n n \n (A panel, Speed message, speed = nnn)
//Another message example: B Y n n n n \n (B panel, Angle message, Move to pos nnnn)
//jimwmurphy.com

#include <AccelStepper.h>
#include <avr/io.h>

//Panel A and B pins
#define ALIMITSWITCH 2
#define ADIRECTION 7
#define ASTEP 5
#define AENABLE 4

#define BLIMITSWITCH 3
#define BDIRECTION 13
#define BSTEP 11
#define BENABLE 9

#define DIAGNOSTICLED 28

volatile int panelAIsAtHome = 0;
volatile int panelBIsAtHome = 0;

int stepperSpeed = 5000;
int maxStepperSpeed = 5000;

int stepsPerRevolution = 10000;
int currentAngleA = 0;
int currentAngleB = 0;

String inString = "";
boolean aMsg = false;
boolean bMsg = false;
boolean angleMsg = false;
boolean speedMsg = false;

enum tag_fsm { 
  _WAIT,
  _1,
  _2,
  _3
} 
readerFSM = _WAIT;

char readByte = 0;                     
int inChar = 0;

AccelStepper stepperA(AccelStepper::DRIVER,ASTEP,ADIRECTION);
AccelStepper stepperB(AccelStepper::DRIVER,BSTEP,BDIRECTION);

void setup(){
  Serial.begin(9600);

  pinMode(ADIRECTION, OUTPUT);
  pinMode(ASTEP, OUTPUT);
  pinMode(AENABLE, OUTPUT);
  pinMode(BDIRECTION, OUTPUT);
  pinMode(BSTEP, OUTPUT);
  pinMode(BENABLE, OUTPUT);
  pinMode(DIAGNOSTICLED, OUTPUT);

  stepperA.setEnablePin(AENABLE);
  stepperB.setEnablePin(BENABLE);

  attachInterrupt(0, homeA, FALLING);
  attachInterrupt(1, homeB, FALLING);  

  digitalWrite(DIAGNOSTICLED, HIGH);
  //panelAHome();
  //panelBHome();
  stepperA.setCurrentPosition(0); //this also sets speed to 0
  stepperB.setCurrentPosition(0); //this also sets speed to 0
  stepperA.setAcceleration(100); 
  panelAIsAtHome = 1;
  panelBIsAtHome = 1;  
  delay(1000);
  digitalWrite(DIAGNOSTICLED, LOW);  
}

void homeA(){
  panelAIsAtHome = 1;
}

void homeB(){
  panelBIsAtHome = 1;
}

void panelAHome(){
  stepperA.setSpeed(200);
  while(panelAIsAtHome != 1){
    stepperA.runSpeed();
  }
  panelAIsAtHome = 0;
  stepperA.setCurrentPosition(0); //this also sets speed to 0
}

void panelBHome(){
  stepperB.setSpeed(200);  
  while(panelBIsAtHome != 1){
    stepperB.runSpeed();
  }
  panelBIsAtHome = 0;
  stepperB.setCurrentPosition(0); //this also sets speed to 0
}

void loop(){
  fsm();

  stepperA.run();
  stepperB.run();

  currentAngleA = stepperA.currentPosition()%stepsPerRevolution;
  currentAngleB = stepperB.currentPosition()%stepsPerRevolution;

  stepperB.currentPosition();
}

void fsm(){
  while (Serial.available()) {
    inChar = Serial.read();
    readByte = (char)inChar;

    switch(readerFSM){
    case _WAIT:
    default:
      readerFSM = _1; 
    case _1:
      if(readByte == 'A'){
        aMsg = true;
        readerFSM = _2;
      }
      else if(readByte == 'B'){
        bMsg = true;
        readerFSM = _2;
      }
      else{
        readerFSM = _WAIT;
      }
      break;
    case _2:
      if(readByte == 'X'){
        angleMsg = true;
        readerFSM = _3;
      }
      else if(readByte == 'Y'){
        speedMsg = true;
        digitalWrite(DIAGNOSTICLED, HIGH);  
        delay(300);
        digitalWrite(DIAGNOSTICLED, LOW);      
        readerFSM = _3;
      }      
      else{
        readerFSM = _WAIT;
      }
      break;  
    case _3:
      if (isDigit(inChar)) {
        inString += (char)inChar; 
      }
      else if(readByte == '\n'){
        //if panel A
        if(aMsg == true){
          if(angleMsg == true){
            //set position to angle relative to 0 (good if pos. was high from speedrun)
            stepperA.setCurrentPosition(currentAngleA); //this also sets speed to 0 

            //update panel angle target
            stepperA.setMaxSpeed(stepperSpeed);
            stepperA.moveTo(map(inString.toInt(), -180, 180, -1*(stepsPerRevolution/2), stepsPerRevolution/2));
          }
          else if(speedMsg == true){
            //set destination really high, change speed
            int aSpeed = inString.toInt();
            if(aSpeed > 100){
              map(aSpeed, 100, 200, 0, maxStepperSpeed); 
              stepperA.setMaxSpeed(aSpeed);   
              stepperA.moveTo(1000000);              
            }
            else if(aSpeed < 100){
              map(aSpeed, 0, 100, -maxStepperSpeed, 0);
              stepperA.setMaxSpeed(aSpeed);
              stepperA.moveTo(-1000000);              
            }
          }
        }
        //if panel B
        if(bMsg == true){
          if(angleMsg == true){
            //set position to angle relative to 0 (good if pos. was high from speedrun)            
            stepperB.setCurrentPosition(currentAngleB); //this also sets speed to 0             
            //update panel angle target
            stepperB.setMaxSpeed(stepperSpeed);
            stepperB.moveTo(inString.toInt());
          }
          else if(speedMsg == true){
            //set destination really high, change speed
            int bSpeed = inString.toInt();
            if(bSpeed > 100){
              map(bSpeed, 100, 200, 0, maxStepperSpeed); 
              stepperB.setMaxSpeed(bSpeed);
              stepperB.moveTo(1000000);              
            }
            else if(bSpeed < 100){
              map(bSpeed, 0, 100, -maxStepperSpeed, 0);
              stepperB.setMaxSpeed(bSpeed);
              stepperB.moveTo(-1000000);              
            }
          }
        }        
        readerFSM = _WAIT;
        readByte = 0;
        aMsg = false;
        bMsg = false;
        angleMsg = false;
        speedMsg = false;
        inString = "";         
      }
      else{
        readerFSM = _WAIT;  
      }
      break; 
    }
  }
}

