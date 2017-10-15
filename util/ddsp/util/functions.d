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

float floatToDecibel(float value) nothrow @nogc
{
  return clamp(20 * log(value), -96, 12);  
}

float dedibelToFloat(float value) nothrow @nogc
{
  return pow(10, value/20);
}

float msToSamples(float ms, float sampleRate) nothrow @nogc
{
  return ms * (sampleRate / 1000);
}

float samplesToMs(float samples, float sampleRate) nothrow @nogc
{
  return samples / (1000 / sampleRate);
}

float lagrpol(float[] arrX, float [] arrY, int order, float input) nothrow @nogc
{
  float sum = 0;
  for(int i = 0; i < order; ++i)
  {
    float Lg = 1.0f;
    for(int j = 0; j < order; ++j)
    {
      if (i != j)
        Lg *= (input - arrX[j])/(arrX[i] - arrX[j]);
    }
    sum += Lg * arrY[i];
  }
  return sum;
}

float linearInterp(float x1, float x2, float y1, float y2, float x) nothrow @nogc
{
  return (x - x1) * (y2 - y1) / (x2 - x1) + y1;
}

unittest
{
  import std.stdio;

  bool runTest = true;

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