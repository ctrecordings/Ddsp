/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.osc.cfoscillator;

import ddsp.effect.effect;

import std.math;

/**
* Coupled-Form Oscillator (Gordon-Smith Oscillator)
*/
class CFOscillator : AudioEffect
{
public:
nothrow:
@nogc:

    this()
    {
        init = false;
    }
    
    void initialize(float frequency) nothrow @nogc
    {
        fo = frequency;
        
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
        initialize(frequency);
    }
    
    override float getNextSample(const float input) nothrow @nogc
    {
        yq = yq1-epsilon * yn1;
        yn = epsilon * yq + yn1;
        
        yq1 = yq;
        yn1 = yn;
        
        return yn;
    }
    
    override void reset() nothrow @nogc
    {
        init = false;
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
    
    bool init;
}

unittest
{
    import dplug.core.nogc;
    import ddsp.effect.effect;

    CFOscillator osc = mallocNew!CFOscillator;

    osc.initialize(1000, 44100);

    testEffect(osc, "Coupled-Form Oscillator", 20000, false);
}