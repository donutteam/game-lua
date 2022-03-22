assert(Game, "You must load Game.lua prior to loading GameHooks.lua")

GameHooks = GameHooks or {}
local Hooks = {}

local function ShowError(Command, Message, Arguments)
	local args = {}
	
	for i=1,#Arguments do
		args[i] = tostring(Arguments[i])
	end
	
	Alert("Hook for " .. Command .. " failed.\n\nError: " .. Message .. "\n\nArguments:\n" .. (#Arguments > 0 and ("\"" .. table.concat(args, "\", \"") .. "\"") or "NONE") .. "\n\n" .. debug.traceback(), "Game Hooks")
end

local function ProcessHooks(Command, Hooks, Callback, Arguments)
	for i=#Hooks,1,-1 do
		local Success, Result = pcall(Hooks[i], Arguments)
		
		if not Success then
			ShowError(Command, Result, Arguments)
		elseif Result then
			print("GameHooks.lua", "Hook for ".. Command .. " returned false. Voiding command.")
			return
		end
	end
	
	local Success, Result = pcall(Callback, table.unpack(Arguments))
	
	if not Success then
		ShowError(Command, Result, Arguments)
	end
end

function GameHooks.RegisterHook(Command, Callback)
	assert(Game[Command], "Command \"" .. Command .. "\" does not exist in the Game table.")
	
	if not Hooks[Command] then
		Hooks[Command] = {}
		
		local OriginalFunction = Game[Command]
		
		Game[Command] = function(...)
			ProcessHooks(Command, Hooks[Command], OriginalFunction, {...})
		end
	end
	
	Hooks[Command][#Hooks[Command] + 1] = Callback
end

return GameHooks