import intcode, logging
export intcode


when isMainModule:
  setLogFilter(lvlError)
  discard Interp(Load("input.int"))
