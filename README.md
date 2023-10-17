# Ddsp [![Build Status](https://travis-ci.org/ctrecordings/Ddsp.svg?branch=master)](https://travis-ci.org/ctrecordings/Ddsp) [![Build Status](https://cutthroughrecordings.visualstudio.com/Ddsp/_apis/build/status/ctrecordings.Ddsp?branchName=master)](https://cutthroughrecordings.visualstudio.com/Ddsp/_build/latest?definitionId=2&branchName=master) [![Dub version](https://img.shields.io/dub/v/ddsp.svg)](https://code.dlang.org/packages/ddsp) 
A high level library for Digital Signal Processing in D with a focus on audio.

I am not an expert on DSP by any means.  Most of the designs for these plugins are ones that I have found and compiled from various books and websites.
I have many people to thank for doing the math and work that makes it possible for someone like me to implement and use these complex equations.
Many of these effects are based on designs from [Designing Audio Effect Plug-Ins in C++](http://www.willpirkle.com/about/books/)
Another important source is [MusicDSP.org](http://www.musicdsp.org)

# Disclaimer
**This package is no longer actively maintained and should only be used as a reference.**

I've personally pivoted to using `Faust` as the backend for any plugins I develop and intend to eventually replace all of the Ddsp code I use with it.  The main reason is that Faust has a massive library of functions that I could never hope to replicate.  Faust is also highly efficient and quick to develop with since it is designed specifically for signal processing.

If you are interested in seeing how to use Faust as the backend for a Dplug plugin, see [Dplug Faust Example](https://github.com/ctrecordings/dplug-faust-example)

## Sub-Packages

### ddsp:util
- Envelope Detection
- Circular Buffer
- Memory Management
- Basic DSP functions

### ddsp:effect
- AudioEffect : base class for all effects
- Dynamics: Compressor, Limiter, Expander, Gate
- Modulated Delay: Generic ModDelay, Phaser, Flanger, Chorus
- Digital Delay

### ddsp:filter
- Biquad
- Lowpass (1st order, 2nd order, butterworth, linkwitz-riley)
- Highpass (1st order, 2nd order, butterworth, linkwitz-riley)
- Allpass
- Shelf (Lowpass only)

### ddsp:osc
- Wavetable Oscillator
- Coupled-from oscillator

### Dependecies
Ddsp depends on `dplug:core` for use of it's `@nogc` capabilities.  The D Runtime is only used for testing purposes within the library.  This is to make it compatible with dplug but it can be used in any D framework/application.

Many more components are planned to be added soon.
- Reverb
- Modulated Filter