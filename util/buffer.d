/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.util.buffer;

import core.stdc.stdlib;
import dplug.core.alignedbuffer;
import dplug.core.nogc;

/**
An Index that points to a position in a buffer.
*/
class BufferIndex
{
    public:

    this(size_t position, size_t bufferLength, int id)
    {
        _id = id;
        _position = position;
        _bufferLength = bufferLength;
    }

    @property size_t position() nothrow @nogc { return _position; }

    size_t getPositionAndIncrement() nothrow @nogc
    {
        if(++_position == _bufferLength)
            _position = 0;
        return _position;
    }
    
    /**
    * same as above but shifts the index by amount specified
    */
    /*size_t getPositionShiftAndIncrement(size_t shiftAmount) nothrow @nogc
    {
        _position += shiftAmount + 1;
        if(_position >= _bufferLength)
            _position = 
        //return 
    }*/

    void resetSize(size_t bufferLength) nothrow @nogc
    {
        _bufferLength = bufferLength;
        if(_position >= bufferLength){
            _position %= bufferLength;
        }
    }

    private:

    int _id;
    size_t _position;
    size_t _bufferLength;
}

/**
TODO: Add separate Vecs for read and write indexes so that they can
all be shifted equally on resize operations.
*/
class AudioBuffer
{
    public:

    /**
    * Allocates a memory heap for the buffer. And sets each element to 0.
    */
    void initialize(size_t size)
    {
        _indexList = makeVec!BufferIndex();
        buffer = cast(float*) malloc(size * float.sizeof);
        _sudoLength = size;
        _size = size;
        clear();
    }

    /**
    Creates a new index at the startingPosition and assigns it an id to be
    retrieved by.
    
    IMPORTANT:
    0 should be the read index for resizing purposes.
    */
    void addIndex(ulong startingPosition, int id)
    {
        BufferIndex newIndex = mallocNew!BufferIndex(cast(uint) startingPosition, _sudoLength, id);
        _indexList.pushBack(newIndex);
    }

    /**
    Retrieves the Index with specified Id
    */
    BufferIndex getIndex(int id) nothrow @nogc
    {
        assert(id >= 0 && id < _indexList.length);
        return _indexList[id];
    }

    /**
    Read the buffer at the position of the given index id.
    */
    float read(int indexId) nothrow @nogc
    {
        return buffer[getIndex(indexId).getPositionAndIncrement()];
    }

    /**
    Write to the buffer at the position of the given index id.
    */
    void write(int indexId, float value) nothrow @nogc
    {
        buffer[getIndex(indexId).getPositionAndIncrement()] = value;
    }

    /**
    This is currently not ideal since the position of each index is basically
    chopped off if it is greater than the new size.  The best case would be to
    shift the indexes first.
    */
    void resize(size_t size) nothrow @nogc
    {
        size_t difference = size - _sudoLength;
        _sudoLength += difference;
        foreach(BufferIndex index; _indexList){
            index.resetSize(_sudoLength);
        }
    }
    
    void betterResize(size_t size) nothrow @nogc
    {
        if(size != _size)
        {
            float *newBuffer = cast(float*) malloc(size * float.sizeof);
            
            //size_t smallerSize = size < _size ? size : _size;
            for(int i = 0; i < size; ++i){
                newBuffer[i] = read(0);
            }
            
            free(buffer);
            buffer = newBuffer;
            
            foreach(BufferIndex index; _indexList)
            {
                index.resetSize(size);
            }
        }
    }
    
    ///Reset all elements to 0
    void clear() nothrow @nogc
    {
        for(int i = 0; i < _size; ++i)
        {
            buffer[i] = 0;
        }
    }

    @property size_t size() nothrow @nogc {return _size;}

    /**
    Used for testing. Returns buffer as array.
    */
    float[] getElements()
    {
        float[] data;
        for(int i = 0; i < _size; ++i)
            data ~= buffer[i];
        return data;
    }

    private:

    float* buffer;
    size_t _size;
    
    size_t _sudoLength;
    
    Vec!BufferIndex _indexList;
}

unittest
{
    import std.stdio;
    import std.random;

    bool runTest = false;

    if(runTest)
    {
        Random gen;

        enum indexes
        {
            writeIndex,
            readIndex,
        }

        //AudioBuffer b = new AudioBuffer();
        AudioBuffer b = mallocNew!AudioBuffer();
        b.initialize(100);
        b.clear();

        b.addIndex(0, indexes.readIndex);
        b.addIndex(99, indexes.writeIndex);

        writeln("Buffer test...");
        writefln("Elements: %s", b.getElements());
        for(int i = 0; i < b.size * 2; ++i){
            float sample = uniform(0.0L, 1.0L, gen);
            b.write(indexes.writeIndex, sample);
            if(i%10 == 0)
                writef("%s ", b.read(indexes.readIndex));
        }
        writeln("\n...End Buffer test\n");
        }
}
