local assert = assert
local error = error
local pairs = pairs
local tostring = tostring
local type = type

Game = Game or {}
assert(type(Game) == "table", "Global variable \"Game\" must be a table.")

local Game = Game
local HackCommandCounts = {}

local string_gsub = string.gsub
local string_unpack = string.unpack

local table_concat = table.concat

local utf8_char = utf8.char

local GetPath = GetPath
local Output = Output

local ArgumentLengthLimit = 63
local Limits = {
	BonusMission = 10,
	ChaseManager = 1,
	Gag = 64,
	Mission = 8,
	SpawnPoint = 50,
	SuppressDriver = 32,
	TeleportDests = 64,
	MissionStage = 25,
	MissionStateProps = 10,
	StageCharacter = 6,
	StageConditions = 8,
	StageCountdownSequence = 8,
	StageObjective = 1,
	StageVehicle = 4,
	StageWaypoints = 32,
	ObjectiveAddNPCs = 4,
	ObjectiveCollectibles = 32,
	ObjectiveNPCWaypoints = 32,
	ObjectiveRemoveNPCs = 4,
}

if IsHackLoaded("CustomLimits") and Exists(GetModPath() .. "/CustomLimits.ini", true, false) then
	local fmtMap = {
		["\xFF\xFE"] = "<H", -- UTF-16LE
		["\xFE\xFF"] = ">H", -- UTF-16BE
	}
	local function ReadTextFile(path)
		local content = ReadFile(path)
		if not content then
			return nil
		end
		
		local contentN = #content
		if contentN == 0 then
			return ""
		end
		
		if contentN >= 3 and content:sub(1, 3) == "\xEF\xBB\xBF" then -- UTF-8 BOM
			return content:sub(4)
		end
		
		if contentN >= 2 then -- UTF-16
			local fmt = fmtMap[content:sub(1, 2)]
			
			if fmt then
				local out = {}
				local outN = 0
				local i = 3
				
				local codepoint
				while i <= contentN do
					codepoint, i = string_unpack(fmt, content, i)
					
					-- Handle surrogate pairs
					if codepoint >= 0xD800 and codepoint <= 0xDBFF and i + 1 <= contentN then
						local low, ni2 = string_unpack(fmt, content, i)
						if low >= 0xDC00 and low <= 0xDFFF then
							codepoint = 0x10000 + ((codepoint - 0xD800) * 0x400) + (low - 0xDC00)
							i = ni2
						end
					end
					
					outN = outN + 1
					out[outN] = utf8_char(codepoint)
				end

				return table_concat(out)
			end
		end
		
		return content -- Assume normal UTF-8
	end
	
	local CustomLimits = ReadTextFile(GetModPath() .. "/CustomLimits.ini")
	local currentHeader
	for line in CustomLimits:gmatch("[^\n\r]+") do
		local header = line:match("^%s*%[(.-)%]%s*$")
		if line:match("^%s*[;#]") then
			-- Comment
		elseif header then
			currentHeader = header
		elseif currentHeader ~= nil then
			local key, value = line:match('^(.-)%s*=%s*"(.-)"$')
			if not key then
				key, value = line:match('^(.-)%s*=%s*(.-)%s*$')
			end
			if key then
				if currentHeader == "Missions" then
					if key == "StageLimit" then
						local stageLimit = tonumber(value)
						if stageLimit then
							Limits.MissionStage = stageLimit
						end
					end
				elseif currentHeader == "Scripting" then
					if key == "ArgumentLengthLimit" then
						local argumentLengthLimit = tonumber(value)
						if argumentLengthLimit then
							ArgumentLengthLimit = argumentLengthLimit - 1
						end
					end
				end
			end
		end
	end
end

local LastPath = nil
local OpenScopes = {}
local Counts = {
	Default = {}
}

local function AddCommand(Command, Hack)
	assert(type(Command.Name) == "string", "Command.Name must be a string")
	assert(type(Command.MinArgs) == "number", "Command.MinArgs must be a number.")
	assert(type(Command.MaxArgs) == "number", "Command.MaxArgs must be a number.")
	assert(Command.IncrementCount == nil or Limits[Command.IncrementCount], "Command.IncrementCount must be a valid limit.")
	
	if Command.CustomOutput then
		Game[Command.Name] = function()
			Output(Command.CustomOutput)
		end
	else
		Game[Command.Name] = function(...)
			local path = GetPath()
			if path ~= LastPath then
				if LastPath ~= nil then
					local stillOpenScopes = {}
					local stillOpenScopesN = 0
					for scope in pairs(OpenScopes) do
						stillOpenScopesN = stillOpenScopesN + 1
						stillOpenScopes[stillOpenScopesN] = scope
					end
					assert(stillOpenScopesN == 0, "New file detected but the following scopes are still open from \"" .. LastPath .. "\": " .. table_concat(stillOpenScopes, ", "))
				end
				LastPath = path
				Counts = {
					Default = {}
				}
			end
			
			local args = {...}
			local argsN = #args
			
			assert(argsN >= Command.MinArgs, Command.Name .. " requires at least " .. Command.MinArgs .. " arguments.")
			assert(argsN <= Command.MaxArgs, Command.Name .. " has a maximum of " .. Command.MaxArgs .. " arguments.")
			
			if Command.RequiresScope then
				assert(OpenScopes[Command.RequiresScope], Command.Name .. " requires scope \"" .. Command.RequiresScope .. "\" but it is not open.")
			end
			if Command.OpensScope then
				assert(OpenScopes[Command.OpensScope] == nil, Command.Name .. " opens scope \"" .. Command.OpensScope .. "\" but it is already open.")
				OpenScopes[Command.OpensScope] = Command.RequiresScope or true
				Counts[Command.OpensScope] = {}
			end
			if Command.ClosesScope then
				assert(OpenScopes[Command.ClosesScope], Command.Name .. " closes scope \"" .. Command.ClosesScope .. "\" but it is not open.")
				OpenScopes[Command.ClosesScope] = nil
				Counts[Command.ClosesScope] = nil
				for scope, requiredScope in pairs(OpenScopes) do
					assert(requiredScope ~= Command.ClosesScope, Command.Name .. " just closed scope \"" .. Command.ClosesScope .. "\" but open scope \"" .. scope .. "\" requires it.")
				end
			end
			
			if Command.IncrementCount then
				local CountsTbl = Command.RequiresScope and Counts[Command.RequiresScope] or Counts["Default"]
				CountsTbl[Command.IncrementCount] = (CountsTbl[Command.IncrementCount] or 0) + 1
				assert(CountsTbl[Command.IncrementCount] <= Limits[Command.IncrementCount], Command.Name .. " increased count of \"" .. Command.IncrementCount .. "\" to " .. CountsTbl[Command.IncrementCount] .. " but there is a limit of " .. Limits[Command.IncrementCount] .. ".")
			end
			
			Output(Command.Name)
			Output("(")
			
			if argsN > 0 then
				for i=1,argsN do
					args[i] = string_gsub(tostring(args[i]), "\"", "\\\"")
					assert(#args[i] <= ArgumentLengthLimit, Command.Name .. " argument " .. i .. "'s length of " .. #args[i] .. " exceeds max length of " .. ArgumentLengthLimit .. ".")
				end
				
				Output("\"")
				Output(table_concat(args, "\",\""))
				Output("\"")
			end
			
			Output(")")
			Output(Command.Conditional and "{" or ";")
		end
		
		if Command.Conditional then
			Game["Not_" .. Command.Name] = function(...)
				Output("!")
				Game[Command.Name](...)
			end
			
			Game["Not"] = Game["Not"] or function()
				Output("!")
			end
			
			Game["EndIf"] = Game["EndIf"] or function()
				Output("}")
			end
			
			HackCommandCounts[Hack] = (HackCommandCounts[Hack] or 0) + 1
		end
	end
	
	HackCommandCounts[Hack] = (HackCommandCounts[Hack] or 0) + 1
end

local function AddInvalidCommand(Command, Hack)
	assert(type(Command.Name) == "string", "Command.Name must be a string.")
	
	Game[Command.Name] = function()
		error(Command.Name .. " can not be used. Required hack \"" .. Hack .. "\" is not loaded.")
	end
	
	if Command.Conditional then	
		Game["Not_" .. Command.Name] = function()
			error(Command.Name .. " can not be used. Required hack \"" .. Hack .. "\" is not loaded.")
		end
		
		HackCommandCounts[Hack] = (HackCommandCounts[Hack] or 0) + 1
	end
	
	HackCommandCounts[Hack] = (HackCommandCounts[Hack] or 0) + 1
end

local function LoadHackCommands(Commands, Hack)
	local Loaded = Hack == nil or IsHackLoaded(Hack)
	Hack = Hack or "Default"
	local AddFunc = Loaded and AddCommand or AddInvalidCommand
	
	local StartTime = GetTime()
	
	for i=1,#Commands do
		AddFunc(Commands[i], Hack)
	end
	
	local EndTime = GetTime()
	
	local CommandCount = HackCommandCounts[Hack]
	print("Game.lua", string.format("%s %d \"%s\" command%s in %.2fms", Loaded and "Loaded" or "Handled", CommandCount, Hack, CommandCount == 1 and "" or "s", (EndTime - StartTime) * 1000))
end

-- Each command required Name, MinArgs and MaxArgs. Optional Conditional.
local DefaultCommands = {
	{ Name = "ActivateTrigger", MinArgs = 1, MaxArgs = 1 },
	{ Name = "ActivateVehicle", MinArgs = 3, MaxArgs = 4, RequiresScope = "Stage", IncrementCount = "StageVehicle" },
	{ Name = "AddAmbientCharacter", MinArgs = 2, MaxArgs = 3 },
	{ Name = "AddAmbientNPCWaypoint", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddAmbientNpcAnimation", MinArgs = 1, MaxArgs = 2 },
	{ Name = "AddAmbientPcAnimation", MinArgs = 1, MaxArgs = 2 },
	{ Name = "AddBehaviour", MinArgs = 2, MaxArgs = 7 },
	{ Name = "AddBonusMission", MinArgs = 1, MaxArgs = 1, IncrementCount = "BonusMission" },
	{ Name = "AddBonusMissionNPCWaypoint", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddBonusObjective", MinArgs = 1, MaxArgs = 2 },
	{ Name = "AddCharacter", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddCollectible", MinArgs = 1, MaxArgs = 4, RequiresScope = "Objective", IncrementCount = "ObjectiveCollectibles" },
	{ Name = "AddCollectibleStateProp", MinArgs = 3, MaxArgs = 3, RequiresScope = "Mission", IncrementCount = "MissionStateProps" },
	{ Name = "AddCondition", MinArgs = 1, MaxArgs = 2, OpensScope = "Condition", RequiresScope = "Stage", IncrementCount = "StageConditions" },
	{ Name = "AddDriver", MinArgs = 2, MaxArgs = 2, RequiresScope = "Objective", IncrementCount = "ObjectiveAddNPCs" },
	{ Name = "AddFlyingActor", MinArgs = 5, MaxArgs = 5 },
	{ Name = "AddFlyingActorByLocator", MinArgs = 3, MaxArgs = 4 },
	{ Name = "AddGagBinding", MinArgs = 5, MaxArgs = 5, IncrementCount = "Gag" },
	{ Name = "AddGlobalProp", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddMission", MinArgs = 1, MaxArgs = 1, IncrementCount = "Mission" },
	{ Name = "AddNPC", MinArgs = 2, MaxArgs = 3, RequiresScope = "Objective", IncrementCount = "ObjectiveAddNPCs" },
	{ Name = "AddNPCCharacterBonusMission", MinArgs = 7, MaxArgs = 8 },
	{ Name = "AddObjective", MinArgs = 1, MaxArgs = 3, OpensScope = "Objective", RequiresScope = "Stage", IncrementCount = "StageObjective" },
	{ Name = "AddObjectiveNPCWaypoint", MinArgs = 2, MaxArgs = 2, RequiresScope = "Objective", IncrementCount = "ObjectiveNPCWaypoints" },
	{ Name = "AddPed", MinArgs = 2, MaxArgs = 2, RequiresScope = "PedGroup" },
	{ Name = "AddPurchaseCarNPCWaypoint", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddPurchaseCarReward", MinArgs = 5, MaxArgs = 6 },
	{ Name = "AddSafeZone", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "AddShield", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddSpawnPoint", MinArgs = 8, MaxArgs = 8, IncrementCount = "SpawnPoint" },
	{ Name = "AddSpawnPointByLocatorScript", MinArgs = 6, MaxArgs = 6, IncrementCount = "SpawnPoint" },
	{ Name = "AddStage", MinArgs = 0, MaxArgs = 7, OpensScope = "Stage", RequiresScope = "Mission", IncrementCount = "MissionStage" },
	{ Name = "AddStageCharacter", MinArgs = 3, MaxArgs = 5, RequiresScope = "Stage", IncrementCount = "StageCharacter" },
	{ Name = "AddStageMusicChange", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "AddStageTime", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "AddStageVehicle", MinArgs = 3, MaxArgs = 5, RequiresScope = "Stage", IncrementCount = "StageVehicle" },
	{ Name = "AddStageWaypoint", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage", IncrementCount = "StageWaypoints" },
	{ Name = "AddTeleportDest", MinArgs = 3, MaxArgs = 5, IncrementCount = "TeleportDests" },
	{ Name = "AddToCountdownSequence", MinArgs = 1, MaxArgs = 2, RequiresScope = "Stage", IncrementCount = "StageCountdownSequence" },
	{ Name = "AddTrafficModel", MinArgs = 2, MaxArgs = 3, RequiresScope = "TrafficGroup" },
	{ Name = "AddVehicleSelectInfo", MinArgs = 3, MaxArgs = 3 },
	{ Name = "AllowMissionAbort", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "AllowRockOut", MinArgs = 0, MaxArgs = 0, RequiresScope = "Objective" },
	{ Name = "AllowUserDump", MinArgs = 0, MaxArgs = 0, RequiresScope = "Objective" },
	{ Name = "AmbientAnimationRandomize", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "AttachStatePropCollectible", MinArgs = 2, MaxArgs = 2, IncrementCount = "MissionStateProps" },
	{ Name = "BindCollectibleTo", MinArgs = 2, MaxArgs = 2, RequiresScope = "Objective" },
	{ Name = "BindReward", MinArgs = 5, MaxArgs = 7 },
	{ Name = "CharacterIsChild", MinArgs = 1, MaxArgs = 1 },
	{ Name = "ClearAmbientAnimations", MinArgs = 1, MaxArgs = 1 },
	{ Name = "ClearGagBindings", MinArgs = 0, MaxArgs = 0 },
	{ Name = "ClearTrafficForStage", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "ClearVehicleSelectInfo", MinArgs = 0, MaxArgs = 0 },
	{ Name = "CloseCondition", MinArgs = 0, MaxArgs = 0, ClosesScope = "Condition", RequiresScope = "Stage" },
	{ Name = "CloseMission", MinArgs = 0, MaxArgs = 0, ClosesScope = "Mission" },
	{ Name = "CloseObjective", MinArgs = 0, MaxArgs = 0, ClosesScope = "Objective", RequiresScope = "Stage" },
	{ Name = "ClosePedGroup", MinArgs = 0, MaxArgs = 0, ClosesScope = "PedGroup" },
	{ Name = "CloseStage", MinArgs = 0, MaxArgs = 0, ClosesScope = "Stage", RequiresScope = "Mission" },
	{ Name = "CloseTrafficGroup", MinArgs = 0, MaxArgs = 0, ClosesScope = "TrafficGroup" },
	{ Name = "CreateActionEventTrigger", MinArgs = 5, MaxArgs = 5 },
	{ Name = "CreateAnimPhysObject", MinArgs = 2, MaxArgs = 2 },
	{ Name = "CreateChaseManager", MinArgs = 3, MaxArgs = 3, IncrementCount = "ChaseManager" },
	{ Name = "CreatePedGroup", MinArgs = 1, MaxArgs = 1, OpensScope = "PedGroup" },
	{ Name = "CreateTrafficGroup", MinArgs = 1, MaxArgs = 1, OpensScope = "TrafficGroup" },
	{ Name = "DeactivateTrigger", MinArgs = 1, MaxArgs = 1 },
	{ Name = "DisableHitAndRun", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "EnableHitAndRun", MinArgs = 0, MaxArgs = 0 },
	{ Name = "EnableTutorialMode", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagBegin", MinArgs = 1, MaxArgs = 1, OpensScope = "Gag", IncrementCount = "Gag" },
	{ Name = "GagCheckCollCards", MinArgs = 5, MaxArgs = 5, RequiresScope = "Gag" },
	{ Name = "GagCheckMovie", MinArgs = 4, MaxArgs = 4, RequiresScope = "Gag" },
	{ Name = "GagEnd", MinArgs = 0, MaxArgs = 0, ClosesScope = "Gag" },
	{ Name = "GagPlayFMV", MinArgs = 1, MaxArgs = 1, RequiresScope = "Gag" },
	{ Name = "GagSetAnimCollision", MinArgs = 1, MaxArgs = 1, RequiresScope = "Gag" },
	{ Name = "GagSetCameraShake", MinArgs = 2, MaxArgs = 3, RequiresScope = "Gag" },
	{ Name = "GagSetCoins", MinArgs = 1, MaxArgs = 2, RequiresScope = "Gag" },
	{ Name = "GagSetCycle", MinArgs = 1, MaxArgs = 1, RequiresScope = "Gag" },
	{ Name = "GagSetInterior", MinArgs = 1, MaxArgs = 1, RequiresScope = "Gag" },
	{ Name = "GagSetIntro", MinArgs = 1, MaxArgs = 1, RequiresScope = "Gag" },
	{ Name = "GagSetLoadDistances", MinArgs = 2, MaxArgs = 2, RequiresScope = "Gag" },
	{ Name = "GagSetOutro", MinArgs = 1, MaxArgs = 1, RequiresScope = "Gag" },
	{ Name = "GagSetPersist", MinArgs = 1, MaxArgs = 1, RequiresScope = "Gag" },
	{ Name = "GagSetPosition", MinArgs = 1, MaxArgs = 3, RequiresScope = "Gag" },
	{ Name = "GagSetRandom", MinArgs = 1, MaxArgs = 1, RequiresScope = "Gag" },
	{ Name = "GagSetSound", MinArgs = 1, MaxArgs = 1, RequiresScope = "Gag" },
	{ Name = "GagSetSoundLoadDistances", MinArgs = 2, MaxArgs = 2, RequiresScope = "Gag" },
	{ Name = "GagSetSparkle", MinArgs = 1, MaxArgs = 1, RequiresScope = "Gag" },
	{ Name = "GagSetTrigger", MinArgs = 3, MaxArgs = 5, RequiresScope = "Gag" },
	{ Name = "GagSetWeight", MinArgs = 1, MaxArgs = 1, RequiresScope = "Gag" },
	{ Name = "GoToPsScreenWhenDone", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "InitLevelPlayerVehicle", MinArgs = 3, MaxArgs = 4 },
	{ Name = "KillAllChaseAI", MinArgs = 1, MaxArgs = 1 },
	{ Name = "LinkActionToObject", MinArgs = 5, MaxArgs = 5 },
	{ Name = "LinkActionToObjectJoint", MinArgs = 5, MaxArgs = 5 },
	{ Name = "LoadDisposableCar", MinArgs = 3, MaxArgs = 3 },
	{ Name = "LoadP3DFile", MinArgs = 1, MaxArgs = 3 },
	{ Name = "MoveStageVehicle", MinArgs = 3, MaxArgs = 3, RequiresScope = "Stage", IncrementCount = "StageVehicle" },
	{ Name = "MustActionTrigger", MinArgs = 0, MaxArgs = 0, RequiresScope = "Objective" },
	{ Name = "NoTrafficForStage", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "PlacePlayerAtLocatorName", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "PlacePlayerCar", MinArgs = 2, MaxArgs = 2 },
	{ Name = "PreallocateActors", MinArgs = 2, MaxArgs = 2 },
	{ Name = "PutMFPlayerInCar", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "RESET_TO_HERE", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "RemoveDriver", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective", IncrementCount = "ObjectiveRemoveNPCs" },
	{ Name = "RemoveNPC", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective", IncrementCount = "ObjectiveRemoveNPCs" },
	{ Name = "ResetCharacter", MinArgs = 2, MaxArgs = 2 },
	{ Name = "ResetHitAndRun", MinArgs = 0, MaxArgs = 0 },
	{ Name = "SelectMission", MinArgs = 1, MaxArgs = 1, OpensScope = "Mission" },
	{ Name = "SetActorRotationSpeed", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetAllowSeatSlide", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetAnimCamMulticontName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetAnimatedCameraName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetBonusMissionDialoguePos", MinArgs = 3, MaxArgs = 4 },
	{ Name = "SetBonusMissionStart", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "SetBrakeScale", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetBurnoutRange", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCMOffsetX", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCMOffsetY", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCMOffsetZ", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCamBestSide", MinArgs = 1, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetCarAttributes", MinArgs = 5, MaxArgs = 5 },
	{ Name = "SetCarStartCamera", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCharacterPosition", MinArgs = 3, MaxArgs = 3 },
	{ Name = "SetCharacterScale", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCharacterToHide", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetCharactersVisible", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetChaseSpawnRate", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetCoinDrawable", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCoinFee", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetCollectibleEffect", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetCollisionAttributes", MinArgs = 4, MaxArgs = 4 },
	{ Name = "SetCompletionDialog", MinArgs = 1, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetCondMinHealth", MinArgs = 1, MaxArgs = 1, RequiresScope = "Condition" },
	{ Name = "SetCondTargetVehicle", MinArgs = 1, MaxArgs = 1, RequiresScope = "Condition" },
	{ Name = "SetCondTime", MinArgs = 1, MaxArgs = 1, RequiresScope = "Condition" },
	{ Name = "SetConditionPosition", MinArgs = 1, MaxArgs = 1, RequiresScope = "Condition" },
	{ Name = "SetConversationCam", MinArgs = 2, MaxArgs = 3, RequiresScope = "Stage" },
	{ Name = "SetConversationCamDistance", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetConversationCamName", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetConversationCamNpcName", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetConversationCamPcName", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetDamperC", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetDemoLoopTime", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetDestination", MinArgs = 1, MaxArgs = 3, RequiresScope = "Objective" },
	{ Name = "SetDialogueInfo", MinArgs = 4, MaxArgs = 4, RequiresScope = "Objective" },
	{ Name = "SetDialoguePositions", MinArgs = 2, MaxArgs = 4, RequiresScope = "Objective" },
	{ Name = "SetDonutTorque", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetDriver", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetDurationTime", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetDynaLoadData", MinArgs = 1, MaxArgs = 2, RequiresScope = "Mission" },
	{ Name = "SetEBrakeEffect", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetFMVInfo", MinArgs = 1, MaxArgs = 2, RequiresScope = "Objective" },
	{ Name = "SetFadeOut", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetFollowDistances", MinArgs = 2, MaxArgs = 2, RequiresScope = "Condition" },
	{ Name = "SetForcedCar", MinArgs = 0, MaxArgs = 0, RequiresScope = "Mission" },
	{ Name = "SetGamblingOdds", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetGameOver", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "SetGasScale", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetGasScaleSpeedThreshold", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHUDIcon", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetHasDoors", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHighRoof", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHighSpeedGasScale", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHighSpeedSteeringDrop", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHitAndRunDecay", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHitAndRunDecayInterior", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHitAndRunMeter", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHitNRun", MinArgs = 0, MaxArgs = 0, RequiresScope = "Condition" },
	{ Name = "SetHitPoints", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetInitialWalk", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetIrisTransition", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetIrisWipe", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetLevelOver", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "SetMass", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMaxSpeedBurstTime", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMaxTraffic", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetMaxWheelTurnAngle", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMissionNameIndex", MinArgs = 1, MaxArgs = 1, RequiresScope = "Mission" },
	{ Name = "SetMissionResetPlayerInCar", MinArgs = 1, MaxArgs = 1, RequiresScope = "Mission" },
	{ Name = "SetMissionResetPlayerOutCar", MinArgs = 2, MaxArgs = 2, RequiresScope = "Mission" },
	{ Name = "SetMissionStartCameraName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMissionStartMulticontName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMusicState", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetNormalSteering", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetNumChaseCars", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetNumValidFailureHints", MinArgs = 1, MaxArgs = 1, RequiresScope = "Mission" },
	{ Name = "SetObjDistance", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetObjTargetBoss", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetObjTargetVehicle", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetParTime", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetParticleTexture", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetPickupTarget", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetPlayerCarName", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetPostLevelFMV", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetPresentationBitmap", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetProjectileStats", MinArgs = 3, MaxArgs = 3 },
	{ Name = "SetRaceEnteryFee", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetRaceLaps", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetRespawnRate", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetShadowAdjustments", MinArgs = 8, MaxArgs = 8 },
	{ Name = "SetShininess", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSlipEffectNoEBrake", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSlipGasScale", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSlipSteering", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSlipSteeringNoEBrake", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSpringK", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageAIEvadeCatchupParams", MinArgs = 3, MaxArgs = 3, RequiresScope = "Stage" },
	{ Name = "SetStageAIRaceCatchupParams", MinArgs = 5, MaxArgs = 5, RequiresScope = "Stage" },
	{ Name = "SetStageAITargetCatchupParams", MinArgs = 3, MaxArgs = 3, RequiresScope = "Stage" },
	{ Name = "SetStageCamera", MinArgs = 3, MaxArgs = 3, RequiresScope = "Stage" },
	{ Name = "SetStageMessageIndex", MinArgs = 1, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetStageMusicAlwaysOn", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "SetStageTime", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetStatepropShadow", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetSuspensionLimit", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSuspensionYOffset", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSwapDefaultCarLocator", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetSwapForcedCarLocator", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetSwapPlayerLocator", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetTalkToTarget", MinArgs = 1, MaxArgs = 4, RequiresScope = "Objective" },
	{ Name = "SetTireGrip", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetTopSpeedKmh", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetTotalGags", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetTotalWasps", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetVehicleAIParams", MinArgs = 3, MaxArgs = 3, RequiresScope = "Stage" },
	{ Name = "SetVehicleToLoad", MinArgs = 3, MaxArgs = 3, RequiresScope = "Objective" },
	{ Name = "SetWeebleOffset", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetWheelieOffsetY", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetWheelieOffsetZ", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetWheelieRange", MinArgs = 1, MaxArgs = 1 },
	{ Name = "ShowHUD", MinArgs = 1, MaxArgs = 1, RequiresScope = "Mission" },
	{ Name = "ShowStageComplete", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "StageStartMusicEvent", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "StartCountdown", MinArgs = 1, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "StayInBlack", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "StreetRacePropsLoad", MinArgs = 1, MaxArgs = 1, RequiresScope = "Mission" },
	{ Name = "StreetRacePropsUnload", MinArgs = 1, MaxArgs = 1, RequiresScope = "Mission" },
	{ Name = "SuppressDriver", MinArgs = 1, MaxArgs = 1, IncrementCount = "SuppressDriver" },
	{ Name = "SwapInDefaultCar", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "TurnGotoDialogOff", MinArgs = 0, MaxArgs = 0, RequiresScope = "Objective" },
	{ Name = "UseElapsedTime", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "UsePedGroup", MinArgs = 1, MaxArgs = 1, RequiresScope = "Mission" },
	{ Name = "msPlacePlayerCarAtLocatorName", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
}

local ASFCommands = {
	{ Name = "AddCondTargetModel", MinArgs = 1, MaxArgs = 1, RequiresScope = "Condition" },
	{ Name = "AddObjTargetModel", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "AddParkedCar", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddStageVehicleCharacter", MinArgs = 2, MaxArgs = 4, RequiresScope = "Stage" },
	{ Name = "AddVehicleCharacter", MinArgs = 1, MaxArgs = 3 },
	{ Name = "AddVehicleCharacterSuppressionCharacter", MinArgs = 2, MaxArgs = 2 },
	{ Name = "CHECKPOINT_HERE", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "DisableTrigger", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "IfCurrentCheckpoint", MinArgs = 0, MaxArgs = 0, Conditional = true, RequiresScope = "Stage" },
	{ Name = "RemoveStageVehicleCharacter", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "ResetStageHitAndRun", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "ResetStageVehicleAbductable", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetCarChangeHitAndRunChange", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCheckpointDynaLoadData", MinArgs = 1, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetCheckpointPedGroup", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetCheckpointResetPlayerInCar", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetCheckpointResetPlayerOutCar", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetCheckpointTrafficGroup", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetCollectibleSoundEffect", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetCondDecay", MinArgs = 1, MaxArgs = 2, RequiresScope = "Condition" },
	{ Name = "SetCondDelay", MinArgs = 1, MaxArgs = 1, RequiresScope = "Condition" },
	{ Name = "SetCondDisplay", MinArgs = 1, MaxArgs = 1, RequiresScope = "Condition" },
	{ Name = "SetCondMessageIndex", MinArgs = 1, MaxArgs = 1, RequiresScope = "Condition" },
	{ Name = "SetCondSound", MinArgs = 1, MaxArgs = 4, RequiresScope = "Condition" },
	{ Name = "SetCondSpeedRangeKMH", MinArgs = 2, MaxArgs = 2, RequiresScope = "Condition" },
	{ Name = "SetCondThreshold", MinArgs = 1, MaxArgs = 1, RequiresScope = "Condition" },
	{ Name = "SetCondTotal", MinArgs = 1, MaxArgs = 1, RequiresScope = "Condition" },
	{ Name = "SetCondTrigger", MinArgs = 1, MaxArgs = 1, RequiresScope = "Condition" },
	{ Name = "SetConditionalParameter", MinArgs = 3, MaxArgs = 5 },
	{ Name = "SetHUDMapDrawable", MinArgs = 1, MaxArgs = 1, RequiresScope = "Mission" },
	{ Name = "SetHitAndRunDecayHitAndRun", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHitAndRunFine", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetNoHitAndRunMusicForStage", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "SetObjCameraName", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetObjCanSkip", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetObjDecay", MinArgs = 1, MaxArgs = 2, RequiresScope = "Objective" },
	{ Name = "SetObjExplosion", MinArgs = 2, MaxArgs = 3, RequiresScope = "Objective" },
	{ Name = "SetObjMessageIndex", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetObjMulticontName", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetObjNoLetterbox", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetObjSound", MinArgs = 1, MaxArgs = 4, RequiresScope = "Objective" },
	{ Name = "SetObjSpeedKMH", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetObjThreshold", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetObjTotal", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetObjTrigger", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetObjUseCameraPosition", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "SetParkedCarsEnabled", MinArgs = 1, MaxArgs = 1, RequiresScope = "Mission" },
	{ Name = "SetPedsEnabled", MinArgs = 1, MaxArgs = 1, RequiresScope = "Mission" },
	{ Name = "SetStageAllowMissionCancel", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetStageCarChangeHitAndRunChange", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetStageCharacterModel", MinArgs = 1, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetStageHitAndRun", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetStageHitAndRunDecay", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetStageHitAndRunDecayHitAndRun", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetStageHitAndRunDecayInterior", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetStageHitAndRunFine", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetStageNumChaseCars", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetStagePayout", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetStageVehicleAbductable", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetStageVehicleAllowSeatSlide", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetStageVehicleCharacterAnimation", MinArgs = 3, MaxArgs = 4, RequiresScope = "Stage" },
	{ Name = "SetStageVehicleCharacterJumpOut", MinArgs = 2, MaxArgs = 3, RequiresScope = "Stage" },
	{ Name = "SetStageVehicleCharacterScale", MinArgs = 3, MaxArgs = 3, RequiresScope = "Stage" },
	{ Name = "SetStageVehicleCharacterVisible", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetStageVehicleNoDestroyedJumpOut", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "SetStageVehicleReset", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "SetVehicleCharacterAnimation", MinArgs = 2, MaxArgs = 3 },
	{ Name = "SetVehicleCharacterJumpOut", MinArgs = 1, MaxArgs = 2 },
	{ Name = "SetVehicleCharacterScale", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetVehicleCharacterVisible", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetWheelieOffsetX", MinArgs = 1, MaxArgs = 1 },
	{ Name = "UseTrafficGroup", MinArgs = 1, MaxArgs = 1, RequiresScope = "Mission" },
}

local DebugTestCommands = {
	{ Name = "DebugBreak", MinArgs = 0, MaxArgs = 0 },
	{ Name = "LucasTest", MinArgs = 0, MaxArgs = 16 },
	{ Name = "Sleep", MinArgs = 1, MaxArgs = 1 },
	{ Name = "TaskMessage", MinArgs = 3, MaxArgs = 4 },
}

LoadHackCommands(DefaultCommands)
LoadHackCommands(ASFCommands, "AdditionalScriptFunctionality")
LoadHackCommands(DebugTestCommands, "DebugTest")

-- If no conditional commands are loaded, add default functions to error.
Game["Not"] = Game["Not"] or function()
	error("Game.Not() can not be used. No conditional commands are loaded.")
end
Game["EndIf"] = Game["EndIf"] or function()
	error("Game.EndIf() can not be used. No conditional commands are loaded.")
end

return Game