module ddsp.util.oversample;

import ddsp.effect.effect;

class OverSampler(T) : AudioEffect
{
public:
nothrow:
@nogc:

    this()
    {
        
    }

    this(uint factor)
    {
        setSampleFactor(factor);
    }

    // Power of 2
    void setSampleFactor(uint factor)
    {
        assert(factor >= 0 && factor < 7, "OverSampler factor must be 0 or greater");
        _factor = 2 << factor;
    }

    override void setSampleRate(float sampleRate)
    {
        assert(_factor >= 0, "setSampleFactor must be called or have factor passed in constructor");
        _sampleRate = sampleRate * _factor;
    }

    override float getNextSample(const float input)
    {
        return 0;
    }

    override void reset()
    {

    }

private:
    uint _factor;
}

unittest
{
    import std.stdio;

    OverSampler!float sampler = new OverSampler!float();
    sampler.setSampleRate(44100);
    sampler.setSampleFactor(1);
}