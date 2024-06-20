---@meta

error("Meta files should not be executed.")

--
-- Types
--

---@alias GameTypes.AIType "NULL" | "chase" | "evade" | "race" | "target"

---@alias GameTypes.GagCycleType "cycle" | "default" | "reset" | "single"

---@alias GameTypes.GagTriggerType "action" | "touch"

-- MAYBE: This should maybe include "AI" because the game checks for it but that's weird as fuck
---@alias GameTypes.PlayerVehicleSlotType "DEFAULT" | "OTHER"

---@alias GameTypes.RewardQuestType "bonusmission" | "cards" | "defaultcar" | "defaultskin" | "forsale" | "goldcards" | "streetrace"

---@alias GameTypes.RewardSellerType "gil" | "interior" | "simpson"

---@alias GameTypes.RewardType "car" | "skin"

---@alias GameTypes.RoadArrowType "BOTH" | "both" | "b" | "NEITHER" | "neither" | "n" | "INTERSECTION" | "intersection" | "i" | "NEAREST ROAD" | "nearest road"

--
-- Globals
--

Game = {}

-- TODO: ActivateTrigger (Min: 1, Max: 1)

---Activates a vehicle added with AddStageVehicle in a previous stage.
---
---@param VehicleName string The name of the vehicle to activate.
---@param LocatorName string The name of the locator to add the vehicle to. Use "NULL" to keep the vehicle in its current location.
---@param AIType GameTypes.AIType The AI type of the vehicle.
---@param DriverName string | nil The name of the driver for the vehicle. Optional.
function Game.ActivateVehicle(VehicleName, LocatorName, AIType, DriverName) end

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

---Adds a collectible to a stage.
---
---For "delivery" objectives, these are the items the player must collect to complete the stage.
---
---For "dump" objectives, these are the items the player must obtain from the target vehicle.
---
---For "race" objectives, these are the waypoints the player must pass to complete the race.
---
---@param LocatorName string The name of the locator to add the collectible to. The position of the locator does not matter for "dump" objectives.
---@param DrawableName string | nil The name of the drawable to use.
---@param NoBoxConversationName string | nil The name of the conversation to play when the collectible is picked up. Optional.
---@param NoBoxConversationCharacterName string | nil The name of a second character in the conversation. Optional if the only character talking is the player.
function Game.AddCollectible(LocatorName, DrawableName, NoBoxConversationName, NoBoxConversationCharacterName) end

-- TODO: AddCollectibleStateProp (Min: 3, Max: 3)

---Adds a condition to a stage.
---
---@param ConditionType string The type of condition to add.
function Game.AddCondition(ConditionType) end

---Adds a "carryingspcollectible" condition to a stage.
---
---Radical does not use this type of condition in the base game.
---
---@param ConditionType "carryingspcollectible" The carryingspcollectible condition type.
---@param CollectibleName string | nil The name of the collectible to carry. Technically optional, but the player will always fail if its not specified.
function Game.AddCondition(ConditionType, CollectibleName) end

---Adds a "keepbarrel" condition to a stage.
---
---@param ConditionType "keepbarrel" The keepbarrel condition type.
---@param NumberOfStagesToGoBack integer | nil The number of stages to go back if the user drops the barrel. Optional, defaults to 1.
function Game.AddCondition(ConditionType, NumberOfStagesToGoBack) end

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

---Adds an NPC to an objective.
---
---@param NPCName string The name of the NPC to add.
---@param LocatorName string The name of the locator to add the NPC to.
---@param UnusedArgument3 any Unused by the game.
function Game.AddNPC(NPCName, LocatorName, UnusedArgument3) end

-- TODO: AddNPCCharacterBonusMission (Min: 7, Max: 8)

---Adds an objective to a stage.
---
---@param ObjectiveType string The type of objective to add.
---@param RoadArrowType GameTypes.RoadArrowType | nil Indicates where road arrows should be placed when guiding the player to their destination.
function Game.AddObjective(ObjectiveType, RoadArrowType) end

---Adds a "buycar" or "buyskin" objective to a stage.
---
---@param ObjectiveType "buycar" | "buyskin" The buycar/buyskin objective type.
---@param CarOrSkinName string The name of the car or skin to buy.
---@param RoadArrowType GameTypes.RoadArrowType | nil Indicates where road arrows should be placed when guiding the player to their destination.
function Game.AddObjective(ObjectiveType, CarOrSkinName, RoadArrowType) end

---Adds a "getin" objective where you must get into a specific car.
---
---Note: The car must be the player's current car or the specificity will be ignored.
---
---@param ObjectiveType "getin" The getin objective type.
---@param CarName string The name of the car to get into.
function Game.AddObjective(ObjectiveType, CarName) end

---Adds a gamble "race" objective to a stage.
---
---@param ObjectiveType "race" The race objective type.
---@param Gamble "gamble" Specifying "gamble" as the second argument indicates this is a gamble race.
---@param RoadArrowType GameTypes.RoadArrowType | nil Indicates where road arrows should be placed when guiding the player to their destination.
function Game.AddObjective(ObjectiveType, Gamble, RoadArrowType) end

-- TODO: AddObjectiveNPCWaypoint (Min: 2, Max: 2)

---Adds a ped to the current ped group.
---
---@param CharacterName string The name of the character to add.
---@param MaxAmount integer The maximum amount of this character that can appear at once.
function Game.AddPed(CharacterName, MaxAmount) end

-- TODO: AddPurchaseCarNPCWaypoint (Min: 2, Max: 2)

---Adds a purchase car NPC to the level.
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

---Adds a stage to the mission.
---
---When using 0 to 2 arguments, the string "final" as either argument tells the game to do final stage things, like showing "Mission Complete!". This probably shouldn't be used in Sunday Drive Missions.
---
---Other values when using 0 to 2 arguments, such as numbers like how Radical often uses, are ignored.
---
---@param Argument1 any
---@param Argument2 any
function Game.AddStage(Argument1, Argument2) end

---Adds a locked stage to the mission requiring one car or skin.
---
---Should probably only be used in Sunday Drive missions.
---
---@param Locked "locked" The word "locked".
---@param LockedType "car" | "skin" The type of thing the player must have.
---@param RequiredCarOrSkinName string The name of the car or skin the player must have.
function Game.AddStage(Locked, LockedType, RequiredCarOrSkinName) end

---Adds a locked stage to the mission requiring two cars and/or skins.
---
---Of course, the player can only have one of each at a time so you probably want to specify one car AND one skin.
---
---Should probably only be used in Sunday Drive missions.
---
---@param Locked1 "locked" The word "locked".
---@param LockedType1 "car" | "skin" The type of thing the player must have.
---@param RequiredCarOrSkinName1 string The name of the car or skin the player must have.
---@param Locked2 "locked" The word "locked".
---@param LockedType2 "car" | "skin" The type of thing the player must have.
---@param RequiredCarOrSkinName2 string The name of the car or skin the player must have.
function Game.AddStage(Locked1, LockedType1, RequiredCarOrSkinName1, Locked2, LockedType2, RequiredCarOrSkinName2) end

-- TODO: AddStageCharacter (Min: 3, Max: 5)

-- TODO: AddStageMusicChange (Min: 0, Max: 0)

---Adds time to an existing stage timer upon reaching the stage.
---
---@param TimeSeconds integer The amount of time to add to the stage timer in seconds.
function Game.AddStageTime(TimeSeconds) end

---Adds a vehicle to a stage.
---
---@param VehicleName string The name of the vehicle to add.
---@param LocatorName string The name of the locator to add the vehicle to.
---@param AIType GameTypes.AIType The AI type of the vehicle.
---@param CONFilePath string | nil The path to the CON file for the vehicle. Optional. Relative to "scripts/cars".
---@param DriverName string | nil The name of the driver for the vehicle. Optional.
function Game.AddStageVehicle(VehicleName, LocatorName, AIType, CONFilePath, DriverName) end

---Adds a waypoint for AI cars to follow in a stage.
---
---@param LocatorName string The name of the locator to add the waypoint to.
function Game.AddStageWaypoint(LocatorName) end

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

---Binds a reward to a quest type.
---
---@param Name string The name of the reward.
---@param FilePath string The file path of the reward.
---@param Type GameTypes.RewardType The type of the reward.
---@param QuestType GameTypes.RewardQuestType The quest type to bind the reward to.
---@param Level integer The level to bind the reward to.
function Game.BindReward(Name, FilePath, Type, QuestType, Level) end

---Binds a reward to the "forsale" quest type.
---
---@param Name string The name of the reward.
---@param FilePath string The file path of the reward.
---@param Type GameTypes.RewardType The type of the reward.
---@param QuestType "forsale" The "forsale" quest type.
---@param Level integer The level to bind the reward to.
---@param CoinCost integer The cost of the reward in coins.
---@param Seller GameTypes.RewardSellerType The car shop to obtain the reward from.
function Game.BindReward(Name, FilePath, Type, QuestType, Level, CoinCost, Seller) end

-- TODO: CharacterIsChild (Min: 1, Max: 1)

-- TODO: ClearAmbientAnimations (Min: 1, Max: 1)

---Clears gag bindings.
function Game.ClearGagBindings() end

-- TODO: ClearTrafficForStage (Min: 0, Max: 0)

---Does nothing.
---
---This is used by Radical in the base game, but it does nothing.
function Game.ClearVehicleSelectInfo() end

---Closes the condition being initialised.
function Game.CloseCondition() end

---Closes the mission being initialised.
function Game.CloseMission() end

---Closes the objective being initialised.
function Game.CloseObjective() end

---Ends initializing the current ped group.
function Game.ClosePedGroup() end

---Closes the stage being initialised.
function Game.CloseStage() end

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

---Requires the player to interact with the trigger in a "goto" objective to complete the stage.
function Game.MustActionTrigger() end

-- TODO: NoTrafficForStage (Min: 0, Max: 0)

-- TODO: PlacePlayerAtLocatorName (Min: 1, Max: 1)

---Places the player's car at a locator.
---
---@param CarName "current" The name of the car to place. This only actually supports "current" to place the player's current car.
---@param LocatorName string The name of the locator to place the car at.
function Game.PlacePlayerCar(CarName, LocatorName) end

-- TODO: PreallocateActors (Min: 2, Max: 2)

-- TODO: PutMFPlayerInCar (Min: 0, Max: 0)

---Sets this stage as the starting point when selecting or restarting the mission.
function Game.RESET_TO_HERE() end

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

---Sets the phone booth attributes for a car.
---
---@param CarName string The name of the car.
---@param TopSpeed number The top speed of the car.
---@param Acceleration number The acceleration of the car.
---@param Toughness number The toughness of the car.
---@param Handling number The handling of the car.
function Game.SetCarAttributes(CarName, TopSpeed, Acceleration, Toughness, Handling) end

-- TODO: SetCarStartCamera (Min: 1, Max: 1)

-- TODO: SetCharacterPosition (Min: 3, Max: 3)

-- TODO: SetCharacterScale (Min: 1, Max: 1)

-- TODO: SetCharacterToHide (Min: 1, Max: 1)

-- TODO: SetCharactersVisible (Min: 1, Max: 1)

-- TODO: SetChaseSpawnRate (Min: 2, Max: 2)

-- TODO: SetCoinDrawable (Min: 1, Max: 1)

-- TODO: SetCoinFee (Min: 1, Max: 1)

---Sets the effect drawable when picking up collectibles in "goto" objectives and other objectives with collectibles.
---
---@param DrawableName string The name of the drawable to use.
function Game.SetCollectibleEffect(DrawableName) end

-- TODO: SetCollisionAttributes (Min: 4, Max: 4)

---Sets dialog to play upon completing the stage.
---
---@param NoBoxConversationName string The name of the conversation to play.
---@param NoBoxConversationCharacterName string | nil The name of a second character in the conversation. Optional if the only character talking is the player.
function Game.SetCompletionDialog(NoBoxConversationName, NoBoxConversationCharacterName) end

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

---Sets the destination for an objective.
---
---For "gooutside" and "goto" objectives, this specifies the locator whose trigger(s) you must enter.
---
---For "interior" objectives, this specifies the interior you must enter.
---
---@param InteriorOrLocatorName string The name of the interior or locator to go to, depending on the objective type.
---@param FirstTriggerScale number | nil Scales the locator's first trigger, if it's a sphere trigger. Defaults to 1.
function Game.SetDestination(InteriorOrLocatorName, FirstTriggerScale) end

---Sets the destination for an objective.
---
---For "gooutside" and "goto" objectives, this specifies the locator whose trigger(s) you must enter.
---
---For "interior" objectives, this specifies the interior you must enter.
---
---@param InteriorOrLocatorName string The name of the interior or locator to go to, depending on the objective type.
---@param DrawableName string | nil The name of the drawable to use. Optional.
---@param FirstTriggerScale number | nil Scales the locator's first trigger, if it's a sphere trigger. Defaults to 1.
function Game.SetDestination(InteriorOrLocatorName, DrawableName, FirstTriggerScale) end

-- TODO: SetDialogueInfo (Min: 4, Max: 4)

---Sets the character positions for a "dialogue" objective.
---
---@param CharacterLocator1 string A locator name.
---@param CharacterLocator2 string A locator name.
---@param UnusedCarLocator string | nil A locator name. Unused by the game.
---@param DoNotResetCharacters integer | nil If this is 1, the game will not attempt to put the characters back to where they were when the dialogue started.
function Game.SetDialoguePositions(CharacterLocator1, CharacterLocator2, UnusedCarLocator, DoNotResetCharacters) end

-- TODO: SetDonutTorque (Min: 1, Max: 1)

-- TODO: SetDriver (Min: 1, Max: 1)

---Sets the amount of time a "timer" objective should last.
---
---@param TimeSeconds integer The amount of time in seconds.
function Game.SetDurationTime(TimeSeconds) end

---Sets dyna load data to be executed when restarting the mission.
---
---@param DynaLoadData string A dyna load data string.
---@param InteriorName string | nil The name of the interior the player starts in, if they start in one.
function Game.SetDynaLoadData(DynaLoadData, InteriorName) end

-- TODO: SetEBrakeEffect (Min: 1, Max: 1)

-- TODO: SetFMVInfo (Min: 1, Max: 2)

-- TODO: SetFadeOut (Min: 1, Max: 1)

-- TODO: SetFollowDistances (Min: 2, Max: 2)

-- TODO: SetForcedCar (Min: 0, Max: 0)

-- TODO: SetGamblingOdds (Min: 1, Max: 1)

-- TODO: SetGameOver (Min: 0, Max: 0)

-- TODO: SetGasScale (Min: 1, Max: 1)

-- TODO: SetGasScaleSpeedThreshold (Min: 1, Max: 1)

---Sets the HUD icon for a stage.
---
---@param IconName string The name of the HUD icon sprite, minus the ".png" extension. Max length of 11 characters.
function Game.SetHUDIcon(IconName) end

-- TODO: SetHasDoors (Min: 1, Max: 1)

-- TODO: SetHighRoof (Min: 1, Max: 1)

-- TODO: SetHighSpeedGasScale (Min: 1, Max: 1)

-- TODO: SetHighSpeedSteeringDrop (Min: 1, Max: 1)

-- TODO: SetHitAndRunDecay (Min: 1, Max: 1)

-- TODO: SetHitAndRunDecayInterior (Min: 1, Max: 1)

-- TODO: SetHitAndRunMeter (Min: 1, Max: 1)

-- TODO: SetHitNRun (Min: 0, Max: 0)

-- TODO: SetHitPoints (Min: 1, Max: 1)

---Sets a locator that the character will walk to from their starting position at the beginning of the mission.
---
---@param LocatorName string A locator name. Max length of 64 characters.
function Game.SetInitialWalk(LocatorName) end

-- TODO: SetIrisTransition (Min: 1, Max: 1)

-- TODO: SetIrisWipe (Min: 1, Max: 1)

-- TODO: SetLevelOver (Min: 0, Max: 0)

-- TODO: SetMass (Min: 1, Max: 1)

-- TODO: SetMaxSpeedBurstTime (Min: 1, Max: 1)

---Sets the maximum amount of traffic when starting a stage.
---
---@param MaxTraffic integer The maximum amount of traffic cars.
function Game.SetMaxTraffic(MaxTraffic) end

-- TODO: SetMaxWheelTurnAngle (Min: 1, Max: 1)

-- TODO: SetMissionNameIndex (Min: 1, Max: 1)

---Makes the player get reset inside their car at the specified locator name when restarting the mission.
---
---@param CarLocatorName string A locator name.
function Game.SetMissionResetPlayerInCar(CarLocatorName) end

---Makes the player get reset outside their car at the specified locator name when restarting the mission.
---
---@param PlayerLocatorName string A locator name.
---@param CarLocatorName string A locator name.
function Game.SetMissionResetPlayerOutCar(PlayerLocatorName, CarLocatorName) end

-- TODO: SetMissionStartCameraName (Min: 1, Max: 1)

-- TODO: SetMissionStartMulticontName (Min: 1, Max: 1)

---Sets the music state for a stage.
---
---@param StateName string The name of the music state.
---@param StateValue string The value of the music state.
function Game.SetMusicState(StateName, StateValue) end

-- TODO: SetNormalSteering (Min: 1, Max: 1)

-- TODO: SetNumChaseCars (Min: 1, Max: 1)

-- TODO: SetNumValidFailureHints (Min: 1, Max: 1)

-- TODO: SetObjDistance (Min: 1, Max: 1)

-- TODO: SetObjTargetBoss (Min: 1, Max: 1)

---Sets the target vehicle for an objective.
---
---For "destroy" objectives, this sets the vehicle to destroy.
---
---For "dump" objectives, this sets the vehicle to hit.
---
---For "follow" objectives, this sets the vehicle to follow.
---
---For "getin" objectives, this does nothing even though Radical attempts to use it this way.
---
---For "losetail" objectives, this sets the vehicle to lose.
---
---@param VehicleName string The name of the vehicle to target.
function Game.SetObjTargetVehicle(VehicleName) end

-- TODO: SetParTime (Min: 1, Max: 1)

-- TODO: SetParticleTexture (Min: 2, Max: 2)

-- TODO: SetPickupTarget (Min: 1, Max: 1)

-- TODO: SetPlayerCarName (Min: 2, Max: 2)

-- TODO: SetPostLevelFMV (Min: 1, Max: 1)

---Sets the current presentation bitmap.
---
---@param P3DFilePath string The path to a P3D file containing the presentation bitmap Sprite.
function Game.SetPresentationBitmap(P3DFilePath) end

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

---Sets the message index for a stage.
---
---In regular stages, this is the message that shows up in the message box and uses MISSION_OBJECTIVE_* strings.
---
---In locked stages, this is the message that shows up in the full screen message box and uses INGAME_MESSAGE_* strings.
---
---@param MessageIndex integer The message index.
---@param UnusedArgument2 any Unused by the game.
function Game.SetStageMessageIndex(MessageIndex, UnusedArgument2) end

---Makes the stage's music stay on even when the player is not in a vehicle.
function Game.SetStageMusicAlwaysOn() end

---Sets the amount of time the player has to complete the stage.
---
---@param TimeSeconds integer The amount of time in seconds.
function Game.SetStageTime(TimeSeconds) end

-- TODO: SetStatepropShadow (Min: 2, Max: 2)

-- TODO: SetSuspensionLimit (Min: 1, Max: 1)

-- TODO: SetSuspensionYOffset (Min: 1, Max: 1)

-- TODO: SetSwapDefaultCarLocator (Min: 1, Max: 1)

-- TODO: SetSwapForcedCarLocator (Min: 1, Max: 1)

-- TODO: SetSwapPlayerLocator (Min: 1, Max: 1)

-- TODO: SetTalkToTarget (Min: 1, Max: 4)

-- TODO: SetTireGrip (Min: 1, Max: 1)

-- TODO: SetTopSpeedKmh (Min: 1, Max: 1)

---Sets the amount of gags in the specified level.
---
---@param LevelNumber integer The level number to set the gags for.
---@param NumberOfGags integer The amount of gags in the level.
function Game.SetTotalGags(LevelNumber, NumberOfGags) end

---Sets the amount of wasp cameras in the specified level.
---
---@param LevelNumber integer The level number to set the wasp cameras for.
---@param NumberOfWasps integer The amount of wasp cameras in the level.
function Game.SetTotalWasps(LevelNumber, NumberOfWasps) end

---Sets what types of shortcuts an AI vehicle will try to take.
---
---@param VehicleName string The name of the vehicle to set the AI params for.
---@param MinimumShortcutSkill integer The minimum skill level for taking shortcuts.
---@param MaximumShortcutSkill integer The maximum skill level for taking shortcuts.
function Game.SetVehicleAIParams(VehicleName, MinimumShortcutSkill, MaximumShortcutSkill) end

-- TODO: SetVehicleToLoad (Min: 3, Max: 3)

-- TODO: SetWeebleOffset (Min: 1, Max: 1)

-- TODO: SetWheelieOffsetY (Min: 1, Max: 1)

-- TODO: SetWheelieOffsetZ (Min: 1, Max: 1)

-- TODO: SetWheelieRange (Min: 1, Max: 1)

-- TODO: ShowHUD (Min: 1, Max: 1)

---Makes the stage show the "TASK COMPLETE!" message when completed.
function Game.ShowStageComplete() end

---Starts a music event at the start of the stage.
---
---@param EventName string The name of the music event to start.
function Game.StageStartMusicEvent(EventName) end

-- TODO: StartCountdown (Min: 1, Max: 2)

-- TODO: StayInBlack (Min: 0, Max: 0)

---Sets regions to load for the mission.
---
---Calling this command also disables parked cars and peds for the duration of the mission. 
---
---You can use SetParkedCarsEnabled and SetPedsEnabled in the AdditionalScriptFunctionality hack to re-enable them.
---
---@param DynaLoadData string A dyna load data string.
function Game.StreetRacePropsLoad(DynaLoadData) end

---Sets regions to unload for the mission.
---
---@param DynaLoadData string A dyna load data string.
function Game.StreetRacePropsUnload(DynaLoadData) end

-- TODO: SuppressDriver (Min: 1, Max: 1)

-- TODO: SwapInDefaultCar (Min: 0, Max: 0)

---Prevents the character from saying a dialogue line about reaching the destination upon reaching the destination in a "gooutside" or "goto" objective.
function Game.TurnGotoDialogOff() end

-- TODO: UseElapsedTime (Min: 0, Max: 0)

---Sets the ped group used when restarting the mission.
---
---@param PedGroupIndex integer The ped group index.
function Game.UsePedGroup(PedGroupIndex) end

-- TODO: msPlacePlayerCarAtLocatorName (Min: 1, Max: 1)
