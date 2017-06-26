module ddsp.util.functions;

import std.math;
import core.stdc.stdlib;
import std.conv : emplace;

auto allocate(T, Args...)(Args args)
{
  static if (is(T == class))
        immutable size_t allocSize = __traits(classInstanceSize, T);
    else
        immutable size_t allocSize = T.sizeof;

    void* rawMemory = malloc(allocSize);

    static if (is(T == class))
    {
        T obj = emplace!T(rawMemory[0 .. allocSize], args);
    }
    else
    {
        T* obj = cast(T*)rawMemory;
        emplace!T(obj, args);
    }

    return obj;
}

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