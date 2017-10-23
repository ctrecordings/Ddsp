/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.effect.aeffect;

import dplug.core.alignedbuffer;
import dplug.core.nogc;

/**
* Should be inherited by all Audio Effect classes to allow for batch processing
*/
abstract class AEffect
{
public:
    
    /**
    * Process a sample that is passed to the processor, and return the next sample.
    */
    abstract float getNextSample(const ref float input) nothrow @nogc;
    
    
    
    /**
    * Should be used to free any delay elements or do any setup before play begins.
    */
    abstract void reset() nothrow @nogc;

    /**
    *
    */
    void setSampleRate(float sampleRate) nothrow @nogc
    {
        _sampleRate = sampleRate;
        reset();
    }
    
protected:
    float _sampleRate;
}

class FXChain : AEffect
{
public:

    this()
    {
        _fxChain = makeVec!AEffect();
    }
    
    void addEffect(AEffect effect)
    {
        _fxChain.pushBack(effect);
    }

    override float getNextSample(const ref float input) nothrow @nogc
    {
        float output = input;
        foreach(AEffect e; _fxChain)
        {
            output = e.getNextSample(output);
        }
        return output;
    }

    override void reset() nothrow @nogc
    {
        foreach(AEffect e; _fxChain){
            e.reset();
        }
    }

private:
    Vec!AEffect _fxChain;
}

/**
* This function should only be called in a unittest block.
*/
void testEffect(AEffect effect, string name, size_t bufferSize = 20000, bool outputResults = false)
{
    import std.stdio;
    import std.random;

    Random gen;

    if(outputResults)
    {
        writefln("Testing %s..", name);
        writefln("Initial State: %s", effect.toString()); 
    }

    float[] outputs;
    string[] stringResults;

    for(int i = 0; i < bufferSize; ++i){
        float sample = uniform(0.0L, 1.0L, gen);
        float val = effect.getNextSample(sample);
        if(i%1000 == 0){
            outputs ~= val;
            stringResults ~= effect.toString();
        }
    }

    if(outputResults)
    {
        for(int i = 0; i < outputs.length && i < stringResults.length; ++i)
        {
            writefln("Output: %s ||| String: %s    ", outputs[i], stringResults[i]);
        }
        writefln("End %s test..", name);
    }

}

unittest
{
    import std.stdio;
    import ddsp.effect.digitaldelay;

    /*auto fxchain = mallocEmplace!FXChain();

    auto d = mallocEmplace!DigitalDelay();
    d.initialize(44100, 2000, 500, 0.5, 0.5);

    auto d2 = mallocEmplace!DigitalDelay();
    d2.initialize(44100, 2000, 100,  0.1, 0.9);

    fxchain.addEffect(d);

    testEffect(fxchain, "FX Chain");*/
}