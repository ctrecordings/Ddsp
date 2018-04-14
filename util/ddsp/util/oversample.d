module ddsp.util.oversample;

import core.stdc.stdlib;

import ddsp.effect.effect : AudioEffect;
import ddsp.util.memory : calloc;
import ddsp.util.functions : linearInterp;
import ddsp.filter.lowpass : LinkwitzRileyLP;

import dplug.core.vec;

class OverSampler(T) : AudioEffect
{
public:
nothrow:
@nogc:

    this()
    {
        lowpassIn = calloc!LinkwitzRileyLP.init();
        lowpassOut = calloc!LinkwitzRileyLP.init();

        effects = makeVec!AudioEffect();
    }

    this(uint factor)
    {
        setSampleFactor(factor);
        this();
    }

    // Power of 2
    void setSampleFactor(uint factor)
    {
        assert(factor >= 0 && factor < 7, "OverSampler factor must be 0 or greater");
        _bufferSize = (1 << factor) + 1;
        initializeBuffer();
    }

    override void setSampleRate(float sampleRate)
    {
        assert(_bufferSize > 0, "setSampleFactor must be called or have factor passed in constructor");
        _sampleRate = sampleRate * (_bufferSize - 1);
        nyquistFrequency = cast(long)(sampleRate / 2);

        lowpassIn.setSampleRate(_sampleRate);
        lowpassOut.setSampleRate(_sampleRate);
        lowpassIn.setFrequency(nyquistFrequency);
        lowpassOut.setFrequency(nyquistFrequency);

        foreach(effect; effects)
        {
            effect.setSampleRate(_sampleRate);
        }
    }

    override float getNextSample(const float input)
    {
        upSample(input);
        doLowpassIn();
        foreach(effect; effects)
        {
            for(int i = 0; i < _bufferSize; ++i)
            {
                buffer[i] = effect.getNextSample(buffer[i]);
            }
        }
        doLowpassOut();
        return buffer[0];
    }

    void upSample(const float input)
    {
        buffer[0] = buffer[_bufferSize - 1];
        buffer[_bufferSize - 1] = input;
        for(int i = 1; i < _bufferSize - 1; ++i)
        {
            buffer[i] = linearInterp(0, _bufferSize - 1, buffer[0], input, i);
        }
    }

    override void reset()
    {
        lowpassIn.reset();
        lowpassOut.reset();
        foreach(effect; effects)
        {
            effect.reset();
        }
    }

    /// Note that buffer includes previous sample and current sample so its size is 2^factor + 1
    T[] Buffer() @property
    {
        return buffer[0.._bufferSize];
    }

    float Nyquist() @property
    {
        return nyquistFrequency;
    }

    void insertEffect(AudioEffect effect)
    {
        effects.pushBack(effect);
    }


private:
    uint _bufferSize;
    T* buffer;
    long nyquistFrequency;

    LinkwitzRileyLP lowpassIn;
    LinkwitzRileyLP lowpassOut;

    Vec!AudioEffect effects;

    void initializeBuffer()
    {
        assert(_bufferSize >= 1, "Must set oversample factor");
        buffer = cast(float*)malloc(float.sizeof * _bufferSize);
        buffer[0]  = 0;
    }

    void doLowpassIn()
    {
        for(int i = 1; i < _bufferSize; ++i)
        {
            buffer[i] = lowpassIn.getNextSample(buffer[i]);
        }
    }

    void doLowpassOut()
    {
        for(int i = 1; i < _bufferSize; ++i)
        {
            buffer[i] = lowpassOut.getNextSample(buffer[i]);
        }
    }
}

unittest
{
    //Oversampler pushBackSampleTest
    import std.stdio;

    OverSampler!float sampler = new OverSampler!float();
    sampler.setSampleFactor(2);
    sampler.setSampleRate(44100);
    

    sampler.upSample(0.5);
    sampler.upSample(1.0);

    auto expected = [0.5, 0.6250, 0.7500, 0.8750, 1.0];
    auto actual = sampler.Buffer();

    assert(expected == actual, "Failed Test - Oversampler pushBackSampleTest");
    assert(sampler.SampleRate == 176400f, "Failed Test - Oversampler setSampleRate");

    ///
    ///
    ///

    import ddsp.effect.effect : testEffect;

    class Distorter : AudioEffect
    {
        private import std.math;
        override float getNextSample(const float input) { return sin(input * PI_2);}
        override void reset() {}
    }

    Distorter distorter = calloc!Distorter.init();

    sampler = new OverSampler!float();
    sampler.setSampleFactor(2);
    sampler.setSampleRate(44100);
    sampler.insertEffect(distorter);
    testEffect(sampler, "Oversampler", 20000 * 4, false);
}