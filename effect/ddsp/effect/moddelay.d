/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.effect.moddelay;

import ddsp.effect.effect;
import ddsp.osc;
import ddsp.effect.digitaldelay;
import ddsp.util.memory;

// This class is not implemented yet
class ModDelay : AudioEffect
{
public:
nothrow:
@nogc:

    this()
    {
        lfo = calloc!CFOscillator.init();
        delay = calloc!DigitalDelay.init();
    }

    override float getNextSample(const float input)
    {
        return 0;
    }

    override void reset()
    {

    }
private:
    float _mod_rate;
    float _mod_depth;
    float _feedback;
    float _delay_offset;

    CFOscillator lfo;
    DigitalDelay delay;
}