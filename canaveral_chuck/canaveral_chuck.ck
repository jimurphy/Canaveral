//OSC in from iPad (or other) - serial out to Arduino.
//Runs in miniaudicle fine; intended for use in command line on RPi.

OscRecv recv;

false => int panelAMsg;
false => int angleAMsg;
false => int speedAMsg;

false => int panelBMsg;
false => int angleBMsg;
false => int speedBMsg;

0 => int AXValue;
0 => int BXValue;
0 => int AYValue;
0 => int BYValue;

500 => stepperrev; //number of steps per revolution

1337 => recv.port;

recv.listen();

recv.event( "/panelOne/angle, f" ) @=> OscEvent paneloneangle;
recv.event( "/panelTwo/angle, f" ) @=> OscEvent paneltwoangle;
recv.event( "/panelOne/speed, f" ) @=> OscEvent panelonespeed;
recv.event( "/panelTwo/speed, f" ) @=> OscEvent paneltwospeed;

SerialIO.list() @=> string list[];
0 => int serialValue;
if(list.cap() == 0)
{
    cherr <= "no serial devices available\n";
    me.exit(); 
}

chout <= "Available devices\n";
for(int i; i < list.cap(); i++)
{
    chout <= i <= ": " <= list[i] <= IO.newline();
}

2 => int device;
if(me.args()) me.arg(0) => Std.atoi => device;

if(device >= list.cap())
{
    cherr <= "serial device #" <= device <= "not available\n";
    me.exit(); 
}

SerialIO cereal;
if(!cereal.open(device, SerialIO.B9600, SerialIO.ASCII))
{
    chout <= "unable to open serial device '" <= list[device] <= "'\n";
    me.exit();
}

2::second => now;

spork ~ panel1Angle();
spork ~ panel2Angle();
spork ~ panel1Speed();
spork ~ panel2Speed();

fun void panel1Angle(){
    while ( true )
    {
        paneloneangle => now;
        while (paneloneangle.nextMsg() )
        {
            1 => panelAMsg;
            1 => angleAMsg; 
            
            paneloneangle.getFloat() => float mapValue;
            <<< "AXValue (via OSC):", mapValue >>>;
            map(mapValue, -360, 360, 0, stepperRev);
            mapValue $ int => AXValue;
        }
    }
}

fun void panel2Angle(){
    while ( true )
    {
        paneltwoangle => now;
        while (paneltwoangle.nextMsg() )
        {
            true => panelBMsg;
            true => angleBMsg; 
 
            paneltwoangle.getFloat() => float mapValue;
            <<< "BXValue (via OSC):", mapValue >>>;
            map(mapValue, -360, 360, 0, stepperRev);
            mapValue $ int => BXValue;
        }
    }
}

fun void panel1Speed(){
    while ( true )
    {
        panelonespeed => now;
        
        while ( panelonespeed.nextMsg() )
        {
            true => panelAMsg;
            true => speedAMsg; 
            panelonespeed.getFloat() $ int => AYValue;
            <<< "AYValue (via OSC):", AYValue >>>;
        }
    }
}

fun void panel2Speed(){
    while ( true )
    {
        paneltwospeed => now;
        //<<<oe.nextMsg()>>>;
        while ( paneltwospeed.nextMsg() )
        { 
            true => panelBMsg;
            true => speedBMsg; 
            paneltwospeed.getFloat() $ int => BYValue;
            <<< "BYValue (via OSC):", BYValue >>>;
        }
    }
}


while(true)
{
    //if Panel A and Angle
    if(panelAMsg == 1 && angleAMsg == 1){
        cereal <= "AX" <= AXValue <= "\n";
        0 => panelAMsg;
        0 => angleAMsg;
        <<<"TEST">>>;
        printStuff();
    }
    //if Panel A and Speed
    else if(panelAMsg == true && speedAMsg == true){
        cereal <= "AY" <= AYValue <= "\n";
        false => panelAMsg;
        false => speedAMsg;
        printStuff();             
    }    
    //if Panel B and Angle
    else if(panelBMsg == true && angleBMsg == true){
        cereal <= "BX" <= BXValue <= "\n";
        false => panelBMsg;
        false => angleBMsg;
        printStuff();                     
    }   
    //if Panel B and Speed
    else if(panelBMsg == true && speedBMsg == true){
        cereal <= "BY" <= BYValue <= "\n"; 
        false => panelBMsg;
        false => speedBMsg;
        printStuff();                         
    }      
    1::second => now;
}

fun void printStuff(){
    for(0 => int i; i < 5; i++){
        cereal.onLine() => now;
        chout <= "=> " <= cereal.getLine() <= IO.nl();
        .1::second => now;
    }
}

fun float map(float x, float in_min, float in_max, float out_min, float out_max){
    return(x-in_min)*(out_max-out_min) / (in_max-in_min)+out_min;
}

