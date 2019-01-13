import os, docopt
import interpreter

when isMainModule:
  let doc = """
brainfuck

Usage:
  brainfuck interpret [--jit] [<file.b>]
  brainfuck (-h | --help)
  brainfuck (-v | --version)

Options:
  -h --help     Show this screen.
  -v --version  Show version.
  --jit         Enable JIT.
"""
  
  let args = docopt(doc, version = "brainfuck 1.0")

  if args["interpret"]:
    let code = if args["<file.b>"]: readFile($args["<file.b>"]) else: readAll stdin
    interpret(code, args["--jit"])
