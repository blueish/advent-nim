import unittest
import pkg/src/advent


suite "run  intcode":
  #[
  echo "suite setup: run once before the tests"

  setup:
    echo "run before each test"

  teardown:
    echo "run after each test"
  ]#

  test "simple read":
    # give up and stop if this fails
   var
     prog = Load("tests/data/simple")
     res = Interp(prog)

   check(res[0] == 30)


