local PATH = ... and (...):match("(.-)[^%.]+$") or ""


local strict = require(PATH .. "test.lib.strict")


local errTest = require(PATH .. "test.lib.err_test")
local stringWalk = require(PATH .. "string_walk")


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


local self = errTest.new("stringWalk", cli_verbosity)


-- [===[
self:registerFunction("stringWalk.new()", stringWalk.new)

self:registerJob("stringWalk.new()", function(self)
	self:expectLuaError("arg #1 bad type", stringWalk.new, {})
	self:expectLuaReturn("arg #1 nil is acceptable", stringWalk.new, nil)

	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")
		self:isEqual(type(W), "table")
		self:isEqual(W.S, "foobar")
		self:isEqual(W.I, 1)
		self:lf(4)
	end
end
)
--]===]



-- [===[
self:registerFunction("W:newString()", _mt_walk.newString)

self:registerJob("W:newString()", function(self)
	do
		local W = stringWalk.new()
		self:expectLuaError("arg #1 bad type", _mt_walk.newString, W, nil)
	end

	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")
		W.I = 5
		W:newString("bazbop")

		self:isEqual(W.S, "bazbop")
		self:isEqual(W.I, 1)
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:reset()", _mt_walk.reset)

self:registerJob("W:reset()", function(self)
	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")
		W.I = 5
		W:reset()

		self:isEqual(W.I, 1)
		self:lf(4)
	end
end
)
--]===]


-- The functionality of Terse Mode, Byte Mode and line+char display are tested in the error and warning tests.


-- [===[
self:registerFunction("W:setTerseMode()", _mt_walk.setTerseMode)

self:registerJob("W:setTerseMode()", function(self)
	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")
		W:setTerseMode(true)
		self:print(4, W._terse)
		self:isEvalTrue(W._terse)

		self:print(4, W._terse)
		W:setTerseMode(false)
		self:isEvalFalse(W._terse)
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:setByteMode()", _mt_walk.setByteMode)

self:registerJob("W:setByteMode()", function(self)
	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")
		W:setByteMode(true)
		self:isEvalTrue(W._bmode)

		W:setByteMode(false)
		self:isEvalFalse(W._bmode)
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:setLineCharDisplay()", _mt_walk.setLineCharDisplay)

self:registerJob("W:setLineCharDisplay()", function(self)
	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")

		W:setLineCharDisplay(false, false)
		self:isEvalFalse(W._ln)
		self:isEvalFalse(W._cn)

		W:setLineCharDisplay(true, true)
		self:isEvalTrue(W._ln)
		self:isEvalTrue(W._cn)
		self:lf(4)
	end
end
)
--]===]


-- [===[
--]]
self:registerFunction("W:find()", _mt_walk.find)

self:registerJob("W:find()", function(self)
	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")
		local i, j = W:find("o+")
		self:isEqual(i, 2)
		self:isEqual(j, 3)

		W:reset()
		local c1, c2, c3
		i, j, c1, c2, c3 = W:find("(f).-(b).-(r)")
		self:isEqual(c1, "f")
		self:isEqual(c2, "b")
		self:isEqual(c3, "r")
	end
end
)
--]===]


-- [===[
self:registerFunction("W:findReq()", _mt_walk.findReq)

self:registerJob("W:findReq()", function(self)
	do
		local W = stringWalk.new("foobar")
		self:expectLuaError("no match", _mt_walk.findReq, W, "zan", false, "no dice")
	end

	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")
		local i, j, cap = W:findReq("(bar)")
		self:isEqual(i, 4)
		self:isEqual(j, 6)
		self:isEqual(cap, "bar")
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:lit()", _mt_walk.lit)

self:registerJob("W:lit()", function(self)
	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")
		local str = W:lit("bar")
		self:isEqual(str, nil)
		str = W:lit("foo")
		self:isEqual(str, "foo")
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:litReq()", _mt_walk.litReq)

self:registerJob("W:litReq()", function(self)
	do
		local W = stringWalk.new("foobar")
		self:expectLuaError("no match", _mt_walk.litReq, W, "zub", "not there")
	end

	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")
		W:step(2)
		local str = W:litReq("oba")
		self:isEqual(str, "oba")
		self:lf(4)
	end
end
)
--]===]


-- [===[
--]]
self:registerFunction("W:match()", _mt_walk.match)

self:registerJob("W:match()", function(self)
	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")
		local str = W:match("o+")
		self:isEqual(str, "oo")

		W:reset()
		local c1, c2, c3 = W:match("(f).-(b).-(r)")
		self:isEqual(c1, "f")
		self:isEqual(c2, "b")
		self:isEqual(c3, "r")
	end
end
)
--]===]


-- [===[
self:registerFunction("W:matchReq()", _mt_walk.matchReq)

self:registerJob("W:matchReq()", function(self)
	do
		local W = stringWalk.new("foobar")
		self:expectLuaError("no match", _mt_walk.matchReq, W, "([x-z]+)", "nope")
	end

	do
		self:print(3, "[+] expected behavior")
		local W = stringWalk.new("foobar")
		local c1, c2 = W:matchReq("(f)(ooba)")
		self:isEqual(c1, "f")
		self:isEqual(c2, "ooba")
		self:lf(4)
	end
end
)
--]===]


-- [===[
--]]
self:registerJob("Walker internal state assertions", function(self)
	do
		local W = stringWalk.new("foobar")
		W.S = {}
		self:expectLuaError("bad type for internal walker string", _mt_walk.find, W, "foo")
	end

	do
		local W = stringWalk.new("foobar")
		W.I = "oopsie"
		self:expectLuaError("bad type for internal walker index", _mt_walk.find, W, "foo")
	end

	do
		local W = stringWalk.new("foobar")
		W.I = 1.5
		self:expectLuaError("internal walker index is non-integer", _mt_walk.find, W, "foo")
	end

	do
		local W = stringWalk.new("foobar")
		W.I = -1
		self:expectLuaError("internal walker index is too low", _mt_walk.find, W, "foo")
	end
	-- A walker index greater than #W.S is permitted, and treated as an end-of-string state.
end
)
--]===]


-- [===[
self:registerFunction("W:seek()", _mt_walk.seek)

self:registerJob("W:seek()", function(self)
	do
		local W = stringWalk.new("foobar")
		self:expectLuaError("arg #1 bad type", _mt_walk.seek, W, {})
	end

	do
		self:print(3, "[+] Expected behavior")
		local W = stringWalk.new("foobar")
		W:seek(4)
		self:isEqual(W.I, 4)

		W:seek(-1)
		self:isEqual(W.I, 1)

		W:seek(1000)
		self:isEqual(W.I, 7)
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:step()", _mt_walk.step)

self:registerJob("W:step()", function(self)
	do
		local W = stringWalk.new("foobar")
		self:expectLuaError("arg #1 bad type", _mt_walk.step, W, {})
	end

	do
		self:print(3, "[+] Expected behavior")
		local W = stringWalk.new("foobar")
		W:step(4)
		self:isEqual(W.I, 5)

		W:step(-1)
		self:isEqual(W.I, 4)

		W:step(0)
		self:isEqual(W.I, 4)

		W:step(-1000)
		self:isEqual(W.I, 1)

		W:step(2000)
		self:isEqual(W.I, #W.S + 1)
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:peek()", _mt_walk.peek)

self:registerJob("W:peek()", function(self)
	do
		local W = stringWalk.new("foobar")
		self:expectLuaError("arg #1 bad type", _mt_walk.peek, W, {})
		self:expectLuaError("arg #1 must be an integer", _mt_walk.peek, W, 1.5)
		self:expectLuaError("arg #1 must be >= 1", _mt_walk.peek, W, 0)
	end

	do
		self:print(3, "[+] Expected behavior")
		local W = stringWalk.new("foobar")
		local res
		res = W:peek()
		self:isEqual(res, "f")

		res = W:peek(1)
		self:isEqual(res, "f")

		res = W:peek(2)
		self:isEqual(res, "fo")

		res = W:peek(99)
		self:isEqual(res, "foobar")
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:ws()", _mt_walk.ws)

self:registerJob("W:ws()", function(self)
	do
		self:print(3, "[+] Move across whitespace")
		local W = stringWalk.new("foo   bar")
		W:step(3)
		W:ws()
		self:isEqual(W.I, 7)
		self:lf(4)
	end

	do
		self:print(3, "[+] Stay put on non-whitespace")
		local W = stringWalk.new("foo   bar")
		W:ws()
		self:isEqual(W.I, 1)
		self:lf(4)
	end

	do
		self:print(3, "[+] Move to end-of-string")
		local str = "foo      "
		local W = stringWalk.new(str)
		W:step(3)
		W:ws()
		self:isEqual(W.I, #str + 1)
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:wsReq()", _mt_walk.wsReq)

self:registerJob("W:wsReq()", function(self)

	do
		self:print(3, "[+] Move across whitespace")
		local W = stringWalk.new("foo   bar")
		W:step(3)
		W:wsReq()
		self:isEqual(W.I, 7)
		self:lf(4)
	end

	do
		local W = stringWalk.new("foo   bar")
		self:expectLuaError("expected whitespace", _mt_walk.wsReq, W)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:wsNext()", _mt_walk.wsNext)

self:registerJob("W:wsNext()", function(self)
	do
		self:print(3, "[+] Move across non-whitespace")
		local W = stringWalk.new("   foooooo   ")
		print("W.I", W.I)
		W:step(3)
		print("W.I", W.I)
		W:wsNext()
		print("W.I", W.I)
		self:isEqual(W.I, 11)
		self:lf(4)
	end

	do
		self:print(3, "[+] Stay put on whitespace")
		local W = stringWalk.new("   foo   ")
		W:wsNext()
		self:isEqual(W.I, 1)
		self:lf(4)
	end

	do
		self:print(3, "[+] Move to end-of-string")
		local str = "    foooooooooo"
		local W = stringWalk.new(str)
		W:step(4)
		W:wsNext()
		self:isEqual(W.I, #str + 1)
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:isEOS()", _mt_walk.isEOS)

self:registerJob("W:isEOS()", function(self)
	do
		self:print(3, "[+] Expected behavior")
		local W = stringWalk.new("woop")
		local ok

		W:step(99)
		ok = W:isEOS()
		self:isEvalTrue(ok)

		W:reset()
		ok = W:isEOS()
		self:isEvalFalse(ok)
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:goEOS()", _mt_walk.goEOS)

self:registerJob("W:goEOS()", function(self)
	do
		self:print(3, "[+] Expected behavior")
		local W = stringWalk.new("woop")
		local ok

		W:goEOS()
		self:isEqual(W.I, 5)
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:getLineCharNumbers()", _mt_walk.getLineCharNumbers)

self:registerJob("W:getLineCharNumbers()", function(self)
	do
		self:print(3, "[+] Expected behavior")
		local W = stringWalk.new("11\n22")
		local ln, cn

		-- 11\n22
		-- ^
		ln, cn = W:getLineCharNumbers()
		self:isEqual(ln, 1)
		self:isEqual(cn, 1)
		-- 11\n22
		--  ^
		W:step(1)
		ln, cn = W:getLineCharNumbers()
		self:isEqual(ln, 1)
		self:isEqual(cn, 2)

		-- 11\n22
		--     ^
		W:step(1)
		ln, cn = W:getLineCharNumbers()
		self:isEqual(ln, 2)
		self:isEqual(cn, 1)

		-- 11\n22
		--      ^
		W:step(1)
		ln, cn = W:getLineCharNumbers()
		self:isEqual(ln, 2)
		self:isEqual(cn, 2)
		self:lf(4)
	end

	do
		self:print(3, "[+] Handle /r/n pairs")
		local W = stringWalk.new("aa\r\nbb")
		local ln, cn

		-- aa\r\nbb
		-- ^
		ln, cn = W:getLineCharNumbers()
		self:isEqual(ln, 1)
		self:isEqual(cn, 1)
		-- aa\r\nbb
		--  ^
		W:step(1)
		ln, cn = W:getLineCharNumbers()
		self:isEqual(ln, 1)
		self:isEqual(cn, 2)

		-- aa\r\nbb
		--       ^
		W:step(2)
		ln, cn = W:getLineCharNumbers()
		self:isEqual(ln, 2)
		self:isEqual(cn, 1)
		self:lf(4)
	end

	do
		self:print(3, "[+] EOS: use final index in string")
		local W = stringWalk.new("abcdefg")
		local ln, cn

		W:goEOS()
		ln, cn = W:getLineCharNumbers()
		self:isEqual(ln, 1)
		self:isEqual(cn, 7)
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:getIndex()", _mt_walk.getIndex)

self:registerJob("W:getIndex()", function(self)
	do
		self:print(3, "[+] Expected behavior")
		local W = stringWalk.new("doop")
		local i
		i = W:getIndex()
		self:isEqual(i, W.I)
		W:goEOS()
		i = W:getIndex()
		self:isEqual(i, W.I)
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:error()", _mt_walk.error)

self:registerJob("W:error()", function(self)
	do
		local W = stringWalk.new("foobar")
		self:expectLuaError("must raise a Lua error, even if the provided arguments are nonsense", _mt_walk.error, W, {}, function() end)
	end

	do
		local W = stringWalk.new("foobar")
		self:print(3, "[+] Terse Mode")
		W:setTerseMode(true)
		local ok, err = pcall(_mt_walk.error, W, "This error message should not appear.")
		self:print(4, err)
		self:isEvalTrue(err:find("parsing failed$"))
		self:lf(4)
	end

	do
		local W = stringWalk.new("foobar")
		self:print(3, "[+] Byte Mode")
		W:setByteMode(true)
		local ok, err = pcall(_mt_walk.error, W, "This error should be accompanied by a byte index position.")
		self:print(4, err)
		self:isEvalTrue(err:find("^index #1:"))
		self:lf(4)
	end

	do
		local W = stringWalk.new("foobar")
		self:print(3, "[+] Don't show character number")
		W:setLineCharDisplay(true, false)
		local ok, err = pcall(_mt_walk.error, W, "This error should not display the character number.")
		self:print(4, err)
		self:isEvalTrue(err:find("^line 1:"))
		self:lf(4)
	end

	do
		local W = stringWalk.new("foobar")
		self:print(3, "[+] Don't show line number (this also disables character number)")
		W:setLineCharDisplay(false)
		local ok, err = pcall(_mt_walk.error, W, "This error should not display any line or character number.")
		self:print(4, err)
		self:isEvalTrue(err:find("^This error"))
		self:lf(4)
	end
end
)
--]===]



-- We can't fully test warnings because there is nothing tangible to assert.
-- [===[
self:registerFunction("W:warn()", _mt_walk.warn)

self:registerJob("W:warn()", function(self)
	do
		local W = stringWalk.new("foobar")
		self:print(3, "[ad hoc] No warnings in Terse Mode")
		W:setTerseMode(true)
		W:warn(":^)")
		W:setTerseMode(false)
		W:warn("This warning should have a line number and character number. It should *not* be preceded by an ASCII smiley.")
		self:lf(4)
	end

	do
		local W = stringWalk.new("foobar")
		self:print(3, "[ad hoc] Byte Mode")
		W:setByteMode(true)
		W:warn("This warning should have a byte position.")
		self:lf(4)
	end

	do
		local W = stringWalk.new("foobar")
		self:print(3, "[ad hoc] Don't show character number")
		W:setLineCharDisplay(true, false)
		W:warn("This warning should have a line number, but not a character number.")
		self:lf(4)
	end

	do
		local W = stringWalk.new("foobar")
		self:print(3, "[ad hoc] No line number, no character number")
		W:setLineCharDisplay(false)
		W:warn("This warning should have no line number, no character number and no byte index.")
		self:lf(4)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:push()", _mt_walk.push)
self:registerFunction("W:pop()", _mt_walk.pop)
self:registerFunction("W:popAll()", _mt_walk.popAll)

self:registerJob("W:push(), W:pop(), W:popAll()", function(self)
	do
		local W = stringWalk.new("foobar")
		W:litReq("foo")
		W:push("zyp")
		W:push("doop")
		self:isEqual(#W._st, 2)
		self:isEqual(W._st[1][1], "foobar")
		self:isEqual(W._st[1][2], 4)

		self:isEqual(W._st[2][1], "zyp")
		self:isEqual(W._st[2][2], 1)

		self:isEqual(W.S, "doop")
		self:isEqual(W.I, 1)

		W:pop()
		self:isEqual(#W._st, 1)
		self:isEqual(W.S, "zyp")

		W:popAll()
		self:isEqual(#W._st, 0)
		self:isEqual(W.S, "foobar")
	end
end
)
--]===]


-- [===[
self:registerFunction("W:bytes()", _mt_walk.bytes)

self:registerJob("W:bytes()", function(self)
	do
		local W = stringWalk.new("foobar")
		local r
		r = W:bytes()
		self:isEqual(r, "f")
		r = W:bytes(2)
		self:isEqual(r, "oo")
		r = W:bytes(3)
		self:isEqual(r, "bar")
		r = W:bytes(4)
		self:isEqual(r, nil)

		W:reset()
		self:expectLuaError("arg #1 bad type", W.bytes, W, {})
		self:expectLuaError("fractional offset", W.bytes, W, 1.1)
		self:expectLuaError("zero offset", W.bytes, W, 0)
		self:expectLuaError("negative offset", W.bytes, W, -1)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:bytesReq()", _mt_walk.bytesReq)

self:registerJob("W:bytesReq()", function(self)
	do
		local W = stringWalk.new("foobar")
		local r
		r = W:bytesReq(3)
		self:isEqual(r, "foo")
		r = W:bytes(3)
		self:isEqual(r, "bar")
		self:expectLuaError("failed to match", W.bytesReq, W, 3)

		W:reset()
		self:expectLuaError("arg #1 bad type", W.bytesReq, W, {})
		self:expectLuaError("fractional offset", W.bytesReq, W, 1.1)
		self:expectLuaError("zero offset", W.bytesReq, W, 0)
		self:expectLuaError("negative offset", W.bytesReq, W, -1)
	end
end
)
--]===]


-- [===[
self:registerFunction("W:req()", _mt_walk.req)

self:registerJob("W:req()", function(self)
	do
		--[[
		W:req() is used to implement other *Req() methods. It doesn't perform type checks
		on the input, and bad error string values are coerced to strings in W:error(), so there
		isn't much to check here.
		--]]

		local W = stringWalk.new("foobar")
		local r
		W:req(function() return true end, "this call should never fail")

		self:expectLuaError("arg #1 bad type", W.req, W, {}, "boo")
	end
end
)
--]===]


-- [===[
self:registerFunction("W:assert()", _mt_walk.assert)

self:registerJob("W:assert()", function(self)
	do
		--[[
		Like W:req(), there isn't much to check here.
		--]]
		local W = stringWalk.new("foobar")
		local r
		self:expectLuaReturn("passed eval", W.assert, W, true, "this call should never fail")
		self:expectLuaError("failed eval", W.assert, W, false, "this call should always fail")
	end
end
)


-- [===[
self:registerJob("stringWalk.ptn_code", function(self)
	do
		local W = stringWalk.new("abcdë§偕𐀀")
		self:isEqual(W:match(stringWalk.ptn_code), "a")
		self:isEqual(W:match(stringWalk.ptn_code), "b")
		self:isEqual(W:match(stringWalk.ptn_code), "c")
		self:isEqual(W:match(stringWalk.ptn_code), "d")
		self:isEqual(W:match(stringWalk.ptn_code), "ë")
		self:isEqual(W:match(stringWalk.ptn_code), "§")
		self:isEqual(W:match(stringWalk.ptn_code), "偕")
		self:isEqual(W:match(stringWalk.ptn_code), "𐀀")
		self:isEqual(W:match(stringWalk.ptn_code), nil)
	end
end
)


-- Don't test W:_status().


self:runJobs()

