module fir;

import dplug.core.nogc;

import std.math;

import std.stdio;
// /**
//  * A fast method of convolution of a long signal with a FIR filter
//  */
// void overlapAdd(float[] impulseResponse, ref float[] inputSignal)
// {
//     int m = impulseResponse.length;
//     int nx = 
// }

/**
 * IDCT algorithm need to extract the impulse response from sampled frequency plot
 */
float[] inverseDiscreteCosineTransformReal(float[] frequencyPlot)
{
    int N = cast(int)frequencyPlot.length * 2;

    float[] a = mallocSlice!float(N);

    for(int n = 0; n < (N / 2); ++n)
    {
        float x = 0;
        for(int i = 1; i < (N / 2); ++i)
        {
            x += abs(frequencyPlot[i] * abs(cos( abs(2 * PI * i *((n - (cast(float)N - 1) / 2)) / cast(float)N))));
        }
        a[n] = (1 / cast(float)N ) * (frequencyPlot[0] + 2 * x);
    }

    // for(int n = ())

    // foreach(index, )

    return a;
}

// /**
//  * IDCT algorithm need to extract the impulse response from sampled frequency plot
//  */
// float[] inverseDiscreteCosineTransformReal(float[] frequencyPlot)
// {
//     int N = cast(int)frequencyPlot.length * 2;

//     float[] a = mallocSlice!float(N);

//     for(int k = 0; k < (N / 2); ++k)
//     {
//         float an = 0;
//         for(int n = 0; n < (N / 2); ++n)
//         {
//             an += frequencyPlot[n] * cos((PI * k * (2 * n + 1)) / (2 * N));
//         }
//         a[k] = 2 * an;
//     }

//     // for(int n = ())

//     // foreach(index, )

//     return a;
// }


unittest
{
    import std.stdio;
    import std.conv;

    float[] frequencyPlot = [1.0, 1.0, 1.0, 0.001, 0.001, 0.001, 0.001, 0.001];
    float[] expected = [0.04858366, 0.00364087, -0.05199205, -0.07047625, -0.02194221, 0.08695625, 0.21101949, 0.29421023, 0.29421023, 0.21101949, 0.08695625, -0.02194221, -0.07047625, -0.05199205, 0.00364087, 0.04858366]; 
    // float[] frequencyPlot = [0.1, 2.1, 0.3, 4.2];
    // float[] expected = [ 0.95238737, -0.80969772,  0.7286317,  -0.82132135,  -0.82132135,  0.7286317, -0.80969772, 0.95238737];
    float[] actual = inverseDiscreteCosineTransformReal(frequencyPlot);

    assert(actual.length == expected.length, "Expected actual.length to be " ~ to!string(expected.length) ~ `. Instead got ` ~ to!string(actual.length));
    foreach(index, e; expected)
    {
        if(e != actual[index])
        {
            writeln("Index: " ~ to!string(index));
            assert(e == actual[index], "Error: expected " ~ to!string(e) ~ " to equal " ~ to!string(actual[index]));
        }
    }
}