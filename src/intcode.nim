import strutils, sequtils
import logging

var logger = newConsoleLogger()

type
  InvalidOpCode* = object of Exception
  ParameterMode = tuple
    pmFirstisImm: bool
    pmSecondisImm: bool
    pmThirdisImm: bool


proc Load*(filename: string): seq[int] =
  let contents = readFile(filename).strip().split(',').map(parseInt)

  return contents

#[ Spec for intcodes
1, [l], [r], [dst] -> dst = l + r
2, [l], [r], [dst] -> dst = l * r
3, [dst] -> dst = dst = <input>
4, [param] -> <output, no assign>
5, [c], [d] -> pc = f IFF d != 0
6, [c], [d] -> pc = f IFF d == 0
7, [f], [s], [dst] -> dst = 1 IFF f < s
8, [f], [s], [dst] -> dst = 1 IFF f == s
99: # terminate
]#

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


    logger.log(lvlDebug, "Processing op: " & $op)
    logger.log(lvlDebug, "Mode is: ", $mode)


    case op
    of 1: # 1, [l], [r], [dst] -> dst = l + r
      var
        left = if mode.pmFirstisImm: program[curr+1]
               else: program[program[curr+1]]
        right = if mode.pmSecondisImm: program[curr+2]
                else: program[program[curr+2]]
        dest = program[curr+3]

      logger.log(lvlDebug, " ", "op 1", " ", left, " ", right, " ", dest)
      program[dest] = left + right

      curr += 4
    of 2: # 2, [l], [r], [dst] -> dst = l * r
      var
        left = if mode.pmFirstisImm: program[curr+1]
               else: program[program[curr+1]]
        right = if mode.pmSecondisImm: program[curr+2]
                else: program[program[curr+2]]
        dest = program[curr+3]

      logger.log(lvlDebug, "op 2", " ", left, " ", right, " ", dest)
      program[dest] = left * right

      curr += 4
    of 3: # 3,[dst] -> dst = dst = <input>
      # opcode 3 gets user input and puts it in dst
      echo "Input requested > "
      var
        input = stdin.readLine()
        dest = program[curr+1]

      logger.log(lvlDebug, "op 3", " ", input, " ", dest)
      # save input to position at first parameter:
      program[dest] = parseInt(input)

      curr += 2
    of 4: # 4,[param] -> <output, no assign>
      # Outputs the value of param
      var
        dest = program[curr+1]

      echo "Computer output: ", program[dest]

      curr += 2
    of 5: # 5, [c], [d] -> pc = f IFF d != 0
      var
        cond = if mode.pmFirstisImm: program[curr+1]
               else: program[program[curr+1]]
        jmp_location = if mode.pmSecondisImm: program[curr+2]
                       else: program[program[curr+2]]

      logger.log(lvlDebug, " ", "op 5", " ", cond, " ", jmp_location)
      if cond != 0:
        curr = jmp_location
      else:
        curr += 3
    of 6: # 6, [c], [d] -> pc = f IFF d == 0
      var
        cond = if mode.pmFirstisImm: program[curr+1]
               else: program[program[curr+1]]
        jmp_location = if mode.pmSecondisImm: program[curr+2]
                       else: program[program[curr+2]]

      logger.log(lvlDebug, " ", "op 6", " ", cond, " ", jmp_location)
      if cond == 0:
        curr = jmp_location
      else:
        curr += 3
    of 7: # 7, [f], [s], [dst] -> dst = 1 IFF f < s
      var
        first = if mode.pmFirstisImm: program[curr+1]
                else: program[program[curr+1]]
        second = if mode.pmSecondisImm: program[curr+2]
                else: program[program[curr+2]]
        dest = program[curr+3]

      logger.log(lvlDebug, " ", "op 7", " ", first, " ", second, " ", dest)
      if first < second:
        program[dest] = 1
      else:
        program[dest] = 0

      curr += 4
    of 8: # 8, [f], [s], [dst] -> dst = 1 IFF f == s
      var
        first = if mode.pmFirstisImm: program[curr+1]
                else: program[program[curr+1]]
        second = if mode.pmSecondisImm: program[curr+2]
                 else: program[program[curr+2]]
        dest = program[curr+3]

      logger.log(lvlDebug, " ", "op 8", " ", first, " ", second, " ", dest)
      if first == second:
        program[dest] = 1
      else:
        program[dest] = 0

      curr += 4
    of 99: # terminate
      return program
    else:
      quit "Unrecognized opcode " & $op & " at pos " & $curr, 1


  return program

