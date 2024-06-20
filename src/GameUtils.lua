local assert = assert

assert(Game, "You must load Game.lua prior to loading GameUtils.lua")
local Game = Game

GameUtils = GameUtils or {}


GameUtils.Conditions = GameUtils.Conditions or {}

function GameUtils.Conditions.Damage()
	Game.AddCondition("damage")
	
	Game.CloseCondition()
end

function GameUtils.Conditions.FollowDistance(Target, Distance)
	assert(Target, "FollowDistance condition requires a Target")
	assert(Distance, "FollowDistance condition requires a Distance")
	
	Game.AddCondition("followdistance")
	
	Game.SetFollowDistance(0, Distance)
	Game.SetCondTargetVehicle(Target)
	
	Game.CloseCondition()
end

function GameUtils.Conditions.KeepBarrel(Stages)
	assert(Stages, "KeepBarrel condition requires number of stages to go back")
	
	Game.AddCondition("keepbarrel", Stages)
	
	Game.CloseCondition()
end

function GameUtils.Conditions.OutOfBounds()
	Game.AddCondition("outofbounds")
	
	Game.CloseCondition()
end

function GameUtils.Conditions.OutOfVehicle(Time)
	assert(Time, "OutOfVehicle condition requires a time allowed")
	
	Game.AddCondition("outofvehicle")
	
	Game.SetCondTime(Time)
	
	Game.CloseCondition()
end

function GameUtils.Conditions.Position(Position)
	assert(Position, "Position condition requires a Position")
	
	Game.AddCondition("position")
	
	Game.SetConditionPosition(Position)
	
	Game.CloseCondition()
end

function GameUtils.Conditions.Race(Target)
	assert(Target, "Race condition requires a Target")
	
	Game.AddCondition("race")
	
	Game.SetCondTargetVehicle(Target)
	
	Game.CloseCondition()
end

function GameUtils.Conditions.Timeout()
	Game.AddCondition("timeout")
	
	Game.CloseCondition()
end


GameUtils.Objectives = GameUtils.Objectives or {}
local PossibleRoadArrows = { ["neither"] = true, ["both"] = true, ["nearest road"] = true, ["intersection"] = true }
local PossibleRoadArrowsTbl = {}
for k in pairs(PossibleRoadArrows) do
	PossibleRoadArrowsTbl[#PossibleRoadArrowsTbl + 1] = k
end
local PossibleRoadArrowsStr = table.concat(PossibleRoadArrowsTbl, "; ")

function GameUtils.Objectives.BuyCar(Car)
	assert(Car, "BuyCar objective requires a Car")
	
	Game.AddObjective("buycar", Car)
	
	Game.CloseObjective()
end

function GameUtils.Objectives.BuySkin(Skin)
	assert(Skin, "BuySkin objective requires a Skin")
	
	Game.AddObjective("buyskin", Skin)
	
	Game.CloseObjective()
end

function GameUtils.Objectives.Coins(CoinCount)
	assert(CoinCount, "Coins objective requires a CoinCount")
	
	Game.AddObjective("coins")
	
	Game.SetCoinFee(CoinCount)
	
	Game.CloseObjective()
end

function GameUtils.Objectives.Delivery(Location, Drawable, RoadArrow, SoundResource, CollectibleEffect)
	assert(Location, "Delivery objective requires a Location")
	assert(Drawable, "Delivery objective requires a Drawable")
	RoadArrow = RoadArrow or "both"
	assert(PossibleRoadArrows[RoadArrow], "Delivery objective requires a valid RoadArrow: " .. PossibleRoadArrowsStr)
	
	Game.AddObjective("delivery", RoadArrow)
	
	Game.AddCollectible(Location, Drawable, SoundResource)
	if CollectibleEffect then
		Game.SetCollectibleEffect(CollectibleEffect)
	end
	
	Game.CloseObjective()
end

function GameUtils.Objectives.Destroy(Target)
	assert(Target, "Destroy objective requires a Target")
	
	Game.AddObjective("destroy")
	
	Game.SetObjTargetVehicle(Target)
	
	Game.CloseObjective()
end

function GameUtils.Objectives.DestroyBoss(Target)
	assert(Target, "DestroyBoss objective requires a Target")
	
	Game.AddObjective("destroyboss")
	
	Game.AddCondition("damage")
	Game.SetObjTargetBoss(Target)
	Game.CloseCondition()
	
	Game.CloseObjective()
end

function GameUtils.Objectives.Dialogue(Player, NPC, Conversation, PlayerLocation, NPCLocation, CarLocation, PlayerRandomAnimations, NPCRandomAnimations, ConversationCams, PlayerAnimations, NPCAnimations, CamBestSide)
	assert(Player, "Dialogue objective requires a Player")
	assert(NPC, "Dialogue objective requires an NPC")
	assert(Conversation, "Dialogue objective requires a Conversation")
	assert((PlayerLocation == nil and NPCLocation == nil and CarLocation == nil) or (PlayerLocation and NPCLocation and CarLocation), "Dialogue objective requires either all of or none of PlayerLocation, NPCLocation and CarLocation.")
	
	Game.AddObjective("dialogue")
	
	Game.SetDialogueInfo(Player, NPC, Conversation, 0)
	if PlayerLocation then
		Game.SetDialoguePositions(PlayerLocation, NPCLocation, CarLocation)
	end
	if PlayerRandomAnimations then
		Game.AmbientAnimationRandomize(0, PlayerRandomAnimations and 1 or 0)
	end
	if NPCRandomAnimations then
		Game.AmbientAnimationRandomize(1, NPCRandomAnimations and 1 or 0)
	end
	if ConversationCams then
		for i=1,#ConversationCams do
			Game.SetConversationCam(i - 1, ConversationCams[i])
		end
	end
	if PlayerAnimations then
		for i=1,#PlayerAnimations do
			Game.AddAmbientPcAnimation(PlayerAnimations[i])
		end
	end
	if NPCAnimations then
		for i=1,#NPCAnimations do
			Game.AddAmbientNpcAnimation(NPCAnimations[i])
		end
	end
	if CamBestSide then
		Game.SetCamBestSide(CamBestSide)
	end
	
	Game.CloseObjective()
end

return GameUtils