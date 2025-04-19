# elixir
with a <- true,
     b <- false do
  :ok
end

# tokens
:TokenWith
{:TokenIdentifier, "a"}
:TokenLArrow
:TokenTrue
:TokenComma
{:TokenIdentifier, "b"}
:TokenLArrow
:TokenFalse
:TokenDo
{:TokenAtom, "ok"}
:TokenEnd
:TokenEOF

# ast
