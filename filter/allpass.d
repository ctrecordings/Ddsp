/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.filter.allpass;

import std.math;

const float pi = 3.14159265;

struct Allpass
{
    float a0 = 0;
    float a1 = 0;
    float a2 = 0;
    float b0 = 0;
    float b1 = 0;
    float b2 = 0;

    float w = 0;
    float w1 = 0;
    float w2 = 0;

    float yn;

    float _frequency;
    float _sampleRate;

    void initialize(float frequency, float sampleRate, float q = 0.707) nothrow @nogc
    {
        _frequency = frequency;
        _sampleRate = sampleRate;
        float w0 = 2 * pi * _frequency / _sampleRate;
        float cs = cos(w0);
        float sn = sin(w0);
        float AL = sn / (2 * q);

        a0 = 1 + AL;
        a1 = (-2 * cs) / a0;
        a2 = (1 - AL) / a0;
        b0 = (1 - AL) / a0;
        b1 = (-2 * cs) / a0;
        b2 = (1 + AL) / a0;
    }

    float getNextSample(float input)  nothrow @nogc
    {
        w = input - a1 * w1 - a2 * w2;
        yn = b0 * w + b1 *w1 + b2 * w2;

        w2 = w1;
        w1 = w;

        return yn;
    }

    void setFrequency(float frequency) nothrow @nogc
    {
        if(_frequency != frequency)
            initialize(frequency, _sampleRate);
    }
}

unittest
{
    import std.random;
    import std.stdio;
    import std.math;

    Random gen;

    Allpass f1;
    f1.initialize(5000, 44100);
    //writefln("a0:%s a1:%s a2:%s b0:%s b1:%s b2:%s", f1.a0, f1.a1, f1.a2, f1.b0, f1.b1, f1.b2);
    for(int i = 0; i < 1000; ++i){
        float sample = uniform(0.0L, 1.0L, gen);
        float output = f1.getNextSample(sample);
        //if(i %10 == 0)
            //writefln("Input: %s | Output: %s", sample, output);
        //assert(abs(f1.getNextSample(sample)) <= 1);
    }
    for(int i = 0; i < 20050; ++i){
        float checkFreq = cast(float) i;
        float w = checkFreq * 2 * pi / 44100.0f;
        float ca = 1 + f1.a1*cos(w) + f1.a2*cos(2*w);
        float sa = f1.a1*sin(w) + f1.a2*sin(2*w);
        float cb = f1.b0 + f1.b1*cos(w) + f1.b2*cos(2*w);
        float sb = f1.b1*sin(w) + f1.b2*sin(2*w);
        float M = sqrt((cb * cb + sb * sb)/(ca * ca + sa * sa));
        float P = atan2(sb,cb)-atan2(sa,ca);
        //writefln("Magnitude: %s Phase: %s frequency: %s", M, P, i);
        //assert(M == 1);
    }
}

/**
phaseFrequency = 5000
sampleRate = 44100
doublePi = 3.14159265
q = 0.707
w0 = 2 * doublePi * phaseFrequency / sampleRate
cs = cos (w0)
sn = sin (w0)
AL = sn / ( 2 * q )
b0 =  1 - AL
b1 = -2 * cs
b2 =  1 + AL
a0 =  1 + AL
a1 = -2 * cs
a2 =  1 - AL

b0 = b0/a0
b1 = b1/a0
b2 = b2/a0
a1 = a1/a0
a2 = a2/a0

inp = 0
w = 0
w1 = 0
w2 = 0
out = 0

#Testing
for i in range(0, 1000):
    inp = float(i / 1000) * pow(-1,i)
    w = inp - a1 * w1 - a2 * w2
    out = b0 * w + b1* w1 + b2 * w2
    if Mod(i, 10) == 0:
        print "Input: " + str(inp)
        print "Output: " + str(out)
*/
/**
https://www.kvraudio.com/forum/viewtopic.php?t=278736
https://github.com/vinniefalco/DSPFilters/blob/4677dd7555eed12ad126c24b42a04cc887877925/shared/DSPFilters/include/DspFilters/State.h
https://www.kvraudio.com/forum/viewtopic.php?t=479651
*/