import unittest
import sequtils, strutils, streams, logging

import intcode
import helpers


suite "run  intcode":
  setup:
    setLogFilter(lvlError)



  test "simple read":
    var
      prog = Load("tests/data/simple.int")
      res = Interp(prog, useStdIo())

    check(res[0] == 30)

  test "with immediate parameter mode":
    var
      prog = Load("tests/data/with_mode.int")
      res = Interp(prog, useStdIo())

    check(res[4] == 99)

  test "a jump intcode":
    var
      prog = "3,9,8,9,10,9,4,9,99,-1,8".split(',').map(parseInt)
      inStream = newStringStream("8")
      outStream = newStringStream()
      ios = newIoStream(inStream, outStream)

    discard Interp(prog, ios)

    check(ios.readOutputLine() == "1")

