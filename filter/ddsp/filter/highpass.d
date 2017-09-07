/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.filter.highpass;

import ddsp.filter.biquad;
import std.math;

/// First order highpass filter
class HighpassO1 : BiQuad
{
public:
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

/// Second order highpass filter
class HighpassO2 : BiQuad
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
        _d0 = 1 / _q;
        _beta = 0.5 * (1 - (_d0 / 2) * sin(_thetac)) / (1 + (_d0 / 2) * sin(_thetac));
        _gamma = (0.5 + _beta) * cos(_thetac);
        _a1 = -(0.5 + _beta + _gamma);
        _a0 = (-_a1) / 2.0;
        _a2 = _a0;
        _b1 = -2.0 * _gamma;
        _b2 = 2.0 * _beta;
    }
    
private:
    float _thetac;
    float _q = 0.707f;
    float _beta;
    float _gamma;
}

/// Second order butterworth highpass filter
class ButterworthHP : BiQuad
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

/// Second order LinkwitzRiley highpass filter
class LinkwitzRileyHP : BiQuad
{
public:
    override void calcCoefficients() nothrow @nogc
    {
        _theta = PI * _frequency / _sampleRate;
        _omega = PI * _frequency;
        _kappa = _omega / tan(_theta);
        _delta = _kappa * _kappa + _omega * _omega + 2 * _kappa * _omega;
        _a0 = (_kappa * _kappa) / _delta;
        _a1 = -2 * _a0;
        _a2 = _a0;
        _b1 = (-2 * _kappa * _kappa + 2 * _omega * _omega) / _delta;
        _b2 = (-2 * _kappa * _omega + _kappa * _kappa + _omega * _omega) / _delta;
    }
private:
    float _theta;
    float _omega;
    float _kappa;
    float _delta;
}