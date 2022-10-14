/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.effect.effect;

import dplug.core.vec;
import dplug.core.nogc;

/**
* Should be inherited by all Audio Effect classes to allow for batch processing
*/
abstract class AudioEffect(T)
{
public:

  /**
    * Process a sample that is passed to the processor, and return the next sample.
    */
  abstract T getNextSample(const T input) nothrow @nogc;

  /**
     * Takes a set of buffers and processes them with getNextSample()
     * In the future this could possibly be optimized
     */
  void processBuffers(const(T)* inputBuffer, T* outputBuffer, int numSamples)
  {
    foreach (sample; 0 .. numSamples)
    {
      outputBuffer[sample] = getNextSample(inputBuffer[sample]);
    }
  }

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

  float SampleRate() @property
  {
    return _sampleRate;
  }

protected:
  float _sampleRate;
}

/// Holds a list of AudioEffects.  getNextSample(input)
/// call getNextSample(input) on each effect in the chain
class FXChain(T) : AudioEffect!T
{
public:

  this()
  {
    _fxChain = makeVec!AudioEffect();
  }

  /// Adds an effect to the end of the FX Chain
  void addEffect(AudioEffect effect)
  {
    _fxChain.pushBack(effect);
  }

  override void setSampleRate(float sampleRate)
  {
    foreach (effect; _fxChain)
    {
      effect.setSampleRate(sampleRate);
    }
  }

  /// Override from AudioEffect.  Processes the input through each effect
  /// and passes the result to the next effect.
  override T getNextSample(const T input) nothrow @nogc
  {
    float output = input;
    foreach (AudioEffect e; _fxChain)
    {
      output = e.getNextSample(output);
    }
    return output;
  }

  /// Resets each effect in the chain. To clear buffers
  /// and recalculate coefficients.
  override void reset() nothrow @nogc
  {
    foreach (AudioEffect e; _fxChain)
    {
      e.reset();
    }
  }

private:

  /// Vector of audio effects.
  Vec!AudioEffect _fxChain;
}

/**
* This function should only be called in a unittest block.
* AudioEffect effect : Effect to be tested.
* string name : name that will be written to output.
* size_t bufferSize : number of samples to be processed.
* bool outputResults : determines if output should be printed.
*/
void testEffect(AudioEffect!float effect, string name, size_t bufferSize = 20000, bool outputResults = false)
{
  import std.stdio;
  import std.random;

  Random gen;

  if (outputResults)
  {
    writefln("Testing %s..", name);
    writefln("Initial State: %s", effect.toString());
  }

  float[] outputs;
  string[] stringResults;

  for (int i = 0; i < bufferSize; ++i)
  {
    float sample = uniform(0.0L, 1.0L, gen);
    float val = effect.getNextSample(sample);
    if (i % 1000 == 0)
    {
      outputs ~= val;
      stringResults ~= effect.toString();
    }
  }

  if (outputResults)
  {
    for (int i = 0; i < outputs.length && i < stringResults.length; ++i)
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

