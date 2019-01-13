## What's this?
A simple brainfuck interpreter with loop optimization.

To try this, you have to install nimlang (https://nim-lang.org/).

## How to use
```
$ git clone https://github.com/d2verb/brainfuck
$ cd brainfuck
$ nimble build -d:release
$ ./brainfuck interpret examples/helloworld.b
Hello World!
```

## Benchmark
**hanoi.b**
```
$ time ./brainfuck interpret exmaples/hanoi.b
./brainfuck interpret examples/hanoi.b  20.50s user 0.01s system 99% cpu 20.513 total
$ time ./brainfuck interpret --jit exmaples/hanoi.b
./brainfuck interpret --jit examples/hanoi.b  14.09s user 0.04s system 99% cpu 14.132 total
```
Winner is JIT version.

**hanoi.b(build with release mode)**
```
$ time ./brainfuck interpret exmaples/hanoi.b
./brainfuck interpret examples/hanoi.b  5.74s user 0.00s system 99% cpu 5.749 total
$ time ./brainfuck interpret --jit exmaples/hanoi.b
./brainfuck interpret --jit examples/hanoi.b  14.04s user 0.04s system 99% cpu 14.082 total
```
Winner is normal version.

|build mode|normal|JIT|
|-|-|-|
|none|20.50s|**14.09s**|
|release|**5.749s**|14.04s|

## Reference
[1] http://howistart.org/posts/nim/1/index.html

[2] https://postd.cc/adventures-in-jit-compilation-part-1-an-interpreter/
