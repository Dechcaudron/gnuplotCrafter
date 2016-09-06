module gnuplot_crafter.singlevar.singlevar_crafter_tls;

import test.gnuplot_crafter.singlevar.singlevar_crafter_tls : test;
mixin test;

import gnuplot_crafter.unmatching_length_exception;

import std.stdio;
import std.exception;
import std.format;

public struct SingleVarCrafter(T = float)
{
    File sinkFile;

    this(string filename, bool appendContent = true)
    {
        this(File(filename, appendContent ? "a" : "w"));
    }

    this(File sinkFile)
    {
        this.sinkFile = sinkFile;
    }

    public void put(bool flush = false)(T x, T y)
    {
        sinkFile.writefln("%s %s", x, y);

        static if (flush)
            sinkFile.flush();
    }

    public void put(bool flush = false)(const T[] xs, const T[] ys)
    {
        enforce!UnmatchingLengthException(xs.length == ys.length,
            format("Unequal lengths for slices xs(%s) and ys(%s)",
                    xs.length, ys.length));

        for(int i = 0; i < xs.length; i++)
            put(xs[i], ys[i]);

        static if (flush)
            sinkFile.flush();
    }

    public void flush()
    {
        sinkFile.flush();
    }
}
