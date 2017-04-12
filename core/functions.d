module dsp.core.functions;

import std.math;

float floatToDecibel(float value){
  return 20 * log(value);  
}

float dedibelToFloat(float value){
  return pow(10, value/20);
}

float msToSamples(float ms, float sampleRate){
  return ms * (sampleRate / 1000);
}

float samplesToMs(float samples, float sampleRate){
  return samples / (1000 / sampleRate);
}
