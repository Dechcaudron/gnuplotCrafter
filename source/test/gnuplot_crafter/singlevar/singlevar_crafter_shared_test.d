module test.gnuplot_crafter.singlevar.singlevar_crafter_shared;

mixin template test()
{
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
}