module []

import Lexer

# if
expect
    tokens =
        """
        if a == 1 do
          :one
        else if a == 2 do
          :two
        else
          :else
        end
        """
        |> Lexer.process()

    tokens
    == [
        TokenIf,
        TokenIdentifier "a",
        TokenEquals,
        TokenNumber "1",
        TokenDo,
        TokenAtom "one",
        TokenElse,
        TokenIf,
        TokenIdentifier "a",
        TokenEquals,
        TokenNumber "2",
        TokenDo,
        TokenAtom "two",
        TokenElse,
        TokenAtom "else",
        TokenEnd,
        TokenEOF,
    ]

# cond

# case
