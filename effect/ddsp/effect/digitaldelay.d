/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.effect.digitaldelay;

import ddsp.effect.aeffect;
import ddsp.util.functions;

/**
* A general purpose Digital Delay with support for external feedback,
  fractional delay, and feedback path effects.
*/
class DigitalDelay : AEffect
{
    import core.stdc.stdlib : malloc, free;
    import core.stdc.string : memset;
    import dplug.core.alignedbuffer;
    
public:

    this() nothrow @nogc
    {
        buffer = null;
        _size = 0;
        _feedback = 0.0f;
        _mix = 0.0f;
        _useExternalFeedback = false;
        
        _readIndex = 0;
        _writeIndex = 0;
        
        feedbackFX = makeVec!AEffect;
    }
    
    ~this() nothrow @nogc { free(buffer); }
    
    void initialize(float sampleRate) nothrow @nogc
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
    
    void setDelay(float msDelay) nothrow @nogc
    {
        _delayInSamples = msToSamples(msDelay, _sampleRate);
        //assert(_delayInSamples <= cast(float)_size);
        if(_prevDelay != _delayInSamples)
            reset();
        _prevDelay = _delayInSamples;
    }

    void update(float msDelay, float feedback, float mix) nothrow @nogc
    {
        setDelay(msDelay);
        setFeedbackAmount(feedback);
        setMixAmount(mix);
    }
    
    override float getNextSample(const ref float input) nothrow @nogc
    {
        float xn = input;
        float yn = buffer[_readIndex];
        
        if(_readIndex == _writeIndex && _delayInSamples < 1.0f)
        {
            yn = xn;
        }
        
        size_t _readIndex_1 = _readIndex - 1;
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
            buffer[_writeIndex] = xn + _feedback * yn;
        else
            buffer[_writeIndex] = xn + _feedbackIn * _feedback;
        
        float output = _mix * yn + (1.0 - _mix) * xn;
        
        if(++_writeIndex >= _size)
            _writeIndex = 0;
        if(++_readIndex >= _size)
            _readIndex = 0;
            
        return output;
    }
    
    //set all elements in the buffer to 0, and set reset indices.
    override void reset() nothrow @nogc
    {
		memset(buffer, 0, _size * float.sizeof);

        _writeIndex = 0;
        _readIndex = _size - cast(size_t)_delayInSamples;
        if(_readIndex < 0)
            _readIndex += _size;
    }
    
    float getCurrentFeedbackOutput() nothrow @nogc { return _feedback * buffer[_readIndex]; }
    
    float getFeedbackAmount() nothrow @nogc { return _feedback; }
    
    float getMixAmount() nothrow @nogc { return _mix; }
    
    void setCurrentFeedbackInput(float f) nothrow @nogc { _feedbackIn = f; }
    
    void setUseExternalFeedback(bool b) nothrow @nogc { _useExternalFeedback = b; }
    
    void addFeedbackEffect(AEffect effect) nothrow @nogc { feedbackFX.pushBack(effect); }
    
    void setFeedbackAmount(float feedback) nothrow @nogc { _feedback = feedback; }
    
    void setMixAmount(float mix) nothrow @nogc { _mix = mix; }

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
    float _prevDelay;
    
    size_t _writeIndex;
    size_t _readIndex;
    
    bool _useExternalFeedback;
    float _feedbackIn;
    
    Vec!AEffect feedbackFX;

    float maxDelayTime = 3.0f;

}

unittest
{
    import dplug.core.nogc;
    
    //DigitalDelay d = mallocEmplace!DigitalDelay();
    //d.initialize(44100, 2000, 1000, 0.0, 1.0);
    //testEffect(d, "DDelay", 44100 * 2, false);
}

/** TODO: process each AEffect on the feedback input
float fb;
if(!_useExternalFeedback)
    fb = _feedback * yn;
else
    fb = _feedbackIn;

for(int i = 0; i < feedbackFX.length(); ++i){
    fb = feedbackFX[i].getNextSample(fb);
}

buffer[_writeIndex] = xn + fb;
*/