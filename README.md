# Ddsp [![Build Status](https://travis-ci.org/ctrecordings/Ddsp.svg?branch=master)](https://travis-ci.org/ctrecordings/Ddsp) [![Dub version](https://img.shields.io/dub/v/ddsp.svg)](https://code.dlang.org/packages/ddsp) 
A high level library for Digital Signal Processing in D with a focus on audio.

I am not an expert on DSP by any means.  Most of the designs for these plugins are ones that I have found and compiled from various books and websites.
I have many people to thank for doing the math and work that makes it possible for someone like me to implement and use these complex equations.
Many of these effects are based on designs from [Designing Audio Effect Plug-Ins in C++](http://www.willpirkle.com/about/books/)
Another important source is [MusicDSP.org](http://www.musicdsp.org)

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