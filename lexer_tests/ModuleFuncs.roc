module []

import Lexer

# module and functions
expect
    tokens =
        """
        defmodule Scope1.Scope2.Scope3 do
          def func(a) do
            a
          end

          defp func2(b) do
            b
          end
        end
        """
        |> Lexer.process()

    tokens
    == [
        TokenModule,
        TokenIdentifier "Scope1.Scope2.Scope3",
        TokenDo,
        TokenPublicFunc,
        TokenIdentifier "func",
        TokenLParen,
        TokenIdentifier "a",
        TokenRParen,
        TokenDo,
        TokenIdentifier "a",
        TokenEnd,
        TokenPrivateFunc,
        TokenIdentifier "func2",
        TokenLParen,
        TokenIdentifier "b",
        TokenRParen,
        TokenDo,
        TokenIdentifier "b",
        TokenEnd,
        TokenEnd,
        TokenEOF,
    ]

