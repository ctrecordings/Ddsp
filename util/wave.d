module ddsp.util.wave;

import dplug.core.file;
import dplug.core.nogc;
import std.stdio;

///
/// Class for reading and extracting data from files in WAVE format.
/// Currently only 16bit files are supported
///
class WaveFile
{
    this(const(char)[] filename) nothrow @nogc
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

    ubyte[] getData() nothrow @nogc {return data[];}

    override string toString()
    {
        import std.conv;
        return   "Chunk Descriptor: " ~ to!string(chunkDescriptor)
               ~ "\nChunk Size: " ~ to!string(chunkSize)
               ~ "\nSub Chunk1 Size: " ~ to!string(subChunk1Size) 
               ~ "\nAudio Format: " ~ to!string(audioFormat)
               ~ "\nNum Channels: " ~ to!string(numChannels)
               ~ "\nSample Rate: " ~ to!string(sampleRate)
               ~ "\nByte Rate: " ~ to!string(byteRate)
               ~ "\nBlock Align: " ~ to!string(blockAlign)
               ~ "\nBits Per Sample: " ~ to!string(bitsPerSample)
               ~ "\nData Sub Chuck: " ~ to!string(bitsPerSample)
               ~ "\nSub Chunk2 Size: " ~ to!string(subChunk2Size);
    }

private:

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

    uint bytesToInt(ubyte[] bytes) nothrow @nogc
    {
        uint sum = bytes[0];
        for(int i = 1; i < bytes.length; ++i)
        {
            sum |= bytes[i] << (i *8);
        }
        return sum;
    }

    float convertSampleData(ubyte[] bytes) nothrow @nogc
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
}

unittest
{
    import std.stdio;

    WaveFile file = new WaveFile("D:/Google Drive/PROGRAMMING/Git Repos/Ddsp/util/8bitexample.wav");
    writeln(file.toString());
}

//24-bit range -8,388,608 to 8388,607