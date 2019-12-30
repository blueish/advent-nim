import unittest
import pkg/src/advent


suite "run  intcode":
  test "simple read":
    var
      prog = Load("tests/data/simple.int")
      res = Interp(prog)

    check(res[0] == 30)

  test "with immediate parameter mode":
    var
      prog = Load("tests/data/with_mode.int")
      res = Interp(prog)

    check(res[4] == 99)


