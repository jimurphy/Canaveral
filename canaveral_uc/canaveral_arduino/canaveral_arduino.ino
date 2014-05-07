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
}

void homeA(){
  panelAIsAtHome = 1;
}

void homeB(){
  panelBIsAtHome = 1;
}

void loop(){
  fsm();
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
        speedMsg = true;
        readerFSM = _3;
      }
      else if(readByte == 'Y'){
        angleMsg = true;
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
             //update panel angle target
          }
          else if(speedMsg == true){
            //set destination really high, change speed
          }
        }
        //if panel B
        
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
