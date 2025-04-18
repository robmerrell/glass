app [main!] { cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br" }

import cli.Stdout
import Lexer

main! = |_args|
    out = Lexer.process("a == 1")
    Stdout.line!(Inspect.to_str(out))

