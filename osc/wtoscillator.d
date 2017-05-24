module ddsp.osc.wtoscillator;

import std.math;

const float pi = 3.14159265;

enum OSCType
{
    wav,
    sqr,
    saw,
    tri
}

struct WTOscillator
{
    float[1024] _sinArray;
    float _readIndex;
    float _incVal;
    float _sampleRate;
    bool _noteOn;

    void initialize(float frequency, float sampleRate, OSCType osctype)
    {
        if(osctype == OSCType.wav)
        {
            for(int i = 0; i < 1024; ++i)
            {
                _sinArray[i] = sin( (cast(float)i/1024.0f) * 2 * pi);
            }
        }

        _readIndex = 0.0f;
        setFrequency(frequency, sampleRate);
    }

    void setFrequency(float frequency, float sampleRate)
    {
        _incVal = 1024.0f * frequency / sampleRate;
    }

    void setFrequency(float frequency)
    {
        _incVal = 1024.0f * frequency / _sampleRate;
    }

    void reset()
    {
        _readIndex = 0.0f;
    }

    float getNextSample()
    {
        float output = 0.0f;

        int readIndex = cast(int)_readIndex;
        float frac = _readIndex - readIndex;
        int readIndexNext = readIndex + 1 > 1023 ? 0 : readIndex + 1;

        return output;
    }
}

float linearInterp(float x1, float x2, float y1, float y2, float frac)
{
    return 0;
}
