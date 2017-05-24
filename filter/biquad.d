/**
Copyright: 2017 Cut Through Recordings
License: GNU General Public License
Author(s): Ethan Reker
*/
module ddsp.filter.biquad;

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
class BiQuad
{
    public:

        this() nothrow @nogc
        {

        }

        void initialize(float a0,
                        float a1,
                        float a2,
                        float b1,
                        float b2,
                        float c0 = 1,
                        float d0 = 0)  nothrow @nogc
        {
           _a0 = a0;
           _a1 = a1;
           _a2 = a2;
           _b1 = b1;
           _b2 = b2;
           _c0 = c0;
           _d0 = d0;
        }

        float getNextSample(float input)  nothrow @nogc
        {
            float output = (_a0 * input + _a1 * _xn1 + _a1 * _xn2 - _b1 * _yn1 - _b2 * _yn2) * _c0 + (input * _d0);

            _xn2 = _xn1;
            _xn1 = input;
            _yn2 = _yn1;
            _yn1 = output;

            return output;
        }

    protected:

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

        void calculateCoefficients()  nothrow @nogc {}
}
