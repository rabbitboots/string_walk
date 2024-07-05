# StringProc

StringProc is an auxiliary module for StringWalk that parses strings according to grammar productions. The format is similar to, **but not fully compatible with** the version of eBNF that appears in the XML specification (see [6: Notation](https://www.w3.org/TR/REC-xml/#sec-notation)).


# API: StringProc

StringProc requires StringWalk to be in the same directory.

To simplify processing, grammar strings are converted to nested tables of strings. For example:

```
-- Input:
"foo bar (baz | bop) 'doop'?"

-- Becomes:
`{"foo", "bar", {"baz", "|", "bop"}, "'doop'", "?"}`
```


## stringProc.toTable

Converts a grammar production string to a table.

`local t = stringProc.toTable(s)`

* `s`: The production string to convert.

**Returns:** The converted table, to be used with `stringProc.traverse()`.

**Notes:**

* This function will raise an error if it encounters a problem with the string syntax.


## stringProc.traverse

Processes a string, following a grammar production table and a table of symbols.

`local res = stringProc.traverse(W, t, symbols)`

* `W`: The walker object, configured with the string to be processed and its start position.

* `t`: A production table for the string, having been created by `stringProc.toTable()`.

* `symbols`: A lookup table of symbols. (See [Symbols](#symbols) for more info.)

**Returns:** A table of return values, or false if the walker's string failed to match the grammar.


# API: StringProcDebug

Contains some diagnostic functions for StringProc.


### stringProcDebug.checkSymbols

Checks the types for keys and values in a symbol look-up table, raising a Lua error if a problem is encountered.

`stringProcDebug.checkSymbols(symbols)`

* `symbols`: The symbol look-up table. All keys must be strings, and all values must be one of: `string`, `number`, `function`, or boolean `true`.

**Notes:**

* This function halts on the first problem. While all keys in `symbols` are checked, the order is undefined.


### stringProcDebug.checkWords

Checks words in a production table against the keys in a symbol look-up table. Raises a Lua error if the symbol table does not have entries for all words in the production table.

`stringProcDebug.checkWords(symbols, t)`

* `symbols`: The symbol look-up table.

* `t`: The production table to check.

**Notes:**

* This function halts on the first problem.


# StringProc Notes

## Notation

### string literal

`"`/`'`: A string literal, enclosed in single or double quotes.

`"foo" 'bar'`

* "Empty" string literals are permitted: `''`, `""`

* There is no character escape mechanism.

* You can enclose one type of quote within another, like `"foo 'bar' baz"`.


### word

`[a-zA-Z0-9_]+`: Any non-empty string of latin letters, digits and underscores.

`foo`

* The word must be populated in the symbol lookup table. Unhandled words will raise an error.


### match zero or one

`?`: Permits zero or one matches of the preceding expression.

`foo?`


### match zero or many

`*`: Permits zero or many matches of the preceding expression.

`foo*`


### match one or many

`+`: Permits one or many matches of the preceding expression.

`foo+`


### group

`()`: A subgroup of tokens that are handled like one word.

`foo (bar baz) bop`

* Empty groups are permitted: `()`

* It's an error to have an unbalanced number of brackets: `a((b)`, `ab)c`


### alternate

`|`: Alternate choice.

`foo | bar`

* If *this* expression failed, try the next token in the group.

* If *this* expression succeeded, exit the group.

* It's an error when an alternate token is not followed by an expression: `foo |`, `foo | | bar`


## Precedence

From highest to lowest: `()` `A[?*+]` `A B` `A | B` `A - B`


## Traverse Return Tables

On success, `stringProc.traverse()` returns a table of values that were fetched while processing the string:

* Quoted string literals: appended with the quotes stripped.

* Group (Parentheses): If successful, group results are appended to this level's results table.

* Words: results are based on the symbol lookup table (see **Symbols** below).

On failure, `stringProc.traverse()` returns `false`.


## Symbols

The symbols look-up table controls how words are processed. The keys in this table match words in the production table, while the values determine the evaluation status of words. The values control what is included in the return table.

Values can be any of the following:

* `false/nil`: indicates a failure to process the word.

* `true`: indicates success, adding nothing to the results table.

* String, Number: indicates success, adding the value to the results table.

* Table: indicates success, and the table's array contents are pasted into the results table.

* Function:
  * Takes `W` (the walker) as its only argument.

  * Returns `false/nil`, `true`, a string, a number, or a table.

When a function returns a table, the second return value being `true` will cause the table itself to be added rather than its array contents. The second return value has no significance in other cases.

The function is expected to advance the walker's position.

Be careful about function side effects, as the return table's contents may be erased or go unused if an expression fails. Also, it's an error for the traversal function to encounter a word that is not populated in the symbols table.


## Infinite Loops

The parser can be tricked into reading the same chunks over and over. For example, the following production will loop endlessly (assume that 'never' returns `nil` every time):

`(never*)*`

Zero matches of 'never' is okay, so the outer group is continually successful.

Empty string literals (`'' ""`) will not advance the walker position, so they will match endlessly when paired with `*` or `+`.

To halt infinite loops, assign a large (but not too large) number to `stringProc._iter` before every top-level call to the parser. If the loop count exceeds this number, the parser will raise a Lua error.


## No Sets Or Ranges

There is no direct support for matching characters by set or range, like `[#x20-#xd7ff]`. Lua's built-in string engine works on characters as bytes, so it's not easy to match ranges of Unicode code points greater than U+007F, which can be two, three or four bytes in size when encoded as UTF-8.


## No 'Except' Token

There is no *except* token `-`. The XML spec's *except* is mostly used to describe forbidden substrings within larger runs of text.
