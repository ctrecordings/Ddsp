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

// This class is not implemented yet
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
        float lfoOffset = _mod_depth * (abs(lfoValue) * (_max_delay - _min_delay)) + _min_delay;
		return lfoOffset + startDelay;
    }

    void setDelayRange(float minDelay, float maxDelay)
    {
        _min_delay = minDelay;
        _max_delay = maxDelay;
    }

    void setParams(float rate, float depth, float mix, float feedback, int offset)
    {
        _mod_rate = rate;
        _mod_depth = depth;
        _delay_offset = offset;
        _feedback = feedback;
        _mix = mix;

        //Frequency, sin, not bandlimited
        lfo.setParams(rate, 0, true);
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