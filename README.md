# Ddsp [![Dub version](https://img.shields.io/dub/v/ddsp.svg)](https://code.dlang.org/packages/ddsp)
A high level library for Digital Signal Processing in D with a focus on audio.

### Components
- Circular buffer
- Digital Delay
- Compressor
- Envelope Detector
- Oscillators
- Generic BiQuad
- Allpass Filter
- Linkwitz-Riley Lowpass/Highpass Filters
- FX Chain

### Dependecies
Ddsp depends on `dplug:core` for use of it's `@nogc` capabilities.  The D Runtime is only used for testing purposes within the library.

Many more components are planned to be added soon.  
