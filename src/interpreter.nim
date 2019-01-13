import os
import ir
import optimizer
import picojit

proc interpret*(code: string, jit: bool) =
  # JIT
  proc runJIT(code: string) =
    var
      codePos = 0
      tape: array[1_000_000, uint8]
      tapeAddr = cast[uint64](addr(tape))
      openStack = newSeq[uint64]()
      cs = newCodeSeq()

    # movabs tapeAddr, %r13
    cs.emitU8s(2, 0x49, 0xbd)
    cs.emitU64(tapeAddr)

    while codePos < code.len:
      case code[codePos]
      of '<': cs.emitU8s(3, 0x49, 0xff, 0xc5)             # dec %r13
      of '>': cs.emitU8s(3, 0x49, 0xff, 0xcd)             # inc %r13
      of '+': cs.emitU8s(5, 0x41, 0x80, 0x45, 0x00, 0x01) # addb $1, 0(%r13)
      of '-': cs.emitU8s(5, 0x41, 0x80, 0x6d, 0x00, 0x01) # subb $1, 0(%r13)
      of '.':
        # mov $1, %rax
        # mov $1, %rdi
        # mov %r13, %rsi
        # mov $1, %rdx
        # syscall
        cs.emitU8s(7, 0x48, 0xc7, 0xc0, 0x01, 0x00, 0x00, 0x00)
        cs.emitU8s(7, 0x48, 0xc7, 0xc7, 0x01, 0x00, 0x00, 0x00)
        cs.emitU8s(3, 0x4c, 0x89, 0xee)
        cs.emitU8s(7, 0x48, 0xc7, 0xc2, 0x01, 0x00, 0x00, 0x00)
        cs.emitU8s(2, 0x0f, 0x05)
      of ',':
        # mov $0, %rax
        # mov $1, %rdi
        # mov %r13, %rsi
        # mov $1, %rdx
        # syscall
        cs.emitU8s(7, 0x48, 0xc7, 0xc0, 0x00, 0x00, 0x00, 0x00)
        cs.emitU8s(7, 0x48, 0xc7, 0xc7, 0x00, 0x00, 0x00, 0x00)
        cs.emitU8s(3, 0x4c, 0x89, 0xee)
        cs.emitU8s(7, 0x48, 0xc7, 0xc2, 0x01, 0x00, 0x00, 0x00)
        cs.emitU8s(2, 0x0f, 0x05)
      of '[':
        cs.emitU8s(5, 0x41, 0x80, 0x7d, 0x00, 0x00) # cmpb $0, 0(%r13)
        openStack.add cs.len
        cs.emitU8s(2, 0x0f, 0x84) # jz
        cs.emitU32(0)
      of ']':
        let
          openOff = openStack.pop
        cs.emitU8s(5, 0x41, 0x80, 0x7d, 0x00, 0x00)

        let
          jumpBackFrom = cs.len + 6
          jumpBackTo = openOff + 6
          pcRelOffBack = calcRel32Off(jumpBackFrom, jumpBackTo)

        cs.emitU8s(2, 0x0f, 0x85)
        cs.emitU32(pcRelOffBack)

        let
          jumpForwardFrom = openOff + 6
          jumpForwardTo = cs.len
          pcRelOffForward = calcRel32Off(jumpForwardFrom, jumpForwardTo)

        cs.replU32At(openOff+2, pcRelOffForward)
      else: discard
      inc codePos

    # ret
    cs.emitU8(0xc3)

    cs.execCode
    cs.delCodeSeq

  # no JIT
  proc run(irs: seq[IRNode]) =
    var
      tape = newSeq[uint8]()
      irPos = 0
      tapePos = 0

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

  if jit:
    code.runJIT
  else:
    code.genIR.optimizeZeroClear.optimizeMoveDataToLeft.optimizeMoveDataToRight.run
