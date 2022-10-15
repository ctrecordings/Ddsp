module ddsp.filter.onepole;

import ddsp.effect.effect : AudioEffect;

import std.math : PI, cos, sqrt;

class OnePoleFilter(T) : AudioEffect!T
{
    abstract void calcCoefficients();

    void setFrequency(float frequency)
    {
        _frequency = frequency;
        calcCoefficients();
    }

    override void processBuffers(const(T)* inputBuffer, T* outputBuffer, int numSamples)
    {
        foreach (sample; 0 .. numSamples)
        {
            outputBuffer[sample] = _a0 * outputBuffer[sample] - _b1 * _yn1;
            _yn1 = outputBuffer[sample];
        }
    }

    override void reset() nothrow @nogc
    {
        _thetac = 0;
        _gamma = 0;
        _b1 = 0;
        _a0 = 0;
        _yn1 = 0;
    }

protected:
    float _frequency;
    float _thetac;
    float _gamma;
    float _b1;
    float _a0;

private:
    float _yn1 = 0;
}

class OnePoleLPF(T) : OnePoleFilter!T
{
    override void calcCoefficients()
    {
        _thetac = 2 * PI * _frequency / _sampleRate;
        _gamma = 2 - cos(_thetac);
        _b1 = sqrt((_gamma * _gamma) - 1) - _gamma;
        _a0 = 1 + _b1;
    }
}

class OnePoleHPF(T) : OnePoleFilter!T
{
    override void calcCoefficients()
    {
        _thetac = 2 * PI * _frequency / _sampleRate;
        _gamma = 2 + cos(_thetac);
        _b1 = _gamma - sqrt((_gamma * _gamma) - 1);
        _a0 = 1 - _b1;
    }
}

unittest
{
    import std.stdio;

    writeln("****************************");
    writeln("* One-pole Filter tests    *");
    writeln("****************************");

    OnePoleLPF!float lowpass = new OnePoleLPF!float();
    lowpass.setSampleRate(44100);
    lowpass.setFrequency(1000);

    OnePoleHPF!float highpass = new OnePoleHPF!float();
    highpass.setSampleRate(44100);
    highpass.setFrequency(1000);

    float[] impulse = [1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f];
    float[] lpfOutput = [];
    float[] hpfOutput = [];
    foreach (sample; impulse)
    {
        lpfOutput ~= lowpass.getNextSample(sample);
        hpfOutput ~= highpass.getNextSample(sample);
    }

    writeln("Lowpass Output:");
    writeln(lpfOutput);
    writeln("Highpass Output");
    writeln(hpfOutput);
}
