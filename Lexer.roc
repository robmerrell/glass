module [process]

Token : [
    # math
    TokenAssign,
    TokenPlus,
    TokenPlusEquals,
    TokenMinus,
    TokenMinusEquals,
    TokenMultiply,
    TokenMultiplyEquals,
    TokenDivide,
    TokenDivideEquals,
    TokenEquals,
    TokenNotEquals,
    TokenGreaterThan,
    TokenGreaterThanEquals,
    TokenLessThan,
    TokenLessThanEquals,

    # surrounds
    TokenLParen,
    TokenRParen,
    TokenLBrace,
    TokenRBrace,
    TokenLBracket,
    TokenRBracket,
    TokenMapOpen,

    # other symbols
    TokenComma,
    TokenColon,
    TokenRArrow,
    TokenLArrow,
    TokenDoubleArrow,
    TokenExclamation,

    # types
    TokenNumber Str,
    TokenString Str,
    TokenAtom Str,

    # conditionals
    TokenIf,
    TokenWhen,
    TokenCase,
    TokenCond,
    TokenElse,
    TokenWith,

    # structure
    TokenDo,
    TokenEnd,
    TokenIdentifier Str,
    TokenModule,
    TokenPublicFunc,
    TokenPrivateFunc,
    TokenEOF,

    TokenTrue,
    TokenFalse,
    TokenNil,

    TokenIllegal U8,
    TokenUnused, # spaces, newlines, tabs, etc.
]

State : { input : List U8, tokens : List Token, position : U64 }

keywords =
    Dict.empty({})
    |> Dict.insert("defmodule", TokenModule)
    |> Dict.insert("def", TokenPublicFunc)
    |> Dict.insert("defp", TokenPrivateFunc)
    |> Dict.insert("do", TokenDo)
    |> Dict.insert("end", TokenEnd)
    |> Dict.insert("if", TokenIf)
    |> Dict.insert("when", TokenWhen)
    |> Dict.insert("case", TokenCase)
    |> Dict.insert("cond", TokenCond)
    |> Dict.insert("else", TokenElse)
    |> Dict.insert("with", TokenWith)
    |> Dict.insert("true", TokenTrue)
    |> Dict.insert("false", TokenFalse)
    |> Dict.insert("nil", TokenNil)

## Process the given input and generate a list of tokens
process : Str -> List Token
process = |input|
    input_code_units = Str.to_utf8(input)
    state = process_state({ input: input_code_units, tokens: [], position: 0 })
    state.tokens

expect
    tokens = process("()[]=")
    tokens == [TokenLParen, TokenRParen, TokenLBracket, TokenRBracket, TokenAssign, TokenEOF]

expect
    tokens = process("+-*/<>! == !=")
    tokens == [TokenPlus, TokenMinus, TokenMultiply, TokenDivide, TokenLessThan, TokenGreaterThan, TokenExclamation, TokenEquals, TokenNotEquals, TokenEOF]

expect
    tokens = process("+= -= *= /= <= >=")
    tokens == [TokenPlusEquals, TokenMinusEquals, TokenMultiplyEquals, TokenDivideEquals, TokenLessThanEquals, TokenGreaterThanEquals, TokenEOF]

expect
    tokens = process("-> <- =>")
    tokens == [TokenRArrow, TokenLArrow, TokenDoubleArrow, TokenEOF]

expect
    tokens = process(" 100 + 2.1423 ")
    tokens == [TokenNumber "100", TokenPlus, TokenNumber "2.1423", TokenEOF]

expect
    tokens = process("%{a: 1, \"b\" => 3}")
    tokens
    == [
        TokenMapOpen,
        TokenIdentifier "a",
        TokenColon,
        TokenNumber "1",
        TokenComma,
        TokenString "b",
        TokenDoubleArrow,
        TokenNumber "3",
        TokenRBrace,
        TokenEOF,
    ]

expect
    tokens =
        """
        defmodule hello     do
          def say_hello(name) do
          end
        end
        """
        |> process()

    tokens == [TokenModule, TokenIdentifier "hello", TokenDo, TokenPublicFunc, TokenIdentifier "say_hello", TokenLParen, TokenIdentifier "name", TokenRParen, TokenDo, TokenEnd, TokenEnd, TokenEOF]

expect
    tokens = process("\"testing an easy string()!\"")
    tokens == [TokenString "testing an easy string()!", TokenEOF]

expect
    tokens = process(":atom :")
    tokens == [TokenAtom "atom", TokenColon, TokenEOF]

# process the input from the state until we reach an EOF
process_state : State -> State
process_state = |state|
    # read a token and add it to a list
    (read_length, token) = next_token(state)

    # toss out the unused tokens. This turned out to be convenient, but probably not the most
    # performant approach to tossing out intentionally unused characters like whitespace. I think I
    # understand now why people just pass state around and modify it everywhere instead of modifying it
    # in just a few functions...
    tokens =
        when token is
            TokenUnused -> state.tokens
            _ -> List.append(state.tokens, token)

    updated_state = { state & tokens: tokens, position: state.position + read_length }

    if token == TokenEOF then
        updated_state
    else
        process_state(updated_state)

# extracts the next token from the input at the current read position. The length of the input used to
# consume the token is returned along with the token itself.
next_token : State -> (U64, Token)
next_token = |state|
    when read_char(state) is
        '=' ->
            when peek(state) is
                '=' -> (2, TokenEquals)
                '>' -> (2, TokenDoubleArrow)
                _ -> (1, TokenAssign)

        '+' ->
            when peek(state) is
                '=' -> (2, TokenPlusEquals)
                _ -> (1, TokenPlus)

        '-' ->
            when peek(state) is
                '=' -> (2, TokenMinusEquals)
                '>' -> (2, TokenRArrow)
                _ -> (1, TokenMinus)

        '*' ->
            when peek(state) is
                '=' -> (2, TokenMultiplyEquals)
                _ -> (1, TokenMultiply)

        '/' ->
            when peek(state) is
                '=' -> (2, TokenDivideEquals)
                _ -> (1, TokenDivide)

        '<' ->
            when peek(state) is
                '=' -> (2, TokenLessThanEquals)
                '-' -> (2, TokenLArrow)
                _ -> (1, TokenLessThan)

        '>' ->
            when peek(state) is
                '=' -> (2, TokenGreaterThanEquals)
                _ -> (1, TokenGreaterThan)

        '!' ->
            when peek(state) is
                '=' -> (2, TokenNotEquals)
                _ -> (1, TokenExclamation)

        '%' ->
            when peek(state) is
                '{' -> (2, TokenMapOpen)
                _ -> (1, TokenIllegal '%')

        '(' -> (1, TokenLParen)
        ')' -> (1, TokenRParen)
        '[' -> (1, TokenLBracket)
        ']' -> (1, TokenRBracket)
        '{' -> (1, TokenLBrace)
        '}' -> (1, TokenRBrace)
        ',' -> (1, TokenComma)
        ':' ->
            next = peek(state)
            if is_identifier_part(next) then
                atom = read_identifier({ state & position: state.position + 1 })
                atom_string = Str.from_utf8_lossy(atom)
                (List.len(atom) + 1, TokenAtom atom_string)
            else
                (1, TokenColon)

        ' ' -> (1, TokenUnused)
        '\n' -> (1, TokenUnused)
        '\t' -> (1, TokenUnused)
        '"' ->
            code_units = read_string(state)
            str = Str.from_utf8_lossy(code_units)
            (List.len(code_units) + 2, TokenString str) # adding 2 for opening and closing "

        0 -> (1, TokenEOF)
        char ->
            if is_identifier_beginning(char) then
                ident = read_identifier(state)
                ident_string = Str.from_utf8_lossy(ident)

                # if the identifier is a keyword use the keyword token. Otherwise a generic identifier token
                return_token =
                    when Dict.get(keywords, ident_string) is
                        Ok token -> token
                        Err _ -> TokenIdentifier ident_string

                (List.len(ident), return_token)
            else if is_number(char) then
                num = read_number(state)
                num_string = Str.from_utf8_lossy(num)

                (List.len(num), TokenNumber num_string)
            else
                (1, TokenIllegal char)

peek = |state|
    List.get(state.input, state.position + 1) ?? 0

# reads a character. If we can't get the char then 0 (EOF) is returned
read_char : State -> U8
read_char = |state|
    List.get(state.input, state.position) ?? 0

# consumes from the input until a full identifier is read
read_identifier : State -> List U8
read_identifier = |state|
    # walk and collect the input characters until it's no longer an identifier
    List.walk_from_until(
        state.input,
        state.position,
        [],
        |identifier, char|
            if is_identifier_part(char) then
                Continue List.append(identifier, char)
            else
                Break identifier,
    )

expect
    input = "defmodule hello"
    identifier = read_identifier({ input: Str.to_utf8(input), tokens: [], position: 0 })
    identifier == Str.to_utf8("defmodule")

read_number : State -> List U8
read_number = |state|
    # walk and collect the input characters until it's no longer a valid number
    List.walk_from_until(
        state.input,
        state.position,
        [],
        |number, char|
            if is_number(char) or char == '.' or char == '_' then
                Continue List.append(number, char)
            else
                Break number,
    )

expect
    int = read_number({ input: Str.to_utf8("12345"), tokens: [], position: 0 })
    int == Str.to_utf8("12345")

expect
    int = read_number({ input: Str.to_utf8("12_345"), tokens: [], position: 0 })
    int == Str.to_utf8("12_345")

expect
    float = read_number({ input: Str.to_utf8("12.345"), tokens: [], position: 0 })
    float == Str.to_utf8("12.345")

# baby steps with strings, ignore interpolation for now
read_string : State -> List U8
read_string = |state|
    List.walk_from_until(
        state.input,
        state.position + 1, # increment past the initial "
        [],
        |str, code_unit|
            prev_code_unit = List.last(str) ?? 0
            if code_unit == '"' and prev_code_unit != '\\' then
                Break str
            else
                Continue List.append(str, code_unit),
    )

expect
    str = read_string({ input: Str.to_utf8("\"hello!\""), tokens: [], position: 0 })
    str == Str.to_utf8("hello!")

expect
    str = read_string({ input: Str.to_utf8("\"hello, \\\"Bilbo Baggins\\\"!\""), tokens: [], position: 0 })
    str == Str.to_utf8("hello, \\\"Bilbo Baggins\\\"!")

# identifiers in elixir can only begin with letters or _. This might be doing too much and better moved
# to the parser instead.
is_identifier_beginning : U8 -> Bool
is_identifier_beginning = |code_unit|
    is_letter(code_unit) or code_unit == '_'

expect is_identifier_beginning('a') == Bool.true
expect is_identifier_beginning('_') == Bool.true
expect is_identifier_beginning('1') == Bool.false

is_identifier_part : U8 -> Bool
is_identifier_part = |code_unit|
    is_letter(code_unit) or is_number(code_unit) or is_valid_punctuation(code_unit)

is_number : U8 -> Bool
is_number = |code_unit|
    code_unit >= '0' and code_unit <= '9'

expect is_number('1') == Bool.true
expect is_number('a') == Bool.false

is_letter : U8 -> Bool
is_letter = |code_unit|
    (code_unit >= 'a' and code_unit <= 'z') or (code_unit >= 'A' and code_unit <= 'Z')

expect is_letter('a') == Bool.true
expect is_letter('?') == Bool.false

is_valid_punctuation : U8 -> Bool
is_valid_punctuation = |code_unit|
    code_unit == '_' or code_unit == '?' or code_unit == '!' or code_unit == '.'

