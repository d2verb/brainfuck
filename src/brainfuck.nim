import os

let
  code = if paramCount() > 0: readFile paramStr(1) else: readAll stdin

var
  tape = newSeq[char]()
  jumpTable = newSeq[int]()
  codePos = 0
  tapePos = 0

{.push overflowchecks: off.}
proc xinc(c: var char) = inc c
proc xdec(c: var char) = dec c
{.pop.}

proc buildJumpTable() =
  for i in 0..<code.len:
    jumpTable.add i

  for startPos in 0..<code.len:
    if code[startPos] != '[':
      continue

    var
      nesting = 1
      pos = startPos + 1

    while pos < code.len:
      case code[pos]
      of '[': inc nesting
      of ']': dec nesting
      else: discard

      if nesting == 0:
        break

      inc pos

    jumpTable[startPos] = pos
    jumpTable[pos] = startPos

proc run() =
  while tapePos >= 0 and codePos < code.len:
    if tapePos >= tape.len:
      tape.add '\0'

    case code[codePos]
    of '+': xinc tape[tapePos]
    of '-': xdec tape[tapePos]
    of '.': stdout.write tape[tapePos]
    of ',': tape[tapePos] = stdin.readChar
    of '[': codePos = if tape[tapePos] == '\0': jumpTable[codePos] else: codePos
    of ']': codePos = if tape[tapePos] != '\0': jumpTable[codePos] else: codePos
    of '>': inc tapePos
    of '<': dec tapePos
    else: discard

    inc codePos

buildJumpTable()
run()
