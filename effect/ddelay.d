/**
* Copyright 2017 Cut Through Recordings
* Author(s): Ethan Reker
*/
module ddsp.effect.ddelay;

import ddsp.effect.aeffect;
import ddsp.util.functions;

/**
* A general purpose Digital Delay with support for external feedback and fractional delay.
*/
class DDelay : AEffect
{
public:
    import core.stdc.stdlib;
    import dplug.core.alignedbuffer;

    this() nothrow @nogc
    {
        //_size = maxSize;
        //buffer = cast(float*) malloc(_size * float.sizeof);
        //buffer[0.._size] = 0;
        buffer = null;
        _size = 0;
        _feedback = 0.0f;
        _mix = 0.0f;
        _useExternalFeedback = false;
        
        _readIndex = 0;
        _writeIndex = 0;
        
        feedbackFX = makeAlignedBuffer!AEffect;
    }
    
    ~this() nothrow @nogc { free(buffer); }
    
    void initialize(float sampleRate, float maxSizeMS, float delayInMS, float feedback, float mix) nothrow @nogc
    {
        _sampleRate = sampleRate;
       // _size = size;
        _feedback = feedback;
        _mix = mix;
        _delayInSamples = msToSamples(delayInMS, sampleRate);
        
        //Create buffer if null and reset it to 0
        _size = cast(size_t)msToSamples(maxSizeMS, sampleRate);
        if(buffer == null)
            buffer = cast(float*) malloc(_size * float.sizeof);
        reset();
        
        assert(cast(size_t)_delayInSamples <= _size);
        
        _writeIndex = 0;
        _readIndex = _writeIndex - cast(size_t)_delayInSamples;
        if(_readIndex < 0)
            _readIndex += _size;
    }
    
    void setDelay(size_t msDelay) nothrow @nogc
    {
        _delayInSamples = msToSamples(msDelay, _sampleRate);
        reset();
    }
    
    override float getNextSample(float input) nothrow @nogc
    {
        //Non-fractional delay
        /*float xn = input;
        float yn = buffer[_readIndex];
        
        if(_delayInSamples == 0)
            yn = xn;
        
        if(!_useExternalFeedback)
            buffer[_writeIndex] = xn + _feedback * yn;
        else
            buffer[_writeIndex] = xn + _feedbackIn;
        
        float output = _mix * yn + (1.0 - _mix) * xn;
        
        if(++_writeIndex >= _size)
            _writeIndex = 0;
        if(++_readIndex >= _size)
            _readIndex = 0;
            
        return output;*/
        
        float xn = input;
        float yn = buffer[_readIndex];
        
        //if delay < 1 sample, interpolate between input x(n) and x(n-1)
        if(_readIndex == _writeIndex && _delayInSamples < 1.00)
        {
            yn = xn;
        }
        
        //Read the location ONE BEHIND yn at y(n-1)
        size_t _readIndex_1 = _readIndex - 1;
        if(_readIndex_1 < 0)
            _readIndex_1 = _size - 1;
        
        //get y(n -1)
        float yn_1 = buffer[_readIndex_1];
        
        //interpolate: (0, yn) and (1, yn_1) by the amount fracDelay
        float fracDelay = _delayInSamples - cast(int)_delayInSamples;
        
        float interp = linearInterp(0, 1, yn, yn_1, fracDelay);
        
        if(_delayInSamples == 0)
            yn = xn;
        else
            yn = interp;
        
        /** TODO: process each AEffect on the feedback input
        float fb;
        if(!_useExternalFeedback)
            fb = _feedback;
        else
            fb = _feedbackIn;
        
        for(int i = 0; i < feedbackFX.length(); ++i){
            fb = feedbackFX[i].getNextSample(fb);
        }
        
        buffer[_writeIndex] = xn + fb * yn;
        */
        
        
        if(!_useExternalFeedback)
            buffer[_writeIndex] = xn + _feedback * yn;
        else
            buffer[_writeIndex] = xn + _feedbackIn;
        
        float output = _mix * yn + (1.0 - _mix) * xn;
        
        if(++_writeIndex >= _size)
            _writeIndex = 0;
        if(++_readIndex >= _size)
            _readIndex = 0;
            
        return output;
    }
    
    //set all elements in the buffer to 0
    override void reset() nothrow @nogc
    {
        //buffer[0..cast(size_t)_delayInSamples] = 0;
        buffer[0.._size] = 0;
    }
    
    float getCurrentFeedbackOutput() nothrow @nogc { return _feedback * buffer[_readIndex];}
    
    void setCurrentFeedbackInput(float f) nothrow @nogc { _feedbackIn = f;}
    
    void setUseExternalFeedback(bool b) nothrow @nogc { _useExternalFeedback = b;}
    
    void addFeedbackEffect(AEffect effect) nothrow @nogc { feedbackFX.pushBack(effect);}
    
private:

    float *buffer;
    float _sampleRate;
    float _feedback;
    float _mix;
    
    size_t _size;
    float _delayInSamples;
    float _delayInMS;
    
    size_t _writeIndex;
    size_t _readIndex;
    
    bool _useExternalFeedback;
    float _feedbackIn;
    
    AlignedBuffer!AEffect feedbackFX;
}

unittest
{
    import dplug.core.nogc;
    
    DDelay d = mallocEmplace!DDelay(cast(size_t)msToSamples(2000, 44100));
    d.initialize(44100, 1000, 0.0, 1.0);
    testEffect(d, "DDelay", 44100 * 2);
}