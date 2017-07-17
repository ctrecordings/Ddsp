/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.filter.linkwitzriley;

import ddsp.filter.biquad;

/**
A second order Linkwitz-Riley filter which has an attenuation of -6db at the
corner frequency.  These filters are great for multiband processing since a
highpass and lowpass with the same frequency will sum to a flat frequency
response.
*/
struct LinkwitzRiley
{
    private import std.math;
    private import ddsp.filter.biquad;

    public:

    /**
    Sets the center frequency, sample rate and the type of filter.
    FilterType should either be FilterType.lowpass or FilterType.highpass.
    */
    void initialize(float frequency, float sampleRate, FilterType type) nothrow @nogc
    {
        _sampleRate = sampleRate;
        _frequency = frequency;
        _type = type;
        calculateCoefficients();
    }

    float getNextSample(float input)  nothrow @nogc
    {
        float output = _a0 * input + _a1 * _xn1 + _a2 * _xn2 - _b1 * _yn1 - _b2 * _yn2;

        _xn2 = _xn1;
        _xn1 = input;
        _yn2 = _yn1;
        _yn1 = output;

        return output;
    }

    void setFrequency(float frequency) nothrow @nogc
    {
        _frequency = frequency;
        calculateCoefficients();
    }

    void setSampleRate(float sampleRate) nothrow @nogc
    {
        _sampleRate = sampleRate;
        calculateCoefficients();
    }

    private:

    float _theta;
    float _omega;
    float _kappa;
    float _delta;
    FilterType _type;

    //Delay samples
    float _xn1=0, _xn2=0;
    float _yn1=0, _yn2=0;

    //Biquad Coeffecients
    float _a0=0, _a1=0, _a2=0;
    float _b1=0, _b2=0;
    float _c0=1, _d0=0;

    float _sampleRate;
    float _qFactor;
    float _frequency;

    void calculateCoefficients()  nothrow @nogc
    {
        _theta = pi * _frequency / _sampleRate;
        _omega = pi * _frequency;
        _kappa = _omega / tan(_theta);
        _delta = _kappa * _kappa + _omega * _omega + 2 * _kappa * _omega;

        if(_type == FilterType.lowpass){
            _a0 = (_omega * _omega) / _delta;
            _a1 = 2 * _a0;
        }
        if(_type == FilterType.highpass){
            _a0 = (_kappa * _kappa) / _delta;
            _a1 = -2 * _a0;
        }

        _a2 = _a0;
        _b1 = (-2 * _kappa * _kappa + 2 * _omega * _omega) / _delta;
        _b2 = (-2 * _kappa * _omega + _kappa * _kappa + _omega * _omega) / _delta;
    }
}
