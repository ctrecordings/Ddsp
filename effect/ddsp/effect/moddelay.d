/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.effect.moddelay;

import ddsp.effect.effect;

class ModDelay : AudioEffect
{
public:
nothrow:
@nogc:

    this()
    {

    }

    override float getNextSample(const float input)
    {
        return 0;
    }

    override void reset()
    {

    }
private:
    
}