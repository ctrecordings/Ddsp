/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
* 
* Based on equations from https://github.com/vinniefalco/DSPFilters
* --------------------------------------------------------------------------------
* License: MIT License (http://www.opensource.org/licenses/mit-license.php)
* Copyright (c) 2009 by Vinnie Falco
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/
module ddsp.filter.allpass;

import std.math;

import ddsp.effect.aeffect;

const float pi = 3.14159265;


/// Allpass filter for introducting a 180 degrees phase shift at the center
/// frequency.  This is necessary for summing more than 2 bands created from
/// Linkwitz-Riley filters.
/// TODO: Inherit BiQuad directly to remove redundent code.
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

    override float getNextSample(const float input)  nothrow @nogc
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