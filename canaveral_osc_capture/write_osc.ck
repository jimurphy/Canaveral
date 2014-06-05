FileIO file;
OscRecv recv;

1337 => recv.port;
recv.listen();

recv.event( "/panelOne/angle, f" ) @=> OscEvent paneloneangle;
recv.event( "/panelTwo/angle, f" ) @=> OscEvent paneltwoangle;
recv.event( "/panelOne/speed, f" ) @=> OscEvent panelonespeed;
recv.event( "/panelTwo/speed, f" ) @=> OscEvent paneltwospeed;

0.0 => float panel1AngleValue;
0.0 => float panel2AngleValue;
0.0 => float panel1SpeedValue;
0.0 => float panel2SpeedValue;

spork ~ panel1Angle();
spork ~ panel2Angle();
spork ~ panel1Speed();
spork ~ panel2Speed();

fun void panel1Angle(){
    while(true){
        paneloneangle => now;    
        while (paneloneangle.nextMsg()){
            paneloneangle.getFloat() => panel1AngleValue;
        }     
    }
}

fun void panel2Angle(){
    while(true){
        paneltwoangle => now;    
        while (paneltwoangle.nextMsg()){
            paneltwoangle.getFloat() => panel2AngleValue;
        }     
    }
}

fun void panel1Speed(){
    while(true){
        panelonespeed => now;            
        while (panelonespeed.nextMsg()){
            panelonespeed.getFloat() => panel1SpeedValue;
        }     
    }
}

fun void panel2Speed(){
    while(true){
        paneltwospeed => now;            
        while (paneltwospeed.nextMsg()){
            paneltwospeed.getFloat() => panel2SpeedValue;
        }     
    }
}

0 => int i;
while(i < 1000){
    writeOscValues(panel1AngleValue, i);
    writeOscValues(panel2AngleValue, i);
    writeOscValues(panel1SpeedValue, i);
    writeOscValues(panel2SpeedValue, i);
    .1::second => now;    
}

fun void writeOscValues(float angle, int value){
    if(!file.open(me.dir()+"/test1.txt", FileIO.APPEND)){
        <<<"ERROR. CAN NOT OPEN FILE!">>>;
        return;
    }
    //open file
    file <= "angleA" <= value <= "," <= angle <= IO.newline();
    file.close();
}
