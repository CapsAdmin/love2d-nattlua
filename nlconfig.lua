local nl = require("nattlua")
local cmd = ...

local analyzer_config = {
	working_directory = "src/",
	inline_require = true,
}

if cmd == "build-api" then
	os.execute("nattlua run build_api.nlua")
	os.execute("nattlua check src/love_api.nlua")
elseif cmd == "get-analyzer-config" then
	analyzer_config.entry_point = "main.nlua"
	return analyzer_config
elseif cmd == "check" then

	local compiler = assert(
		nl.Compiler([[return import("./main.nlua")]],
		"src/main.nlua", analyzer_config))

	if cmd == "check-language-server" then
		return compiler
	end

	assert(compiler:Analyze())


elseif cmd == "build" then
	os.execute("nattlua check")

	local compiler = assert(
		nl.Compiler([[
			return import("./main.nlua")
		]], "src/main.nlua", analyzer_config)
	)

	local code = compiler:Emit({
		blank_invalid_code = true,
		module_encapsulation_method = "loadstring",
	})
	local f = assert(io.open("dist/main.lua", "w"))
	f:write(code)
	f:close()

	-- analyze after file write so hotreload is faster
	--compiler:Analyze()
elseif cmd == "run" then
	if not io.open("dist/main.lua", "r") then
		os.execute("nattlua build")
	end
	os.execute("love dist/")
end