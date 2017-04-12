/**
Author: Ethan Reker
Date: April 12, 2017
Purpose:  class to circular buffer data for use in delay lines and modulation.
*/
module dsp.core.buffer;

struct Buffer(T)
{
  T[] buffer;
  const default_size = 1000;
  
  ulong readIndex, writeIndex;
  
  /+Initializes the Buffer with a set size +/
  this(ulong size)
  {
    buffer.length = size;
    writeIndex = size - 1;
    readIndex = 0;
  }
  
  this()
  {
    buffer.length = default_size;
  }
  
  T read(){
    float val = buffer[readIndex];
    increment[readIndex];
    return val;
  }
  
  void write(T sample)
  {
    buffer[writeIndex] = sample;
    increment(writeIndex);
  }
  
  
  void increment(ulong index)
  {
    if(++index == buffer.length)
      index = 0;
  }
  
  void decrement(ulong index)
  {
    if(--index < 0)
      index = buffer.length - 1;
  }
  
}
