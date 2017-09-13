module ddsp.filter.shelf;

import ddsp.filter.biquad;

import std.math;

class LowShelf : BiQuad
{
nothrow:
@nogc:
public:
    override void calcCoefficients()
    {
        _thetac = 2.0f * pi * _frequency / _sampleRate;
        _mu = pow(10.0f, _gain / 20.0f);
        _beta = 4.0f / (1.0f + _mu);
        _delta = _beta * tan(_thetac / 2.0f);
        _gamma = ( 1.0f - _delta) / (1.0f + _delta);
        _a0 = (1.0f - _gamma) / 2.0f;
        _a1 = _a0;
        _a2 = 0.0f;
        _b1 = - _gamma;
        _b2 = 0.0f;
        _c0 = (_mu - 1.0f);
        _d0 = 1.0f;
    }

    void setGain(float gain)
    {
        if(_gain != gain)
        {
            _gain = gain;
            calcCoefficients();
        }
    }
private:
    /// amount of gain in decibels
    float _gain;
    float _thetac;
    float _mu;
    float _beta;
    float _delta;
    float _gamma;
}