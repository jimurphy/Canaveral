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

volatile int panelAIsAtHome = 0;
volatile int panelBIsAtHome = 0;

String inString = "";
boolean aMsg = false;
boolean bMsg = false;

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
    Serial.println("WAIT");
    default:
      readerFSM = _1; 
    case _1:
      if(readByte == 'A'){
        aMsg = true;
        readerFSM = _2;
        Serial.println("A message"); 
      }
      else if(readByte == 'B'){
        bMsg = true;
        readerFSM = _2;
        Serial.println("B message");        
      }
      else{
        readerFSM = _WAIT;
      }
      break;
    case _2:
      if(readByte == 'X'){
        readerFSM = _3;
        Serial.println("Expecting steps from home"); 
      }
      else if(readByte == 'Y'){
        readerFSM = _3;
        Serial.println("Expecting speed"); 
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
        readerFSM = _WAIT;  
        digitalWrite(13,HIGH);
        delay(1000);
        digitalWrite(13,LOW);
        readByte = 0;
        aMsg = false;
        bMsg = false;

        Serial.println(inString.toInt());
        Serial.print("String: ");
        Serial.println(inString);
        // clear the string for new input:
        inString = "";         
      }
      else{
        readerFSM = _WAIT;  
      }
     break; 
    }
  }
}
