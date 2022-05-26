local nl = require("nattlua")
local cmd = ...

if cmd == "build-api" then
	os.execute("nattlua run build_api.nlua")
	os.execute("nattlua check src/love_api.nlua")
elseif cmd == "check" then

	local compiler = assert(
		nl.Compiler([[return import("./main.nlua")]],
		"src/main.nlua",
			{
				working_directory = "src/",
				inline_require = true,
			}
		)
	)

	assert(compiler:Analyze())


elseif cmd == "build" then
	os.execute("nattlua check")

	local compiler = assert(
		nl.Compiler([[
			return import("./main.nlua")
		]],
		"src/main.nlua",
			{
				working_directory = "src/",
				inline_require = true,
			}
		)
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