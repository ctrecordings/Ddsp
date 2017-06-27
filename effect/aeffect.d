module ddsp.effect.aeffect;

import dplug.core.alignedbuffer;
import dplug.core.nogc;

/**
* Should be inherited by all Audio Effect classes to allow for batch processing
*/
abstract class AEffect
{
public:

    //abstract void initialize(Args...)(Args args);
    
    /**
    * Process a sample that is passed to the processor, and return the next sample.
    */
    float getNextSample(float input) nothrow @nogc;
    
    /**
    * Should be used to free any delay elements or do any setup before play begins.
    */
    void reset() nothrow @nogc;
    
protected:
    float _sampleRate;
    
}

class FXChain : AEffect
{
public:

    this()
    {
        _fxChain = makeAlignedBuffer!AEffect();
    }
    
    void addEffect(AEffect effect)
    {
        _fxChain.pushBack(effect);
    }

    override float getNextSample(float input) nothrow @nogc
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
    AlignedBuffer!AEffect _fxChain;
}

void testEffect(AEffect effect, string name)
{
    import std.stdio;
    import std.random;

    Random gen;

    writefln("Testing %s..", name); 

    float[] outputs;

    for(int i = 0; i < 20000; ++i){
        float sample = uniform(0.0L, 1.0L, gen);
        float val = effect.getNextSample(sample);
        if(i%1000 == 0){
            outputs ~= val;
        }
    }

    writeln(outputs);
    writefln("End %s test..", name);

}

unittest
{
    import std.stdio;
    import ddsp.effect.delay;

    auto fxchain = mallocEmplace!FXChain();

    auto d = mallocEmplace!DigitalDelay();
    d.initialize(2000, 0.5, 0.5);

    auto d2 = mallocEmplace!DigitalDelay();
    d2.initialize(2000, 0.1, 0.9);

    fxchain.addEffect(d);

    testEffect(fxchain, "FX Chain");
}