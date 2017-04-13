module dsp.filter.biquadfilter;

class BiQuadFilter
{
  private import dsp.core.buffer;
  
  private int centerFrequency;
  private float sampleRate;
 
  private Buffer!float
  this(int centerFrequency, double sampleRate)
  {
    this.centerFrequency = centerFrequency;
    this.sampleRate = 
  }
  
  float nextSample(float input)
  {
    
  }
  
  virtual void update(float fc, float fs, float G = 0){}
  
  void setSampleRate(){ return this.sampleRate; }
  float getSampleRate(){ this.sampleRate = sampleRate; }
}
