module ddsp.util.envelope;

import std.math;

/// Enum to represent different detection modes
enum DetectorType : int
{
    PEAK = 0,
    MS = 1,
    RMS = 2
}

/// 
class EnvelopeDetector
{
public:
nothrow:
@nogc:
    this()
    {
        _env = 0.0f;
        digital = true;
        _preGain = 0.0f;
    }
    
    /// Must be called to set the sample rate before setEnvelope()
    void setSampleRate(float sampleRate)
    {
        _sampleRate = sampleRate;
    }
    
    /// must be called atleast once before calling detect()
    /// used to set all important parameters at the same time
    void setEnvelope(float attackTime, float releaseTime, DetectorType type = DetectorType.RMS)
    {
        setDetectMode(type);
        setAttackTime(attackTime);
        setReleaseTime(releaseTime);
    }
    
    /// _env is recalculated from the input value.  Should be called inside
    /// `processReplacing` or similar function call from the host
    void detect(float input)
    {
        if(_type == DetectorType.PEAK)
            input = abs(input);
        if(_type == DetectorType.MS)
            input = abs(input) * abs(input);
        if(_type == DetectorType.RMS)
            input = sqrt(abs(input) * abs(input));
            
        if(input > _env)
            _env = _attackTime * (_env - input) + input;
        else
            _env = _releaseTime * (_env - input) + input;
    }
    
    /// get current envelope value
    float getEnvelope() { return _env; }
    
    /// sets the attack coefficient based to the attack time given
    /// `attackTime` is in milliseconds
    void setAttackTime(float attackTime)
    {
        _tc = digital ? log(0.01) : log(0.368);
        _attackTime = exp(_tc / (attackTime * _sampleRate * 0.001));
    }
    
    /// sets the release coefficient based to the attack time given
    /// `releaseTime` is in milliseconds
    void setReleaseTime(float releaseTime)
    {
        _tc = digital ? log(0.01) : log(0.368);
        _releaseTime = exp(_tc / (releaseTime * _sampleRate * 0.001));
    }

    /// Change the time mode to analog.  This leads to the timeConstant being 
    /// log(0.368)
    void setModeAnalog() { digital = false; }
    
    /// Change the time mode to digital. Note that the time mode is already
    /// Digital by default.  This makes the timeConstant = log(0.01)
    void setModeDigital() { digital = true; }
    
    /// Change the dector type.  Possible values {PEAK, MS, RMS}
    void setDetectMode(DetectorType type) { _type = type; }
    
protected:

    /// 0 to +20dB gain to drive the detector
    float _preGain;
    
    /// the value that the input signal must cross to trigger the detector
    float _threshold;

    /// Attack time in ms
    float _attackTime;
    
    /// Release time in ms
    float _releaseTime;
    
    /// 
    float _sampleRate;
    
    /// determines the time constant for detection
    bool digital;
    
    /// time constant calculated
    float _tc;
    
    /// value that the holds the current envelope
    float _env;
    
    /// enum to represent different detection modes
    DetectorType _type;
    
    /// second-order lowpass filter to smooth the envelope
    //LowpassFilterO2 lowpass;
}