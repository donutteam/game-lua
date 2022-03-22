local Path = FixSlashes(GetPath(), false, true)
local NewPath = GetModPath() .. "/Resources/" .. RemoveFileExtension(Path) .. ".lua"
if Exists(NewPath, true, false) then
	local StartTime = GetTime()
	dofile(NewPath)
	local EndTime = GetTime()
	print("Redirect.lua", "Executed \"" .. NewPath .. "\" in " .. (EndTime - StartTime) * 1000 .. "ms.")
end