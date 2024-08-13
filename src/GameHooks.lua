local assert = assert
local pcall = pcall
local tostring = tostring
local type = type

local table_unpack = table.unpack

assert(type(Game) == "table", "You must load Game.lua prior to loading GameHooks.lua")
local Game = Game

GameHooks = GameHooks or {}
local Hooks = {}

local function ShowError(Command, Message, Arguments)
	local args = {}
	
	for i=1,#Arguments do
		args[i] = tostring(Arguments[i])
	end
	
	Alert("Hook for " .. Command .. " failed.\n\nError: " .. Message .. "\n\nArguments:\n" .. (#Arguments > 0 and ("\"" .. table.concat(args, "\", \"") .. "\"") or "NONE") .. "\n\n" .. debug.traceback())
end

local function ProcessHooks(Command, Hooks, Callback, Arguments)
	for i=#Hooks,1,-1 do
		local Success, Result = pcall(Hooks[i], Arguments)
		
		if not Success then
			ShowError(Command, Result, Arguments)
		elseif Result == false then
			print("GameHooks.lua", "Hook for ".. Command .. " returned false. Voiding command.")
			return
		end
	end
	
	local Success, Result = pcall(Callback, table_unpack(Arguments))
	
	if not Success then
		ShowError(Command, Result, Arguments)
	end
end

---Registers a hook for the specified command.
---
---@param Command string The name of the command to hook.
---@param Callback fun(Arguments : any[]) : boolean | nil The callback for the hook. This can return false to void the command.
---@return integer Index The index of the hook.
function GameHooks.RegisterHook(Command, Callback)
	local OriginalFunction = Game[Command]
	assert(type(OriginalFunction) == "function", "Command \"" .. Command .. "\" does not exist in the Game table.")
	
	local CommandHooks = Hooks[Command]
	if not CommandHooks then
		CommandHooks = {}
		Hooks[Command] = CommandHooks
		
		Game[Command] = function(...)
			ProcessHooks(Command, CommandHooks, OriginalFunction, {...})
		end
	end
	
	local HookIndex = #CommandHooks + 1
	CommandHooks[HookIndex] = Callback
	return HookIndex
end

local function RemovedHook()
	return true
end

---Removes a hook for the specified command by index.
---
---@param Command string The name of the command to remove the hook from.
---@param Index integer The index of the hook to remove.
function GameHooks.RemoveHook(Command, Index)
	assert(type(Index) == "number" and Index >= 1, "Index must be a number greater than or equal to 1.")
	local CommandHooks = Hooks[Command]
	assert(type(CommandHooks) == "table", "Command \"" .. Command .. "\" does not have any existing hooks.")
	assert(Index <= #CommandHooks, "Index must be less than or equal to the number of hooks.")
	
	CommandHooks[Index] = RemovedHook
end

return GameHooks
