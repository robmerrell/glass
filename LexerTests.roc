# TODO: document this module
module []

import Lexer

TestData : { elixir : Str, tokens : Str, ast : Str }

# test fixtures. I don't love building these into the parser, so this is just
# temporary until I know how to deal with side effects in modules.
import "testdata/with.exs" as with_test : Str

test_data =
    Dict.empty({})
    |> Dict.insert("with.exs", with_test)

# TODO: document this better
# converts tokens to a list that is proper elixir. Used for tests.
to_elixir_tuples = |tokens|
    List.walk(
        tokens,
        "",
        |state, token|
            # this is a bit hack, but we want this to be valid elixir.
            "${state}\n${token_to_elixir_tuple(token)}",
    )

token_to_elixir_tuple : Token -> Str
token_to_elixir_tuple = |token|
    when token is
        TokenIdentifier x -> "{:TokenIdentifier, \"${x}\"}"
        TokenNumber x -> "{:TokenNumber,\"${x}\"}"
        TokenString x -> "{:TokenString,\"${x}\"}"
        TokenAtom x -> "{:TokenAtom, \"${x}\"}"
        TokenIllegal _x -> "{:TokenIllegal}" # this value isn't important to the tests
        _ -> "{:${Inspect.to_str(token)}}"

expect
    dbg with_test
    with_test == "hi"

# # test_files = [
# #     "testdata/with.exs",
# # ]

# parse_test_data = |_|
#     { elixir: "1", tokens: "{:TokenNumber, \"1\"}{:TokenEOF}", ast: "" }

# parse_test_tokens = |input|
#     Lexer.process(input)
#     |> List.keep_if(
#         |token|
#             when token is
#                 TokenLBrace -> Bool.false
#                 TokenRBrace -> Bool.false
#                 _ -> Bool.true,
#     )

# expect
#     test_data = parse_test_data("testdata/with.exs")
#     # tokens = Lexer.process(test_data.elixir)

#     normal = parse_test_tokens(test_data.tokens)
#     normal == [TokenEOF]

a = 1
