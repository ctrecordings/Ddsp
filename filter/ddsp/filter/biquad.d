/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.filter.biquad;

import ddsp.effect.effect;

const float pi = 3.14159265;

enum FilterType
{
    lowpass,
    highpass,
    bandpass,
    allpass,
    peak,
    lowshelf,
    highshelf,
}

/**
This class implements a generic biquad filter. Should be inherited by all filters.
*/
class BiQuad(T) : AudioEffect!T
{
    public:

        this() nothrow @nogc
        {

        }

        void initialize(T a0,
                        T a1,
                        T a2,
                        T b1,
                        T b2,
                        T c0 = 1,
                        T d0 = 0)  nothrow @nogc
        {
           _a0 = a0;
           _a1 = a1;
           _a2 = a2;
           _b1 = b1;
           _b2 = b2;
           _c0 = c0;
           _d0 = d0;
        }
        
        void setFrequency(float frequency) nothrow @nogc
        {
            if(_frequency != frequency)
            {
                _frequency = frequency;
                calcCoefficients();
            }
        }
    
        override void setSampleRate(float sampleRate) nothrow @nogc
        {
            _sampleRate = sampleRate;
            calcCoefficients();
            reset();
        }

        override T getNextSample(const T input)  nothrow @nogc
        {
            _w = input - _b1 * _w1 - _b2 * _w2;
            _yn = (_a0 * _w + _a1 *_w1 + _a2 * _w2) * _c0 + (input * _d0);

            _w2 = _w1;
            _w1 = _w;

            return _yn;
        }

        override void reset()
        {
            _w = 0;
            _w1 = 0;
            _w2 = 0;

            _yn = 0;
        }

        abstract void calcCoefficients() nothrow @nogc;

    protected:

        //Delay samples
        float _w = 0;
        float _w1 = 0;
        float _w2 = 0;
        float _yn = 0;

        //Biquad Coeffecients
        T _a0=0, _a1=0, _a2=0;
        T _b1=0, _b2=0;
        T _c0=1, _d0=0;

        float _sampleRate;
        float _qFactor;
        float _frequency;
}