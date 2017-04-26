module ddsp.filter.biquadfilter;

import ddsp.core.buffer;

class BiQuadFilter
{ 
  private int centerFrequency;
  private float sampleRate;
 
  private Buffer!float buffer;
  this(int centerFrequency, double sampleRate)
  {
    this.centerFrequency = centerFrequency;
    this.sampleRate = sampleRate;
  }
  
  /*Not yet implemented*/
  float nextSample(float input)
  {
    
	return 0;
  }
  
  abstract void update(float fc, float fs, float G = 0);
  
  void setSampleRate(){ this.sampleRate = sampleRate; }
  float getSampleRate(){ return sampleRate; }
}
