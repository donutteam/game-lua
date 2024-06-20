---@meta

error("Meta files should not be executed.")

--
-- Types
--

---@alias GameTypes.GagCycleType "cycle" | "default" | "reset" | "single"

---@alias GameTypes.GagTriggerType "action" | "touch"

-- MAYBE: This should maybe include "AI" because the game checks for it but that's weird as fuck
---@alias GameTypes.PlayerVehicleSlotType "DEFAULT" | "OTHER"

--
-- Globals
--

Game = {}

-- TODO: ActivateTrigger (Min: 1, Max: 1)

-- TODO: ActivateVehicle (Min: 3, Max: 4)

-- TODO: AddAmbientCharacter (Min: 2, Max: 3)

-- TODO: AddAmbientNPCWaypoint (Min: 2, Max: 2)

-- TODO: AddAmbientNpcAnimation (Min: 1, Max: 2)

-- TODO: AddAmbientPcAnimation (Min: 1, Max: 2)

-- TODO: AddBehaviour (Min: 2, Max: 7)

-- TODO: AddBonusMission (Min: 1, Max: 1)

-- TODO: AddBonusMissionNPCWaypoint (Min: 2, Max: 2)

-- TODO: AddBonusObjective (Min: 1, Max: 2)

---Adds a player character to the level.
---
---@param CharacterName string The name of the character to add.
---@param ChoreographyName string The name of the choreography to use.
function Game.AddCharacter(CharacterName, ChoreographyName) end

-- TODO: AddCollectible (Min: 1, Max: 4)

-- TODO: AddCollectibleStateProp (Min: 3, Max: 3)

-- TODO: AddCondition (Min: 1, Max: 2)

-- TODO: AddDriver (Min: 2, Max: 2)

-- TODO: AddFlyingActor (Min: 5, Max: 5)

-- TODO: AddFlyingActorByLocator (Min: 3, Max: 4)

---Binds a gag to an interior.
---
---@param InteriorName string The name of the interior to bind the gag to.
---@param GagFileName string The name of the gag file to load. Relative to "art/nis/gags".
---@param CycleType "cycle" | "default" | "single" The cycle type of the gag.
---@param Weight integer The probability of selecting this gag.
---@param SoundResourceName string The name of the sound resource to play.
function Game.AddGagBinding(InteriorName, GagFileName, CycleType, Weight, SoundResourceName) end

---Does nothing.
---
---@param UnusedArgument1 any
function Game.AddGlobalProp(UnusedArgument1) end

-- TODO: AddMission (Min: 1, Max: 1)

-- TODO: AddNPC (Min: 2, Max: 3)

-- TODO: AddNPCCharacterBonusMission (Min: 7, Max: 8)

-- TODO: AddObjective (Min: 1, Max: 3)

-- TODO: AddObjectiveNPCWaypoint (Min: 2, Max: 2)

---Adds a ped to the current ped group.
---
---@param CharacterName string The name of the character to add.
---@param MaxAmount integer The maximum amount of this character that can appear at once.
function Game.AddPed(CharacterName, MaxAmount) end

-- TODO: AddPurchaseCarNPCWaypoint (Min: 2, Max: 2)

---Adds a purchase car NPC to the level.
---
---Note: The game registers this command as taking 5-6 arguments but it actually requires 6.
---
---@param ShopName "gil" | "simpson" The name of the car shop this NPC uses.
---@param CharacterName string The name of the character to add.
---@param CharacterAnimationSetName string The name of the animation set to use.
---@param CharacterLocatorName string The name of the locator to place the character at.
---@param CharacterTriggerRadius number The radius of the trigger around the character.
---@param CarLocatorName string The name of the locator to place the car at.
function Game.AddPurchaseCarReward(ShopName, CharacterName, CharacterAnimationSetName, CharacterLocatorName, CharacterTriggerRadius, CarLocatorName) end

-- TODO: AddSafeZone (Min: 2, Max: 2)

-- TODO: AddShield (Min: 2, Max: 2)

-- TODO: AddSpawnPoint (Min: 8, Max: 8)

-- TODO: AddSpawnPointByLocatorScript (Min: 6, Max: 6)

-- TODO: AddStage (Min: 0, Max: 7)

-- TODO: AddStageCharacter (Min: 3, Max: 5)

-- TODO: AddStageMusicChange (Min: 0, Max: 0)

-- TODO: AddStageTime (Min: 1, Max: 1)

-- TODO: AddStageVehicle (Min: 3, Max: 5)

-- TODO: AddStageWaypoint (Min: 1, Max: 1)

-- TODO: AddTeleportDest (Min: 3, Max: 5)

-- TODO: AddToCountdownSequence (Min: 1, Max: 2)

---Adds a traffic model to the current traffic group.
---
---@param CarName string The name of the car to add.
---@param Amount integer The amount of this car to add.
---@param IsParkedCar integer | nil When set to 1, this car can appear in parking spaces.
function Game.AddTrafficModel(CarName, Amount, IsParkedCar) end

---Does nothing.
---
---This is used by Radical in the base game, but it does nothing.
---
---@param UnusedArgument1 any
---@param UnusedArgument2 any
---@param UnusedArgument3 any
function Game.AddVehicleSelectInfo(UnusedArgument1, UnusedArgument2, UnusedArgument3) end

-- TODO: AllowMissionAbort (Min: 1, Max: 1)

-- TODO: AllowRockOut (Min: 0, Max: 0)

-- TODO: AllowUserDump (Min: 0, Max: 0)

-- TODO: AmbientAnimationRandomize (Min: 2, Max: 2)

-- TODO: AttachStatePropCollectible (Min: 2, Max: 2)

-- TODO: BindCollectibleTo (Min: 2, Max: 2)

-- TODO: BindReward (Min: 5, Max: 7)

-- TODO: CharacterIsChild (Min: 1, Max: 1)

-- TODO: ClearAmbientAnimations (Min: 1, Max: 1)

---Clears gag bindings.
function Game.ClearGagBindings() end

-- TODO: ClearTrafficForStage (Min: 0, Max: 0)

---Does nothing.
---
---This is used by Radical in the base game, but it does nothing.
function Game.ClearVehicleSelectInfo() end

-- TODO: CloseCondition (Min: 0, Max: 0)

---Closes the mission being initialised.
function Game.CloseMission() end

-- TODO: CloseObjective (Min: 0, Max: 0)

---Ends initializing the current ped group.
function Game.ClosePedGroup() end

-- TODO: CloseStage (Min: 0, Max: 0)

---Ends initializing the current traffic group.
function Game.CloseTrafficGroup() end

-- TODO: CreateActionEventTrigger (Min: 5, Max: 5)

-- TODO: CreateAnimPhysObject (Min: 2, Max: 2)

---Creates a chase manager for the level.
---
---@param VehicleName string The name of the vehicle to initialise.
---@param CONFilePath string The path to the CON file for the vehicle. Relative to "scripts/cars".
---@param SpawnRate number The spawn rate of the vehicles. This does effectively nothing when there is only one model for the chase manager to use, the maximum amount supported by the game.
function Game.CreateChaseManager(VehicleName, CONFilePath, SpawnRate) end

---Starts initializing a new ped group.
---
---@param PedGroupIndex integer The index of the ped group to create.
function Game.CreatePedGroup(PedGroupIndex) end

---Initializes a new traffic group.
---
---@param TrafficGroupIndex integer The index of the traffic group to create.
function Game.CreateTrafficGroup(TrafficGroupIndex) end

-- TODO: DeactivateTrigger (Min: 1, Max: 1)

-- TODO: DisableHitAndRun (Min: 0, Max: 0)

-- TODO: EnableHitAndRun (Min: 0, Max: 0)

-- TODO: EnableTutorialMode (Min: 1, Max: 1)

---Adds a gag to the level.
---
---@param GagFileName string The file name of the gag. Relative to "art/nis/gags".
function Game.GagBegin(GagFileName) end

---Sets various attributes for the special collector card gag.
---
---@param CharacterName1 string The name of the first character. This or CharacterName2 should be the player.
---@param CharacterName2 string The name of the second character. This or CharacterName1 should be the player.
---@param AcceptConversationName string The name of the conversation to play when the player interacts with the gag with a complete set of cards.
---@param InstructConversationName string The name of the conversation to play when the player interacts with the gag for the first time.
---@param RejectConversationName string The name of the conversation to play when the player interacts with the gag with an incomplete set of cards.
function Game.GagCheckCollCards(CharacterName1, CharacterName2, AcceptConversationName, InstructConversationName, RejectConversationName) end

---Sets an FMV or conversation to play when interacting with the NPC with or without a complete set of cards respectively.
---
---@param CharacterName1 string The name of the first character. This or CharacterName2 should be the player.
---@param CharacterName2 string The name of the second character. This or CharacterName1 should be the player.
---@param FMVName string The name of the FMV to play when the player interacts with the NPC with a complete set of cards.
---@param RejectConversationName string The name of the conversation to play when the player interacts with the NPC without a complete set of cards.
function Game.GagCheckMovie(CharacterName1, CharacterName2, FMVName, RejectConversationName) end

---Ends the gag being initialised.
function Game.GagEnd() end

---Plays an FMV after interacting with the gag.
---
---@param FMVName string The file name of the FMV. Relative to "movies". Note that this has a max of 13 characters, including the extension.
function Game.GagPlayFMV(FMVName) end

---Sets if the gag has animated collision.
---
---@param HasAnimatedCollision integer Whether the gag has animated collision.
function Game.GagSetAnimCollision(HasAnimatedCollision) end

---Makes the camera shake after interacting with the gag.
---
---@param DelaySeconds number The delay before the camera shake.
---@param Force number The force of the camera shake.
---@param DurationSeconds number | nil The duration of the camera shake.
function Game.GagSetCameraShake(DelaySeconds, Force, DurationSeconds) end

---Spawns coins after interacting with the gag.
---
---@param Quantity integer The quantity of coins to spawn.
---@param DelaySeconds number | nil The delay before spawning the coins. Optional, defaults to 1.0. Furthermore, 0.0 will be the same as 1.0.
function Game.GagSetCoins(Quantity, DelaySeconds) end

---Sets the type of cycle this gag uses.
---
---@param CycleType GameTypes.GagCycleType The cycle type.
function Game.GagSetCycle(CycleType) end

---Sets the gag to be in the specified interior.
---
---@param InteriorName string The name of the interior to put the gag in.
function Game.GagSetInterior(InteriorName) end

---Makes the specified number of frames at the start of the gag's animation loop until it is interacted with.
---
---@param NumberOfIntroFrames integer The number of frames to loop.
function Game.GagSetIntro(NumberOfIntroFrames) end

---Overrides the load distances for the gag.
---
---@param LoadDistance number The load distance. Defaults to 100.
---@param UnloadDistance number The unload distance. Defaults to 150.
function Game.GagSetLoadDistances(LoadDistance, UnloadDistance) end

---Makes the specified number of frames at the end of the gag's animation loop after it is interacted with.
---
---@param NumberOfOutroFrames integer The number of frames to loop.
function Game.GagSetOutro(NumberOfOutroFrames) end

---Sets if whether you've interacted with the gag is saved to the save file.
---
---@param IsPersisted integer Whether the gag is saved.
function Game.GagSetPersist(IsPersisted) end

---Sets the position of the gag using a locator.
---
---@param LocatorName string The name of the locator to put the gag at.
function Game.GagSetPosition(LocatorName) end

---Sets the position of the gag using coordinates.
---
---@param X number The X coordinate.
---@param Y number The Y coordinate.
---@param Z number The Z coordinate.
function Game.GagSetPosition(X, Y, Z) end

---Sets whether the gag is randomised.
---
---@param IsRandom integer Whether the gag is randomised.
function Game.GagSetRandom(IsRandom) end

---Sets the sound played when interacting with the gag.
---
---@param SoundResourceName string The name of the sound resource to play.
function Game.GagSetSound(SoundResourceName) end

---Overrides the sound load distances for the gag.
---
---@param LoadDistance number The load distance. Defaults to 10.
---@param UnloadDistance number The unload distance. Defaults to 20.
function Game.GagSetSoundLoadDistances(LoadDistance, UnloadDistance) end

---Sets if the gag has sparkles on it.
---
---@param HasSparkles integer Whether the gag has sparkles.
function Game.GagSetSparkle(HasSparkles) end

---Sets the trigger type, position (using a locator) and radius of the gag.
---
---@param Type GameTypes.GagTriggerType The trigger type.
---@param LocatorName string The name of the locator to put the trigger at.
---@param Radius number The radius of the trigger.
function Game.GagSetTrigger(Type, LocatorName, Radius) end

---Sets the trigger type, position (using coordinates) and radius of the gag.
---
---@param Type GameTypes.GagTriggerType The trigger type.
---@param X number The X coordinate.
---@param Y number The Y coordinate.
---@param Z number The Z coordinate.
---@param Radius number The radius of the trigger.
function Game.GagSetTrigger(Type, X, Y, Z, Radius) end

---Sets the probability of selecting this gag when its set to random.
---
---@param Weight integer The probability of selecting this gag.
function Game.GagSetWeight(Weight) end

-- TODO: GoToPsScreenWhenDone (Min: 0, Max: 0)

---Initialises a vehicle for the level or a forced car mission.
---
---@param VehicleName string The name of the vehicle to initialise.
---@param LocatorName string The name of the locator to put the vehicle at.
---@param VehicleSlot GameTypes.PlayerVehicleSlotType The vehicle slot to put the vehicle in.
---@param CONFilePath string | nil The path to the CON file for the vehicle. Optional. Relative to "scripts/cars".
function Game.InitLevelPlayerVehicle(VehicleName, LocatorName, VehicleSlot, CONFilePath) end

-- TODO: KillAllChaseAI (Min: 1, Max: 1)

-- TODO: LinkActionToObject (Min: 5, Max: 5)

-- TODO: LinkActionToObjectJoint (Min: 5, Max: 5)

-- TODO: LoadDisposableCar (Min: 3, Max: 3)

-- TODO: LoadP3DFile (Min: 1, Max: 3)

-- TODO: MoveStageVehicle (Min: 3, Max: 3)

-- TODO: MustActionTrigger (Min: 0, Max: 0)

-- TODO: NoTrafficForStage (Min: 0, Max: 0)

-- TODO: PlacePlayerAtLocatorName (Min: 1, Max: 1)

---Places the player's car at a locator.
---
---@param CarName "current" The name of the car to place. This only actually supports "current" to place the player's current car.
---@param LocatorName string The name of the locator to place the car at.
function Game.PlacePlayerCar(CarName, LocatorName) end

-- TODO: PreallocateActors (Min: 2, Max: 2)

-- TODO: PutMFPlayerInCar (Min: 0, Max: 0)

-- TODO: RESET_TO_HERE (Min: 0, Max: 0)

-- TODO: RemoveDriver (Min: 1, Max: 1)

-- TODO: RemoveNPC (Min: 1, Max: 1)

-- TODO: ResetCharacter (Min: 2, Max: 2)

-- TODO: ResetHitAndRun (Min: 0, Max: 0)

---Sets what mission is being initialised.
---
---@param MissionIdentifier string The mission identifier such as m0, m0sd or sr1.
function Game.SelectMission(MissionIdentifier) end

-- TODO: SetActorRotationSpeed (Min: 2, Max: 2)

-- TODO: SetAllowSeatSlide (Min: 1, Max: 1)

-- TODO: SetAnimCamMulticontName (Min: 1, Max: 1)

-- TODO: SetAnimatedCameraName (Min: 1, Max: 1)

-- TODO: SetBonusMissionDialoguePos (Min: 3, Max: 4)

-- TODO: SetBonusMissionStart (Min: 0, Max: 0)

-- TODO: SetBrakeScale (Min: 1, Max: 1)

-- TODO: SetBurnoutRange (Min: 1, Max: 1)

-- TODO: SetCMOffsetX (Min: 1, Max: 1)

-- TODO: SetCMOffsetY (Min: 1, Max: 1)

-- TODO: SetCMOffsetZ (Min: 1, Max: 1)

-- TODO: SetCamBestSide (Min: 1, Max: 2)

-- TODO: SetCarAttributes (Min: 5, Max: 5)

-- TODO: SetCarStartCamera (Min: 1, Max: 1)

-- TODO: SetCharacterPosition (Min: 3, Max: 3)

-- TODO: SetCharacterScale (Min: 1, Max: 1)

-- TODO: SetCharacterToHide (Min: 1, Max: 1)

-- TODO: SetCharactersVisible (Min: 1, Max: 1)

-- TODO: SetChaseSpawnRate (Min: 2, Max: 2)

-- TODO: SetCoinDrawable (Min: 1, Max: 1)

-- TODO: SetCoinFee (Min: 1, Max: 1)

-- TODO: SetCollectibleEffect (Min: 1, Max: 1)

-- TODO: SetCollisionAttributes (Min: 4, Max: 4)

-- TODO: SetCompletionDialog (Min: 1, Max: 2)

-- TODO: SetCondMinHealth (Min: 1, Max: 1)

-- TODO: SetCondTargetVehicle (Min: 1, Max: 1)

-- TODO: SetCondTime (Min: 1, Max: 1)

-- TODO: SetConditionPosition (Min: 1, Max: 1)

-- TODO: SetConversationCam (Min: 2, Max: 3)

-- TODO: SetConversationCamDistance (Min: 2, Max: 2)

-- TODO: SetConversationCamName (Min: 1, Max: 1)

-- TODO: SetConversationCamNpcName (Min: 1, Max: 1)

-- TODO: SetConversationCamPcName (Min: 1, Max: 1)

-- TODO: SetDamperC (Min: 1, Max: 1)

-- TODO: SetDemoLoopTime (Min: 1, Max: 1)

-- TODO: SetDestination (Min: 1, Max: 3)

-- TODO: SetDialogueInfo (Min: 4, Max: 4)

-- TODO: SetDialoguePositions (Min: 2, Max: 4)

-- TODO: SetDonutTorque (Min: 1, Max: 1)

-- TODO: SetDriver (Min: 1, Max: 1)

-- TODO: SetDurationTime (Min: 1, Max: 1)

-- TODO: SetDynaLoadData (Min: 1, Max: 2)

-- TODO: SetEBrakeEffect (Min: 1, Max: 1)

-- TODO: SetFMVInfo (Min: 1, Max: 2)

-- TODO: SetFadeOut (Min: 1, Max: 1)

-- TODO: SetFollowDistances (Min: 2, Max: 2)

-- TODO: SetForcedCar (Min: 0, Max: 0)

-- TODO: SetGamblingOdds (Min: 1, Max: 1)

-- TODO: SetGameOver (Min: 0, Max: 0)

-- TODO: SetGasScale (Min: 1, Max: 1)

-- TODO: SetGasScaleSpeedThreshold (Min: 1, Max: 1)

-- TODO: SetHUDIcon (Min: 1, Max: 1)

-- TODO: SetHasDoors (Min: 1, Max: 1)

-- TODO: SetHighRoof (Min: 1, Max: 1)

-- TODO: SetHighSpeedGasScale (Min: 1, Max: 1)

-- TODO: SetHighSpeedSteeringDrop (Min: 1, Max: 1)

-- TODO: SetHitAndRunDecay (Min: 1, Max: 1)

-- TODO: SetHitAndRunDecayInterior (Min: 1, Max: 1)

-- TODO: SetHitAndRunMeter (Min: 1, Max: 1)

-- TODO: SetHitNRun (Min: 0, Max: 0)

-- TODO: SetHitPoints (Min: 1, Max: 1)

-- TODO: SetInitialWalk (Min: 1, Max: 1)

-- TODO: SetIrisTransition (Min: 1, Max: 1)

-- TODO: SetIrisWipe (Min: 1, Max: 1)

-- TODO: SetLevelOver (Min: 0, Max: 0)

-- TODO: SetMass (Min: 1, Max: 1)

-- TODO: SetMaxSpeedBurstTime (Min: 1, Max: 1)

-- TODO: SetMaxTraffic (Min: 1, Max: 1)

-- TODO: SetMaxWheelTurnAngle (Min: 1, Max: 1)

-- TODO: SetMissionNameIndex (Min: 1, Max: 1)

-- TODO: SetMissionResetPlayerInCar (Min: 1, Max: 1)

-- TODO: SetMissionResetPlayerOutCar (Min: 2, Max: 2)

-- TODO: SetMissionStartCameraName (Min: 1, Max: 1)

-- TODO: SetMissionStartMulticontName (Min: 1, Max: 1)

-- TODO: SetMusicState (Min: 2, Max: 2)

-- TODO: SetNormalSteering (Min: 1, Max: 1)

-- TODO: SetNumChaseCars (Min: 1, Max: 1)

-- TODO: SetNumValidFailureHints (Min: 1, Max: 1)

-- TODO: SetObjDistance (Min: 1, Max: 1)

-- TODO: SetObjTargetBoss (Min: 1, Max: 1)

-- TODO: SetObjTargetVehicle (Min: 1, Max: 1)

-- TODO: SetParTime (Min: 1, Max: 1)

-- TODO: SetParticleTexture (Min: 2, Max: 2)

-- TODO: SetPickupTarget (Min: 1, Max: 1)

-- TODO: SetPlayerCarName (Min: 2, Max: 2)

-- TODO: SetPostLevelFMV (Min: 1, Max: 1)

-- TODO: SetPresentationBitmap (Min: 1, Max: 1)

-- TODO: SetProjectileStats (Min: 3, Max: 3)

-- TODO: SetRaceEnteryFee (Min: 1, Max: 1)

-- TODO: SetRaceLaps (Min: 1, Max: 1)

-- TODO: SetRespawnRate (Min: 2, Max: 2)

-- TODO: SetShadowAdjustments (Min: 8, Max: 8)

-- TODO: SetShininess (Min: 1, Max: 1)

-- TODO: SetSlipEffectNoEBrake (Min: 1, Max: 1)

-- TODO: SetSlipGasScale (Min: 1, Max: 1)

-- TODO: SetSlipSteering (Min: 1, Max: 1)

-- TODO: SetSlipSteeringNoEBrake (Min: 1, Max: 1)

-- TODO: SetSpringK (Min: 1, Max: 1)

-- TODO: SetStageAIEvadeCatchupParams (Min: 3, Max: 3)

-- TODO: SetStageAIRaceCatchupParams (Min: 5, Max: 5)

-- TODO: SetStageAITargetCatchupParams (Min: 3, Max: 3)

-- TODO: SetStageCamera (Min: 3, Max: 3)

-- TODO: SetStageMessageIndex (Min: 1, Max: 2)

-- TODO: SetStageMusicAlwaysOn (Min: 0, Max: 0)

-- TODO: SetStageTime (Min: 1, Max: 1)

-- TODO: SetStatepropShadow (Min: 2, Max: 2)

-- TODO: SetSuspensionLimit (Min: 1, Max: 1)

-- TODO: SetSuspensionYOffset (Min: 1, Max: 1)

-- TODO: SetSwapDefaultCarLocator (Min: 1, Max: 1)

-- TODO: SetSwapForcedCarLocator (Min: 1, Max: 1)

-- TODO: SetSwapPlayerLocator (Min: 1, Max: 1)

-- TODO: SetTalkToTarget (Min: 1, Max: 4)

-- TODO: SetTireGrip (Min: 1, Max: 1)

-- TODO: SetTopSpeedKmh (Min: 1, Max: 1)

-- TODO: SetTotalGags (Min: 2, Max: 2)

-- TODO: SetTotalWasps (Min: 2, Max: 2)

-- TODO: SetVehicleAIParams (Min: 3, Max: 3)

-- TODO: SetVehicleToLoad (Min: 3, Max: 3)

-- TODO: SetWeebleOffset (Min: 1, Max: 1)

-- TODO: SetWheelieOffsetY (Min: 1, Max: 1)

-- TODO: SetWheelieOffsetZ (Min: 1, Max: 1)

-- TODO: SetWheelieRange (Min: 1, Max: 1)

-- TODO: ShowHUD (Min: 1, Max: 1)

-- TODO: ShowStageComplete (Min: 0, Max: 0)

-- TODO: StageStartMusicEvent (Min: 1, Max: 1)

-- TODO: StartCountdown (Min: 1, Max: 2)

-- TODO: StayInBlack (Min: 0, Max: 0)

-- TODO: StreetRacePropsLoad (Min: 1, Max: 1)

-- TODO: StreetRacePropsUnload (Min: 1, Max: 1)

-- TODO: SuppressDriver (Min: 1, Max: 1)

-- TODO: SwapInDefaultCar (Min: 0, Max: 0)

-- TODO: TurnGotoDialogOff (Min: 0, Max: 0)

-- TODO: UseElapsedTime (Min: 0, Max: 0)

---Sets the ped group used when restarting the mission.
---
---@param PedGroupIndex integer The ped group index.
function Game.UsePedGroup(PedGroupIndex) end

-- TODO: msPlacePlayerCarAtLocatorName (Min: 1, Max: 1)
