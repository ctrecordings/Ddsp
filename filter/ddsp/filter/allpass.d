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


/// Allpass filter for introducting a 180 degrees phase shift at the center
/// frequency.  This is necessary for summing more than 2 bands created from
/// Linkwitz-Riley filters.
class Allpass(T) : BiQuad!T
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

unittest
{
    import dplug.core.nogc;
    import ddsp.effect : testEffect;
    
    Allpass!float f = mallocNew!(Allpass!float)();
    f.setSampleRate(44100);
    f.setFrequency(10000);
    testEffect(f, "Allpass", 44100 * 2, false);
}