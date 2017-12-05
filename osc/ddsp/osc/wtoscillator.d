/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.osc.wtoscillator;

import ddsp.effect.aeffect;

const float pi = 3.14159265;

enum : int
{
    wav,
    sqr,
    saw,
    tri
}

class WTOscillator : AEffect
{
    import std.math;
    import core.stdc.stdlib;
    import ddsp.util.functions;
    import ddsp.effect.aeffect;
    
public:

    this() nothrow @nogc
    {
        _waveTable = cast(float*) malloc(1024 * float.sizeof);
        m_fReadIndex = 0.0f;
        m_fQuadPhaseReadIndex = 0.0f;
        _oscType = wav;
        _noteOn = true;
    }

    void doOscillate(float* pYn, float* pYqn) nothrow @nogc
    {
        if(!_noteOn)
        {
            *pYn = 0.0;
            *pYqn = 0.0;
            return;
        }
        
        //output values for this cycle
        float fOutSample = 0;
        float fQuadPhaseOutSample = 0;
        
        // get INT part
        int nReadIndex = cast(int)m_fReadIndex;
        int nQuadPhaseReadIndex = cast(int)m_fQuadPhaseReadIndex;
        
        // get FRAC part - NOTE no quad phase frac is needed because it ill be the same!
        float fFrac = m_fReadIndex - nReadIndex;
        
        //setup second index for interpolation; wrap the buffer if needed
        int nReadIndexNext = nReadIndex + 1 > 1023 ? 0 : nReadIndex + 1;
        int nQuadPhaseReadIndexNext = nQuadPhaseReadIndex + 1 > 1023 ? 0 : nQuadPhaseReadIndex + 1;
        
        fOutSample = linearInterp(0, 1, _waveTable[nReadIndex], _waveTable[nReadIndexNext], fFrac);
        fQuadPhaseOutSample = linearInterp(0, 1, _waveTable[nQuadPhaseReadIndex], _waveTable[nQuadPhaseReadIndexNext], fFrac);
        
        // add the increment for next time
        m_fReadIndex += _incVal;
        m_fQuadPhaseReadIndex += _incVal;
        
        // check for wrap
        if(m_fReadIndex > 1024)
            m_fReadIndex -= 1024;
        if(m_fQuadPhaseReadIndex > 1024)
            m_fQuadPhaseReadIndex -= 1024;
        
        //invert?
        if(_invert)
        {
            fOutSample *= -1.0;
            fQuadPhaseOutSample *= -1.0;
        }
        
        *pYn = fOutSample;
        *pYqn = fQuadPhaseOutSample;
        
    }

    void initialize(float frequency, float sampleRate, int oscType, bool tableMode = true) nothrow @nogc
    {
        setFrequency(frequency, sampleRate);
        _tableModeNormal = tableMode;
        prevMode = !_tableModeNormal;
        setOscType(oscType);
        
        
    }
    
    /**
    *   Recalculates the values in the sine table based on the oscillator type
    */
    void setOscType(int oscType) nothrow @nogc
    {
        //Triangle
        //rising edge1:
        float mt1 = 1.0f / 256.0f;
        float bt1 = 0.0f;
        
        //rising edge2:
        float mt2 = 1.0f / 256.0f;
        float bt2 = -1.0;
        
        //falling edge
        float mtf2 = -2.0f / 512.0f;
        float btf2 = 1.0f;
        
        // Sawtooth
        // rising edge1:
        float ms1 = 1.0f / 512.0f;
        float bs1 = 0.0f;
        
        //rising edge2:
        float ms2 = 1.0f / 512.0f;
        float bs2 = -1.0f;
        
        if(_oscType != oscType || _tableModeNormal != prevMode )
        {
            _oscType = oscType;
            prevMode = _tableModeNormal;
            
            for(int i = 0; i < 1024; ++i)
            {
                float maxVal = 0.0f;
                switch(_oscType)
                {
                    case wav:
                        //SIN MODE
                        _waveTable[i] = sin( ( cast(float)i / 1024.0) * (2 * pi));
                        break;
                    case saw:
                        //SAW NORMAL
                        if(_tableModeNormal)
                        {
                            _waveTable[i] = i < 512 ? ms1 * i + bs1 : ms2 * (i - 511) + bs2;
 
                        }
                        //SAW BAND-LIMITED
                        else
                        {
                            for(int g=1; g <= 6; ++g)
                            {
                                double n = cast(double)g;
                                _waveTable[i] += pow(cast(float)-1.0f, cast(float)(g+1)) * (1.0 / n) * sin(2.0 * pi * i * n / 1024.0f);
                            } 
                        }
                        break;
                    case tri:
                        //TRI NORMAL
                        if(_tableModeNormal)
                        {
                            if(i < 256)
                                _waveTable[i] = mt1 * i + bt1;
                            else if(i >= 256 && i < 768)
                                _waveTable[i] = mtf2 * (i - 256) + btf2;
                            else
                                _waveTable[i] = mt2 * (i - 768) + bt2;
                        }
                        //TRI BAND-LIMITED
                        else
                        {
                            _waveTable[i] = 0;
                        }
                        break;
                    case sqr:
                        //SQR NORMAL
                        if(_tableModeNormal)
                        {
                            _waveTable[i] = i < 512 ? + 1.0 : -1.0;
                        }
                        //SQR BAND-LIMITED
                        else
                        {
                            _waveTable[i] = 0;
                        }
                        break;
                    default:
                        //DEFAULT IS SIN
                        _waveTable[i] = sin( ( cast(float)i / 1024.0) * (2 * pi));
                        break;
                }
            }
        }
    }

    void setFrequency(float frequency, float sampleRate) nothrow @nogc
    {
        _incVal = 1024.0f * frequency / sampleRate;
    }
    
    void setTableModeNormal()
    {
        prevMode = _tableModeNormal;
        _tableModeNormal = true;
        setOscType(_oscType);
    }
    
    void setTableModeBandLimited()
    {
        prevMode = _tableModeNormal;
        _tableModeNormal = true;
        setOscType(_oscType);
    }

    override void reset() nothrow @nogc
    {
        
    }

    /**
    *   Note: only returns single phase output. To get quadrature phase output
    *   use `void doOscillate(&float, &float)`
    */
    override float getNextSample(const float input) nothrow @nogc
    {
        currentSample = 0;
        currentQuadPhaseSample = 0;
        
        doOscillate(&currentSample, &currentQuadPhaseSample);
        
        return currentSample;
    }

    void on() {_noteOn = true;}
    void off() {_noteOn = false;}
    
    override string toString()
    {
        import std.conv;
        return "Inc Val:  " ~ to!string(_incVal) ~ " RIndex: " ~ to!string(m_fReadIndex) ~ " TableVal: " ~ to!string(_waveTable[cast(size_t)m_fReadIndex]);
    }
    
private:
    float* _waveTable;
    float m_fReadIndex;
    float m_fQuadPhaseReadIndex;
    float _incVal;
    
    float currentSample;
    float currentQuadPhaseSample;
    bool _noteOn;
    bool _invert;
    
    /++ true = normal | false = band limited +/
    bool _tableModeNormal;
    bool prevMode;
    
    int _oscType;
    
}

unittest
{
    import dplug.core.nogc;
    import ddsp.effect.aeffect;

    WTOscillator osc = mallocNew!WTOscillator();
    osc.initialize(1000, 44100, wav);
    testEffect(osc, "WTOscillator", 44100, false);
}