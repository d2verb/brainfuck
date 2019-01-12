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

## Reference
[1] http://howistart.org/posts/nim/1/index.html

[2] https://postd.cc/adventures-in-jit-compilation-part-1-an-interpreter/
