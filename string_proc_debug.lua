local stringProcDebug = {}


local PATH = ... and (...):match("(.-)[^%.]+$") or ""


local _argType = require(PATH .. "pile_arg_check").type
local stringWalk = require(PATH .. "string_walk")


function stringProcDebug.checkSymbols(symbols)
	_argType(1, symbols, "table")

	for k, v in pairs(symbols) do
		if type(k) ~= "string" then
			error("bad type for symbol key (expected string, got " .. type(k) .. ").")

		elseif type(v) ~= "string" and type(v) ~= "number" and type(v) ~= "function" and v ~= "table" and v ~= true then
			local got = v == false and "false" or type(v)
			error("bad type for symbol value: " .. k .. " (expected string, number, function, true, got " .. got .. ").")
		end
	end
end


local function _getWords(t, _sym)
	_sym = _sym or {}
	for i, chunk in ipairs(t) do
		if type(chunk) == "table" then
			_getWords(t, _sym)

		elseif type(chunk) == "string" and not chunk:sub(1, 1):match("['\"]") then
			_sym[chunk] = true
		end
	end
end


local function _checkWords(t, _sym, _depth)
	for i, v in ipairs(t) do
		if type(v) == "table" then
			_checkWords(v, _sym, _depth + 1)

		elseif type(v) ~= "string" then
			error("depth " .. _depth .. " index " .. i .. ": bad value: " .. tostring(v) " (type: " .. type(v) .. ")")

		elseif not v:sub(1, 1):match("['\"]") then
			if not _sym[v] then
				error("depth " .. _depth .. " index " .. i .. ": missing symbol for word: " .. v)
			end
		end
	end
end


function stringProcDebug.checkWords(symbols, t)
	_argType(1, symbols, "table")
	_argType(2, t, "table")

	_checkWords(t, symbols, 1)
end


return stringProcDebug
