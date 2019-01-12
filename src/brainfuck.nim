import os, docopt
import interpreter

when isMainModule:
  let doc = """
brainfuck

Usage:
  brainfuck interpret [<file.b>]
  brainfuck (-h | --help)
  brainfuck (-v | --version)

Options:
  -h --help     Show this screen.
  -v --version  Show version.
"""
  
  let args = docopt(doc, version = "brainfuck 1.0")

  if args["interpret"]:
    let code = if args["<file.b>"]: readFile($args["<file.b>"]) else: readAll stdin
    interpret(code)
