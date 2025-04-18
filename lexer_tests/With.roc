module []

import Lexer

# multiple clauses
expect
    tokens =
        """
        with a <- true,
             b <- false do
          :ok
        end
        """
        |> Lexer.process()

    tokens
    == [
        TokenWith,
        TokenIdentifier "a",
        TokenLArrow,
        TokenTrue,
        TokenComma,
        TokenIdentifier "b",
        TokenLArrow,
        TokenFalse,
        TokenDo,
        TokenAtom "ok",
        TokenEnd,
        TokenEOF,
    ]

# guards
expect
    tokens =
        """
        with user when user != nil <- get_user() do
          :ok
        end
        """
        |> Lexer.process()

    tokens
    == [
        TokenWith,
        TokenIdentifier "user",
        TokenWhen,
        TokenIdentifier "user",
        TokenNotEquals,
        TokenNil,
        TokenLArrow,
        TokenIdentifier "get_user",
        TokenLParen,
        TokenRParen,
        TokenDo,
        TokenAtom "ok",
        TokenEnd,
        TokenEOF,
    ]

# else
expect
    tokens =
        """
        with user when user != nil <- get_user() do
          :ok
        else
          nil -> :error
          _ -> :other_error
        end
        """
        |> Lexer.process()

    tokens
    == [
        TokenWith,
        TokenIdentifier "user",
        TokenWhen,
        TokenIdentifier "user",
        TokenNotEquals,
        TokenNil,
        TokenLArrow,
        TokenIdentifier "get_user",
        TokenLParen,
        TokenRParen,
        TokenDo,
        TokenAtom "ok",
        TokenElse,
        TokenNil,
        TokenRArrow,
        TokenAtom "error",
        TokenIdentifier "_",
        TokenRArrow,
        TokenAtom "other_error",
        TokenEnd,
        TokenEOF,
    ]
