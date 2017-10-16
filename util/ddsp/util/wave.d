module ddsp.util.wave;

import dplug.core.file;
import dplug.core.nogc;
import std.stdio;

///
/// Class for reading and extracting data from files in WAVE format.
/// Currently only 16bit mono files are supported
///
class WaveFile
{
    this(const(char)[] filename) nothrow @nogc
    {
        data = readFileWav(filename);
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
        uint sampleNum;
        for(int i = 44; i < data.length; i += numChannels * blockAlign, ++sampleNum)
        {
            leftChannel[sampleNum] = convertSampleData(data[i..i+blockAlign]);
        }

    }

    float[] getSampleData() nothrow @nogc {return leftChannel[];}



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
    byte b;

    int sample1;

    byte[] data;
    float[] leftChannel;
    float[] rightChannel;

    int bytesToInt(byte[] bytes) nothrow @nogc
    {
        int sum = cast(ubyte)bytes[0];
        for(int i = 1; i < bytes.length; ++i)
        {
            sum |= cast(ubyte)bytes[i] << (i *8);
        }
        return sum;
    }

    float convertSampleData(byte[] bytes) nothrow @nogc
    {
        int sum = bytes[0];
        for(int i = 1; i < bytes.length; ++i){
            sum |= cast(int)bytes[i] << (8 * i);
        }
        /*//take two's compliment
        0x8000 & sum ? sum = cast(int)(0x7FFF & sum) - 0x8000 : sum = sum;
        return sum / 32768.0f;*/
        const float div = 1.0f / 32768f;
        return cast(float)sum * div;
        //return sum;
    }
}

unittest
{
    import std.stdio;

    //WaveFile file = new WaveFile("util/ddsp/util/8bitexample.wav");
    //writeln(file.toString());
    //writeln(file.getSampleData()[0..1000]);
}

import core.stdc.stdio;

nothrow:
@nogc:

///
/// Taken from dplug.core.file
/// Modified to return signed data instead of unsigned data.
/// 
byte[] readFileWav(const(char)[] fileNameZ)
{
    // assuming that fileNameZ is zero-terminated, since it will in practice be
    // a static string
    FILE* file = fopen(fileNameZ.ptr, "rb".ptr);
    if (file)
    {
        scope(exit) fclose(file);

        // finds the size of the file
        fseek(file, 0, SEEK_END);
        long size = ftell(file);
        fseek(file, 0, SEEK_SET);

        // Is this too large to read? 
        // Refuse to read more than 1gb file (if it happens, it's probably a bug).
        if (size > 1024*1024*1024)
            return null;

        // Read whole file in a mallocated slice
        byte[] fileBytes = mallocSliceNoInit!byte(cast(int)size);
        size_t remaining = cast(size_t)size;

        byte* p = fileBytes.ptr;

        while (remaining > 0)
        {
            size_t bytesRead = fread(p, 1, remaining, file);
            if (bytesRead == 0)
            {
                freeSlice(fileBytes);
                return null;
            }
            p += bytesRead;
            remaining -= bytesRead;
        }

        return fileBytes;
    }
    else
        return null;
}