module gnuplot_crafter.unmatching_length_exception;

class UnmatchingLengthException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line, null);
    }
}
