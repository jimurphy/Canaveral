Canaveral
=========

A software suite for the Satellites piece.
This suite features a program designed to receive Open Sound Control messages and output serial commands and a program designed
to receive the serial commands, parse them, and use the serial messages to control two stepper motors.

The suite's flow is as follows:
1) iPad app with 'satellites' app outputs OSC over WiFi.
2) Raspberry Pi attached to WiFi router runs the code in the canaveral_chuck folder, outputting serial messages over USB.
3) Arduino Mega (1280 or 2560) receives incoming serial, parses it, and adjusts two stepper motors' speeds and directions accordingly.
