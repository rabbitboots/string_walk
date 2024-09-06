**Version:** 2.1.1

# StringWalk

Wrappers for Lua string functions.

Tested with Lua 5.1.5, Lua 5.2.4, Lua 5.3.6, Lua 5.4.6 and LuaJIT 2.1.1707061634 on Fedora 39, and Lua 5.1.5 on Windows 10.

## Behavior

StringWalk provides a *walker* object which ties Lua search methods to an internal position index. Generally, when a search is successful, the position advances past the match region, and when unsuccessful, it stays put (or throws an error.)

### Terms

* Continuation byte: The second, third or fourth byte of a code point that is encoded in UTF-8.

* EOS: End of String, as represented by the byte position index being greater than the walker's bound string.

# Example

```lua
local W = stringWalk.new("foobar")
local first = W:litReq("foo", "Missing crucial 'foo'")
local second = W:litReq("bar", "Missing irreplacable 'bar'")

print(first, second)
```


# StringWalk API

## stringWalk.new

Creates a new walker object.

`local W = stringWalk.new([s])`

* `[s]`: An optional string to assign. If not provided, the walker will start with an empty string.

**Returns:** The walker object.


## stringWalk.countLineChar

Returns the line and character numbers for a given byte position in a UTF-8 string.

`local ln, cn  = function stringWalk.countLineChar(s, i, j, ln, cn)`

* `s`: The string to scan.

* `i`: The byte position in the string.

* `j`: Where to start scanning in the string (use 1 on the first call).

* `ln`: The initial line number to use for this call (use 1 for the first call).

* `cn`: The initial character number to use for this call (use 1 for the first call).

**Returns:** The line and character number for the input position.

**Notes:**

* The input string is expected to be valid UTF-8.

* This function can be used instead of `Walker:getLineCharNumbers()` if you are collecting sequential line and character numbers in a loop. While the walker method begins counting from the first byte every time, this function can start from any valid UTF-8 start byte.

* This function performs no safety checks on the input. For each call:
  * All numbers should be integers
  * `j` should be less than or equal to `i`

* Behavior if `i` is out of bounds:
  * Less than 1: Returns line 1, char 1
  * Greater than `#s`: Returns line 1, char `#s` + 1


# Walker Methods

## W:newString

Assigns a new string to the walker, resets the position to 1, and empties the string stack.

`W:newString(s)`

* `s`: The new string to assign.


## W:reset

Resets the position to 1 and empties the string stack.

`W:reset()`


## W:setTerseMode

Sets *Terse Mode*. When active, error messages display only a generic message, with no positional information (byte index, line number or character number).

`W:setTerseMode(enabled)`

* `enabled`: `true` to enable Terse Mode, `false/nil` to disable it.


## W:setByteMode

Toggles *Byte Mode*. When active, the walker position is reported in warnings and errors as a byte index. Use this when the walker's string contains arbitrary data.

`W:setByteMode(enabled)`

* `enabled`: `true` to enable Byte Mode, `false/nil` to disable it.

**Notes:**

* *Terse Mode* overrides this setting.


## W:setLineCharDisplay

Toggles the printing of line and character numbers in warnings and errors.

`W:setLineCharDisplay(line, char)`

* `line`: `true` to enable the printing of line numbers, `false/nil` to disable it.

* `char`: `true` to enable the printing of character numbers, `false/nil` to disable it.

**Notes:**

* *Byte Mode* and *Terse Mode* both override these settings.


## W:find

Calls `string.find()` at the current position. If a match is found, returns the `i` and `j` indices and captures, and advances the position past `j`.

`local i, j, [captures...] = W:find(ptn)`

* `ptn`: The pattern string for `string.find()`.

**Returns:** The string index boundaries of the find, and up to 16 captures, or `nil` if there wasn't a match.


### W:findReq

Like W:find(), but raises an error if the search is unsuccessful.

`local i, j, [captures...] = W:findReq(ptn, [err])`


## W:plain

Like `W:find()`, but the search is conducted with `string.find()`'s *plain mode* active. All pattern-matching magic characters are treated as plain characters. As such, this method does not support captures.

`local i, j = W:plain(ptn)`

* `ptn`: The pattern string for `string.find()`.

**Returns:** The string index boundaries of the find, or `nil` if there wasn't a match.


## W:plainReq

Like `W:plain()`, but raises an error if the search was unsuccessful.

`local i, j = W:plainReq(ptn, [err])`


## W:lit

Compares a substring at the walker's position against a string literal. If a match is found, returns the string and advances the walker's position. If not, returns `nil`.

`local match = W:lit(s)`

* `s`: The string literal to compare.

**Returns:** The match if successful, `nil` otherwise.

**Notes:**

* The search is anchored to the walker's position. To search the remainder of the string for a string literal, use `string.find()` / `W:find[Req]()` in *plain mode*.

* The successful return value is always the same as the `s` argument. This allows for short circuit evaluations (like `foo = a and W:lit("xyz") or c`).


### W:litReq

Like W:lit(), but raises an error if the search is unsuccessful.

`W:litReq(str, [err])`


## W:match

Calls `string.find()` at the current position. If a match is found, returns the captures (or the whole result, if the pattern contained no captures) and advances the position.

`local <captures...> = W:match(ptn)`

* `ptn`: The pattern string for `string.find()`.

**Returns:** The match or up to 16 captures, or `nil` if there wasn't a match.

**Notes:**

* Uses `string.find()` internally, not `string.match()`, because of a need to advance the walker's position. The return values are modified so that it behaves like `string.match()`, returning the full match if no captures were specified.


### W:matchReq

Like W:match(), but raises a Lua error if the search is unsuccessful.

`local <captures...> = W:matchReq(ptn, [err])`


## W:seek

Sets the walker byte position, clamped between `1` and `#str + 1`.

`local i = W:seek(n)`

* `n`: The new byte position.

**Returns:** The new byte position.

**Notes:**

* This method can move the walker to a UTF-8 *continuation byte*.


## W:step

Moves the walker byte position back or forward. The final position is clamped between `1` and `#str + 1`.

`local i = W:step(n)`

* `n`: How many bytes to advance or rewind (negative).

**Returns:** The new byte position.

**Notes:**

* This method can move the walker to a UTF-8 *continuation byte*.


## W:peek

Gets a substring from the walker's current position to an offset in bytes. Does not advance the walker.

`local sub_str = W:peek([n])`

* `[n]`: *(1)* How many bytes to read from the walker's position. A value of 1 will return the current byte.

**Returns:** The substring.

**Notes:**

* If the walker position is end-of-string, then an empty string is returned. This would be similar to receiving an empty string from `string.sub("foobar", 7, 7)`.

* It's an error to provide an offset of zero or less, or a fractional value.


## W:bytes

Gets a substring from the walker's position to an offset in bytes. If the offset is end-of-string (for example, attempting to get 5 bytes from the string "foo"), then `nil` is returned.

`local sub_str = W:bytes([n])`

* `n`: *(1)* How many bytes to read from the walker's position.

**Returns:** The substring, or `nil` if the offset goes beyond the end of the string.

**Notes:**

* It's an error to provide an offset of zero or less, or a fractional value.


### W:bytesReq

Like W:bytes(), but raises a Lua error if the search is unsuccessful.

`local sub_str = W:bytesReq([n], err)`


## W:ws

Advances the walker position past ASCII whitespace until it either rests on a non-whitespace byte or reaches end-of-string.

`local advanced = W:ws()`

**Returns:** `true` if the walker position advanced, `false` if not.


### W:wsReq

Like W:ws(), but raises a Lua error if the position did not advance.

`W:wsReq([err])`


## W:wsNext

If the walker is currently on a non-whitespace character, advances to the next bit of whitespace, or to the end of the string if none is found. Does not advance if the walker is already on whitespace.

`W:wsNext()`


## W:isEOS

Reports if the walker position is end-of-string.

`local eos = W:isEOS()`

**Returns:** `true` if the walker position is end-of-string, `false` if not.


## W:goEOS

Moves the walker position to end-of-string.

`W:goEOS()`


## W:error

Raises a Lua error. Depending on the walker's configuration, a line and character number may be included in the output. If the walker is in Terse Mode, then a basic *parsing failed* message will be displayed instead.

`W:error([str], [level])`

* `[str]`: The error string to pass to `error()`. `tostring()` is used to ensure that a string will always be passed to `error()`.

* `[level]`: *(2)* The stack level to pass to `error()`.

**Notes:**

* When invoked in a failed `pcall()`, The walker's state is not automatically cleaned up.


## W:warn

Prints a warning message. Depending on the walker's configuration, a line and character number may be included in the output. If the walker is in Terse Mode, no message is printed.

`W:warn(...)`

* `...`: Arguments for `print()`, which is called after the line and character number output (if enabled).


## W:getLineCharNumbers

Gets a line and character number for the walker's position. If there are stack frames, then the lowest stack position is used. *Only valid for correctly encoded UTF-8 strings.*

`local ln, cn = W:getLineCharNumbers()`

**Returns:** The walker's line number and character number.


**Notes:**

* This method counts from the beginning of the string for every call. To count line and character numbers incrementally, see the function `stringWalk.countLineChar()`.


## W:getIndex

Gets the walker's position in bytes. If there are stack frames, then the lowest stack position is used.

`local i = W:getIndex()`

**Returns:** Byte index of the walker in the string.

**Notes:**

* The walker's current byte index can be read directly at `W.I`. This may be wanted instead of the position of the lowest stack frame.


## W:_status

Prints the walker's byte offset and line + character number, and the internal counters for lines, characters and bytes. Intended for debugging.

`W:_status()`


## W:req

The assertion method used by the `*Req` method variations. Raises a Lua error if the first return value is `nil/false`.

`local a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r = W:req(fn, [err], ...)`

* `fn`: The function to call. It takes a walker object as its first argument, and `...` as its remaining arguments.

* `[err]`: An error string to print if the call to `fn` is unsuccessful. If not specified, a generic error message will be used instead.

* `...`: Additional arguments for `fn`.

**Returns:** Up to 18 values returned by `fn`.


## W:assert

A general assertion method. Raises a Lua error if `exp` evaluates to false.

`local retval = W:assert(exp, [err])`

* `exp`: The expression to evaluate.

* `[err]`: The error message to display if `exp` does not evaluate to true.

**Returns:** the result of `exp`, for the convenience of variable assignment.


## W:push

Pushes a new string onto the walker object, moving the existing string and position into a stack. The walker's position becomes 1.

`W:push(str)`

* `str`: The new string to push.


## W:pop

Pops the last string and position from the stack.

`W:pop()`

**Notes:**

* Stack frames are not automatically popped when reaching end-of-string.

* It's an error to call this on an empty stack.


## W:popAll

Pops all strings from the stack.

`W:popAll()`

**Notes:**

* Unlike `W:pop()`, this method does not raise an error when the stack is empty.


# StringWalk Notes

## Field Names

It's convenient to attach state to a walker object while parsing. Besides method names, the following field names are **reserved for internal use**:

* Any field that is a single upper-case ASCII letter (A-Z)

* Any field that begins with an underscore


## 16 Captures

The limit of 16 returned captures is not connected to Lua's actual maximum returnable captures; it is a limitation of the library. Captures #17 and up may be correctly processed by `string.find()` and `string.match()`, but they will not be returned by the walker methods.


## Req methods

Methods ending in `req` will raise a Lua error when unsuccessful. These methods take an optional argument, `err`, for the error string. If `err` is not provided, a generic error message will be used instead. As with Lua's `assert()` function, avoid constructing the error string directly within the method call, as those arguments will be evaluated even if the method is successful:

```lua
local chunk = W:matchReq("foobar", "missing foobar for " .. some_upvalue)
--                                                       ^
--                                            This executes every time!
```


## Whitespace characters

* Out of concern for locale settings potentially affecting Lua's character classes, the StringWalk whitespace methods use sets of the standard ASCII whitespace instead of `%s`. These sets are stored in the fields `stringWalk.ws*`, and may be adjusted as needed. Note that any changes to these fields will affect *all* walker objects created by this module instance.


## Unicode Code Points

Lua's string search library treats all characters as single bytes. In UTF-8, the first 127 code points are one byte, while the rest are 2, 3 or 4 bytes in length. It's easy to match code points 0-127, but multi-byte characters do not work with sets (`[a-zA-Z]`) or pattern items (`?`, `*`, ...).

That said, it's possible to match single code points with a pattern defined in Lua 5.3: [utf8.charpattern](https://www.lua.org/manual/5.3/manual.html#pdf-utf8.charpattern). StringWalk contains a modified version of this pattern, stored in `stringWalk.ptn_code`.

```
-- Matches one UTF-8 character at the walker's position
local u8_str = W:match(stringWalk.ptn_code)
```

**The pattern assumes that the UTF-8 encoding is valid**, so it can return invalid code points if the string is corrupt. There are multiple ways to check a string's UTF-8 encoding from Lua, including Lua 5.3's [utf8.len()](https://www.lua.org/manual/5.3/manual.html#pdf-utf8.len) (which is included in LÖVE), [utf8_validator.lua](https://github.com/kikito/utf8_validator.lua), and [utf8Tools](https://github.com/rabbitboots/utf8_tools).check().

StringWalk cannot get the numeric value of the code point. You can use a function from another library, such as Lua 5.3's [utf8.codepoint()](https://www.lua.org/manual/5.3/manual.html#pdf-utf8.codepoint) or [utf8Tools](https://github.com/rabbitboots/utf8_tools).codeFromString().


# License (MIT)

StringWalk is a rewrite of [StringReader](https://github.com/rabbitboots/string_reader), and is provided under the same license.

```
Copyright (c) 2022 - 2024 RBTS

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```
