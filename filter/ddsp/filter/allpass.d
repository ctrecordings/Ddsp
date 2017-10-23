/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.filter.allpass;

import std.math;

import ddsp.effect.aeffect;

const float pi = 3.14159265;

class Allpass : AEffect
{
public:

    this() nothrow @nogc
    {

    }

    void initialize(float frequency, float q = 0.707) nothrow @nogc
    {
        _frequency = frequency;
        float _w0 = 2 * pi * _frequency / _sampleRate;
        float cs = cos(_w0);
        float sn = sin(_w0);
        float AL = sn / (2 * q);

        _a0 = 1 + AL;
        _a1 = (-2 * cs) / _a0;
        _a2 = (1 - AL) / _a0;
        _b0 = (1 - AL) / _a0;
        _b1 = (-2 * cs) / _a0;
        _b2 = (1 + AL) / _a0;
    }

    override float getNextSample(const ref float input)  nothrow @nogc
    {
        _w = input - _a1 * _w1 - _a2 * _w2;
        _yn = _b0 * _w + _b1 *_w1 + _b2 * _w2;

        _w2 = _w1;
        _w1 = _w;

        return _yn;
    }

    override void reset() nothrow @nogc
    {
        _a0 = 0;
        _a1 = 0;
        _a2 = 0;
        _b0 = 0;
        _b1 = 0;
        _b2 = 0;

        _w = 0;
        _w1 = 0;
        _w2 = 0;

        _yn = 0;
    }

    void setFrequency(float frequency) nothrow @nogc
    {
        if(_frequency != frequency)
            initialize(frequency, _sampleRate);
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
}

unittest
{
    import dplug.core.nogc;
    
    Allpass f = mallocNew!Allpass();
    f.setSampleRate(44100);
    f.setFrequency(10000);
    testEffect(f, "Allpass", 44100 * 2, false);
}