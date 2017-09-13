/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.util.buffer;

import core.stdc.stdlib;

/// Just a simple generic circular buffer.  Should fulfill the needs of most
/// simple delaying tasks.
class Buffer(T)
{
public:
nothrow:
@nogc:
    
    this(size_t size)
    {
        _maxSize = size;
        mallocBuffer(_maxSize);
        _currentSize = _maxSize;
        _writeIndex = _currentSize - 1;
        _readIndex = 0;
    }
    
    /// Gets the element from the buffer at the current read index, and
    /// increments the read index.
    T read()
    {
        T element = _buffer[_readIndex];
        incrementIndex(_readIndex);
        return element;
    }
    
    /// Assign the buffer element at the current write index to element and
    /// increment the write index.
    void write(T element)
    {
        _buffer[_writeIndex] = element;
        incrementIndex(_writeIndex);
    }
    
    /// Resize the buffer. If the new size is larger than the max size, the buffer
    /// will be reallocated so that size is the new maximum size.  It is very
    /// inefficient to delete and allocate large amounts of memory like this so
    /// it is recommended to give the buffer an initial max size that will never
    /// be exceeded.
    void setSize(size_t size)
    {
        if(size > _maxSize)
        {
            _maxSize = size;
            mallocBuffer(_maxSize);
            _currentSize = _maxSize;
        }
        else
        {
            _currentSize = _maxSize;
        }
        _writeIndex = _currentSize - 1;
        _readIndex = 0;
    }
    
private:
    /// The size that the buffer is originally set to.
    size_t _maxSize;
    
    /// The size that the buffer is currently set to.
    size_t _currentSize;
    
    /// Array that holds the elements
    T* _buffer;
    
    /// Points to the current sample to be read from
    size_t _readIndex;
    
    /// Points to the current sample to be written to
    size_t _writeIndex;
    
    /// Takes an index and increments it by 1, if it exceeds the size of the buffer
    /// it will be wrapped around to 0.
    void incrementIndex(ref size_t index)
    {
        if(++index >= _maxSize)
            index = 0;
    }
    
    void mallocBuffer(size_t bufferSize)
    {
        if(_buffer)
            free(_buffer);
            
        _buffer = cast(T*) malloc(bufferSize * T.sizeof);
        foreach(element; 0..bufferSize)
            _buffer[element] = cast(T) 0;
    }
}