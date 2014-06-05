FileIO file;

fun void writeOscValues(int value, float angle){
    if(!file.open(me.dir()+"/test1.txt", FileIO.APPEND)){
        <<<"ERROR. CAN NOT OPEN FILE!">>>;
        return;
    }
    //open file
    file <= "angleA" <= value <= "," <= angle <= IO.newline();
    file.close();
}

0 => int i;
while(i < 100000){
    writeOscValues(i, 4.004);
    .1::second => now;
    i++;
}