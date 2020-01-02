import logging
import intcode
import helpers


when isMainModule:
  setLogFilter(lvlError)
  discard Interp(Load("input.int"), useStdIo())
