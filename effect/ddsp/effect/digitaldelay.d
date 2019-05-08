/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.effect.digitaldelay;

import ddsp.effect.effect;
import ddsp.util.functions;

/**
* A general purpose Digital Delay with support for external feedback,
  fractional delay, and feedback path effects.
*/
class DigitalDelay(T) : AudioEffect!T
{
    import core.stdc.stdlib : malloc, free;
    import core.stdc.string : memset;
    import dplug.core.vec;
    
public:

    this() nothrow @nogc
    {
        buffer = null;
        _size = 0;
        _feedback = 0.0f;
        _mix = 0.0f;
        _useExternalFeedback = false;
        
        _readIndex = 1;
        _writeIndex = 0;
        
        feedbackFX = makeVec!(AudioEffect!T);
    }
    
    ~this() nothrow @nogc { free(buffer); }
    
    /// Set the sample rate and initialize the buffer.
    override void setSampleRate(float sampleRate) nothrow @nogc
    {
        _sampleRate = sampleRate;
        _feedback = 0;
        _mix = 0;
        _size = cast(uint)sampleRate * 2;

        if(buffer != null)
            free(buffer);

        buffer = cast(float*) malloc(_size * float.sizeof);
        reset();
    }
    
    /// calculates and sets the number of samples required.
    void setDelay(float msDelay) nothrow @nogc
    {
        _delayInSamples = msToSamples(msDelay, _sampleRate);
        if(_delayInSamples > _size)
        {
            reset();
        }
        else
        {
            resetIndices();
        }
    }

    /// Sets delay time, feedback, and mix
    void setParams(float msDelay, float feedback, float mix) nothrow @nogc
    {
        setDelay(msDelay);
        setFeedbackAmount(feedback);
        setMixAmount(mix);
    }
    
    override T getNextSample(const T input) nothrow @nogc
    {
        float xn = input;
        float yn = buffer[cast(size_t)_readIndex];
        
        if(_readIndex == _writeIndex && _delayInSamples < 1.0f)
        {
            yn = xn;
        }
        
        size_t _readIndex_1 = cast(size_t)(_readIndex - 1);
        if(_readIndex_1 < 0)
            _readIndex_1 = _size - 1;
        
        float yn_1 = buffer[_readIndex_1];
        
        float fracDelay = _delayInSamples - cast(int)_delayInSamples;
        
        float interp = linearInterp(0, 1, yn, yn_1, fracDelay);
        
        if(_delayInSamples == 0)
            yn = xn;
        else
            yn = interp;
        
        if(!_useExternalFeedback)
            buffer[cast(size_t)_writeIndex] = xn + _feedback * yn;
        else
            buffer[cast(size_t)_writeIndex] = xn + _feedbackIn * _feedback;
        
        float output = _mix * yn + (1.0 - _mix) * xn;
        
        if(++_writeIndex >= _size)
            _writeIndex = 0;
        if(++_readIndex >= _size)
            _readIndex = 0;
            
        return output;
    }
    
    //set all elements in the buffer to 0, and reset indices.
    override void reset() nothrow @nogc
    {
        memset(buffer, 0, _size * float.sizeof);

        resetIndices();
    }

    void resetIndices() nothrow @nogc
    {
        _readIndex = cast(long)(_writeIndex - cast(long)_delayInSamples);
        if(_readIndex < 0)
            _readIndex += _size;
    }
    
    float getCurrentFeedbackOutput() nothrow @nogc { return _feedback * buffer[cast(size_t)_readIndex]; }
    
    float getFeedbackAmount() nothrow @nogc { return _feedback; }
    
    float getMixAmount() nothrow @nogc { return _mix; }
    
    void setCurrentFeedbackInput(float f) nothrow @nogc { _feedbackIn = f; }
    
    void setUseExternalFeedback(bool b) nothrow @nogc { _useExternalFeedback = b; }
    
    void addFeedbackEffect(AudioEffect!T effect) nothrow @nogc { feedbackFX.pushBack(effect); }
    
    void setFeedbackAmount(float feedback) nothrow @nogc { _feedback = feedback; }
    
    void setMixAmount(float mix) nothrow @nogc { _mix = mix; }

    /// used for debuging purposes.
    override string toString()
    {
        import std.conv;
        string output = "Rindex " ~ to!string(_readIndex) ~ " Windex " ~ to!string(_writeIndex) ~ " Size " ~ to!string(_size) ~ " Delay " ~ to!string(_delayInSamples);
        return output;
    }
    
protected:

    float *buffer;
    float _sampleRate;
    float _feedback;
    float _mix;
    
    size_t _size;
    float _delayInSamples;
    float _delayInMS;
    
    long _writeIndex;
    long _readIndex;
    
    bool _useExternalFeedback;
    float _feedbackIn;
    
    Vec!(AudioEffect!T) feedbackFX;

    float maxDelayTime = 3.0f;

}

unittest
{
    import dplug.core.nogc;
    
    DigitalDelay!float d = mallocNew!(DigitalDelay!float)();
    //d.initialize(44100);
    //d.update(22050, 0.5, 0.5);
    //testEffect(d, "DDelay", 44100 * 2, false);
}