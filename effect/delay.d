module ddsp.effect.delay;

enum DelayMode {digital, analog}

class Delay
{
  private import ddsp.core.buffer;
  public:
  this(size_t delayAmount, float fb, float wet  = 0)
  {
    this.delayAmount = delayAmount;
    this.feedback = fb;
    this.mix = wet;
    buffer = new Buffer!float(delayAmount);
  }
  
  float getNextSample(float sample) nothrow @nogc
  {
    float yn = buffer.read();
    buffer.write((sample + feedback * yn)*0.5f);
    return mix * yn + sample * (1 - mix);
	//return sample;
  }
  
  /+This is a special case used in Entropy's crossover delay feature +/
  /*float getNextSample(float sample, float sideChain) nothrow @nogc
  {
    return 0;
  }*/
  
  void resize(size_t delayAmount) nothrow @nogc
  {
    buffer.resize(delayAmount);
  }
  
  void flush()
  {
    
  }
  
  size_t size() nothrow @nogc
  {
	return buffer.size();
  }
  
  void setFeedback(float fb) nothrow @nogc
  {
    feedback = fb;
  }
  
  void setMix(float amount) nothrow @nogc
  {
    mix = amount;
  }
  private:
  Buffer!float buffer;
  size_t delayAmount;
  float feedback;
  float mix;
}

@system unittest
{
	import std.stdio;
	Delay d = new Delay(100, 1, 1);
	for(int i = 0; i < 200; ++i){
		writefln("%s", d.getNextSample(i));
	}
}