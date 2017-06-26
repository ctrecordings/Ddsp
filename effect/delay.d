module ddsp.effect.delay;

import ddsp.util.buffer;
import ddsp.util.functions;
import ddsp.util.time;

class DigitalDelay
{
    public:

    this(){}

    void initialize(size_t size, float mix, float feedback)
    {
        _bufferSize = size;
        _buffer.initialize(_bufferSize);
        _buffer.addIndex(0, readIndex);
        _buffer.addIndex(size - 1, writeIndex);
        _buffer.addIndex(size - 1, sidechainIndex);

        _mix = mix;
        _feedback = feedback;
    }

    float read() nothrow @nogc
    {
        return _buffer.read(readIndex);
    }

    void write(float sample) nothrow @nogc
    {
        _buffer.write(writeIndex, sample);
    }

    void writeSidechain(float sample) nothrow @nogc
    {
        _buffer.write(sidechainIndex, sample);
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

    enum : int  {readIndex, writeIndex, sidechainIndex};
    AudioBuffer _buffer;
    size_t _bufferSize;
    float _mix;
    float _feedback;
}

class SyncedDelay : DigitalDelay
{
public:
    
    void initialize(size_t size, float mix, float feedback, float sampleRate)
    {
        _bufferSize = size;
        _buffer.initialize(_bufferSize);
        _buffer.addIndex(0, readIndex);
        _buffer.addIndex(size - 1, writeIndex);
        _buffer.addIndex(size - 1, sidechainIndex);

        _mix = mix;
        _feedback = feedback;
        _sampleRate = sampleRate;
    }
    
    /**
    *  Should be called at the beginning of the audio processing method.
    */
    void updateTimeInfo(float tempo, float currentSample, bool isPlaying, float noteLength)
    {
        timeCursor.updateTimeInfo(tempo, currentSample, isPlaying);
        delayNote.tempo = tempo;
        delayNote.length = noteLength;
        
        if(!isPlaying)
        {
          inInitPhase = true;
        }
        
        if(timeCursor.currentPosIsNoteMultiple(delayNote.length) && inInitPhase && isPlaying)
        {
            _writeEnabled = true;
            inInitPhase = false;
        }
        
        _buffer.resize(cast(size_t)msToSamples(delayNote.getTimeInMilliseconds(), _sampleRate));
    }
    
    override void write(float sample) nothrow @nogc
    {
        if(_writeEnabled)
        {
            _buffer.write(writeIndex, sample);
        }
        else
        {
            _buffer.write(writeIndex, 0);
        }
    }

private:
    bool synced;
    bool firstMarkHit;
    bool inInitPhase;
    bool _writeEnabled;
    TimeCursor timeCursor;
    Note delayNote;
    float _sampleRate;
}

unittest
{
    import std.stdio;
    import std.random;
    import ddsp.util.functions;
    import dplug.core.nogc;

    writeln("\nDelay Test");

    Random gen;

    auto d = mallocEmplace!DigitalDelay();
    
    d.initialize(2000, 0.5, 0.5);

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
