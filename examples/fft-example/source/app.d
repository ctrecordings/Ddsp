import std.stdio;

import dplug.dsp.fft;

void main()
{
	//initialize(int windowSize, int fftSize, int analysisPeriod, WindowDesc windowDesc, bool zeroPhaseWindowing)
	FFTAnalyzer!float fft;
	fft.initialize(1024, 2048, 512, WindowDesc(WindowType.HANN), true);
}
