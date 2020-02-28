/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.filter.lowpass;

import ddsp.filter.biquad;
import ddsp.effect.effect : AudioEffect;

import std.math;
import dplug.core.nogc;

/// First order lowpass filter
class LowpassO1(T) : BiQuad!T
{
public:
    override void calcCoefficients() nothrow @nogc
    {
        _thetac = 2 * PI * _frequency / _sampleRate;
        _gamma = cos(_thetac) / (1 + sin(_thetac));
        _a0 = (1 - _gamma) / 2;
        _a1 = _a0;
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
    LowpassO1!float lowpassQ1 = new LowpassO1!float();
}

/// Second order lowpass filter
class LowpassO2(T) : BiQuad!T
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
        _a0 = (0.5 + _beta - _gamma) / 2;
        _a1 = 0.5 + _beta - _gamma;
        _a2 = _a1 / 2;
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
    LowpassO2!float lowpassQ2 = new LowpassO2!float();
}

/// Second order butterworth lowpass filter
class ButterworthLP(T) : BiQuad!T
{
public:
    override void calcCoefficients() nothrow @nogc
    {
        _C = 1.0 / tan(PI * _frequency / _sampleRate);
        _a0 = 1.0 / (1 + sqrt(2.0f) * _C + (_C * _C));
        _a1 = 2.0 * _a0;
        _a2 = _a0;
        _b1 = 2.0 * _a0 * (1 - _C * _C);
        _b2 = _a0 * (1.0f - sqrt(2.0f) * _C + _C * _C);
    }
private:
    float _C;
}

unittest
{
    ButterworthLP!float butterworthLP = new ButterworthLP!float();
}

//Second order linkwitz-riley lowpass filter
class LinkwitzRileyLP(T) : BiQuad!T
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

        _a0 = (_omega * _omega) / _delta;
        _a1 = 2 * _a0;

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
    LinkwitzRileyLP!float linkwitzRileyLP = new LinkwitzRileyLP!float();
}

float[] calculateQValuesForButterworth(int filterOrder) nothrow @nogc
{
    float[] qValues = mallocSlice!float(filterOrder / 2);
    immutable int denominator = 4 * filterOrder / 2;
    int numerator = 1;
    foreach(fIndex; 0..(filterOrder / 2))
    {
        qValues[fIndex] = abs(1 / (2 * cos(numerator * PI / denominator)));
        numerator += 2;
    }
    return qValues;
}

class ButterworthLPNthOrder(T) : AudioEffect!T
{
public:
nothrow:
@nogc:
    this(int order)
    {
        _order = order;
        _secondOrderLowpasses = mallocSlice!(LowpassO2!float)(order / 2);
        foreach(index; 0..(order / 2))
        {
            _secondOrderLowpasses[index] = mallocNew!(LowpassO2!float)();
        }
    }

    void setFrequency(float frequency)
    {
        if(frequency != _frequency)
        {
            _frequency = frequency;
            float[] qValues = calculateQValuesForButterworth(_order);
            foreach(index, lpf; _secondOrderLowpasses)
            {
                float qValue = qValues[index];
                lpf.setFrequency(frequency);
                lpf.setQualityFactor(qValue);
            }
        }
    }

    override float getNextSample(const(float) input)
    {
        float output = input;
        foreach(lpf; _secondOrderLowpasses)
        {
            output = lpf.getNextSample(output);
        }
        return output;
    }

    override void reset()
    {
        foreach(lpf; _secondOrderLowpasses)
        {
            if(lpf)
            {
                lpf.reset();
            }
        }
    }

    override void setSampleRate(float sampleRate)
    {
        if(sampleRate != _sampleRate)
        {
            _sampleRate = sampleRate;
            foreach(index; 0.._secondOrderLowpasses.length)
            {
                _secondOrderLowpasses[index].setSampleRate(sampleRate);
            }
        }
    }

private:
    LowpassO2!float[] _secondOrderLowpasses;

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

    ButterworthLPNthOrder!float butterworth4 = mallocNew!(ButterworthLPNthOrder!float)(4);
    butterworth4.setSampleRate(44100.0f);
    butterworth4.setFrequency(10);

    float[] impulse = [1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f];
    float[] lpfOutput = [];
    foreach(sample; impulse)
    {
        lpfOutput ~= butterworth4.getNextSample(sample);
    }

    writeln("Butterworth N=4 Output:");
    writeln(lpfOutput);
    
}