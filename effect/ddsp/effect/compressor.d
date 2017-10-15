/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.effect.compressor;

import ddsp.util.functions;
import ddsp.effect.dynamics;

import dplug.core.nogc;

import std.algorithm;
import std.math;

/// Basic compressor
class Compressor : DynamicsProcessor
{
public:
nothrow:
@nogc:
    
    override float getNextSample(float input)
    {
        _detector.detect(input);
        float detectorValue = floatToDecibel(_detector.getEnvelope());
        
        return input * calcCompressorGain(detectorValue, _threshold, _ratio, _kneeWidth);
    }
    
private:

    /// If set to true, ratio will become infinite and result in limiting
    bool _limit;
    
    /// This is the function that does most of the work with calculating compression
    float calcCompressorGain(float detectorValue, float threshold, float ratio, float kneeWidth)
    {
        float CS = 1.0f - 1.0f / ratio;
        
        if(_limit)
            CS = 1.0f;
            
        if(kneeWidth > 0 && detectorValue > (threshold - kneeWidth / 2.0f) && 
           detectorValue < threshold + kneeWidth / 2.0f)
        {
            x[0] = threshold - kneeWidth / 2.0f;
            x[1] = threshold + kneeWidth / 2.0f;
            x[1] = clamp(x[1], -96.0f, 0.0f);
            y[0] = 0;
            y[1] = CS;
            
            CS = lagrpol(x, y, 2, detectorValue);
        }
        
        float yG = CS * (threshold - detectorValue);
        
        yG = clamp(yG, -96.0, 0);
        
        return pow(10.0f, yG / 20.0f);
    }
}

/// Basic look-ahead limiter that is based on the compressor from before.
class Limiter : Compressor
{
    private import ddsp.util.buffer;
    private import dplug.core.nogc;
nothrow:
@nogc:
public:
    
    /// maxLookAhead is 300 by default.  If you intend to use a longer look-ahead
    /// time then it is best to specify it here so that no reallocation is needed
    /// later.
    this(int maxLookAhead = 300)
    {
        _lookAheadAmount = msToSamples(maxLookAhead, _sampleRate);
        _buffer = mallocNew!(Buffer!float)(cast(size_t)_lookAheadAmount);
        _ratio = float.infinity;
        _limit = true;
    }
    
    override float getNextSample(float input)
    {
        _buffer.write(input);
        float lookAheadOutput = _buffer.read();
        _detector.detect(input);
        float detectorValue = floatToDecibel(_detector.getEnvelope());
        return lookAheadOutput * calcCompressorGain(detectorValue, _threshold, _ratio, _kneeWidth);
    }
    
    /// 
    void setLookAhead(int msLookAhead)
    {
        _lookAheadAmount = msToSamples(msLookAhead, _sampleRate);
        _buffer.setSize(cast(size_t)_lookAheadAmount);
    }
private:
    /// Circular buffer that holds delay elements for look-ahead feature
    Buffer!float _buffer;
    
    /// Current amount of lookahead being used in samples.
    float _lookAheadAmount;
}
