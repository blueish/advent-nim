import algorithm, logging, streams, strutils, sequtils
import intcode
import helpers

var logger = newConsoleLogger()

proc amp_output(phase: seq[int]): int =
  var
    input_signal = 0

  for i in 0..<5:
    var
      inStream = newStringStream($phase[i] & "\n" & $input_signal & "\n")
      outStream = newStringStream()
      ios = newIoStream(inStream, outStream)

    discard Interp(Load("input.int"), ios)

    input_signal = parseInt(ios.readOutputLine())

  return input_signal



proc max_amplifier_signal*(): int =
  var
    phase = @[0, 1, 2, 3, 4]
    maximum = 0

  while phase.nextPermutation():
    var
      output = amp_output(phase)

    if output > maximum:
      logger.log(lvlInfo, "Updated max amp signal: ", output, " from ", phase)
      maximum = output

  return maximum


when isMainModule:
  setLogFilter(lvlInfo)
  echo max_amplifier_signal()
