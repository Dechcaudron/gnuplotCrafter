module test.gnuplot_crafter.singlevar.singlevar_crafter_tls_test;

mixin template test()
{
    import std.stdio;
    import std.string;
    import std.exception;

    unittest
    {
        File f = File.tmpfile();

        auto a = SingleVarCrafter!float(f);
        a.put!true(0, 2);

        f.rewind();

        string s;
        f.readf("%s", &s);

        assert(s.chomp() == "0 2");
    }

    unittest
    {
        File f = File.tmpfile();

        //Check flush on struct destruction
        {
            auto a = SingleVarCrafter!float(f);
            a.put(0.02, 0.003);
            a.put(2, 3);
        }

        f.rewind();

        string s;
        f.readf("%s", &s);

        assert(s.chomp() == "0.02 0.003\n2 3");
    }

    unittest
    {
        File f = File.tmpfile();

        auto a = SingleVarCrafter!float(f);

        a.put!true([1, 1.5, 3.02], [0.1, 0.2, 0.03]);

        f.rewind();

        string s;
        f.readf("%s", &s);

        assert(s.chomp() == "1 0.1" ~ "\n"
                            ~ "1.5 0.2" ~ "\n"
                            ~ "3.02 0.03");
    }

    unittest
    {
        auto a = SingleVarCrafter!float(File.tmpfile());

        assertThrown!UnmatchingLengthException(a.put([0, 2], [0, 1, 2]));
    }
}
