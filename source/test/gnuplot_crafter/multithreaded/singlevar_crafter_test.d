module test.gnuplot_crafter.multithreaded.singlevar_crafter_test;

mixin template test()
{
    import std.stdio;
    import std.string;

    unittest
    {
        {
            auto a = shared SingleVarCrafter!float("test_out/t1.dat", false);
            a.put(2, 3);
        }

        File f = File("test_out/t1.dat", "r");

        string s;
        f.readf("%s", &s);

        assert(s.chomp() == "2 3");
    }

    unittest
    {
        auto a = shared SingleVarCrafter!float("test_out/t2.dat", false);

        a.put!true([0.2, 0.3], [5.1, 0.02]);

        File f = File("test_out/t2.dat", "r");

        string s;
        f.readf("%s", &s);

        assert(s.chomp() == "0.2 5.1" ~ "\n" ~ "0.3 0.02");
    }

    unittest
    {
        string filePath = "test_out/t3.dat";
        auto a = new shared SingleVarCrafter!float(filePath, false);

        a.put(5, 2);

        a.__dtor(); // destroy does not call the destructor so far. Bug??
        destroy(a);

        File f = File(filePath, "r");

        string s;
        f.readf("%s", &s);

        assert(s.chomp() == "5 2");
    }
}
