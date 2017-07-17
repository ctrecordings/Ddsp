/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.util.scale;

import std.math;

struct RealRange
{
    float x1;
    float x2;
}

class Scale
{
    public:

    /++Calculates the coefficient a and b based on the ranges given. +/
    abstract void initialize(RealRange inputRange, RealRange outputRange)  nothrow @nogc;

    /++input value is converted and returned. +/
    abstract float convert(float x)  nothrow @nogc;

    float getA(){ return _a;}

    float getB(){ return _b;}

    protected:

    //Coefficients which will shape the output funtion.
    float _a;
    float _b;
    float _minVal;
    float _maxVal;
}

/**
Takes an input range which is logarithmic and converts it to a linear scale.
*/
class LogToLinearScale : Scale
{
    public:

    this() nothrow @nogc
    {
    }

    override void initialize(RealRange inputRange, RealRange outputRange)  nothrow @nogc
    {
        _minVal = inputRange.x1;
        _maxVal = inputRange.x2;
        _b = log(outputRange.x1/outputRange.x2)/(inputRange.x1 - inputRange.x2);
        _a = outputRange.x1 / exp(_b * inputRange.x1);
    }

    override float convert(float x)  nothrow @nogc
    {
        x < _minVal ? x = _minVal : x = x;
        x > _maxVal ? x = _maxVal : x = x;
        return log(x / _a) / _b;
    }

    private:

}

/**
Takes an input range which is linear and converts it to a logarithmic scale.
*/
class LinearToLogScale : Scale
{
    public:

    this() nothrow @nogc
    {
    }

    override void initialize(RealRange inputRange, RealRange outputRange)  nothrow @nogc
    {
        _minVal = inputRange.x1;
        _maxVal = inputRange.x2;
        _b = log(outputRange.x1/outputRange.x2)/(inputRange.x1 - inputRange.x2);
        _a = outputRange.x1 / exp(_b * inputRange.x1);
    }

    override float convert(float x)  nothrow @nogc
    {
        x < _minVal ? x = _minVal : x = x;
        x > _maxVal ? x = _maxVal : x = x;
        return _a * exp(_b * x);
    }

    private:

}

unittest
{
    LinearToLogScale scale1 = new LinearToLogScale();
    scale1.initialize(RealRange(0.1f, 1.0f), RealRange(0.1f, 1.0f));
    LogToLinearScale scale2 = new LogToLinearScale();
    scale2.initialize(RealRange(0.1f, 1.0f), RealRange(0.1f, 1.0f));
}
