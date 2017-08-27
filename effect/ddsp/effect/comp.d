/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.effect.comp;

import std.math;

import ddsp.util.envelope;
import ddsp.util.scale;
import ddsp.util.functions;
import ddsp.effect.aeffect;

/**
Point for passing x y value pairs
*/
struct P
{
    float x;
    float y;
}

/**
Uses polynomial interpolation to fit the curve of the knee.
The points should be calculated and passed to the function.
*/
float kneeInterpolation(P _p0, P _p1, P _p2, float input) nothrow @nogc
{
    float t = abs(input - _p0.x)/(_p2.x - _p0.x);
    float output = (1 - t) * (1 - t) * _p0.y + 2 * (1 - t) * t * _p1.y + t * t * _p2.y;
    return output;
}

class Compressor : AEffect
{

public:

    void initialize(float attTime, float relTime, float knee, float threshold, float ratio, float mGain)  nothrow @nogc
    {
        detector.initialize(_sampleRate, attTime, relTime, true, DetectorType.peak);
        _knee = knee;
        _threshold = threshold;
        _autoGain = 2 - pow(10.0, threshold/20.0);
        _mGain = mGain;
        _ratio = ratio;

        _kneeWidth = (_knee * _threshold) / 2;

        calcCoefficientsAndSetPoints();
    }

    void setParams(float attTime, float relTime, float knee, float threshold, float ratio, float mGain) nothrow @nogc
    {
        detector.setAttackTime(attTime);
        detector.setReleaseTime(relTime);
        _knee = knee;
        _threshold = threshold;
        _autoGain = 2 - pow(10.0, threshold/20.0);
        _mGain = mGain;
        _ratio = ratio;
    }

    void calcCoefficientsAndSetPoints()  nothrow @nogc
    {
        _a = 1 / _ratio;
        _b = _threshold  - _a * _threshold;

        _p0.x = _threshold - (_kneeWidth/2);
        _p0.y = _p0.x;

        _p1.x = _threshold;
        _p1.y = _p0.x;

        _p2.x = _threshold + (_kneeWidth/2);
        _p2.y = _a * _p2.x + _b;
    }

    float process(float input)  nothrow @nogc
    {
        float inputdb = 20 * log10(input);
        float CS = 1.0 - 1.0/_ratio;

        float detectorVal = 20 * log10(detector.detect(input));
        float yG = CS * (_threshold - detectorVal);
        0 < yG ? yG = 0 : yG = yG;
        yG = pow(10.0, yG/20.0);
        /*float output = 0;
        float detectorValue = scale.convert(detector.detect(input));
        //float detectorValue = 0.9f;
        float gainVal;

        if(detectorValue >= _threshold + _kneeWidth)
            gainVal = _a * detectorValue + _b;
        else if(detectorValue >= _threshold - _kneeWidth)
            gainVal = kneeInterpolation(_p0, _p1, _p2, detectorValue);
        else
            gainVal = 1;

        output = input * gainVal;

        if(abs(output) < abs(input))
            _gainReduction = abs(input) - abs(output);

        return output;*/
        _gainReduction = 1 - yG;
        //float gainLog = 1 + (1 - pow(10.0, _threshold / 20.0));
        //float gainLog = (1 - pow(10.0, _threshold / 20.0)) * -60;
        
        return input * yG * (1 + _mGain) * _autoGain;

    }

    override float getNextSample(float input)
    {
        return process(input);
    }

    float getReductionAmount() nothrow @nogc
    {
        return _gainReduction;
    }

    void autoGainEnabled(bool enabled) nothrow @nogc
    {
        if(enabled)
        {
            _autoGain = linearInterp(-60, 0, 3, 1, _threshold); 
        }
        else
        {
            _autoGain = 1.0f;
        }
    }

    override void reset()
    {

    }

private:
    EnvelopeDetector detector;
    LogToLinearScale scale = new LogToLinearScale();

    float _knee;
    float _kneeWidth;
    float _threshold;
    float _ratio;
    float _mGain;
    float _gainReduction;
    float _autoGain;

    float _a;
    float _b;
    P _p0;
    P _p1;
    P _p2;
}

unittest
{
    import dplug.core.nogc;

    Compressor f = mallocNew!Compressor();
    f.setSampleRate(44100);
    f.initialize(500, 200, 0.5, 0.3, 4, 1.0);
    testEffect(f, "Compressor", 44100 * 2, true);
}
