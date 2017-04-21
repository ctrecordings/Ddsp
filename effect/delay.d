module dlangdsp.effect.delay;

enum DelayMode {digital, analog}

class Delay
{
  private import dlangdsp.core.buffer;
  public:
  this(size_t delayAmount, float fb, float wet  = 0)
  {
    this.delayAmount = delayAmount;
    this.feedback = fb;
    this.mix = wet;
    buffer = new Buffer!float(delayAmount);
  }
  
  float getNextSample(float sample)
  {
    float yn = buffer.read();
    buffer.write(sample + feedback * yn);
    return mix * yn + sample * (1 - mix);
  }
  
  /+This is a special case used in Entropy's crossover delay feature +/
  float getNextSample(float sample, float sideChain)
  {
    return 0;
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
