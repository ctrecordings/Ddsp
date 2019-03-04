module ddsp.util.memory;

import dplug.core.nogc;


/// Template for allocating single instances of class or arrays of classes
/// for multiple channels.
template calloc(alias EffectName)
{
    private import core.stdc.stdlib : malloc;

    /// Returns an initialized array of the given template parameter.
    EffectName[] numChannels(Args...)(int n, Args args) nothrow @nogc
    {
        EffectName* e = cast(EffectName*)malloc(EffectName.sizeof * n);
        foreach(chan; 0..n)
            e[chan] = mallocNew!EffectName(args);
        return e[0..n];
    }

    /// Returns a new instance of EffectName
    EffectName init(Args...)(Args args)
    {
        return mallocNew!EffectName(args);
    }
}

unittest
{
    import ddsp.effect.compressor;

    Compressor!float[] compChannel = calloc!(Compressor!float).numChannels(2);
    Compressor!float comp = calloc!(Compressor!float).init();
}

/// Allocates a slice of memory of type T and with the specified length.
/// Since dynamic arrays cannot be 
T[] callocSlice(T)(size_t length) nothrow @nogc
{
    T* mem = cast(T*)malloc(T.sizeof * length);
    return mem[0..length];
}

/// Free memory from slice created with callocSlice
void freeSlice(T)(T[] slice)
{
    free(cast(T*)slice);
}

unittest
{
    import std.stdio;
    char[] s = callocSlice!char(200);
    s.freeSlice();
}