/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.filter.shelf;

import ddsp.filter.biquad;
import ddsp.effect.effect;

import std.math;

/// The equations for calculating the BiQuad Coefficients are based off of those from vinniefalco/DSPFilters
class LowShelf(T) : AudioEffect!T
{
public:

    void setGain(float gain) nothrow @nogc
    {
        if(_gain != gain)
        {
            _gain = gain;
            calcCoefficients();
        }
    }

    override T getNextSample(const T input)  nothrow @nogc
    {
        _w = input - _a1 * _w1 - _a2 * _w2;
        _yn = _b0 * _w + _b1 *_w1 + _b2 * _w2;

        _w2 = _w1;
        _w1 = _w;

        return _yn;
    }

    override void reset() nothrow @nogc
    {
        _w = 0;
        _w1 = 0;
        _w2 = 0;

        _yn = 0;
    }

    void setFrequency(float frequency) nothrow @nogc
    {
        if(_frequency != frequency)
        {
            _frequency = frequency;
            calcCoefficients();
        }
    }
    
    override string toString()
    {
        import std.conv;
        return "a0: " ~ to!string(_a0) ~
               "a1: " ~ to!string(_a1) ~
               "a2: " ~ to!string(_a2) ~
               "b0: " ~ to!string(_b0) ~
               "b1: " ~ to!string(_b1) ~
               "b2: " ~ to!string(_b2);
    }

private:
    float _a0 = 0;
    float _a1 = 0;
    float _a2 = 0;
    float _b0 = 0;
    float _b1 = 0;
    float _b2 = 0;

    float _w = 0;
    float _w1 = 0;
    float _w2 = 0;

    float _yn;

    float _frequency;
    float _gain;

    void calcCoefficients() nothrow @nogc
    {
        float shelfSlope = 2.0f;
        float A  = pow (10, _gain/40);
        float w0 = 2 * pi * _frequency / _sampleRate;
        float cs = cos (w0);
        float sn = sin (w0);
        float AL = sn / 2 * sqrt ((A + 1/A) * (1 / shelfSlope - 1) + 2);
        float sq = 2 * sqrt(A) * AL;
        _b0 =    A*( (A+1) - (A-1)*cs + sq );
        _b1 =  2*A*( (A-1) - (A+1)*cs );
        _b2 =    A*( (A+1) - (A-1)*cs - sq );
        _a0 =        (A+1) + (A-1)*cs + sq;
        _a1 =   -2*( (A-1) + (A+1)*cs );
        _a2 =        (A+1) + (A-1)*cs - sq;

        _b0 /= _a0;
        _b1 /= _a0;
        _b2 /= _a0;
        _a1 /= _a0;
        _a2 /= _a0;
    }
}

unittest
{
    import dplug.core.nogc;
    import dplug.core.vec;
    import ddsp.effect.effect;

    Vec!(LowShelf!float) filters = makeVec!(LowShelf!float);
    foreach(channel; 0..2)
    {
        filters.pushBack(mallocNew!(LowShelf!float));
        filters[channel].setSampleRate(44100.0f);
        filters[channel].setFrequency(150.0f);
        filters[channel].setGain(3.0f);
    }

    //testEffect(AudioEffect effect, string name, size_t bufferSize = 20000, bool outputResults = false)
    foreach(filter; filters)
        testEffect(filter, "LowShelf" , 20000, false);
}