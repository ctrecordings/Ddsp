/**
Author: Ethan Reker
Date: April 12, 2017
Purpose:  class to circular buffer data for use in delay lines and modulation.
*/
module buffer;

class Buffer (T)
{
  T[] buffer;
  const default_size = 1000;
  
  size_t readIndex, writeIndex;
  
  /+Initializes the Buffer with a set size +/
  this(size_t size)
  {
    buffer.length = size;
    writeIndex = size - 1;
    readIndex = 0;
  }
  
  this()
  {
    buffer.length = default_size;
	writeIndex = size - 1;
    readIndex = 0;
  }
  
  T read() nothrow @nogc 
  {
    T val = buffer[readIndex];
    increment(readIndex);
    return val;
  }
  
  void write(T sample) nothrow @nogc
  {
    buffer[writeIndex] = sample;
    increment(writeIndex);
  }
  void resize(size_t size)
  {
    int difference = numSamples - size;
    shifReadIndex(difference);
  }
  
  void increment(ref size_t index) nothrow @nogc
  {
    if(++index == buffer.length)
      index = 0;
  }
  
  void decrement(ref size_t index) nothrow @nogc
  {
    if(--index < 0)
      index = buffer.length - 1;
  }
	
  void shiftReadIndex(ref size_t amount)
  {
	  if(amount < 0){	  
	  }
  }
  size_t size() nothrow @nogc
  {
	return buffer.length;
  }
  
  size_t rIndex() nothrow @nogc
  {
	return readIndex;
  }
  
  size_t wIndex() nothrow @nogc
  {
	return writeIndex;
  }
  
}

@safe unittest
{
	

}
