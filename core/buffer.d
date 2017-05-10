/**
Author: Ethan Reker
Date: April 12, 2017
Purpose:  class to circular buffer data for use in delay lines and modulation.
*/
module ddsp.core.buffer;

/**
Points to a specified location in a buffer.
*/
class bufferIndex
{
  static int numIndexes = 0;
  size_t position;
  int id;
  this(string name, size_t position = 0)
  {
    id = ++numIndexes;
    position = 0;
  }
}

class Buffer (T)
{
  T[] buffer;
  const default_size = 1000;
  bufferIndex[] indexes;
  size_t readIndex, writeIndex;
  size_t bufferLength;

  /+Initializes the Buffer with a set size +/
  this(size_t size)
  {
    indexes ~= new bufferIndex("read");
    indexes ~= new bufferIndex("write");
    buffer.length = size;
    bufferLength = size;
    writeIndex = size - 1;
    readIndex = 0;
	  initialize();
  }

  this()
  {
    buffer.length = default_size;
	  writeIndex = size - 1;
    readIndex = 0;
	  initialize();
  }

  void addIndex(size_t position, string name)
  {
    indexes ~= new bufferIndex()
  }

  void initialize(){
  	for(int i = 0; i < buffer.length; ++i)
  		buffer[i] = 0;
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
  void resize(size_t size) nothrow @nogc
  {
    bufferLength = size;
    size_t difference = buffer.length - size;
	  readIndex = (readIndex - difference) % size;
    //shiftReadIndex(difference);
  }

  void increment(ref size_t index) nothrow @nogc
  {
    if(++index == buffer.length)
      index = 0;
  }

  void increment(int indexId) nothrow @nogc
  {
    if(++index.position == buffer.length)
      index.position = 0;
  }

  void decrement(ref size_t index) nothrow @nogc
  {
    if(--index < 0)
      index = buffer.length - 1;
  }

  void shiftReadIndex(ref size_t amount) nothrow @nogc
  {
	if(amount < 0){
		for(int i = 0; i > amount; i--)
			decrement(readIndex);
	}
	if(amount > 0){
		for(int i = 0; i < amount; i++)
			increment(readIndex);
	}
  }
  size_t size() nothrow @nogc
  {
	   return bufferLength;
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

@system unittest
{
	import std.stdio;
	writeln("Buffer unittest..");
	Buffer!float b = new Buffer!float(100);
	for(int i = 0; i < 200; ++i){
		b.write(i);
		writef("%s ", b.read());
	}
  writefln("\nRead Index: %s\nShifting readIndex by 50...", b.rIndex());
  b.resize(50);
  writefln("Read Index: %s", b.rIndex());
}
