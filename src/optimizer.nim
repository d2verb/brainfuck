import ir

proc optimizeZeroClear*(irs: seq[IRNode]): seq[IRNode] =
  var irPos = 0

  # detect zero clear loop ([+], [-])
  while irPos+2 < irs.len:
    if irs[irPos].kind != irOpen:
      result.add irs[irPos]
      irPos += 1
    elif irs[irPos+1].kind != irSub and irs[irPos+1].kind != irAdd:
      result.add irs[irPos]
      irPos += 1
    elif irs[irPos+1].val != 1:
      result.add irs[irPos]
      irPos += 1
    elif irs[irPos+2].kind != irClose:
      result.add irs[irPos]
      irPos += 1
    else:
      result.add IRNode(kind: irZeroClear)
      irPos += 3

  # add rest IRs
  while irPos < irs.len:
    result.add irs[irPos]
    inc irPos

  result.updateJumpTarget

proc optimizeMoveDataToLeft*(irs: seq[IRNode]): seq[IRNode] =
  var irPos = 0

  # detect move data to left loop ([-<+>])
  while irPos+5 < irs.len:
    if irs[irPos].kind != irOpen or irs[irPos+5].kind != irClose:
      result.add irs[irPos]
      irPos += 1
    elif irs[irPos+1].kind != irSub or irs[irPos+1].val != 1:
      result.add irs[irPos]
      irPos += 1
    elif irs[irPos+2].kind != irLeft or irs[irPos+3].kind != irAdd or irs[irPos+4].kind != irRight:
      result.add irs[irPos]
      irPos += 1
    elif irs[irPos+2].off != irs[irPos+4].off:
      result.add irs[irPos]
      irPos += 1
    else:
      result.add IRNode(kind: irMovLeft, off: irs[irPos+2].off)
      irPos += 6

  # add rest IRs
  while irPos < irs.len:
    result.add irs[irPos]
    inc irPos

  result.updateJumpTarget

proc optimizeMoveDataToRight*(irs: seq[IRNode]): seq[IRNode] =
  var irPos = 0

  # detect move data to left loop ([->+<])
  while irPos+5 < irs.len:
    if irs[irPos].kind != irOpen or irs[irPos+5].kind != irClose:
      result.add irs[irPos]
      irPos += 1
    elif irs[irPos+1].kind != irSub or irs[irPos+1].val != 1:
      result.add irs[irPos]
      irPos += 1
    elif irs[irPos+2].kind != irRight or irs[irPos+3].kind != irAdd or irs[irPos+4].kind != irLeft:
      result.add irs[irPos]
      irPos += 1
    elif irs[irPos+2].off != irs[irPos+4].off:
      result.add irs[irPos]
      irPos += 1
    else:
      result.add IRNode(kind: irMovRight, off: irs[irPos+2].off)
      irPos += 6

  # add rest IRs
  while irPos < irs.len:
    result.add irs[irPos]
    inc irPos

  result.updateJumpTarget
