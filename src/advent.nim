import strutils, sequtils

type
  InvalidOpCode* = object of Exception
  ParameterMode = tuple
    pmFirstisImm: bool
    pmSecondisImm: bool
    pmThirdisImm: bool


proc Load*(filename: string): seq[int] =
  let contents = readFile(filename).strip().split(',').map(parseInt)

  return contents

proc Interp*(program: seq[int]): seq[int] =
  var
   curr = 0
   op: int64
   program = program
   progLen = len(program)

  while curr < progLen:
    op = program[curr]

    var
      mode: ParameterMode
      opStr = $op
      opLen = opStr.len

    if opLen > 5:
      raise newException(InvalidOpCode, "Opcode " & $op & " was too long")

    if opLen >= 5:
      mode.pmThirdisImm = opStr[^5] == '1'

    if opLen >= 4:
      mode.pmSecondisImm = opStr[^4] == '1'

    if opLen >= 3:
      mode.pmFirstisImm = opStr[^3] == '1'

      # also reset the op to parse out the other stuff
      op = parseInt(opStr[^2..^1])


    case op
    of 1: # 1, [l], [r], [dst] -> dst = l + r
      var
        left = if mode.pmFirstisImm: program[curr+1]
               else: program[program[curr+1]]
        right = if mode.pmSecondisImm: program[curr+2]
                else: program[program[curr+2]]
        dest = program[curr+3]

      program[dest] = left + right

      curr += 4
    of 2: # 2, [l], [r], [dst] -> dst = l * r
      var
        left = if mode.pmFirstisImm: program[curr+1]
               else: program[program[curr+1]]
        right = if mode.pmSecondisImm: program[curr+2]
                else: program[program[curr+2]]
        dest = program[curr+3]

      program[dest] = left * right

      curr += 4
    of 3: # 3,[dst] -> dst = dst = <input>
      # get input from user:
      echo "Input requested > "
      var
        input = stdin.readLine()
        dest = program[curr+1]

      # save input to position at first parameter:
      program[dest] = parseInt(input)

      curr += 2
    of 4: # 4,[param] -> <output, no assign>
      # Outputs the value of param
      var
        dest = program[curr+1]

      echo "Computer output: ", program[dest]

      curr += 2
    of 99: # terminate
      return program
    else:
      quit "Unrecognized opcode " & $op & " at pos " & $curr, 1


  return program


when isMainModule:
  discard Interp(Load("input.int"))
