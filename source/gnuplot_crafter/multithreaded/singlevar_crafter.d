module gnuplot_crafter.multithreaded.singlevar_crafter;

import test.gnuplot_crafter.multithreaded.singlevar_crafter_test : test;
mixin test;

import gnuplot_crafter.unmatching_length_exception;

import std.concurrency;
import std.stdio;
import std.exception;
import std.format;
import std.conv;
import std.variant;

public shared struct SingleVarCrafter(T = float)
{
    immutable string workerThreadName;

    static size_t counter = 0;

    this(string sinkFilename, bool append = true)
    {
        Tid t = spawn(&threadingLoop, sinkFilename, append);

        workerThreadName = "SingleVarCrafter" ~ to!string(counter++);
        register(workerThreadName, t);

        auto msg = receiveOnly!StartReport();

        enforce(msg == StartReport.success);
    }

    ~this()
    {
        Tid workerThread = locate(workerThreadName);
        if(workerThread != Tid.init)
        {
            workerThread.send(Order.finish);
            receive((FinishReport msg){});
        }
    }

    public void put(bool flush = false)(T x, T y)
    {
        Tid t = locate(workerThreadName);

        t.send(DataMessage([to!(immutable(T))(x)],
                            [to!(immutable(T))(y)]));

        static if (flush)
        {
            t.send(Order.flush);
            receive((FlushReport msg){});
        }
    }

    public void put(bool flush = false)(const T[] xs, const T[] ys)
    {
        enforceEqualLengths(xs.length, ys.length);

        Tid t = locate(workerThreadName);

        t.send(DataMessage(xs.idup, ys.idup));

        static if (flush)
        {
            t.send(Order.flush);
            receive((FlushReport msg){});
        }
    }

    public void put(bool flush = false)(immutable(T)[] xs, immutable(T)[] ys)
    {
        enforceEqualLengths(xs.length, ys.length);

        Tid t = locate(workerThreadName);

        t.send(DataMessage(xs, ys));

        static if (flush)
        {
            t.send(Order.flush);
            receive((FlushReport msg){});
        }
    }

    public void flush()
    {
        Tid t = locate(workerThreadName);
        t.send(Order.flush);
        receive((FlushReport msg){});
    }

    private void enforceEqualLengths(size_t xsLength, size_t ysLength) const
    {
        enforce!UnmatchingLengthException(xsLength == ysLength,
            format("Unequal lengths for slices xs(%s) and ys(%s)",
                    xsLength, xsLength));
    }

    private void threadingLoop(string sinkFilename, bool append)
    {
        File sinkFile;

        try
        {
            sinkFile = File(sinkFilename, append ? "a" : "w");
        }
        catch(ErrnoException e)
        {
            debug writeln(e);
            ownerTid.send(StartReport.failure);
            return;
        }

        ownerTid.send(StartReport.success);

        bool shouldContinue = true;
        while(shouldContinue)
        {
            receive(
                (DataMessage msg)
                {
                    with(msg)
                        for(int i = 0; i < xs.length; i++)
                            sinkFile.writefln("%s %s", xs[i], ys[i]);
                },
                (Order msg)
                {
                    with (Order) final switch(msg)
                    {
                        case flush:
                            sinkFile.flush();
                            ownerTid.send(FlushReport.success);
                            break;

                        case finish:
                            shouldContinue = false;
                            break;
                    }
                },
                (Variant v)
                {
                    debug writeln("Received variant " ~ to!string(v));
                }
            );
        }

        ownerTid.send(FinishReport.success);
    }

    private struct DataMessage
    {
        immutable(T)[] xs;
        immutable(T)[] ys;

        this(immutable(T)[] xs, immutable(T)[] ys)
        in
        {
            assert(xs.length == ys.length);
        }
        body
        {
            this.xs = xs;
            this.ys = ys;
        }
    }
}

private enum StartReport
{
    success,
    failure
}

private enum FinishReport
{
    success
}

private enum FlushReport
{
    success
}

private enum Order
{
    flush,
    finish
}
