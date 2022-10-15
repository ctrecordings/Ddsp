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

import ddsp.filter.biquad;
import ddsp.effect : AudioEffect;

import dplug.core : Vec, mallocNew, makeVec;

/// 1st order Allpass filter for introducting a 90 degrees phase shift at the center
/// frequency.
class AllpassO1(T) : BiQuad!T
{
public:

    this() nothrow @nogc
    {
        super();
    }

    override void calcCoefficients()
    {
        _alpha = (tan(pi * _frequency / _sampleRate) - 1) / (tan(pi * _frequency / _sampleRate) + 1);

        _a0 = _alpha;
        _a1 = 1.0;
        _a2 = 0.0;
        _b1 = _alpha;
        _b2 = 0.0;
    }

private:
    float _alpha;
}

unittest
{
    import dplug.core.nogc;
    import ddsp.effect : testEffect;

    AllpassO1!float f = mallocNew!(AllpassO1!float)();
    f.setSampleRate(44100);
    f.setFrequency(10000);
    testEffect(f, "AllpassO1", 44100 * 2, false);
}

/// 2nd order Allpass filter for introducting a 180 degrees phase shift at the center
/// frequency.  This is necessary for summing more than 2 bands created from 2nd order
/// Linkwitz-Riley filters.
class AllpassO2(T) : BiQuad!T
{
public:

    this() nothrow @nogc
    {
        super();
    }

    override void calcCoefficients()
    {
        immutable float _w0 = 2 * PI * _frequency / _sampleRate;
        immutable float cs = cos(_w0);
        immutable float sn = sin(_w0);
        immutable float AL = sn / (2 * 0.707f);

        immutable float _b0 = 1 + AL;
        _b1 = (-2 * cs) / _b0;
        _b2 = (1 - AL) / _b0;
        _a0 = (1 - AL) / _b0;
        _a1 = (-2 * cs) / _b0;
        _a2 = (1 + AL) / _b0;
    }
}

/// Deprecated: use `AllpassO2` instead.
/// This is just an alias to `AllpassO2` since `Allpass` was renamed
/// to `AllpassO2`
alias Allpass = AllpassO2;

unittest
{
    import dplug.core.nogc;
    import ddsp.effect : testEffect;

    AllpassO2!float f = mallocNew!(AllpassO2!float)();
    f.setSampleRate(44100);
    f.setFrequency(10000);
    testEffect(f, "AllpassO2", 44100 * 2, false);
}

/// Nth order Allpass filter created using 2nd and 1st order Allpass filters
/// Useful to correct phase on crossovers created using nth order Linkwitz-Riley
/// filters.
class AllpassNthOrder(T) : AudioEffect!T
{
public:
nothrow:
@nogc:
    this(int order)
    {
        _order = order;

        // if odd order then we need one 1st order component
        if (_order % 2 != 0)
        {
            _1stOrderFilter = mallocNew!(AllpassO1!T)();
        }

        foreach (i; 0 .. (_order / 2))
        {
            _2ndOrderFilters.pushBack(mallocNew!(AllpassO2!T)());
        }
    }

    void setFrequency(float frequency)
    {
        if (_freqency != frequency)
        {
            _freqency = frequency;

            if (_1stOrderFilter)
            {
                _1stOrderFilter.setFrequency(_freqency);
            }

            foreach (i; 0 .. (_order / 2))
            {
                _2ndOrderFilters[i].setFrequency(_freqency);
            }
        }
    }

    override void setSampleRate(float sampleRate)
    {
        if (_sampleRate != sampleRate)
        {
            _sampleRate = sampleRate;

            if (_1stOrderFilter)
            {
                _1stOrderFilter.setSampleRate(_sampleRate);
            }

            foreach (i; 0 .. (_order / 2))
            {
                _2ndOrderFilters[i].setSampleRate(_sampleRate);
            }
        }
    }

    override void processBuffers(const(T)* inputBuffer, T* outputBuffer, int numSamples)
    {
        if (_1stOrderFilter)
        {
            _1stOrderFilter.processBuffers(inputBuffer, outputBuffer, numSamples);
        }
        else
        {
            foreach (i; 0 .. (_order / 2))
            {
                _2ndorderFilters.processBuffers(inputBuffer, outputBuffer, numSamples);
            }
        }

    }

    override void reset()
    {
        if (_1stOrderFilter)
        {
            _1stOrderFilter.reset();
        }

        foreach (i; 0 .. (_order / 2))
        {
            _2ndOrderFilters[i].reset();
        }
    }

private:
    Vec!(AllpassO2!T) _2ndOrderFilters;
    AllpassO1!T _1stOrderFilter;

    int _order;
    float _freqency;
}
