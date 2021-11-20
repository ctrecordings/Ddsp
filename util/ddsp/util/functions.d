/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.util.functions;

import std.math;
import core.stdc.stdlib;
import std.conv : emplace;
import std.algorithm : clamp;

/++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 + This is a collection of useful DSP related functions and algorithms.
 + if you feel anything is missing, please feel free to add it.
 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++/

/// Accepts a floating point value and returns its decibel equivalent.
/// `value` should be in the range of -1 to 1 and returns a float in the
/// range -96 to 0
T floatToDecibel(T = float)(T value) nothrow @nogc
{
    return 20 * log10(value); 
}

/// Accepts a decibel value and returns its floating point equivalent.
T decibelToFloat(T = float)(T value) nothrow @nogc
{
    return pow(10, value/20);
}

/// Accepts a time in milliseconds and the sample rate
/// Returns the amount of samples that corresponds to the
/// time in milliseconds.
T msToSamples(T = float)(T ms, T sampleRate) nothrow @nogc
{
    return ms * (sampleRate / 1000);
}

/// Accepts a number of samples and the sample rate.
/// Returns the corresponding time in milliseconds.
T samplesToMs(T = float)(T samples, T sampleRate) nothrow @nogc
{
    return samples / (sampleRate / 1000);
}

/// Lagrange Interpolation
/// Accepts:
///         arrX = an array of x coordinates.
///         arrY = an array of y coordinates.
///         order = the number of coordinates (size of arrX & arrY)
///         input = the x coordinate whose corresponding y value will be found
/// Returns a y value along the curve that touches each (x,y) pair from arrX
/// and arrY.    The pair (input, sum) is a point on that curve.
T lagrpol(T = float)(T[] arrX, T[] arrY, int order, T input) nothrow @nogc
{
    T sum = 0;
    for(int i = 0; i < order; ++i)
    {
        T Lg = 1.0f;
        for(int j = 0; j < order; ++j)
        {
            if (i != j)
                Lg *= (input - arrX[j])/(arrX[i] - arrX[j]);
        }
        sum += Lg * arrY[i];
    }
    return sum;
}

/// Linear Interpolation between two points.
/// (x1,y1) is the leftmost point and (x2,y2)
/// is the rightmost point. x is some number
/// between x1 and x2.
/// Returns the corresopnding y value for x
/// such that (x,y) is a point on the line
/// that intersects (x1,y1) and (x2,y2)
T linearInterp(T = float)(T x1, T x2, T y1, T y2, T x) nothrow @nogc
{
    return (x - x1) * (y2 - y1) / (x2 - x1) + y1;
}

/// sinc(x) aka the sampling function.
T sinc(T = float)(T x)
{
    if(x == 0)
        return 1;
    else
        return sin(x) / x;
}

unittest
{
    import std.stdio;

    bool runTest = false;

    if(runTest)
    {
        float[] x = [1, 0.7079457844, 0.5011872336, 0.2511886432, 0.0630957344, 0.0039810717, 0.0000158489];
        float[] y = [1, 0.833333333, 0.666666666, 0.5, 0.333333333, 0.166666666, 0];

        writefln("Functions test..");
        writefln("x: %s", x);
        writefln("y: %s", y);
        for(int i = 0; i < 101; ++i)
        {
            writefln("Lagrange x = %s: %s",cast(float)i / 100, lagrpol(x, y, 2, cast(float)i/100));
        }
    }
}

deprecated("Use std.math.round instead")
{
    /// Simple nothrow @nogc method of rounding a float to an int
    int roundToInt(float x) nothrow @nogc
    {
        return x - cast(int)x >= 0.5f ? (cast(int) x) + 1 : cast(int) x; 
    }
}
