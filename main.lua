local bonusItems = RegisterMod("Bonus Items!", 1)

local bi_blacklist = include("bi_blacklist")
local toyBox = Isaac.GetEntityTypeByName("Toy Box")
local toyboxVar = Isaac.GetEntityVariantByName("Toy Box")

local jacob_type = 19
local tforgotten_type = 35
local destroyed = false
local room = Game():GetRoom()
local state = ""

----------------------------------------------------------------------
function choosePool(player)
    local itemPools = {
        ItemPoolType.POOL_TREASURE, -- 0
        ItemPoolType.POOL_DEVIL, -- 3
        ItemPoolType.POOL_TREASURE, -- 0
        ItemPoolType.POOL_ANGEL, -- 4
        ItemPoolType.POOL_TREASURE, -- 0
        ItemPoolType.POOL_SECRET, -- 5
        ItemPoolType.POOL_TREASURE, -- 0
        ItemPoolType.POOL_GOLDEN_CHEST, -- 8
    }
    roomPool = itemPools[math.random(1,8)]
    -- simplest random selection method I could think of that would yield somewhat balanced item pool draws
end

function bonusItems:giveNewItem(player)
    local level = Game():GetLevel()
    local pos = Isaac.GetFreeNearPosition(player.Position, 70)
    choosePool(player)
    findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)
    local itemConfig = Isaac.GetItemConfig()
    collectibleType = itemConfig:GetCollectible(findCollectible).Type
    -- items fall into 3 categories: collectibleType 1 is passive, 3s is active, and 4 is familiar (2 is trinkets)

    if collectibleType == 3 then -- if the chosen item is active, we reroll until we get a decent item
        bonusItems:giveNewItem(player)
    elseif bi_blacklist.canRollInto(findCollectible) == true then -- if the chosen item is blacklisted, we also reroll until we get a decent item
        bonusItems:giveNewItem(player)
    else    
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, findCollectible, pos, Vector(0, 0), player);
        -- player:AddCollectible(findCollectible)
    end
end
----------------------------------------------------------------------
function bonusItems:itemsPlease(player)
    for i = 1, Game():GetNumPlayers() do
        player = Isaac.GetPlayer(i-1)
        playerType = player:GetPlayerType() 
        if playerType == jacob_type or playerType == tforgotten_type then 
            cap = math.random(2,3)  
            --[[
            this check and compensation is done for double characters (j&e and tForgotten) because, for whatever reason,
            the 'supporting' character inherits the 'dominant' character's unique id
            when initialized and don't receive their own items until the second stage. I imagine this is probably 
            done to prevent multiplayer issues where multiple players might controls multiple characters.
            ]]  
        else                                 
            cap = math.random(1,3)
        end
        for num = 1,cap do
            bonusItems:giveNewItem(player)
        end
    end
end
----------------------------------------------------------------------
function bonusItems:initToybox()
    local room = Game():GetRoom()

	if (Game():IsGreedMode() == false and Game():GetLevel():GetCurrentRoomIndex() == Game():GetLevel():GetStartingRoomIndex())
	or (Game():IsGreedMode() == true  and Game():GetLevel():GetCurrentRoomIndex() == 98)                                 
	or (Game():IsGreedMode() == false and Game():GetLevel():GetCurrentRoomIndex() == 97 and Game():GetLevel():GetStage() == 9) then
        local ent = Isaac.FindByType(toyBox, toyboxVar)
        if #ent > 0 then
			toyboxEntity = ent[1]
			if destroyed == true then
				s = toyboxEntity:GetSprite()
				s:Play("Destroyed",true)
			end
			return
		end

        if (toyboxEntity == nil) or (toyboxEntity:Exists() == false) then
			if Game():IsGreedMode() == false then
			    toyboxEntity = Isaac.Spawn(toyBox, toyboxVar, 0, room:GetGridPosition(116), Vector(0,0), Isaac.GetPlayer(0));
            elseif Game():IsGreedMode() == true then
                toyboxEntity = Isaac.Spawn(toyBox, toyboxVar, 0, room:GetGridPosition(221), Vector(0,0), Isaac.GetPlayer(0));
            end
            s = toyboxEntity:GetSprite()
			s:Play("Idle",true)
			destroyed = false
        end
    else
        toyboxEntity = nil
    end
end

----------------------------------------------------------------------
function bonusItems:updateToyboxState(entity)
    local dist = 0

	if toyboxEntity == nil then
		return
	end

    for i = 1, Game():GetNumPlayers() do
		player = Isaac.GetPlayer(i-1)
		dist = toyboxEntity.Position:Distance(player.Position)
        if dist < 25 and destroyed == false then
            s = toyboxEntity:GetSprite()
            s:Play("Use", true)
        elseif dist >= 25 and destroyed == false then
            s:Play("Idle", true)
        else
            s:Play("Destroyed", true)
        end
    end
end
----------------------------------------------------------------------
function choosePickupPool()
    local pickupPool = {
        10, -- hearts
        20, -- pennies
        30, -- keys
        40, -- bombs
        70, -- pills
        90  -- batteries
    }
    chosenPool = pickupPool[math.random(1,6)]
    return chosenPool
end
----------------------------------------------------------------------
function generatePickups(pos)
    if destroyed == false then
        for i = 1, 3 do
            pickupChoice = choosePickupPool()
            if i == 1 then 
                Isaac.Spawn(5, pickupChoice, 0, room:GetGridPosition(101), Vector(0,0), nil)
            elseif i == 2 then 
                Isaac.Spawn(5, pickupChoice, 0, room:GetGridPosition(115), Vector(0,0), nil)
            else 
                Isaac.Spawn(5, pickupChoice, 0, room:GetGridPosition(117), Vector(0,0), nil) -- obscene way to generate pickups, but I couldn't figure out how to make 
            end                                                                              -- them "fly" from the toybox like a normal chest would
        end
    end
end
----------------------------------------------------------------------
function DamageBox(p1, p2, p3, flags, p4)
	if toyboxEntity ~= nil then
		if (flags & DamageFlag.DAMAGE_EXPLOSION) ~= 0 then
			s = toyboxEntity:GetSprite()
			s:Play("Destroyed", true)
            Isaac.Spawn(1000, 15, 0, toyboxEntity.Position, Vector(0,0), player)
            local spawnpos = Game():GetRoom():FindFreePickupSpawnPosition(toyboxEntity.Position, 1, false)
            generatePickups(spawnpos)
            destroyed = true
        end
		return false
	end
end
----------------------------------------------------------------------

bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, bonusItems.initToybox)
bonusItems:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DamageBox, toyBox)
bonusItems:AddCallback(ModCallbacks.MC_NPC_UPDATE, bonusItems.updateToyboxState, toyBox)


--[[
    I orginally tried to program a real solution to give Jacob and Esau compatibility, but there is so much
    bullshit I don't understand when it came to callback logic I used to give/spawn items, I decided to opt for a workaround instead

    pro tip: don't generate items that generate pickups before the level loads or else the game will crash
    note: lil delirium and red key may also have game crashing properties, but I am completely oblivious as to why
]]