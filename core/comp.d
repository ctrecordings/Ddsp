module ddsp.core.comp;

import std.math;

import ddsp.core.envelope;
import ddsp.core.scale;

struct P
{
    float x;
    float y;
}

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

    float _a;
    float _b;
    P p0;
    P p1;
    P p2;

    void initialize(float sampleRate, float attTime, float relTime, float knee, float threshold, float ratio, float mGain)  nothrow @nogc
    {
        detector.initialize(sampleRate, attTime, relTime, true, DetectorType.rms);
        _knee = knee;
        _threshold = threshold;
        _mGain = mGain;
        _ratio = ratio;

        _kneeWidth = _knee * _threshold;

        calcCoefficientsAndSetPoints();
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
        float output = 0;
        float detectorVal = detector.detect(input);

        if(detectorVal >= _threshold + _kneeWidth / 2 ){
            output = _a * input + _b;
        }
        else if(detectorVal >= _threshold - (_kneeWidth / 2)){
            output = kneeInterpolation(p0, p1, p2, input);
        }
        else{
            output = input;
        }

        if(output < input)
            _gainReduction = input - output;
        else
            _gainReduction = 0.0f;

        output = output * (1 + _mGain);

        return output;
    }

    float getReductionAmount() nothrow @nogc
    {
        return _gainReduction;
    }
}

unittest
{
    import std.random;
    import std.stdio;

    Random gen;

    Compressor c;
    c.initialize(44100, 10, 100, 0.5f, 0.1f, 4, 0.0f);

    for(int i = 0; i < 44100; ++i){
        float sample = uniform(0.0L, 1.0L, gen) * pow(-1, i);
        float output = c.process(sample);
        if(i % 1001 == 0)
            writefln("Input: %s  |  Output: %s  |  Reduction: %s", sample, output, c.getReductionAmount());
    }
}
