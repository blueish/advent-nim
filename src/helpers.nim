import streams
import logging

type
  IoKind = enum
    iokStdIo,
    iokStream
  IoStream* = ref object of RootObj
    case kind: IoKind
    of iokStdIo: infile, outfile: File
    of iokStream: inStream, outStream: Stream

proc useStdIo*(): IoStream = IoStream(kind: iokStdIo, infile: stdin, outfile: stdout)

proc newIoStream*(inStrm, outStrm: Stream): IoStream =
  IoStream(kind: iokStream, inStream: inStrm, outStream: outStrm)

proc readLine*(ios: IoStream): string =
  case ios.kind:
    of iokStdIo:
      return ios.infile.readLine()
    of iokStream:
      return ios.inStream.readLine()


proc writeLine*[Ty](ios: IoStream, x: varargs[Ty, `$`]) =
  case ios.kind:
    of iokStdIo:
      ios.outfile.writeLine(x)
    of iokStream:
      ios.outStream.writeLine(x)
      ios.outStream.setPosition(0)


proc readOutputLine*(ios: IoStream): string =
  ## Useful for testing, debugging, etc to see output
  case ios.kind:
    of iokStdIo:
      return ios.outfile.readLine()
    of iokStream:
      return ios.outStream.readLine()
