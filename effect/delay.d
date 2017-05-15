module ddsp.effect.delay;

import ddsp.core.buffer;

class DigitalDelay
{
    public:

    this(size_t size, float mix, float feedback)
    {
        _bufferSize = size;
        _buffer = new AudioBuffer(_bufferSize);
        _buffer.addIndex(0, indexes.read);
        _buffer.addIndex(size - 1, indexes.write);
        _buffer.addIndex(size - 1, indexes.sidechain);

        _mix = mix;
        _feedback = feedback;
    }

    float read() nothrow @nogc
    {
        return _buffer.read(indexes.read);
    }

    void write(float sample) nothrow @nogc
    {
        _buffer.write(indexes.write, sample);
    }

    void writeSidechain(float sample) nothrow @nogc
    {
        _buffer.write(indexes.sidechain, sample);
    }

    float getNextSample(float input) nothrow @nogc
    {
        float yn = read();
        write((input + _feedback * yn) * 0.5f);
        return _mix * yn + input * (1 - _mix);
    }

    float getNextSampleSideChain(float input1, float input2) nothrow @nogc
    {
        float yn = read();
        writeSidechain((input2 + _feedback * yn) * 0.5f);
        return _mix * yn + input1 * (1 - _mix);
    }

    void setFeedback(float feedback) nothrow @nogc { _feedback = feedback;}

    void setMix(float mix) nothrow @nogc { _mix = mix;}

    void resize(size_t size) nothrow @nogc
    {
        _buffer.resize(size);
    }

    size_t size() nothrow @nogc {return _buffer.size();}

    private:

    enum indexes {read, write, sidechain};
    AudioBuffer _buffer;
    size_t _bufferSize;
    float _mix;
    float _feedback;
}

unittest
{
  import std.stdio;
  import std.random;

  Random gen;

  DigitalDelay d = new DigitalDelay(2000, 0.5, 0.5);

  writeln("\nDelay Test");
  for(int i = 0; i < 20000; ++i){
    float sample = uniform(0.0L, 1.0L, gen);
    float val = d.getNextSample(sample);
    if(i%1000 == 0)
      writef("%s ", val);
  }
  d.resize(1500);
  for(int i = 0; i < 20000; ++i){
    float sample = uniform(0.0L, 1.0L, gen);
    float val = d.getNextSample(sample);
    if(i%1000 == 0)
      writef("%s ", val);
  }
  writeln("\n...End Delay Test\n");
}
