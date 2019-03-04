/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.util.time;

import ddsp.util.functions;

struct Note
{
    float baseLength;
    int multiplier;
    
    float getTimeInMilliseconds(float tempo)
    {
        return (1 / tempo) * baseLength * cast(float)multiplier * 60000;
    }
    
    float getTimeInSamples(float sampleRate, float tempo)
    {
        return msToSamples(getTimeInMilliseconds(tempo), sampleRate);
    }
}

unittest
{
    
}