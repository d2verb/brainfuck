import os
import ir
import optimizer

proc interpret*(code: string) =
  var
    tape = newSeq[uint8]()
    irPos = 0
    tapePos = 0

  proc run(irs: seq[IRNode]) =
    while tapePos >= 0 and irPos < irs.len:
      while tape.len - 1 < tapePos:
        tape.add 0

      case irs[irPos].kind
      of irAdd: tape[tapePos] += irs[irPos].val
      of irSub: tape[tapePos] -= irs[irPos].val
      of irLeft: tapePos -= irs[irPos].off
      of irRight: tapePos += irs[irPos].off
      of irOpen: irPos = if tape[tapePos] == 0: irs[irPos].pos else: irPos
      of irClose: irPos = if tape[tapePos] != 0: irs[irPos].pos else: irPos
      of irIn: tape[tapePos] = uint8(stdin.readChar)
      of irOut: stdout.write char(tape[tapePos])
      of irZeroClear: tape[tapePos] = 0
      of irMovLeft:
        tape[tapePos-irs[irPos].off] += tape[tapePos]
        tape[tapePos] = 0
      of irMovRight:
        tape[tapePos+irs[irPos].off] += tape[tapePos]
        tape[tapePos] = 0

      inc irPos

  code.genIR.optimizeZeroClear.optimizeMoveDataToLeft.optimizeMoveDataToRight.run
