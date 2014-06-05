me.sourceDir() + "/test1.txt" => string filename;
FileIO fio;
fio.open( filename, FileIO.READ );

if( !fio.good() )
{
    cherr <= "can't open file: " <= filename <= " for reading..."
    <= IO.newline();
    me.exit();
}

int val;

while( fio.more() )
{
    fio.readLine() => string output;
//    cherr <= output <= IO.newline();

    if(RegEx.match("^angleA", output)){
        <<<"ANGLE A">>>;
    }
    if(RegEx.match("^angleB", output)){
        <<<"ANGLE B">>>;
    }
    if(RegEx.match("^speedA", output)){
        <<<"Speed A">>>;
    }
    if(RegEx.match("^speedB", output)){
        <<<"speed b">>>;
    }
    .1::second => now;
}

