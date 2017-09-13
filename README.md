# Ddsp [![Build Status](https://travis-ci.org/abaga129/Ddsp.svg?branch=master)](https://travis-ci.org/abaga129/Ddsp) [![Dub version](https://img.shields.io/dub/v/ddsp.svg)](https://code.dlang.org/packages/ddsp) 
A high level library for Digital Signal Processing in D with a focus on audio.

Many of these effects are based on designs from [Designing Audio Effect Plug-Ins in C++](http://www.willpirkle.com/about/books/)

## Sub-Packages

### ddsp:util
- Envelope Detection
- Circular Buffer
- Basic DSP functions

### ddsp:effect
- AEffect : base class for all effects
- Dynamics: Compressor, Limiter, Expander, Gate
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
Ddsp depends on `dplug:core` for use of it's `@nogc` capabilities.  The D Runtime is only used for testing purposes within the library.

Many more components are planned to be added soon.  
