/**
Copyright: 2017 Cut Through Recordings
License: GNU General Public License
Author(s): Ethan Reker
*/
module ddsp.core.envelopedetector;

enum DetectorType
{
    peak,
    ms,
    rms
}

class EnvelopeDetector
{
    private import std.math;

    public:

    this(bool isDigital = true)
    {
        _isDigital = isDigital;
        _envelope = 0;
        _delaySample = 0;
        _attTime = 0;
        _relTime = 0;
        _sampleRate = 0;
        _timeConstant = 0;
    }

    void initialize(float sampleRate,
                    float attTime,
                    float relTime,
                    bool isDigital,
                    DetectorType type)
    {
        _sampleRate = sampleRate;
        _isDigital = isDigital;
        setMode(_isDigital);
        setAttackTime(attTime);
        setReleaseTime(relTime);
        _type = type;
    }

    void setMode(bool isDigital)
    {
        _isDigital = isDigital;
        if(_isDigital)
            _timeConstant = log(0.01);
        else
            _timeConstant = log(0.368);
    }

    void setAttackTime(float attTime)
    {
        _attTime = exp(_timeConstant/(attTime * _sampleRate * 0.001));
    }

    void setReleaseTime(float relTime)
    {
        _relTime = exp(_timeConstant/(relTime * _sampleRate * 0.001));
    }

    void setDetectMode(DetectorType type){ _type = type;}

    float detect(float input)
    {
        input = abs(input);
        _delaySample = _envelope;
        if(input > _envelope){
            _envelope = _attTime * (_envelope - input) + input;
        }
        else{
            _envelope = _relTime * (_envelope - input) + input;
        }

        if(_type == DetectorType.ms && _delaySample != 0)
            _envelope *= _delaySample;
        if(_type == DetectorType.rms && _delaySample != 0)
            _envelope = sqrt(_envelope * _delaySample);

        return _envelope;
    }

    override string toString()
    {
      import std.conv;
      string s = "\nAttack Time: " ~ to!string(_attTime)
               ~  " Release Time: " ~ to!string(_relTime)
               ~  " Sample Rate: " ~ to!string(_sampleRate)
               ~  " Time Constant: " ~ to!string(_timeConstant)
               ~  " Envelope: " ~ to!string(_envelope)
               ~  " Delay: " ~ to!string(_delaySample);

      return s;
    }

    private:

    DetectorType _type;
    float _delaySample;
    float _attTime;
    float _relTime;
    float _sampleRate;
    float _timeConstant;
    float _envelope;
    bool _isDigital;
}

unittest
{
    import std.random;
    import std.stdio;

    Random gen;

    EnvelopeDetector envPeak = new EnvelopeDetector(),
                     envMs = new EnvelopeDetector(),
                     envRms = new EnvelopeDetector();
    envPeak.initialize(44100, 100, 100, true, DetectorType.peak);
    envMs.initialize(44100, 1000, 2000, true, DetectorType.ms);
    envRms.initialize(44100, 100, 4000, true, DetectorType.rms);

    for(int i = 0; i < 44100; ++i){
        float sample = uniform(0.0L, 1.0L, gen);
        float peakVal = envPeak.detect(sample);
        float msVal = envMs.detect(sample);
        float rmsVal = envRms.detect(sample);

        if((i % 1500) == 0){
            //writefln("Input: %s  Peak:%s  MS:%s  RMS:%s  ", sample, peakVal, msVal, rmsVal);
            //writefln(envPeak.toString());
            //writefln(envMs.toString());
            //writefln(envRms.toString());
        }
    }

}
