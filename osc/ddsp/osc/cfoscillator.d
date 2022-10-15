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
class CFOscillator(T) : AudioEffect!T
{
public:
nothrow:
@nogc:

    this()
    {
        init = false;
    }

    void setFrequency(float frequency) nothrow @nogc
    {
        fo = frequency;

        theta = 2 * PI * fo / _sampleRate;
        epsilon = 2 * sin(theta / 2);

        if (!init)
        {
            yn1 = sin(-1 * theta);
            yq1 = cos(-1 * theta);
            init = true;
        }
    }

    override void processBuffers(const(T)* inputBuffer, T* outputBuffer, int numSamples)
    {
        foreach (sample; 0 .. numSamples)
        {
            yq = yq1 - epsilon * yn1;
            outputBuffer[sample] = epsilon * yq + yn1;

            yq1 = yq;
            yn1 = yn;
        }
    }

    override void reset() nothrow @nogc
    {
        init = false;
        setFrequency(fo);
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

    CFOscillator!float osc = mallocNew!(CFOscillator!float);
    osc.setSampleRate(44100);
    osc.setFrequency(1000);

    testEffect(osc, "Coupled-Form Oscillator", 20000, false);
}

