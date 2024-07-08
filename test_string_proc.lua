local PATH = ... and (...):match("(.-)[^%.]+$") or ""


require(PATH .. "test.lib.strict")
local inspect = require(PATH .. "test.lib.inspect.inspect")


local errTest = require(PATH .. "test.lib.err_test")
local stringWalk = require(PATH .. "string_walk")
local stringProc = require(PATH .. "string_proc")
local stringProcDebug = require(PATH .. "string_proc_debug")


local _mt_walk = getmetatable(stringWalk.new())


local hex = string.char


local cli_verbosity
for i = 0, #arg do
	if arg[i] == "--verbosity" then
		cli_verbosity = tonumber(arg[i + 1])
		if not cli_verbosity then
			error("invalid verbosity value")
		end
	end
end


local self = errTest.new("stringProc", cli_verbosity)


-- [===[
self:registerFunction("stringProc.toTable()", stringProc.toTable)

self:registerJob("stringProc.toTable", function(self)

	self:expectLuaError("arg #1 bad type", stringProc.toTable, {})


	self:print(3, "[+] expected behavior")

	local t
	-- [====[
	t = self:expectLuaReturn("empty string", stringProc.toTable, "")
	self:isType(t, "table")
	self:isEqual(next(t), nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("whitespace", stringProc.toTable, " \t\n")
	self:isType(t, "table")
	self:isEqual(next(t), nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("char", stringProc.toTable, "w")
	self:isType(t, "table")
	self:isEqual(t[1], "w")
	self:isEqual(t[2], nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("word", stringProc.toTable, "word")
	self:isType(t, "table")
	self:isEqual(t[1], "word")
	self:isEqual(t[2], nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("string literal, single quotes", stringProc.toTable, "'wörd'")
	self:isType(t, "table")
	self:isEqual(t[1], "'wörd'")
	self:isEqual(t[2], nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("string literal, double quotes", stringProc.toTable, [["wörd"]])
	self:isType(t, "table")
	self:isEqual(t[1], [["wörd"]])
	self:isEqual(t[2], nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("sequence of words", stringProc.toTable, "word word word")
	self:isType(t, "table")
	self:isEqual(t[1], "word")
	self:isEqual(t[2], "word")
	self:isEqual(t[3], "word")
	self:isEqual(t[4], nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("sequence of words", stringProc.toTable, "word | word")
	self:isType(t, "table")
	self:isEqual(t[1], "word")
	self:isEqual(t[2], "|")
	self:isEqual(t[3], "word")
	self:isEqual(t[4], nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("separation of tokens and words without whitespace", stringProc.toTable, [[whitespace|between|words'and'nonword"tokens"is|optional]])
	self:isType(t, "table")
	self:isEqual(t[1], "whitespace")
	self:isEqual(t[2], "|")
	self:isEqual(t[3], "between")
	self:isEqual(t[4], "|")
	self:isEqual(t[5], "words")
	self:isEqual(t[6], "'and'")
	self:isEqual(t[7], "nonword")
	self:isEqual(t[8], '"tokens"')
	self:isEqual(t[9], "is")
	self:isEqual(t[10], "|")
	self:isEqual(t[11], "optional")
	self:isEqual(t[12], nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("nested groups (1)", stringProc.toTable, "word (word)")
	self:isType(t, "table")
	self:isEqual(t[1], "word")
	self:isType(t[2], "table")
	self:isEqual(t[2][1], "word")
	self:isEqual(t[2][2], nil)
	self:isEqual(t[3], nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("nested groups (2)", stringProc.toTable, "word (word (word))")
	self:isType(t, "table")
	self:isEqual(t[1], "word")
	self:isType(t[2], "table")
	self:isEqual(t[2][1], "word")
	self:isType(t[2][2], "table")
	self:isEqual(t[2][2][1], "word")
	self:isEqual(t[2][2][2], nil)
	self:isEqual(t[2][3], nil)
	self:isEqual(t[3], nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("empty group", stringProc.toTable, "()")
	self:isType(t, "table")
	self:isType(t[1], "table")
	self:isEqual(t[1][1], nil)
	--]====]


	-- [====[
	t = self:expectLuaReturn("sequence of empty groups", stringProc.toTable, "()()()(())()()()((())())")
	self:isType(t, "table")
	self:isType(t[1], "table")
	self:isEqual(t[1][1], nil)

	self:isType(t[2], "table")
	self:isEqual(t[2][1], nil)

	self:isType(t[3], "table")
	self:isEqual(t[3][1], nil)

	self:isType(t[4], "table")
	self:isType(t[4][1], "table")
	self:isEqual(t[4][2], nil)

	self:isType(t[5], "table")
	self:isEqual(t[5][1], nil)

	self:isType(t[6], "table")
	self:isEqual(t[6][1], nil)

	self:isType(t[7], "table")
	self:isEqual(t[7][1], nil)

	self:isType(t[8], "table")
	self:isType(t[8][1], "table")
	self:isType(t[8][1][1], "table")
	self:isEqual(t[8][1][2], nil)
	self:isType(t[8][2], "table")
	self:isEqual(t[8][2][1], nil)
	self:isEqual(t[8][3], nil)


	self:print(3, "[-] syntax errors")


	-- [====[
	self:expectLuaError("isolated '?'", stringProc.toTable, "?")
	self:expectLuaError("isolated '*'", stringProc.toTable, "*")
	self:expectLuaError("isolated '+'", stringProc.toTable, "+")
	self:expectLuaError("invalid token", stringProc.toTable, "@")
	self:expectLuaError("invalid token between two tokens", stringProc.toTable, "word @ word")
	self:expectLuaError("'except' token is not supported", stringProc.toTable, "-")
	self:expectLuaError("isolated '|'", stringProc.toTable, "|")
	self:expectLuaError("consecutive quantity marks", stringProc.toTable, "word*? word")
	self:expectLuaError("trailing '|'", stringProc.toTable, "word | word | ")
	self:expectLuaError("consecutive '|'", stringProc.toTable, "word | | word")
	self:expectLuaError("consecutive '|'", stringProc.toTable, "word | | word")
	self:expectLuaError("unbalanced group (1)", stringProc.toTable, ")")
	self:expectLuaError("unbalanced group (2)", stringProc.toTable, "(")
	self:expectLuaError("unbalanced group (3)", stringProc.toTable, "(ab)c)")
	--]====]
end
)
--]===]


-- [===[
self:registerFunction("stringProcDebug.checkWords()", stringProcDebug.checkWords)

self:registerJob("stringProcDebug.checkWords", function(self)
	-- [====[
	do

		self:expectLuaError("arg #1 bad type", stringProcDebug.checkWords, false, {})
		self:expectLuaError("arg #2 bad type", stringProcDebug.checkWords, {}, false)


		self:expectLuaReturn("all words are populated", stringProcDebug.checkWords, {foo="bar", baz=function() end, bop=1}, {"foo", "baz", "bop"})
		self:expectLuaError("missing word", stringProcDebug.checkWords, {foo=1, baz=1, bop=1}, {"foo", "baz", "zyp"})
	end
	--]====]
end
)
--]===]


-- [===[
self:registerFunction("stringProcDebug.checkSymbols()", stringProcDebug.checkSymbols)

self:registerJob("stringProcDebug.checkSymbols", function(self)
	-- [====[
	do

		self:expectLuaError("arg #1 bad type", stringProcDebug.checkSymbols, false)


		self:expectLuaReturn("all symbols OK", stringProcDebug.checkSymbols, {foo="bar", baz=function() end, bop=1})
		self:expectLuaError("bad symbol value", stringProcDebug.checkSymbols, {burp = false})
	end
	--]====]
end
)
--]===]


-- [===[
self:registerFunction("stringProc.traverse()", stringProc.traverse)

self:registerJob("stringProc.traverse", function(self)
	-- [====[
	do

		self:expectLuaError("arg #1 bad type", stringProc.traverse, false, {}, {})
		self:expectLuaError("arg #2 bad type", stringProc.traverse, {}, false, {})
		self:expectLuaError("arg #3 bad type", stringProc.traverse, {}, {}, false)

		-- A silly grammar rule set.

		local sym = {}
		function sym.s(W)
			return W:match("^(\32+)")
		end

		function sym.EOL(W)
			return W:match("^(\n+)")
		end

		function sym.word(W)
			return W:match("^([a-zA-Z]+)")
		end

		function sym.figure(W)
			return W:match("^([0-9]+%.[0-9]*)") or W:match("^([0-9]+)")
		end

		local _assignment = stringProc.toTable("word s? '=' s? figure s? EOL?")
		function sym.assignment(W)
			return stringProc.traverse(W, _assignment, sym)
		end

		function sym.inQuotes(W)
			local q, r = W:match("^(['\"])(.-)%1")
			if q then
				return q .. r .. q
			end
		end

		local _sentenceChunk = stringProc.toTable("word | inQuotes")
		function sym.sentenceChunk(W)
			return stringProc.traverse(W, _sentenceChunk, sym)
		end

		function sym.sentenceEnd(W)
			return W:match("^([%.%?!])")
		end

		local _sentence = stringProc.toTable("(sentenceChunk s?)+ sentenceEnd s?")
		function sym.sentence(W)
			return stringProc.traverse(W, _sentence, sym)
		end

		local _paragraph = stringProc.toTable("sentence+ EOL?")
		function sym.paragraph(W)
			return stringProc.traverse(W, _paragraph, sym)
		end

		local _document = stringProc.toTable("(paragraph | assignment | s | EOL)+")
		function sym.document(W)
			local r = stringProc.traverse(W, _document, sym)
			if not r or not W:isEOS() then
				W:error("couldn't read the full document.")
			end
			return r
		end

		function sym.never(W)
			return
		end

		local _inf_loop = stringProc.toTable("(never*)*")
		function sym.infLoop(W)
			return stringProc.traverse(W, _inf_loop, sym)
		end

		local _inf_loop2 = stringProc.toTable("''+")
		function sym.infLoop2(W)
			return stringProc.traverse(W, _inf_loop2, sym)
		end

		local W, ok

		-- [====[
		self:print(3, "[+] correct input")
		W = stringWalk.new([=[
Fill the bucket. Empty the bucket.
Move the bucket. Upturn the bucket.
a = 3.21
'everything in quotes is parsed as one chunk'.]=])
		stringProc._iter = 50000
		ok = sym.document(W)
		self:isType(ok, "table")
		--print(inspect(ok))
		self:isEqual(ok[1], "Fill")
		self:isEqual(ok[2], " ")
		self:isEqual(ok[3], "the")
		self:isEqual(ok[4], " ")
		self:isEqual(ok[5], "bucket")
		self:isEqual(ok[6], ".")
		-- etc., etc.
		--]====]


		-- [====[
		self:print(3, "[-] bad input")
		W = stringWalk.new("")
		stringProc._iter = 50000
		self:expectLuaError("empty string", sym.document, W)

		W:newString("foobar")
		stringProc._iter = 50000
		self:expectLuaError("invalid document (sentences must end with a period)", sym.document, W)

		W:newString(".")
		stringProc._iter = 50000
		self:expectLuaError("invalid document (no words in sentence)", sym.document, W)

		W:newString("a = a")
		stringProc._iter = 50000
		self:expectLuaError("invalid document (doesn't match 'assignment' rule)", sym.document, W)

		W:newString("'a' = a")
		stringProc._iter = 50000
		self:expectLuaError("invalid document ('assignment' rule doesn't allow quoted sections on left hand)", sym.document, W)

		W:newString("a = 1.0.")
		stringProc._iter = 50000
		self:expectLuaError("invalid document ('assignment' rule doesn't end with a dot)", sym.document, W)

		W:newString("...")
		stringProc._iter = 50000
		self:expectLuaError("invalid document (infinite loop in grammar rule)", sym.infLoop, W)

		W:newString("abc")
		stringProc._iter = 50000
		self:expectLuaError("invalid document (infinite loop caused by empty string literal)", sym.infLoop2, W)
		--]====]

		--[[
		You get the idea.

		StringProc gets more serious use in the Lua XML Library:
		https://github.com/rabbitboots/lxl
		--]]
	end
	--]====]
end
)
--]===]


self:runJobs()
