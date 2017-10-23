/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.util.envelope;

import std.math;
import std.algorithm;

/// Envelop Detector with adjustable attack and release times. Great for compressors
/// and meters.
/+
http://www.musicdsp.org/showArchiveComment.php?ArchiveID=97
+/
class EnvelopeDetector
{
public:
nothrow:
@nogc:

    this()
    {
        _envelope = 0f;    
    }
    
    void setSampleRate(const float sampleRate)
    {
        _sampleRate = sampleRate;
    }
    
    void setEnvelope(const float attackTime, const float releaseTime)
    {
        _ga = exp(-1/(_sampleRate * attackTime / 1000));
        _gr = exp(-1 / (_sampleRate * releaseTime / 1000));
    }
    
    void detect(float input)
    {
        float envIn = abs(input);
        
        if(_envelope < envIn)
            _envelope = _envelope * _ga + (1 - _ga) * envIn;
        else
            _envelope = _envelope * _gr + (1 - _gr) * envIn;
        
    }
    
    float getEnvelope()
    {
        return _envelope;
    }
    
private:
    /// Attack coefficient
    float _ga;
    
    /// Release coefficient
    float _gr;
    
    /// stores the current value of the envelope;
    float _envelope;
    
    /// Sample Rate
    float _sampleRate;
}

/// Simple Peak envelope follower, useful for meters.
/+
http://www.musicdsp.org/archive.php?classid=2#19
+/
class PeakFollower
{
public:
nothrow:
@nogc:

    this()
    {
        _envelope = 0f;
    }
    
    void setSampleRate(const float sampleRate)
    {
        _sampleRate = sampleRate;
    }
    
    void initialize(const float decayTime)
    {
        _decay = pow(0.5, 1.0 / (decayTime * _sampleRate));
    }
    
    void detect(const float input)
    {
        float absInput = abs(input);
        
        if(absInput >= _envelope)
            _envelope = absInput;
        else
        {
            _envelope = clamp(_envelope * _decay, 0.0f, 1.0f);
        }
    }
    
    float getEnvelope()
    {
        return _envelope;
    }
    
private:
    float _envelope;
    
    float _decay;
    
    float _sampleRate;
}

/+class SimpleRMS
{
public:
nothrow:
@nogc:

    this()
    {
        _envelope = 0.0f;
    }
    
    void setSampleRate(float sampleRate)
    {
        _sampleRate = sampleRate;
    }
    
    void initialize(uint windowSize)
    {
        _windowSize = windowSize;
        buffer = cast(T*) malloc(windowSize * T.sizeof);
    }
    
    void detect(float input)
    {
        
    }
    
    float getEnvelope()
    {
        return _envelope;
    }
    
private:
    float[] buffer;
}+/