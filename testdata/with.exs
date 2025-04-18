defmodule With do
  def elixir do
    with a <- true,
         b <- false do
      IO.puts("hello")
    end
  end

  def tokens do
    [
      {:TokenWith},
      {:TokenIdentifier, "a"},
      {:TokenLArrow},
      {:TokenTrue},
      {:TokenComma},
      {:TokenIdentifier, "b"},
      {:TokenLArrow},
      {:TokenFalse},
      {:TokenDo},
      {:TokenEnd},
      {:TokenEOF}
    ]
  end

  def ast do
  end
end
