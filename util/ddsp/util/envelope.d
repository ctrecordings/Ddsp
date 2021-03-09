/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.util.envelope;

import std.math;
import std.algorithm;
import ddsp.util.buffer;
import dplug.core.nogc;
import dplug.core.ringbuf;

/// Envelop Detector with adjustable attack and release times. Great for compressors
/// and meters.
/+
http://www.musicdsp.org/showArchiveComment.php?ArchiveID=97
+/
class EnvelopeDetector(T)
{
public:
nothrow:
@nogc:

    this()
    {
        _envelope = 0f;
        setTimeConstant(0.01);
    }
    
    void setSampleRate(const float sampleRate)
    {
        _sampleRate = sampleRate;
    }


    void setTimeConstant(const float timeConstant) {
        _timeConstant = log10(timeConstant);
    }
    
    /**
     * Set the attack and release times of the envelope detector in milliseconds
     */
    void setEnvelope(const float attackTime, const float releaseTime)
    {
        _ga = exp( _timeConstant /(_sampleRate * attackTime * 0.001));
        _gr = exp( _timeConstant / (_sampleRate * releaseTime * 0.001));
    }
    
    T detect(T input)
    {
        T envIn = processInput(input);
        
        if(_envelope < envIn)
            _envelope = _envelope * _ga + (1 - _ga) * envIn;
        else
            _envelope = _envelope * _gr + (1 - _gr) * envIn;

        if(isNaN(_envelope)) {
            _envelope = 0.0f;
        }
        return _envelope;
    }
    
    T getEnvelope()
    {
        return _envelope;
    }

    void reset()
    {
        _envelope = 0;
    }

    abstract T processInput(T input);
    
private:
    /// Attack coefficient
    float _ga;
    
    /// Release coefficient
    float _gr;
    
    /// stores the current value of the envelope;
    float _envelope;
    
    /// Sample Rate
    float _sampleRate;

    /// time constant used to calculate attack and release times
    float _timeConstant;
}

/// Simple Peak envelope follower, useful for meters.
/+
http://www.musicdsp.org/archive.php?classid=2#19
+/
class PeakDetector(T): EnvelopeDetector!T
{
public:
nothrow:
@nogc:

    this()
    {
        super();
    }

    override T processInput(T input)
    {
        return abs(input);
    }
    
private:    
    float _decay;
    
    float _sampleRate;
}

unittest
{
    PeakDetector!float peakDetector = new PeakDetector!float();
}

class RMSDetector(T): EnvelopeDetector!T
{
    public:
    nothrow:
    @nogc:

        this(int windowSize)
        {
            super();
            _windowSize = windowSize;
            _buffer = mallocNew!(Buffer!T)(_windowSize);
            _counter = 0;
            runningMean = 0;
        }

        override T processInput(T input)
        {
            immutable T poppedVal = _buffer.read();

            if(_counter < _windowSize)
            {
                ++_counter;
            }
            else
            {
                runningMean -= (poppedVal * poppedVal) / _windowSize;
            }
            runningMean += (input * input) / _windowSize;
            _buffer.write(input);
            return sqrt(runningMean);
        }

    private:
        int _windowSize;
        int _counter;
        Buffer!T _buffer;
        T runningMean;
}

unittest
{
    import std.stdio;
    float[] values = [0, 0, 1, 1, 0, 1, 0, 1, 1, 1];

    auto rmsDetector = new RMSDetector!float(10);
    rmsDetector.setSampleRate(44100);
    rmsDetector.setEnvelope(0, 0);
    for(int i = 0; i < 10; ++i)
    {
        foreach(val; values)
        {
            auto result = rmsDetector.detect(val);
            // writeln(result);
        }
    }

    auto peakDetector = new PeakDetector!float();
    peakDetector.setSampleRate(44100);
    peakDetector.setEnvelope(0.1, 1);
    for(int i = 0; i < 10; ++i)
    {
        foreach(val; values)
        {
            auto result = peakDetector.detect(val);
            // writeln(result);
        }
    }
}

/**
 * This class is used for calculating a moving average.  It's useful for things such
 * as smoothing meter values.
 */
class MovingAverage(T)
{
public:
nothrow:
@nogc:

    this(int windowSize)
    {
        _windowSize = windowSize;
        _buffer = makeRingBufferNoGC!T(_windowSize);
		_avg = 0;
    }

    T process(double sample)
    {
        T prevSample = _buffer.isFull() ? _buffer.popFront() : 0;
        _avg -= prevSample / _windowSize;
        _avg += sample / _windowSize;
        _buffer.pushBack(sample);
        return _avg;
    }

    T getAverage()
    {
        return _avg;
    }

private:
    RingBufferNoGC!T _buffer;
    int _windowSize;
    T _avg;

}

unittest
{
    auto movingAverage = mallocNew!(MovingAverage!float)(100);
}