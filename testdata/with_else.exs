# elixir
with user when user != nil <- get_user() do
  :ok
else
  nil -> :error
  _ -> :other_error
end

# tokens
:TokenWith
{:TokenIdentifier, "user"}
:TokenWhen
{:TokenIdentifier, "user"}
:TokenNotEquals
:TokenNil
:TokenLArrow
{:TokenIdentifier, "get_user"}
:TokenLParen
:TokenRParen
:TokenDo
{:TokenAtom, "ok"}
:TokenElse
:TokenNil
:TokenRArrow
{:TokenAtom, "error"}
{:TokenIdentifier, "_"}
:TokenRArrow
{:TokenAtom, "other_error"}
:TokenEnd
:TokenEOF

# ast
