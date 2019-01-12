# Package

version       = "1.0.0"
author        = "d2verb"
description   = "A brainfuck interpreter"
license       = "MIT"
srcDir        = "src"
bin           = @["brainfuck"]


# Dependencies

requires "nim >= 0.19.9"
requires "docopt >= 0.1.0"

task clean, "Clean all artifacts":
  exec "rm -f brainfuck"
