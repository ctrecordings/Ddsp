/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.filter.highpass;

import ddsp.filter.biquad;
import ddsp.effect : AudioEffect;
import ddsp.filter.lowpass : calculateQValuesForButterworth;

import std.math;

import dplug.core : mallocNew, mallocSlice;

/// First order highpass filter
class HighpassO1(T) : BiQuad!T
{
public:
nothrow:
@nogc:

    override void calcCoefficients() nothrow @nogc
    {
        _thetac = 2 * PI * _frequency / _sampleRate;
        _gamma = cos(_thetac) / (1 + sin(_thetac));
        _a0 = (1 + _gamma) / 2;
        _a1 = -_a0;
        _a2 = 0.0;
        _b1 = -_gamma;
        _b2 = 0.0;
    }

private:
    float _thetac;
    float _gamma;
}

unittest
{
    HighpassO1!float hpq1 = new HighpassO1!float();
}

/// Second order highpass filter
class HighpassO2(T) : BiQuad!T
{
public:
    void setQualityFactor(float Q) nothrow @nogc
    { 
        if(Q != _q)
        {
            _q = Q;
            calcCoefficients();
        }
    }

    override void calcCoefficients() nothrow @nogc
    {
        _thetac = 2 * PI * _frequency / _sampleRate;
        _d = 1 / _q;
        _beta = 0.5 * (1 - (_d / 2) * sin(_thetac)) / (1 + (_d / 2) * sin(_thetac));
        _gamma = (0.5 + _beta) * cos(_thetac);

        _a0 = (0.5 + _beta + _gamma) / 2;
        _a1 = - (0.5 + _beta + _gamma);
        _a2 = _a0;
        _b1 = -2.0 * _gamma;
        _b2 = 2.0 * _beta;
    }
    
private:
    float _thetac;
    float _q = 0.707f;
    float _beta;
    float _gamma;
    float _d;
}

unittest
{
    HighpassO2!float hpq2 = new HighpassO2!float();
}

/// Second order butterworth highpass filter
class ButterworthHP(T) : BiQuad!T
{
public:
    this() nothrow @nogc
    {
        super();
    }
    override void calcCoefficients() nothrow @nogc
    {
        _C = tan(PI * _frequency / _sampleRate);
        _a0 = 1.0f / (1.0f + sqrt(2.0f) * _C + (_C * _C));
        _a1 = -2.0f * _a0;
        _a2 = _a0;
        _b1 = 2.0f * _a0 * (_C * _C - 1.0f);
        _b2 = _a0 * (1.0f - sqrt(2.0f) * _C + _C * _C);
    }

private:
    float _C;
}

unittest
{
    ButterworthHP!float butterworthHP = new ButterworthHP!float();
}

/// Second order LinkwitzRiley highpass filter
class LinkwitzRileyHP(T) : BiQuad!T
{
public:
nothrow:
@nogc:

    this()
    {
        super();
    }

    override void calcCoefficients() nothrow @nogc
    {
        _theta = pi * _frequency / _sampleRate;
        _omega = pi * _frequency;
        _kappa = _omega / tan(_theta);
        _delta = _kappa * _kappa + _omega * _omega + 2 * _kappa * _omega;

        _a0 = (_kappa * _kappa) / _delta;
        _a1 = -2 * _a0;

        _a2 = _a0;
        _b1 = (-2 * _kappa * _kappa + 2 * _omega * _omega) / _delta;
        _b2 = (-2 * _kappa * _omega + _kappa * _kappa + _omega * _omega) / _delta;
    }

    // Useful in determining if setSampleRate and setFrequency need to be called
    // Uses short circuiting to squeeze a little more efficiency out of check
    bool isInitialized()
    {
        return !(isNaN(_theta) || isNaN(_omega) || isNaN(_kappa) || isNaN(_delta));
    }
private:
    float _theta;
    float _omega;
    float _kappa;
    float _delta;
}

unittest
{
    LinkwitzRileyHP!float linkwitzRileyHP = new LinkwitzRileyHP!float();
}

class LinkwitzRileyHPNthOrder(T) : AudioEffect!T
{
public:
nothrow:
@nogc:

    this(int order)
    {
        assert(order % 2 == 0, "LR filter order must be even");
        _order = order;

        _bw1 = mallocNew!(ButterworthHPNthOrder!T)(order / 2);
        _bw2 = mallocNew!(ButterworthHPNthOrder!T)(order / 2);
    }

    void setFrequency(float frequency)
    {
        if(frequency != _frequency)
        {
            _frequency = frequency;
            _bw1.setFrequency(_frequency);
            _bw2.setFrequency(_frequency);
        }
    }

    override float getNextSample(const(float) input)
    {
        return _bw2.getNextSample(_bw1.getNextSample(input));
    }

    override void reset()
    {
        _bw1.reset();
        _bw2.reset();
    }

    override void setSampleRate(float sampleRate)
    {
        if(sampleRate != _sampleRate)
        {
            _sampleRate = sampleRate;
            _bw1.setSampleRate(_sampleRate);
            _bw2.setSampleRate(_sampleRate);
        }
    }

private:
    ButterworthHPNthOrder!T _bw1;
    ButterworthHPNthOrder!T _bw2;

    int _order;
    float _frequency;
}

unittest
{
    LinkwitzRileyHPNthOrder!float lr8thOrder = mallocNew!(LinkwitzRileyHPNthOrder!float)(8);
    lr8thOrder.setSampleRate(44100);
    lr8thOrder.setFrequency(400);
    
}

class ButterworthHPNthOrder(T) : AudioEffect!T
{
public:
nothrow:
@nogc:
    this(int order)
    {
        _order = order;
        _secondOrderHighpasses = mallocSlice!(HighpassO2!float)(order / 2);
        foreach(index; 0..(order / 2))
        {
            _secondOrderHighpasses[index] = mallocNew!(HighpassO2!float)();
        }
    }

    void setFrequency(float frequency)
    {
        if(frequency != _frequency)
        {
            _frequency = frequency;
            float[] qValues = calculateQValuesForButterworth(_order);
            foreach(index, hpf; _secondOrderHighpasses)
            {
                float qValue = qValues[index];
                hpf.setFrequency(frequency);
                hpf.setQualityFactor(qValue);
            }
        }
    }

    override float getNextSample(const(float) input)
    {
        float output = input;
        foreach(hpf; _secondOrderHighpasses)
        {
            output = hpf.getNextSample(output);
        }
        return output;
    }

    override void reset()
    {
        foreach(hpf; _secondOrderHighpasses)
        {
            if(hpf)
            {
                hpf.reset();
            }
        }
    }

    override void setSampleRate(float sampleRate)
    {
        if(sampleRate != _sampleRate)
        {
            _sampleRate = sampleRate;
            foreach(index; 0.._secondOrderHighpasses.length)
            {
                _secondOrderHighpasses[index].setSampleRate(sampleRate);
            }
        }
    }

private:
    HighpassO2!float[] _secondOrderHighpasses;

    int _order;
    float _frequency;
}

unittest
{
    import std.stdio;
    writeln("****************************");
    writeln("* Butterworth Filter tests *");
    writeln("****************************");

    writeln("Q Value Calculations");
    float[] actual = calculateQValuesForButterworth(4);
    float[] expected = [0.541196100146197, 1.3065629648763764];
    assert( actual ==  expected, "Failed for order = 4");
    writeln("passed for order = 4");

    ButterworthHPNthOrder!float butterworth4 = mallocNew!(ButterworthHPNthOrder!float)(4);
    butterworth4.setSampleRate(44100.0f);
    butterworth4.setFrequency(10000);

    float[] impulse = [1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f];
    float[] hpfOutput = [];
    foreach(sample; impulse)
    {
        hpfOutput ~= butterworth4.getNextSample(sample);
    }

    writeln("Butterworth N=4 Output:");
    writeln(hpfOutput);
    
}