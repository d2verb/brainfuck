type
  IRKind* = enum
    irAdd,
    irSub,
    irLeft,
    irRight,
    irIn,
    irOut,
    irOpen,
    irClose,
    irZeroClear,
    irMovLeft,
    irMovRight,

  IRNode* = ref object
    case kind*: IRKind
    of irAdd, irSub:
      val*: uint8
    of irLeft, irRight, irMovLeft, irMovRight:
      off*: int
    of irOpen, irClose:
      pos*: int
    else: discard

proc updateJumpTarget*(irs: seq[IRNode]) =
  for startPos in 0..<irs.len:
    if irs[startPos].kind != irOpen:
      continue

    var
      nesting = 1
      stopPos = startPos + 1

    while stopPos < irs.len:
      case irs[stopPos].kind
      of irOpen: inc nesting
      of irClose: dec nesting
      else: discard

      if nesting == 0:
        break

      inc stopPos

    irs[startPos].pos = stopPos
    irs[stopPos].pos = startPos

proc genIR*(code: string): seq[IRNode] =
  var prevCode = '\0'

  # generate IR
  for c in code:
    case c
    of '.': result.add IRNode(kind: irOut)
    of ',': result.add IRNode(kind: irIn)
    of '[': result.add IRNode(kind: irOpen, pos: 0)
    of ']': result.add IRNode(kind: irClose, pos: 0)
    of '+':
      if prevCode == '+':
        result[^1].val += 1
      else:
        result.add IRNode(kind: irAdd, val: 1)
    of '-':
      if prevCode == '-':
        result[^1].val += 1
      else:
        result.add IRNode(kind: irSub, val: 1)
    of '<':
      if prevCode == c:
        result[^1].off += 1
      else:
        result.add IRNode(kind: irLeft, off: 1)
    of '>':
      if prevCode == c:
        result[^1].off += 1
      else:
        result.add IRNode(kind: irRight, off: 1)
    else: discard
    prevCode = c

  result.updateJumpTarget
