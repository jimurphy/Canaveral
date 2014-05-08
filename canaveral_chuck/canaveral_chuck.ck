//OSC in from iPad (or other) - serial out to Arduino.
//Runs in miniaudicle fine; intended for use in command line on RPi.

SerialIO.list() @=> string list[];

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

while(true)
{
    cereal <= "AX123\n";
    chout <= "AX123\n";
    
    //This just dumps out what the arduino’s sending back.
    //just diagnostic - probably delete later or have as own shred
    for(0 => int i; i < 5; i++){
        cereal.onLine() => now;
        chout <= "=> " <= cereal.getLine() <= IO.nl();
        .1::second => now;
    }
    
    1::second => now;
}
