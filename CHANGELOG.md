# StringWalk changelog

# v2.0.0 -- 2024-JUL-04

This is a major rewrite of [StringReader](https://github.com/rabbitboots/string_reader). Unfortunately, there are too many changes to lay out a straightforward upgrade guide.

* Renamed from *StringReader* to *StringWalk*.
* Added *StringProc*, an auxiliary library for parsing grammar productions with StringWalk.
* Fixed incorrect usage of the term *code unit* throughout the library and readme.
* Included a modified version of Lua 5.3's `utf8.charpattern` as `stringWalk.ptn_code`.

## Altered Features

* The walker object no longer stores the results of captures in `self.c[1], self.c[2], …`.
* Options configuration was handled by passing a table when creating a walker object. Now there are setter methods for each option.


## New Features

* *Byte Mode*: displays byte indices in warnings and errors instead of line and character numbers. Use when the string contains arbitrary, non-UTF-8 data.
* *String Stack*: Walkers can now push strings onto a stack, allowing a substring (or any arbitrary temporary string) to be consumed while the line and position counters are "frozen."


## Changes to Functions

* self:advanceBytes()
  * Became self:step().
  * Final position is clamped to `1` - `#str + 1`.
  * Rejects non-integers.

* self:errorHalt()
  * Became self:error().

* self:fetch()
  * Became self:find().
  * Returns match range (`i`, `j`) in addition to captures.

* self:fetchReq()
  * Became self:findReq().
  * Returns match range (`i`, `j`) in addition to captures.

* self:lineNum()
  * Became self:getLineCharNumbers().
  * Now always returns two numbers (lineNum() could return strings or `false`).

* self:newStr()
  * Renamed to self:newString().

* self:peek()
  * The arguments have changed.
  * The range is now always anchored to the walker's position.
  * Rejects non-integers and values less than 1

* self:_status()
  * Is no longer commented out by default.
  * No longer shows captures (as they aren't stored in the Walker object anymore).

* self:warn()
  * Took one string argument, now takes varargs and passes them to Lua's `print()`.
  * No longer type-checks incoming arguments (since they'll be auto-converted to string by `print()` anyways).

* stringReader.new()
  * Became stringWalk.new().
  * No longer takes a table of options.

* self:byteChar(), self:byteChars()
  * Replaced with self:bytes()


## Removed Functions

* self:cap()
* self:capReq()
* self:clearCaptures()
* self:u8Char()
* self:u8Chars()


## Minimally Changed Functions

* self:goEOS()
* self:isEOS()
* self:lit()
* self:litReq()
* self:reset()
* self:ws()
* self:wsNext()
* self:wsReq()


## New Functions

* self:assert()
* self:bytesReq()
* self:getIndex()
* self:match()
* self:matchReq()
* self:pop()
* self:popAll()
* self:push()
* self:seek()
* self:setByteMode()
* self:setLineCharDisplay()
* self:setTerseMode()
* self:req()


## Changed Internals

All internal field names in the walker object have changed. The walker reserves the following key names:

* The method names (find, findReq, etc.)
* All single upper-case characters
* All key names beginning with an underscore

The hope is to reduce the chances of a naming collision with user-specified fields.
