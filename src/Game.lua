local assert = assert
local error = error
local tostring = tostring
local type = type

Game = Game or {}
assert(type(Game) == "table", "Global variable \"Game\" must be a table.")

local Game = Game
local HackCommandCounts = {}

local string_gsub = string.gsub

local table_concat = table.concat

local Output = Output

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
			local args = {...}
			local argsN = #args
			
			assert(argsN >= Command.MinArgs, Command.Name .. " requires at least " .. Command.MinArgs .. " arguments.")
			assert(argsN <= Command.MaxArgs, Command.Name .. " has a maximum of " .. Command.MaxArgs .. " arguments.")
			
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
	{ Name = "ActivateVehicle", MinArgs = 3, MaxArgs = 4 },
	{ Name = "AddAmbientCharacter", MinArgs = 2, MaxArgs = 3 },
	{ Name = "AddAmbientNPCWaypoint", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddAmbientNpcAnimation", MinArgs = 1, MaxArgs = 2 },
	{ Name = "AddAmbientPcAnimation", MinArgs = 1, MaxArgs = 2 },
	{ Name = "AddBehaviour", MinArgs = 2, MaxArgs = 7 },
	{ Name = "AddBonusMission", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddBonusMissionNPCWaypoint", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddBonusObjective", MinArgs = 1, MaxArgs = 2 },
	{ Name = "AddCharacter", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddCollectible", MinArgs = 1, MaxArgs = 4 },
	{ Name = "AddCollectibleStateProp", MinArgs = 3, MaxArgs = 3 },
	{ Name = "AddCondition", MinArgs = 1, MaxArgs = 2 },
	{ Name = "AddDriver", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddFlyingActor", MinArgs = 5, MaxArgs = 5 },
	{ Name = "AddFlyingActorByLocator", MinArgs = 3, MaxArgs = 4 },
	{ Name = "AddGagBinding", MinArgs = 5, MaxArgs = 5 },
	{ Name = "AddGlobalProp", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddMission", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddNPC", MinArgs = 2, MaxArgs = 3 },
	{ Name = "AddNPCCharacterBonusMission", MinArgs = 7, MaxArgs = 8 },
	{ Name = "AddObjective", MinArgs = 1, MaxArgs = 3 },
	{ Name = "AddObjectiveNPCWaypoint", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddPed", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddPurchaseCarNPCWaypoint", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddPurchaseCarReward", MinArgs = 5, MaxArgs = 6 },
	{ Name = "AddSafeZone", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddShield", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AddSpawnPoint", MinArgs = 8, MaxArgs = 8 },
	{ Name = "AddSpawnPointByLocatorScript", MinArgs = 6, MaxArgs = 6 },
	{ Name = "AddStage", MinArgs = 0, MaxArgs = 7 },
	{ Name = "AddStageCharacter", MinArgs = 3, MaxArgs = 5 },
	{ Name = "AddStageMusicChange", MinArgs = 0, MaxArgs = 0 },
	{ Name = "AddStageTime", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddStageVehicle", MinArgs = 3, MaxArgs = 5 },
	{ Name = "AddStageWaypoint", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddTeleportDest", MinArgs = 3, MaxArgs = 5 },
	{ Name = "AddToCountdownSequence", MinArgs = 1, MaxArgs = 2 },
	{ Name = "AddTrafficModel", MinArgs = 2, MaxArgs = 3 },
	{ Name = "AddVehicleSelectInfo", MinArgs = 3, MaxArgs = 3 },
	{ Name = "AllowMissionAbort", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AllowRockOut", MinArgs = 0, MaxArgs = 0 },
	{ Name = "AllowUserDump", MinArgs = 0, MaxArgs = 0 },
	{ Name = "AmbientAnimationRandomize", MinArgs = 2, MaxArgs = 2 },
	{ Name = "AttachStatePropCollectible", MinArgs = 2, MaxArgs = 2 },
	{ Name = "BindCollectibleTo", MinArgs = 2, MaxArgs = 2 },
	{ Name = "BindReward", MinArgs = 5, MaxArgs = 7 },
	{ Name = "CharacterIsChild", MinArgs = 1, MaxArgs = 1 },
	{ Name = "ClearAmbientAnimations", MinArgs = 1, MaxArgs = 1 },
	{ Name = "ClearGagBindings", MinArgs = 0, MaxArgs = 0 },
	{ Name = "ClearTrafficForStage", MinArgs = 0, MaxArgs = 0 },
	{ Name = "ClearVehicleSelectInfo", MinArgs = 0, MaxArgs = 0 },
	{ Name = "CloseCondition", MinArgs = 0, MaxArgs = 0 },
	{ Name = "CloseMission", MinArgs = 0, MaxArgs = 0 },
	{ Name = "CloseObjective", MinArgs = 0, MaxArgs = 0 },
	{ Name = "ClosePedGroup", MinArgs = 0, MaxArgs = 0 },
	{ Name = "CloseStage", MinArgs = 0, MaxArgs = 0 },
	{ Name = "CloseTrafficGroup", MinArgs = 0, MaxArgs = 0 },
	{ Name = "CreateActionEventTrigger", MinArgs = 5, MaxArgs = 5 },
	{ Name = "CreateAnimPhysObject", MinArgs = 2, MaxArgs = 2 },
	{ Name = "CreateChaseManager", MinArgs = 3, MaxArgs = 3 },
	{ Name = "CreatePedGroup", MinArgs = 1, MaxArgs = 1 },
	{ Name = "CreateTrafficGroup", MinArgs = 1, MaxArgs = 1 },
	{ Name = "DeactivateTrigger", MinArgs = 1, MaxArgs = 1 },
	{ Name = "DisableHitAndRun", MinArgs = 0, MaxArgs = 0 },
	{ Name = "EnableHitAndRun", MinArgs = 0, MaxArgs = 0 },
	{ Name = "EnableTutorialMode", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagBegin", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagCheckCollCards", MinArgs = 5, MaxArgs = 5 },
	{ Name = "GagCheckMovie", MinArgs = 4, MaxArgs = 4 },
	{ Name = "GagEnd", MinArgs = 0, MaxArgs = 0 },
	{ Name = "GagPlayFMV", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagSetAnimCollision", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagSetCameraShake", MinArgs = 2, MaxArgs = 3 },
	{ Name = "GagSetCoins", MinArgs = 1, MaxArgs = 2 },
	{ Name = "GagSetCycle", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagSetInterior", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagSetIntro", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagSetLoadDistances", MinArgs = 2, MaxArgs = 2 },
	{ Name = "GagSetOutro", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagSetPersist", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagSetPosition", MinArgs = 1, MaxArgs = 3 },
	{ Name = "GagSetRandom", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagSetSound", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagSetSoundLoadDistances", MinArgs = 2, MaxArgs = 2 },
	{ Name = "GagSetSparkle", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GagSetTrigger", MinArgs = 3, MaxArgs = 5 },
	{ Name = "GagSetWeight", MinArgs = 1, MaxArgs = 1 },
	{ Name = "GoToPsScreenWhenDone", MinArgs = 0, MaxArgs = 0 },
	{ Name = "InitLevelPlayerVehicle", MinArgs = 3, MaxArgs = 4 },
	{ Name = "KillAllChaseAI", MinArgs = 1, MaxArgs = 1 },
	{ Name = "LinkActionToObject", MinArgs = 5, MaxArgs = 5 },
	{ Name = "LinkActionToObjectJoint", MinArgs = 5, MaxArgs = 5 },
	{ Name = "LoadDisposableCar", MinArgs = 3, MaxArgs = 3 },
	{ Name = "LoadP3DFile", MinArgs = 1, MaxArgs = 3 },
	{ Name = "MoveStageVehicle", MinArgs = 3, MaxArgs = 3 },
	{ Name = "MustActionTrigger", MinArgs = 0, MaxArgs = 0 },
	{ Name = "NoTrafficForStage", MinArgs = 0, MaxArgs = 0 },
	{ Name = "PlacePlayerAtLocatorName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "PlacePlayerCar", MinArgs = 2, MaxArgs = 2 },
	{ Name = "PreallocateActors", MinArgs = 2, MaxArgs = 2 },
	{ Name = "PutMFPlayerInCar", MinArgs = 0, MaxArgs = 0 },
	{ Name = "RESET_TO_HERE", MinArgs = 0, MaxArgs = 0 },
	{ Name = "RemoveDriver", MinArgs = 1, MaxArgs = 1 },
	{ Name = "RemoveNPC", MinArgs = 1, MaxArgs = 1 },
	{ Name = "ResetCharacter", MinArgs = 2, MaxArgs = 2 },
	{ Name = "ResetHitAndRun", MinArgs = 0, MaxArgs = 0 },
	{ Name = "SelectMission", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetActorRotationSpeed", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetAllowSeatSlide", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetAnimCamMulticontName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetAnimatedCameraName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetBonusMissionDialoguePos", MinArgs = 3, MaxArgs = 4 },
	{ Name = "SetBonusMissionStart", MinArgs = 0, MaxArgs = 0 },
	{ Name = "SetBrakeScale", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetBurnoutRange", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCMOffsetX", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCMOffsetY", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCMOffsetZ", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCamBestSide", MinArgs = 1, MaxArgs = 2 },
	{ Name = "SetCarAttributes", MinArgs = 5, MaxArgs = 5 },
	{ Name = "SetCarStartCamera", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCharacterPosition", MinArgs = 3, MaxArgs = 3 },
	{ Name = "SetCharacterScale", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCharacterToHide", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCharactersVisible", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetChaseSpawnRate", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetCoinDrawable", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCoinFee", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCollectibleEffect", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCollisionAttributes", MinArgs = 4, MaxArgs = 4 },
	{ Name = "SetCompletionDialog", MinArgs = 1, MaxArgs = 2 },
	{ Name = "SetCondMinHealth", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCondTargetVehicle", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCondTime", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetConditionPosition", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetConversationCam", MinArgs = 2, MaxArgs = 3 },
	{ Name = "SetConversationCamDistance", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetConversationCamName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetConversationCamNpcName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetConversationCamPcName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetDamperC", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetDemoLoopTime", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetDestination", MinArgs = 1, MaxArgs = 3 },
	{ Name = "SetDialogueInfo", MinArgs = 4, MaxArgs = 4 },
	{ Name = "SetDialoguePositions", MinArgs = 2, MaxArgs = 4 },
	{ Name = "SetDonutTorque", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetDriver", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetDurationTime", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetDynaLoadData", MinArgs = 1, MaxArgs = 2 },
	{ Name = "SetEBrakeEffect", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetFMVInfo", MinArgs = 1, MaxArgs = 2 },
	{ Name = "SetFadeOut", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetFollowDistances", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetForcedCar", MinArgs = 0, MaxArgs = 0 },
	{ Name = "SetGamblingOdds", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetGameOver", MinArgs = 0, MaxArgs = 0 },
	{ Name = "SetGasScale", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetGasScaleSpeedThreshold", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHUDIcon", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHasDoors", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHighRoof", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHighSpeedGasScale", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHighSpeedSteeringDrop", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHitAndRunDecay", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHitAndRunDecayInterior", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHitAndRunMeter", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHitNRun", MinArgs = 0, MaxArgs = 0 },
	{ Name = "SetHitPoints", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetInitialWalk", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetIrisTransition", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetIrisWipe", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetLevelOver", MinArgs = 0, MaxArgs = 0 },
	{ Name = "SetMass", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMaxSpeedBurstTime", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMaxTraffic", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMaxWheelTurnAngle", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMissionNameIndex", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMissionResetPlayerInCar", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMissionResetPlayerOutCar", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetMissionStartCameraName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMissionStartMulticontName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetMusicState", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetNormalSteering", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetNumChaseCars", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetNumValidFailureHints", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjDistance", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjTargetBoss", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjTargetVehicle", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetParTime", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetParticleTexture", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetPickupTarget", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetPlayerCarName", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetPostLevelFMV", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetPresentationBitmap", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetProjectileStats", MinArgs = 3, MaxArgs = 3 },
	{ Name = "SetRaceEnteryFee", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetRaceLaps", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetRespawnRate", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetShadowAdjustments", MinArgs = 8, MaxArgs = 8 },
	{ Name = "SetShininess", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSlipEffectNoEBrake", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSlipGasScale", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSlipSteering", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSlipSteeringNoEBrake", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSpringK", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageAIEvadeCatchupParams", MinArgs = 3, MaxArgs = 3 },
	{ Name = "SetStageAIRaceCatchupParams", MinArgs = 5, MaxArgs = 5 },
	{ Name = "SetStageAITargetCatchupParams", MinArgs = 3, MaxArgs = 3 },
	{ Name = "SetStageCamera", MinArgs = 3, MaxArgs = 3 },
	{ Name = "SetStageMessageIndex", MinArgs = 1, MaxArgs = 2 },
	{ Name = "SetStageMusicAlwaysOn", MinArgs = 0, MaxArgs = 0 },
	{ Name = "SetStageTime", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStatepropShadow", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetSuspensionLimit", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSuspensionYOffset", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSwapDefaultCarLocator", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSwapForcedCarLocator", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetSwapPlayerLocator", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetTalkToTarget", MinArgs = 1, MaxArgs = 4 },
	{ Name = "SetTireGrip", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetTopSpeedKmh", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetTotalGags", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetTotalWasps", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetVehicleAIParams", MinArgs = 3, MaxArgs = 3 },
	{ Name = "SetVehicleToLoad", MinArgs = 3, MaxArgs = 3 },
	{ Name = "SetWeebleOffset", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetWheelieOffsetY", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetWheelieOffsetZ", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetWheelieRange", MinArgs = 1, MaxArgs = 1 },
	{ Name = "ShowHUD", MinArgs = 1, MaxArgs = 1 },
	{ Name = "ShowStageComplete", MinArgs = 0, MaxArgs = 0 },
	{ Name = "StageStartMusicEvent", MinArgs = 1, MaxArgs = 1 },
	{ Name = "StartCountdown", MinArgs = 1, MaxArgs = 2 },
	{ Name = "StayInBlack", MinArgs = 0, MaxArgs = 0 },
	{ Name = "StreetRacePropsLoad", MinArgs = 1, MaxArgs = 1 },
	{ Name = "StreetRacePropsUnload", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SuppressDriver", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SwapInDefaultCar", MinArgs = 0, MaxArgs = 0 },
	{ Name = "TurnGotoDialogOff", MinArgs = 0, MaxArgs = 0 },
	{ Name = "UseElapsedTime", MinArgs = 0, MaxArgs = 0 },
	{ Name = "UsePedGroup", MinArgs = 1, MaxArgs = 1 },
	{ Name = "msPlacePlayerCarAtLocatorName", MinArgs = 1, MaxArgs = 1 },
	-- Special Conditional Stuff
	{ Name = "Not", MinArgs = 0, MaxArgs = 0, CustomOutput = "!" },
	{ Name = "EndIf", MinArgs = 0, MaxArgs = 0, CustomOutput = "}" },
}

local ASFCommands = {
	{ Name = "AddCondTargetModel", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddObjTargetModel", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddParkedCar", MinArgs = 1, MaxArgs = 1 },
	{ Name = "AddStageVehicleCharacter", MinArgs = 2, MaxArgs = 4 },
	{ Name = "AddVehicleCharacter", MinArgs = 1, MaxArgs = 3 },
	{ Name = "AddVehicleCharacterSuppressionCharacter", MinArgs = 2, MaxArgs = 2 },
	{ Name = "CHECKPOINT_HERE", MinArgs = 0, MaxArgs = 0 },
	{ Name = "DisableTrigger", MinArgs = 1, MaxArgs = 1 },
	{ Name = "IfCurrentCheckpoint", MinArgs = 0, MaxArgs = 0, Conditional = true },
	{ Name = "RemoveStageVehicleCharacter", MinArgs = 2, MaxArgs = 2 },
	{ Name = "ResetStageHitAndRun", MinArgs = 0, MaxArgs = 0 },
	{ Name = "ResetStageVehicleAbductable", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCarChangeHitAndRunChange", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCheckpointDynaLoadData", MinArgs = 1, MaxArgs = 2 },
	{ Name = "SetCheckpointPedGroup", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCheckpointResetPlayerInCar", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCheckpointResetPlayerOutCar", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetCheckpointTrafficGroup", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCollectibleSoundEffect", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCondDecay", MinArgs = 1, MaxArgs = 2 },
	{ Name = "SetCondDelay", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCondDisplay", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCondMessageIndex", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCondSound", MinArgs = 1, MaxArgs = 4 },
	{ Name = "SetCondSpeedRangeKMH", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetCondThreshold", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCondTotal", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetCondTrigger", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetConditionalParameter", MinArgs = 3, MaxArgs = 5 },
	{ Name = "SetHUDMapDrawable", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHitAndRunDecayHitAndRun", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetHitAndRunFine", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetNoHitAndRunMusicForStage", MinArgs = 0, MaxArgs = 0 },
	{ Name = "SetObjCameraName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjCanSkip", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjDecay", MinArgs = 1, MaxArgs = 2 },
	{ Name = "SetObjExplosion", MinArgs = 2, MaxArgs = 3 },
	{ Name = "SetObjMessageIndex", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjMulticontName", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjNoLetterbox", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjSound", MinArgs = 1, MaxArgs = 4 },
	{ Name = "SetObjSpeedKMH", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjThreshold", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjTotal", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjTrigger", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetObjUseCameraPosition", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetParkedCarsEnabled", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetPedsEnabled", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageAllowMissionCancel", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageCarChangeHitAndRunChange", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageCharacterModel", MinArgs = 1, MaxArgs = 2 },
	{ Name = "SetStageHitAndRun", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageHitAndRunDecay", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageHitAndRunDecayHitAndRun", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageHitAndRunDecayInterior", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageHitAndRunFine", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageNumChaseCars", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStagePayout", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageVehicleAbductable", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetStageVehicleAllowSeatSlide", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetStageVehicleCharacterAnimation", MinArgs = 3, MaxArgs = 4 },
	{ Name = "SetStageVehicleCharacterJumpOut", MinArgs = 2, MaxArgs = 3 },
	{ Name = "SetStageVehicleCharacterScale", MinArgs = 3, MaxArgs = 3 },
	{ Name = "SetStageVehicleCharacterVisible", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetStageVehicleNoDestroyedJumpOut", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetStageVehicleReset", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetVehicleCharacterAnimation", MinArgs = 2, MaxArgs = 3 },
	{ Name = "SetVehicleCharacterJumpOut", MinArgs = 1, MaxArgs = 2 },
	{ Name = "SetVehicleCharacterScale", MinArgs = 2, MaxArgs = 2 },
	{ Name = "SetVehicleCharacterVisible", MinArgs = 1, MaxArgs = 1 },
	{ Name = "SetWheelieOffsetX", MinArgs = 1, MaxArgs = 1 },
	{ Name = "UseTrafficGroup", MinArgs = 1, MaxArgs = 1 },
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

return Game