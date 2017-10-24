/*******************************************
 * Author(s): Ethan Reker
 * License: MIT
 * Copyright: Copyright Cut Through Recordings 2017
 *******************************************/
import std.stdio;
import std.conv;
import waved;

import ddsp.filter.lowpass;

/// 
/// Simple program that processes a wave file and applies a lowpass
/// filter.  The output is saved to a file called filtered.wav
/// 
void main(string[] args)
{
	/++ Declare a Butterworth lowpass filter ++/
	ButterworthLP filter = new ButterworthLP();

	writeln("Ddsp - Lowpass Example");

	if(args.length < 3)
	{
		writefln("Missing args.");
		writefln("Correct usage: lowpass-wavefile <file_name.wav> <lowpass_frequency>");
	}
	else
	{
		scope(success) writefln("Proccessing finished...");
		scope(failure) writefln("An error occured, processing not complete.");

		writefln("Opening file - %s", args[1]);
		// Loads a WAV file in memory
	    Sound input = decodeWAV(args[1]);
	    writefln("channels = %s", input.channels);
	    writefln("samplerate = %s", input.sampleRate);
	    writefln("samples = %s", input.samples.length);

	    // Only keep the first channel (left)
	    input = input.makeMono(); 

		/++ Set samplerate and center frequency for the filter ++/
	    filter.setSampleRate(input.sampleRate);
	    filter.setFrequency(to!float(args[2]));

	    // Multiply the left channel by 2 in-place
	    foreach(i; 0..input.lengthInFrames)
	        input.sample(0, i) = filter.getNextSample(input.sample(0, i));

	    // Duplicate the left channel, saves a two channels WAV file out of it
	    float[][] channels = [input.channel(0), input.channel(0)];
	    Sound(input.sampleRate, channels).encodeWAV("filtered.wav");

	    writefln("Output saved to filtered.wav");
	}
}