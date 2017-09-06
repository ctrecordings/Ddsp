/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.filter.lowpass;

import std.math;

/// First order lowpass filter
class LowpassO1(T) : BiQuad
{
private:
    T _thetac;
    T _gamma;
    
    override void calcCoefficients()
    {
        _thetac = 2 * PI * _frequency / _sampleRate;
        _gamma = cos(thetac) / (1 + sin(thetac));
        _a0 = (1 - gamma) / 2;
        _a1 = _a0;
        _a2 = 0.0;
        _b1 = -gamma;
        _b2 = 0.0;
    }
}

/// Second order lowpass filter
class LowpassO2(T) : BiQuad
{
public:
    void setQualityFactor(T Q)
    { 
        if(Q != _q)
        {
            _q = Q;
            calcCoefficients();
        }
    }
    
private:
    T _thetac;
    T _q = cast(T) 0.707;
    T _beta;
    T _gamma;
    
    override void calcCoefficients()
    {
        thetac = 2 * PI * _frequency / _sampleRate;
        _d0 = 1 / _q;
        _beta = 0.5 * (1 - (_d0 / 2) * sin(_thetac)) / (1 + (_d0 / 2) * sin(_thetac));
        _gamma = (0.5 + _beta) * cos(_thetac);
        _a1 = 0.5 + _beta - _gamma;
        _a0 = _a1 / 2.0;
        _a2 = _a0;
        _b1 = -2.0 * _gamma;
        _b2 = 2.0 * _beta;
    }
}

/// Second order butterworth lowpass filter
class ButterworthLP(T) : BiQuad
{
private:
    T _C;
    
    override void calcCoefficients()
    {
        _C = 1.0 / tan(PI * _frequency / _sampleRate);
        _a0 = 1.0 / (1 + sqrt(2.0f) * _C + (_C * _C));
        _a1 = 2.0 * _a0;
        _a2 = _a0;
        _b1 = 2.0 * _a0 * (1 - _C * _C);
        _b2 = _a0 * (1 - sqrt(2) * _C + _C * _C);
    }
}