//OSC in from iPad (or other) - serial out to Arduino.
//Runs in miniaudicle fine; intended for use in command line on RPi.

OscRecv recv;

0 => int panelAMsg;
0 => int angleAMsg;
0 => int speedAMsg;

0 => int panelBMsg;
0 => int angleBMsg;
0 => int speedBMsg;

0 => int AXValue;
0 => int BXValue;
0 => int AYValue;
0 => int BYValue;


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
            true => panelAMsg;
            true => angleAMsg; 
            
            paneloneangle.getFloat() $ int => AXValue;
            <<< "AXValue (via OSC):", AXValue >>>;
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
 
            paneltwoangle.getFloat() $ int => BXValue;
            <<< "BXValue (via OSC):", BXValue >>>;
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
       1::second => now;
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
    if(panelAMsg == true && angleAMsg == true){
        cereal <= "AX" <= AXValue <= "\n";
        false => panelAMsg;
        false => angleAMsg;
    }
    //if Panel A and Speed
    if(panelAMsg == true && speedAMsg == true){
        cereal <= "AY" <= AYValue <= "\n";
        false => panelAMsg;
        false => speedAMsg;     
    }    
    //if Panel B and Angle
    if(panelBMsg == true && angleBMsg == true){
        cereal <= "BX" <= BXValue <= "\n";
        false => panelBMsg;
        false => angleBMsg;             
    }   
    //if Panel B and Speed
    if(panelBMsg == true && speedBMsg == true){
        cereal <= "BY" <= BYValue <= "\n"; 
        false => panelBMsg;
        false => speedBMsg;                 
    }      
    //This just dumps out what the arduino’s sending back.
    //just diagnostic - probably delete later or have as own shred
    for(0 => int i; i < 5; i++){
        cereal.onLine() => now;
        chout <= "=> " <= cereal.getLine() <= IO.nl();
        .1::second => now;
    }
    1::second => now;
}
