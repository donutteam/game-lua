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

local table_concat = table.concat

local GetPath = GetPath
local Output = Output

local LastPath = nil
local OpenScopes = {}

local function AddCommand(Command, Hack)
	assert(type(Command.Name) == "string", "Command.Name must be a string")
	assert(type(Command.MinArgs) == "number", "Command.MinArgs must be a number.")
	assert(type(Command.MaxArgs) == "number", "Command.MaxArgs must be a number.")
	
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
			end
			if Command.ClosesScope then
				assert(OpenScopes[Command.ClosesScope], Command.Name .. " closes scope \"" .. Command.ClosesScope .. "\" but it is not open.")
				OpenScopes[Command.ClosesScope] = nil
				for scope, requiredScope in pairs(OpenScopes) do
					assert(requiredScope ~= Command.ClosesScope, Command.Name .. " just closed scope \"" .. Command.ClosesScope .. "\" but open scope \"" .. scope .. "\" requires it.")
				end
			end
			
			Output(Command.Name)
			Output("(")
			
			if argsN > 0 then
				for i=1,argsN do
					args[i] = string_gsub(tostring(args[i]), "\"", "\\\"")
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
	{ Name = "ActivateVehicle", MinArgs = 3, MaxArgs = 4, RequiresScope = "Stage" },
	{ Name = "AddAmbientCharacter", MinArgs = 2, MaxArgs = 3 },
	{ Name = "AddAmbientNPCWaypoint", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddAmbientNpcAnimation", MinArgs = 1, MaxArgs = 2 },
	{ Name = "AddAmbientPcAnimation", MinArgs = 1, MaxArgs = 2 },
	{ Name = "AddBehaviour", MinArgs = 2, MaxArgs = 7 },
	{ Name = "AddBonusMission", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddBonusMissionNPCWaypoint", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddBonusObjective", MinArgs = 1, MaxArgs = 2 },
	{ Name = "AddCharacter", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddCollectible", MinArgs = 1, MaxArgs = 4, RequiresScope = "Objective" },
	{ Name = "AddCollectibleStateProp", MinArgs = 3, MaxArgs = 3, RequiresScope = "Mission" },
	{ Name = "AddCondition", MinArgs = 1, MaxArgs = 2, OpensScope = "Condition", RequiresScope = "Stage" },
	{ Name = "AddDriver", MinArgs = 2, MaxArgs = 2, RequiresScope = "Objective" },
	{ Name = "AddFlyingActor", MinArgs = 5, MaxArgs = 5 },
	{ Name = "AddFlyingActorByLocator", MinArgs = 3, MaxArgs = 4 },
	{ Name = "AddGagBinding", MinArgs = 5, MaxArgs = 5 },
	{ Name = "AddGlobalProp", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddMission", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddNPC", MinArgs = 2, MaxArgs = 3, RequiresScope = "Objective" },
	{ Name = "AddNPCCharacterBonusMission", MinArgs = 7, MaxArgs = 8 },
	{ Name = "AddObjective", MinArgs = 1, MaxArgs = 3, OpensScope = "Objective", RequiresScope = "Stage" },
	{ Name = "AddObjectiveNPCWaypoint", MinArgs = 2, MaxArgs = 2, RequiresScope = "Objective" },
	{ Name = "AddPed", MinArgs = 2, MaxArgs = 2, RequiresScope = "PedGroup" },
	{ Name = "AddPurchaseCarNPCWaypoint", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddPurchaseCarReward", MinArgs = 5, MaxArgs = 6 },
	{ Name = "AddSafeZone", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "AddShield", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddSpawnPoint", MinArgs = 8, MaxArgs = 8 },
	{ Name = "AddSpawnPointByLocatorScript", MinArgs = 6, MaxArgs = 6 },
	{ Name = "AddStage", MinArgs = 0, MaxArgs = 7, OpensScope = "Stage", RequiresScope = "Mission" },
	{ Name = "AddStageCharacter", MinArgs = 3, MaxArgs = 5, RequiresScope = "Stage" },
	{ Name = "AddStageMusicChange", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "AddStageTime", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "AddStageVehicle", MinArgs = 3, MaxArgs = 5, RequiresScope = "Stage" },
	{ Name = "AddStageWaypoint", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "AddTeleportDest", MinArgs = 3, MaxArgs = 5 },
	{ Name = "AddToCountdownSequence", MinArgs = 1, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "AddTrafficModel", MinArgs = 2, MaxArgs = 3, RequiresScope = "TrafficGroup" },
	{ Name = "AddVehicleSelectInfo", MinArgs = 3, MaxArgs = 3 },
	{ Name = "AllowMissionAbort", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "AllowRockOut", MinArgs = 0, MaxArgs = 0, RequiresScope = "Objective" },
	{ Name = "AllowUserDump", MinArgs = 0, MaxArgs = 0, RequiresScope = "Objective" },
	{ Name = "AmbientAnimationRandomize", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "AttachStatePropCollectible", MinArgs = 2, MaxArgs = 2 },
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
	{ Name = "CreateChaseManager", MinArgs = 3, MaxArgs = 3 },
	{ Name = "CreatePedGroup", MinArgs = 1, MaxArgs = 1, OpensScope = "PedGroup" },
	{ Name = "CreateTrafficGroup", MinArgs = 1, MaxArgs = 1, OpensScope = "TrafficGroup" },
	{ Name = "DeactivateTrigger", MinArgs = 1, MaxArgs = 1 },
	{ Name = "DisableHitAndRun", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "EnableHitAndRun", MinArgs = 0, MaxArgs = 0 },
	{ Name = "EnableTutorialMode", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagBegin", MinArgs = 1, MaxArgs = 1, OpensScope = "Gag" },
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
	{ Name = "MoveStageVehicle", MinArgs = 3, MaxArgs = 3, RequiresScope = "Stage" },
	{ Name = "MustActionTrigger", MinArgs = 0, MaxArgs = 0, RequiresScope = "Objective" },
	{ Name = "NoTrafficForStage", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "PlacePlayerAtLocatorName", MinArgs = 1, MaxArgs = 1, RequiresScope = "Stage" },
	{ Name = "PlacePlayerCar", MinArgs = 2, MaxArgs = 2, RequiresScope = "Stage" },
	{ Name = "PreallocateActors", MinArgs = 2, MaxArgs = 2 },
	{ Name = "PutMFPlayerInCar", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "RESET_TO_HERE", MinArgs = 0, MaxArgs = 0, RequiresScope = "Stage" },
	{ Name = "RemoveDriver", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
	{ Name = "RemoveNPC", MinArgs = 1, MaxArgs = 1, RequiresScope = "Objective" },
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
	{ Name = "SuppressDriver", MinArgs = 1, MaxArgs = 1 },
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
	{ Name = "SetConditionalParameter", MinArgs = 3, MaxArgs = 5, RequiresScope = "Condition" },
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