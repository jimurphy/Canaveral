//OSC in from iPad (or other) - serial out to Arduino.
//Runs in miniaudicle fine; intended for use in command line on RPi.

OscRecv recv;

false => int panelAMsg;

false => int panelBMsg;

0 => int AXValue;
0 => int BXValue;

500 => int stepperRev; //number of steps per revolution

1337 => recv.port;

recv.listen();

recv.event( "/panelOne/angle, f" ) @=> OscEvent paneloneangle;
recv.event( "/panelTwo/angle, f" ) @=> OscEvent paneltwoangle;

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

fun void panel1Angle(){
    while ( true )
    {
        paneloneangle => now;
        while (paneloneangle.nextMsg() )
        {
            1 => panelAMsg;
            
            paneloneangle.getFloat() => float mapValue;
            <<< "AXValue (via OSC):", mapValue >>>;
            map(mapValue, 0, 360, 0, stepperRev) $ int => AXValue;
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
            
            paneltwoangle.getFloat() => float mapValue;
            <<< "BXValue (via OSC):", mapValue >>>;
            map(mapValue, 0, 360, 0, stepperRev) $ int => BXValue;
        }
    }
}



while(true)
{
    //if Panel A and Angle
    if(panelAMsg == 1){
        <<<"TEST">>>;
        cereal <= "AX" <= AXValue <= "\n";
        0 => panelAMsg;
        //printStuff();
    }
    //if Panel B and Angle
    else if(panelBMsg == true){
        cereal <= "BX" <= BXValue <= "\n";
        false => panelBMsg;
        //printStuff();                     
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
    return((x-in_min)*(out_max-out_min))/((in_max-in_min)+out_min);
}

