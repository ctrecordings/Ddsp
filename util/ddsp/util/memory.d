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

    Compressor[] compChannel = calloc!Compressor.numChannels(2);
    Compressor comp = calloc!Compressor.init();
}