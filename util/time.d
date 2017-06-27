module ddsp.util.time;

import ddsp.util.functions;

static immutable float sixtyfourth = 0.015625f;
static immutable float thirtysecond = 0.03125f;
static immutable float sixteenth = 0.0625f;
static immutable float eight = 0.125;
static immutable float quarter = 0.25f;
static immutable float half = 0.5f;
static immutable float whole = 1;


struct Note
{
    float tempo;
    float length;
    
    float getTimeInMilliseconds()
    {
        return (1 / tempo) * length * 60000;
    }
    
    float getTimeInSeconds()
    {
        return (1 / tempo) * length * 60;
    }
    
    float getTimeInMinutes()
    {
        return (1 / tempo) * length;
    }
}

struct TimeCursor
{
    float _tempo;
    float _currentSample;
    float _isPlaying;
    float _sampleRate;
    
    void initialize(float sampleRate)
    {
        _sampleRate = sampleRate;
    }
    
    void updateTimeInfo(float tempo, float currentSample, bool isPlaying)
    {
        _tempo = tempo;
        _currentSample = currentSample;
        _isPlaying = isPlaying;
    }
    
    bool currentPosIsNoteMultiple(float noteLength)
    {
        float noteTimeInSamples = msToSamples((1 / _tempo) * noteLength * 60000, _sampleRate);
        bool isMultiple;
        _currentSample % noteTimeInSamples == 0 ? isMultiple = true : isMultiple = false;
        return isMultiple;
    }
}

unittest
{
    
}