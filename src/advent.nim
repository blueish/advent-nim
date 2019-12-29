import strutils, sequtils


proc Load*(filename: string): seq[int] =
  let contents = readFile(filename).strip().split(',').map(parseInt)

  return contents

proc Interp*(program: seq[int]): seq[int] =
  var
   curr = 0
   op: int64
   program = program

  while curr < len(program):
    # modes := []int64{0, 0, 0}

    op = program[curr]

    # slice := strconv.FormatInt(op, 10)

    # if len(slice) > 2 {
    #   op, err := strconv.Atoi(slice[len(slice)-2:]) // update op code
    #   if err != nil {
    #     log.Fatal("Unable to update opcode", err)
    #   }

    #   slice = slice[len(slice)-2]
    # }

    # fmt.Println(slice[:3])            // first 3 digits (111)
    # fmt.Println(slice[len(slice)-2:]) // and the last 2 digits (55)

    case op
    of 1: # 1, [l], [r], [dst] -> dst = l + r
      var
        left = program[program[curr+1]]
        right = program[program[curr+2]]
        dest = program[curr+3]

      program[dest] = left + right

      curr += 4
    of 2: # 2, [l], [r], [dst] -> dst = l * r
      var
        left = program[program[curr+1]]
        right = program[program[curr+2]]
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
  echo Interp(Load("input"))
