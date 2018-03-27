/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.effect.moddelay;

import ddsp.effect.effect;
import ddsp.osc.wtoscillator;
import ddsp.effect.digitaldelay;
import ddsp.util.memory;

import std.math;

/// General purpose class for Modulated Delay effects. This class is used with 
/// contraints on depth, offset, mix, and feedback to create other effects. (Flanger, Chorus, Tremolo, etc)
class ModDelay : AudioEffect
{
public:
nothrow:
@nogc:

    this()
    {
        lfo = calloc!WTOscillator.init();
        delay = calloc!DigitalDelay.init();
    }

    override void setSampleRate(float sampleRate)
    {
        _sampleRate = sampleRate;
        lfo.setSampleRate(sampleRate);
        delay.setSampleRate(sampleRate);
    }

    float calcDelayOffset(float lfoValue)
    {
        float startDelay = _min_delay + _delay_offset;
        float lfoOffset = _mod_depth * ((lfoValue + 1) / 2 * (_max_delay - _min_delay)) + _min_delay;
        return lfoOffset + startDelay;
    }

    /// Must be set before processing audio
    void setDelayRange(float minDelay, float maxDelay)
    {
        _min_delay = minDelay;
        _max_delay = maxDelay;
    }

    void setParams(float rate, float depth, float mix, float feedback, int offset, int modType = 0)
    {
        _mod_rate = rate;
        _mod_depth = depth;
        _delay_offset = offset;
        _feedback = feedback;
        _mix = mix;

        //Frequency, sin, not bandlimited
        lfo.setParams(rate, modType, true);
        delay.setParams(0, feedback, mix);
    }

    override float getNextSample(const float input)
    {
        float fYn = 0.0;
        float fYqn = 0.0;
        lfo.doOscillate(&fYn, &fYqn);

        float delaySamples = calcDelayOffset(fYn);
        delay.setParams(delaySamples, _feedback, _mix);

        float output = delay.getNextSample(input);

        return output;
    }

    override void reset()
    {
        lfo.reset();
        delay.reset();
    }
private:
    float _mod_rate;
    float _mod_depth;
    float _mix;
    float _feedback;
    float _delay_offset;

    float _max_delay;
    float _min_delay;

    WTOscillator lfo;
    DigitalDelay delay;
}

class Flanger : AudioEffect
{
public:
nothrow:
@nogc:

    this()
    {
        _modDelay = calloc!ModDelay.init();
    }

	override void setSampleRate(float sampleRate)
	{
		_sampleRate = sampleRate;
		_modDelay.setSampleRate(_sampleRate);
		_modDelay.setDelayRange(0, 7);
	}

    void setParams(float modRate, float modDepth, int oscType = 0)
    {
        _modDelay.setParams(modRate, modDepth, 0.5, 0.5, 0, oscType);
    }

    override float getNextSample(const float input)
    {
        return _modDelay.getNextSample(input);
    }

    override void reset()
    {
        _modDelay.reset();
    }

private:
    ModDelay _modDelay;
}

class Vibrato : AudioEffect
{
public:
nothrow:
@nogc:

    this()
    {
        _modDelay = calloc!ModDelay.init();
    }

	override void setSampleRate(float sampleRate)
	{
		_sampleRate = sampleRate;
		_modDelay.setSampleRate(_sampleRate);
		_modDelay.setDelayRange(0, 7);
	}

    void setParams(float modRate, float modDepth, int oscType = 0)
    {
        _modDelay.setParams(modRate, modDepth, 1.0, 0.0, 0, oscType);
    }

    override float getNextSample(const float input)
    {
        return _modDelay.getNextSample(input);
    }

    override void reset()
    {
        _modDelay.reset();
    }

private:
    ModDelay _modDelay;
}

class Chorus : AudioEffect
{
public:
nothrow:
@nogc:

    this()
    {
        _modDelay = calloc!ModDelay.init();
    }

	override void setSampleRate(float sampleRate)
	{
		_sampleRate = sampleRate;
		_modDelay.setSampleRate(_sampleRate);
		_modDelay.setDelayRange(5, 30);
	}

    void setParams(float modRate, float modDepth, int oscType = 0)
    {
        _modDelay.setParams(modRate, modDepth, 0.5, 0.0, 0, oscType);
    }

    override float getNextSample(const float input)
    {
        return _modDelay.getNextSample(input);
    }

    override void reset()
    {
        _modDelay.reset();
    }

private:
    ModDelay _modDelay;
}