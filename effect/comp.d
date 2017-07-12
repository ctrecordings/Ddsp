module ddsp.effect.comp;

import std.math;

import ddsp.util.envelope;
import ddsp.util.scale;

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
float kneeInterpolation(P p0, P p1, P p2, float input) nothrow @nogc
{
    float t = abs(input - p0.x)/(p2.x - p0.x);
    float output = (1 - t) * (1 - t) * p0.y + 2 * (1 - t) * t * p1.y + t * t * p2.y;
    return output;
}

struct Compressor
{
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
    P p0;
    P p1;
    P p2;

    void initialize(float sampleRate, float attTime, float relTime, float knee, float threshold, float ratio, float mGain)  nothrow @nogc
    {
        detector.initialize(sampleRate, attTime, relTime, true, DetectorType.peak);
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

        p0.x = _threshold - (_kneeWidth/2);
        p0.y = p0.x;

        p1.x = _threshold;
        p1.y = p0.x;

        p2.x = _threshold + (_kneeWidth/2);
        p2.y = _a * p2.x + _b;
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
            gainVal = kneeInterpolation(p0, p1, p2, detectorValue);
        else
            gainVal = 1;

        output = input * gainVal;

        if(abs(output) < abs(input))
            _gainReduction = abs(input) - abs(output);

        return output;*/
        _gainReduction = 1 - yG;
        return input * yG * (1 + _mGain) * _autoGain;
    }

    float getNextSample(float input)
    {
        return process(input);
    }

    float getReductionAmount() nothrow @nogc
    {
        return _gainReduction;
    }
}

unittest
{
    /*import std.random;
    import std.stdio;

    Random gen;

    Compressor c;
    c.initialize(44100, 10, 100, 0.5f, 0.1f, 4, 0.0f);

    for(int i = 0; i < 44100; ++i){
        float sample = uniform(0.0L, 1.0L, gen) * pow(-1, i);
        float output = c.process(sample);
        if(i % 1001 == 0)
            writefln("Input: %s  |  Output: %s  |  Reduction: %s", sample, output, c.getReductionAmount());
    }*/
}
