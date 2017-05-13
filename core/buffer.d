/**
Copyright: 2017 Cut Through Recordings
License: GNU General Public License
Author(s): Ethan Reker
*/
module buffer;

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
        return position;
    }

    void resetSize(size_t bufferLength) nothrow @nogc
    {
        _bufferLength = bufferLength;
        if(position >= bufferLength){
            _position %= bufferLength;
        }
    }

    private:

    int _id;
    size_t _position;
    size_t _bufferLength;
}


/**

*/
class AudioBuffer
{
    public:

    this(size_t size)
    {
        buffer.length = size;
        _sudoLength = size;
        for(size_t i = 0; i < _sudoLength; ++i){
            buffer[i] = 0;
        }
    }

    /**
    Creates a new index at the startingPosition and assigns it an id to be
    retrieved by.
    */
    void addIndex(int startingPosition, int id)
    {
        assert(startingPosition < _sudoLength && startingPosition >= 0);
        if(_indexList.length <= id)
            _indexList.length = id + 1;

        assert(_indexList.length > id);
        _indexList[id] = new BufferIndex(startingPosition, _sudoLength, id);
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

    @property size_t size() nothrow @nogc {return buffer.length;}

    /**
    Used for testing. Returns buffer array.
    */
    float[] getElements() nothrow @nogc {return buffer;}

    private:

    float[] buffer;
    /++ Used as the true length of the buffer so that buffer can be resized without GC +/
    size_t _sudoLength;
    BufferIndex[] _indexList;
}

unittest
{
    import std.stdio;
    import std.random;

    Random gen;

    enum indexes
    {
        writeIndex,
        readIndex,
    }

    AudioBuffer b = new AudioBuffer(100);

    b.addIndex(99, indexes.writeIndex);
    b.addIndex(0, indexes.readIndex);

    writeln("Buffer test...");
    writefln("Elements: %s", b.getElements());
    for(int i = 0; i < b.size * 2; ++i){
        float sample = uniform(0.0L, 1.0L, gen);
        b.write(indexes.writeIndex, sample);
        writef("%s ", b.read(indexes.readIndex));
    }
    writeln("\n...End Buffer test\n");
}
