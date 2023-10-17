/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.effect.expander;

import ddsp.util.functions;
import ddsp.effect.dynamics;

import dplug.core.nogc;

import std.algorithm;
import std.math;

/// Basic Expander
class Expander(T) : DynamicsProcessor!T
{
public:
nothrow:
@nogc:
    
    override T getNextSample(const T input)
    {
        detector.detect(input);
        float detectorValue = floatToDecibel(detector.getEnvelope());
        
        return input * calcExpanderGain(detectorValue, _threshold, _ratio, _kneeWidth);
    }
    
private:

    bool _gate;
    
    /// This is the function that does most of the work with calculating compression
    float calcExpanderGain(float detectorValue, float threshold, float ratio, float kneeWidth)
    {
        float ES = 1.0f / ratio - 1.0f;
        
        if(_gate)
            ES = -1.0f;
            
        if(kneeWidth > 0 && detectorValue > (threshold - kneeWidth / 2.0f) && 
           detectorValue < threshold + kneeWidth / 2.0f)
        {
            x[0] = threshold - kneeWidth / 2.0f;
            x[1] = threshold + kneeWidth / 2.0f;
            x[1] = clamp(x[1], -96.0f, 0.0f);
            y[0] = ES;
            y[1] = 0.0f;
            
            ES = lagrpol(x, y, 2, detectorValue);
        }
        
        float yG = ES * (threshold - detectorValue);
        
        yG = clamp(yG, -96.0, 0);
        
        return pow(10.0f, yG / 20.0f);
    }
}

unittest
{
    Expander!float expander = new Expander!float();
}

class Gate(T) : Expander!T
{
public:
nothrow:
@nogc:
    this()
    {
        _gate = true;
    }
}

unittest
{
    Gate!float gate = new Gate!float();
}