module delay;

enum DelayMode {digital, analog}

class Delay
{
  private import core.buffer;
  public:
  this(size_t delayAmount, float fb, float wet  = 0)
  {
    this.delayAmount = delayAmount;
    this.fb = fb;
    this.wet = wet;
    buffer = new Buffer!float(delayAmount);
  }
  
  float getNextSample(float sample)
  {
    float yn = buffer.read();
    buffer.write(sample + fb * yn);
    return wet * yn + sample * (1 - wet);
  }
  
  /+This is a special case used in Entropy's crossover delay feature +/
  float getNextSample(float sample, float sideChain)
  {
    
  }
  
  void resize(size_t delayAmount)
  {
    buffer.resize(delayAmount);
  }
  
  void flush()
  {
    
  }
  
  void setFeedback(float fb)
  {
    feedback = fb;
  }
  
  void setMix(float amount)
  {
    mix = amount;
  }
  private:
  Buffer!float buffer;
  size_t delayAmount;
  float feedback;
  float mix;
}
