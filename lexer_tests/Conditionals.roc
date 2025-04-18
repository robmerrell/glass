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
expect
    tokens =
        """
        cond do
          2 + 2 == 5 -> :no
          2 * 2 == 3 -> :no
          true -> :default
        end
        """
        |> Lexer.process()

    tokens
    == [
        TokenCond,
        TokenDo,
        TokenNumber "2",
        TokenPlus,
        TokenNumber "2",
        TokenEquals,
        TokenNumber "5",
        TokenRArrow,
        TokenAtom "no",
        TokenNumber "2",
        TokenMultiply,
        TokenNumber "2",
        TokenEquals,
        TokenNumber "3",
        TokenRArrow,
        TokenAtom "no",
        TokenTrue,
        TokenRArrow,
        TokenAtom "default",
        TokenEnd,
        TokenEOF,
    ]

# case
expect
    tokens =
        """
        case "str" do
          "str" -> :ok
          _ -> :default
        end
        """
        |> Lexer.process()

    tokens
    == [
        TokenCase,
        TokenString "str",
        TokenDo,
        TokenString "str",
        TokenRArrow,
        TokenAtom "ok",
        TokenIdentifier "_",
        TokenRArrow,
        TokenAtom "default",
        TokenEnd,
        TokenEOF,
    ]
