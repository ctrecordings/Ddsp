/**
Copyright: 2017 Cut Through Recordings
License: GNU General Public License
Author(s): Ethan Reker
*/
module ddsp.filter.linkwitzriley;

import ddsp.filter.biquad;

/**
A second order Linkwitz-Riley filter which has an attenuation of -6db at the
corner frequency.  These filters are great for multiband processing since a
highpass and lowpass with the same frequency will sum to a flat frequency
response.
*/
class LinkwitzRiley : BiQuad
{
    private import std.math;
    private import ddsp.filter.biquad;

    public:

    /**
    Sets the center frequency, sample rate and the type of filter.
    FilterType should either be FilterType.lowpass or FilterType.highpass.
    */
    void initialize(float frequency, float sampleRate, FilterType type)
    {
        _sampleRate = sampleRate;
        _frequency = frequency;
        _type = type;
        calculateCoefficients();
    }

    void setFrequency(float frequency)
    {
        _frequency = frequency;
        calculateCoefficients();
    }

    void setSampleRate(float sampleRate)
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

    void calculateCoefficients()
    {
        _theta = pi * _frequency / _sampleRate;
        _omega = pi * _frequency;
        _kappa = _omega / tan(_theta);
        _delta = _kappa * _kappa + _omega * _omega + 2 * _kappa * _omega;

        if(_type == FilterType.lowpass){
            _a0 = (_omega * _omega) / _delta;
            _a1 = 2 * _a0;
        }
        else if(_type == FilterType.highpass){
            _a0 = (_kappa * _kappa) / _delta;
            _a1 = -2 * _a0;
        }
        else{
            //Throw exception
        }

        _a2 = _a0;
        _b1 = (-2 * _kappa * _kappa + 2 * _omega * _omega) / _delta;
        _b2 = (-2 * _kappa * _omega + _kappa * _kappa + _omega * _omega) / _delta;
    }
}
