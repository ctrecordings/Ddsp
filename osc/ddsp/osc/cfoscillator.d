/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module cfoscillator.d;

import ddsp.effect.aeffect;

import std.math;

/**
* Coupled-Form Oscillator (Gordon-Smith Oscillator)
*/
class CFOscillator : AEffect
{
public:

    this()
    {
        init = false;
    }
    
    void initialize(float frequency, float sampleRate, float mix = 1.0f) nothrow @nogc
    {
        fo = frequency;
        _sampleRate = sampleRate;
        _mix = mix;
        
        theta = 2 * PI * fo / _sampleRate;
        epsilon = 2 * sin(theta / 2);
        
        if(!init)
        {
            yn1 = sin(-1 * theta);
            yq1 = cos(-1 * theta);
            init = true;
        }
    }
    
    void setFrequency(float frequency) nothrow @nogc
    {
        initialize(frequency, _sampleRate);
    }
    
    override float getNextSample(const ref float input) nothrow @nogc
    {
        yq = yq1-epsilon * yn1;
        yn = epsilon * yq + yn1;
        
        yq1 = yq;
        yn1 = yn;
        
        return (yn * _mix) + (input * (1 - _mix));
    }
    
    override void reset() nothrow @nogc
    {
        initialize(fo, _sampleRate);
    }
    
private:
    
    float yq;
    float yq1;
    float yn;
    float yn1;
    float epsilon;
    float theta;
    float fo;
    float _mix;
    
    bool init;
}

unittest
{
    import dplug.core.nogc;
    import ddsp.effect.aeffect;

    CFOscillator osc = mallocNew!CFOscillator;

    osc.initialize(1000, 44100);

    testEffect(osc, "Coupled-Form Oscillator", 20000, false);
}