module ddsp.effect.compressor;

import ddsp.effect.aeffect;
import ddsp.util.envelope;
import ddsp.util.functions;

import dplug.core.nogc;

import std.algorithm;
import std.math;

class Compressor : AEffect
{
public:
nothrow:
@nogc:

    this()
    {
        x = mallocSlice!float(2);
        y = mallocSlice!float(2);
        _detector = mallocNew!EnvelopeDetector;
    }
    
    void setParams(float attackTime, float releaseTime, float threshold, float ratio, float knee)
    {
        _detector.setEnvelope(attackTime, releaseTime);
        _threshold = threshold;
        _ratio = ratio;
        _kneeWidth = knee;
    }
    
    override float getNextSample(float input)
    {
        //float inputGain = pow(10.0f, _inputGain / 20.0f);
        //float outputGain = pow(10.0f, _outputGain / 20.0f);
        _detector.detect(input);
        float detectorValue = _detector.getEnvelope();
        
        return input * calcCompressorGain(detectorValue, _threshold, _ratio, _kneeWidth, false);
    }
    
    override void reset() nothrow @nogc
    {
        
    }
    
    override void setSampleRate(float sampleRate)
    {
        _detector.setSampleRate(sampleRate);
    }
    
private:
    /// Amount of input gain in decibels
    float _inputGain;
    
    /// Level in decibels that the input signal must cross before compression begins
    float _threshold;
    
    /// Time in milliseconds before compression begins after threshold has been
    /// crossed
    float _attTime;
    
    /// Time in milliseconds before the compression releases after the input signal
    /// has fallen below the threshold
    float _relTime;
    
    /// Ratio of compression, higher ratio = more compression
    float _ratio;
    
    /// Amount of output gain in decibels
    float _outputGain;
    
    /// width of the curve that interpolates between input and output.  Unit in
    /// decibels
    float _kneeWidth;
    
    /// Tracks the input level to trigger compression.
    EnvelopeDetector _detector;
    
    /// Holds the points used for interpolation;
    float[]  x, y;
    
    /// This is the function that does most of the work with calculating compression
    float calcCompressorGain(float detectorValue, float threshold, float ratio, float kneeWidth, bool limit)
    {
        float CS = 1.0f - 1.0f / ratio;
        
        if(limit)
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