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
#define ALIMITSWITCH 1
#define ADIRECTION 7
#define ASTEP 5
#define AENABLE 4

#define DIAGNOSTICLED 28

volatile int panelAIsAtHome = 0;

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

void setup(){
  pinMode(ADIRECTION, OUTPUT);
  pinMode(ASTEP, OUTPUT);
  pinMode(AENABLE, OUTPUT);

  pinMode(DIAGNOSTICLED, OUTPUT);

  stepperA.setCurrentPosition(0);    

  stepperA.setEnablePin(AENABLE);
  stepperA.setCurrentPosition(1);  

  stepperA.setAcceleration(100);   
  stepperA.setMaxSpeed(3000);

  //panelBHome();

  delay(1000);

  Serial.begin(9600);  
}

void loop(){
  stepperA.run();

  stepperA.setMaxSpeed(2000);   
  stepperA.runToNewPosition(10000);
  //delay(5000);
  stepperA.runToNewPosition(-10000);  
}
