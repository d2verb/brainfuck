type
  CodeSeq* {.bycopy.} = object
    code*: ptr uint8
    len*: uint64
    cap*: uint64

proc newCodeSeq*(): ptr CodeSeq {.dynlib: "./libpicojit.so", importc: "newCodeSeq".}
proc delCodeSeq*(cs: ptr CodeSeq) {.dynlib: "./libpicojit.so", importc: "delCodeSeq".}
proc emitU8*(cs: ptr CodeSeq; v: uint8) {.dynlib: "./libpicojit.so", importc: "emitU8".}
proc emitU8s*(cs: ptr CodeSeq; n: int32) {.dynlib: "./libpicojit.so", importc: "emitU8s", varargs.}
proc emitU32*(cs: ptr CodeSeq; v: uint32) {.dynlib: "./libpicojit.so", importc: "emitU32".}
proc emitU64*(cs: ptr CodeSeq; v: uint64) {.dynlib: "./libpicojit.so", importc: "emitU64".}
proc replU8At*(cs: ptr CodeSeq; off: uint64; v: uint8) {.dynlib: "./libpicojit.so", importc: "replU8At".}
proc replU32At*(cs: ptr CodeSeq; off: uint64; v: uint32) {.dynlib: "./libpicojit.so", importc: "replU32At".}
proc execCode*(cs: ptr CodeSeq) {.dynlib: "./libpicojit.so", importc: "execCode".}
proc calcRel32Off*(jfrom: uint64; jto: uint64): uint32 {.dynlib: "./libpicojit.so", importc: "calcRel32Off".}
