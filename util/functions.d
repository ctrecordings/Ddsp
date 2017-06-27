module ddsp.util.functions;

import std.math;
import core.stdc.stdlib;
import std.conv : emplace;

float floatToDecibel(float value) nothrow @nogc
{
  return 20 * log(value);  
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