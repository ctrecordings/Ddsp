/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.effect.dynamics;

import ddsp.effect.effect;
import ddsp.util.envelope;
import ddsp.util.functions;

import dplug.core.nogc;

import std.algorithm;
import std.math;

/// Base class for dynamics processors such as compressor, limiter, expander, and gate.
/// This class is useless on it's own.  It should be inherited from and have getNextSample overriden.
class DynamicsProcessor(T) : AudioEffect!T
{
public:
nothrow:
@nogc:

    /// Tracks the input level to trigger compression.
    PeakDetector!float detector;

    /// Will point to the detector of a processor that is stereo linked
    PeakDetector!float* linkedDetector;

    this()
    {
        x = mallocSlice!float(2);
        y = mallocSlice!float(2);
        detector = mallocNew!(PeakDetector!float)();
    }

    void setParams(float attackTime, float releaseTime, float threshold, float ratio, float knee)
    {
        detector.setEnvelope(attackTime, releaseTime);
        _threshold = threshold;
        _ratio = ratio;
        _kneeWidth = knee;
    }

    override T getNextSample(T input)
    {
        return 0;
    }

    override void processBuffers(const(T)* inputBuffer, T* outputBuffer, int numSamples) nothrow @nogc
    {

    }

    override void reset() nothrow @nogc
    {

    }

    override void setSampleRate(float sampleRate)
    {
        _sampleRate = sampleRate;
        detector.setSampleRate(_sampleRate);
    }

    /// Allows this processors envelope to be linked to another processor.
    /// This way the two will act as a single unit.  Both processors must call
    /// this on each other to function properly
    void linkStereo(DynamicsProcessor stereoProcessor) nothrow @nogc
    {
        linkedDetector = &stereoProcessor.detector;
        stereoProcessor.linkedDetector = &this.detector;
    }

protected:
    /// Amount of input gain in decibels
    float _inputGain;

    /// Level in decibels that the input signal must cross before compression begins
    float _threshold;

    /// Time in milliseconds before compression begins after threshold has been
    /// crossed
    float _attTime;

    /// Time in milliseconds before the compression releases after the input signal
    /// has fallen below the threshold
    float _relTime;

    /// Ratio of compression, higher ratio = more compression
    float _ratio;

    /// Amount of output gain in decibels
    float _outputGain;

    /// width of the curve that interpolates between input and output.  Unit in
    /// decibels
    float _kneeWidth;

    /// Holds the points used for interpolation;
    float[] x, y;

    //DynamicsProcessor _linkedProcessor;
}

unittest
{
    DynamicsProcessor!float dynamicsProcessor = new DynamicsProcessor!float();
}

