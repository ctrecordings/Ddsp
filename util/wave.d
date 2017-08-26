module ddsp.util.wave;

import dplug.core.file;
import dplug.core.nogc;
import std.stdio;

class WaveFile
{
    this(const(char)[] filename)
    {
        data = readFile(filename);
        chunkDescriptor = cast(char[4])data[0..4];
        chunkSize = bytesToInt(data[4..8]);
        subChunk1Size = bytesToInt(data[16..20]);
        audioFormat = bytesToInt(data[20..22]);
        numChannels = bytesToInt(data[22..24]);
        sampleRate = bytesToInt(data[24..28]);
        byteRate = bytesToInt(data[28..32]);
        blockAlign = bytesToInt(data[32..34]);
        bitsPerSample = bytesToInt(data[34..36]);
        dataSubChunk = cast(char[4])data[36..40];
        subChunk2Size = bytesToInt(data[40..44]);

        leftChannel = mallocSlice!float(chunkSize / (numChannels * blockAlign));
        rightChannel = mallocSlice!float(chunkSize / (numChannels * blockAlign));
        uint sampleNum;
        for(int i = 44; i < data.length; i += numChannels * blockAlign, ++sampleNum)
        {
            leftChannel[sampleNum] = convertSampleData(data[i..i+blockAlign]);
            rightChannel[sampleNum] = convertSampleData(data[i+blockAlign..i+blockAlign * 2]);

        }

    }

    ubyte[] getData(){return data[];}

    uint bytesToInt(ubyte[] bytes)
    {
        if(bytes.length == 4)
        {
            return (bytes[3] << 24) 
                | (bytes[2] << 16)
                | (bytes[1] << 8)
                | bytes[0];
        }
        else if(bytes.length == 2)
        {
            return (bytes[1] << 8) | bytes[0];
        }
        else
        {
            return 0;
        }
    }

    float convertSampleData(ubyte[] bytes)
    {
        int sum = bytes[0];
        for(int i = 1; i < bytes.length; ++i){
            sum |= cast(int)bytes[i] << (8 * i);
        }
        //take two's compliment
        0x8000 & sum ? sum = cast(int)(0x7FFF & sum) - 0x8000 : sum = sum;
        //return sum / 2;
        //return (cast(float)sum - 8388608.0f) / 8388608.0f;
        return sum / 32768.0f;
    }

public:

    //RIFF
    char[4] chunkDescriptor;
    uint chunkSize;
    uint subChunk1Size;
    uint audioFormat;
    uint numChannels;
    uint sampleRate;
    uint byteRate;
    uint blockAlign;
    uint bitsPerSample;
    char[4] dataSubChunk;
    uint subChunk2Size;

    int sample1;

    ubyte[] data;
    float[] leftChannel;
    float[] rightChannel;
}

unittest
{
    import std.stdio;

    WaveFile file = new WaveFile("D:/Google Drive/PROGRAMMING/Git Repos/Ddsp/util/8bitexample.wav");
    //writeln(file.getData());
    writeln(file.chunkDescriptor);
    writeln(file.chunkSize);
    writeln(file.subChunk1Size);
    writeln(file.audioFormat);
    writeln(file.numChannels);
    writeln(file.sampleRate);
    writeln(file.byteRate);
    writeln(file.blockAlign);
    writeln(file.bitsPerSample);
    writeln(file.dataSubChunk);
    writeln(file.subChunk2Size);
    writeln(file.sample1);
    writeln(file.leftChannel);
}

//24-bit range -8,388,608 to 8388,607