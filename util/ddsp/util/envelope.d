module ddsp.util.envelope;

import std.math;
import std.algorithm;
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
    
    void setSampleRate(float sampleRate)
    {
        _sampleRate = sampleRate;
    }
    
    void setEnvelope(float attackTime, float releaseTime)
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
    
    void setSampleRate(float sampleRate)
    {
        _sampleRate = sampleRate;
    }
    
    void initialize(float decayTime)
    {
        _decay = pow(0.5, 1.0 / (decayTime * _sampleRate));
    }
    
    void detect(float input)
    {
        input = abs(input);
        
        if(input >= _envelope)
            _envelope = input;
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