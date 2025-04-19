# Glass

A toy Elixir parser written in [Roc](https://www.roc-lang.org) to learn more about the language.

## Usage
TBD - not far enough along yet to get any real usage out of it.

## Running Tests
Other than the usual `roc test` that will run all of the tests in the import tree of the
project I have a file called `IntegrationTests.roc`. It runs integration tests against the
lexer and parser for all files in the testdata directory. You can run these test with `roc
test IntegrationTests.roc`.

## Status
Currently it can lex a great deal of the language, there are still a few keywords and
other syntax bits that will be added later on after I have built the parsing step out.
