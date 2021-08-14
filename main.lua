local bonusItems = RegisterMod("Bonus Items!", 1)

local biBlacklist = include("bi_blacklist")
local toyBox = Isaac.GetEntityTypeByName("Toy Box")
local toyboxVar = Isaac.GetEntityVariantByName("Toy Box")

local tLazAliveType = 29
local tLazDeadType = 38
local toyboxEntity = nil
local destroyed = false
local itemsDropped = false
local box = Isaac.FindByType(toyBox, toyboxVar)


----------------------------------------------------------------------
-- Item generation handlers
----------------------------------------------------------------------
function chooseItemPool(player)
    local itemPools = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_DEVIL,
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_ANGEL,
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SECRET,
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GOLDEN_CHEST,
    }
    roomPool = itemPools[math.random(1,8)] -- simplest random selection method I could think of that would yield somewhat balanced item pool draws
end
----------------------------------------------------------------------
function bonusItems:giveNewItem(player)
    chooseItemPool(player)
    findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)
    local itemConfig = Isaac.GetItemConfig()
    collectibleType = itemConfig:GetCollectible(findCollectible).Type
    -- items fall into 3 categories: collectibleType 1 is passive, 3 is active, and 4 is familiar (2 is trinkets)

    if collectibleType == 3 then -- if the chosen item is active, we reroll until we get a decent item
        bonusItems:giveNewItem(player)
    elseif biBlacklist.canRollInto(findCollectible) == true then -- if the chosen item is blacklisted, we also reroll until we get a decent item
        bonusItems:giveNewItem(player)   
    else
        local pos = Isaac.GetFreeNearPosition(toyboxEntity.Position, 70)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, findCollectible, pos, Vector(0, 0), player);
    end
end
----------------------------------------------------------------------
function itemsPlease(player)
    if itemsDropped == false then
        for i = 1, Game():GetNumPlayers() do
            player = Isaac.GetPlayer(i-1)
            pType = player:GetPlayerType() 
            if pType == tLazAliveType or pType == tLazDeadType then cap = 2 else cap = 1 end
            for num = 1, cap do
                bonusItems:giveNewItem(player)
            end
        end
    end
end
----------------------------------------------------------------------
-- Pickup generation handlers
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
function generatePickups()
    if destroyed == false then
        for i = 1, 3 do
            pickupChoice = choosePickupPool()
            Isaac.Spawn(5, pickupChoice, 0, toyboxEntity.Position, Vector(math.random(-10,10), math.random(-10,10)), nil)
            -- silly method of making items spew out from the toybox, but it works and I like it this way
        end
    end
end
----------------------------------------------------------------------
-- Toybox generation and toybox state handlers
----------------------------------------------------------------------
function bonusItems:initToybox()
    local room = Game():GetRoom()
    local entities = Isaac.GetRoomEntities()

	if (Game():IsGreedMode() == false and Game():GetLevel():GetCurrentRoomIndex() == Game():GetLevel():GetStartingRoomIndex())
    or (Game():IsGreedMode() == false and Game():GetLevel():GetCurrentRoomIndex() == 97 and Game():GetLevel():GetStage() == 9)
	or (Game():IsGreedMode() == true  and Game():GetLevel():GetCurrentRoomIndex() == 98) then
        local entities = Isaac.FindByType(toyBox, toyboxVar)
        if #entities > 0 then
			toyboxEntity = entities[1]
			if destroyed == true then
				sprite = toyboxEntity:GetSprite()
				sprite:Play("Destroyed", true)
			end
			return
		end
        -- for i = 1, #entities do
        --     toyboxEntByType = Isaac.FindByType(toyBox, toyboxVar)
        --     if entities[i].Type == toyboxEntByType then
		-- 	    toyboxEntity = entities[i]
        --         if destroyed == true then
        --             sprite = toyboxEntity:GetSprite()
        --             sprite:Play("Destroyed",true)
        --         end
        --         return
        --     end
        -- end

        if (toyboxEntity == nil) or (toyboxEntity:Exists() == false) then
			-- if Game():IsGreedMode() ~= true then
            --     if Game():GetLevel():GetStage() == 9 then
            --         toyboxEntity = Isaac.Spawn(toyBox, toyboxVar, 0, room:GetGridPosition(221), Vector(0,0), Isaac.GetPlayer(0));
            --     else
			--         toyboxEntity = Isaac.Spawn(toyBox, toyboxVar, 0, room:GetGridPosition(116), Vector(0,0), Isaac.GetPlayer(0));
            --     end
            -- else
            --     toyboxEntity = Isaac.Spawn(toyBox, toyboxVar, 0, room:GetGridPosition(112), Vector(0,0), Isaac.GetPlayer(0));
            -- end
            if Game():IsGreedMode() ~= true then
                toyboxEntity = Isaac.Spawn(toyBox, toyboxVar, 0, room:GetGridPosition(18), Vector(0,0), Isaac.GetPlayer(0));
            else
                toyboxEntity = Isaac.Spawn(toyBox, toyboxVar, 0, room:GetGridPosition(112), Vector(0,0), Isaac.GetPlayer(0));
            end

            sprite = toyboxEntity:GetSprite()
			sprite:Play("Idle",true)
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
        sprite = toyboxEntity:GetSprite()
        if dist < 25 and destroyed == false and itemsDropped == false then
            sprite:Play("FirstUse", true)
        elseif dist < 25 and destroyed == false and itemsDropped == true then
            sprite:Play("2+Use", true)
        elseif dist >= 25 and destroyed == false and (itemsDropped == false or itemsDropped == true) then
            sprite:Play("Idle", true)
        elseif destroyed == true and (itemsDropped == true or itemsDropped == false) then
            sprite:Play("Destroyed", true)
        end
    end
end
----------------------------------------------------------------------
function boxDamage(p1, p2, p3, flags, p4) -- check done to generate pickups the first time the toybox is bombed
    local beeps = Isaac.GetRoomEntities()
    for i = 1, #beeps do
        if (beeps[i].Type == 4) then
            print("bomb!")
            bomba = beeps[i]
            dist = toyboxEntity.Position:Distance(bomba.Position)
            print(dist)
            if dist <= 107 then
	            if toyboxEntity ~= nil then
		            if (flags & DamageFlag.DAMAGE_EXPLOSION) ~= 0 and destroyed == false then
			            -- sprite:Play("Destroyed", true)
                        Isaac.Spawn(1000, 15, 0, toyboxEntity.Position, Vector(0,0), player)
                        generatePickups()
                        destroyed = true
                    end
                end
            end
        end
	end
    return false
end

bonusItems:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, boxDamage, toyBox)
----------------------------------------------------------------------
function itemSpawnCheck() -- check done to generate items the first time the chest is opened
    if toyboxEntity ~= nil then
        player = Isaac.GetPlayer(0)
        dist = toyboxEntity.Position:Distance(player.Position)
        if dist < 25 and itemsDropped == false and destroyed == false then
            itemsPlease(player)
            itemsDropped = true
        end
    end
end
----------------------------------------------------------------------
-- Cleanup/Support
----------------------------------------------------------------------
function resetLevelTracker()
    itemsDropped = false -- used to reset a cap on the amount of times a toybox will generate items per level
end
----------------------------------------------------------------------
function playOpenSound()
    if dist < 25 and destroyed == false then
        SFXManager():Play(SoundEffect.SOUND_CHEST_OPEN, 1, 10, false, 1.5)
    end
end
----------------------------------------------------------------------
function onDMG(target,amount,flag,source,num)
    if target.Type == box.Type then
        print("toybox got Dmg")
    end
end

bonusItems:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onDMG)
----------------------------------------------------------------------

bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, bonusItems.initToybox)
-- bonusItems:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, bombToBoxDist, toyBox)
bonusItems:AddCallback(ModCallbacks.MC_NPC_UPDATE, bonusItems.updateToyboxState, toyBox)
bonusItems:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, itemSpawnCheck)
bonusItems:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, playOpenSound, toyBox)
bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetLevelTracker)

--[[
    I orginally tried to program a solution to give Jacob and Esau proper compatibility, but there is so much
    horsepoop I don't understand when it came to callback logic I used to give/spawn items, I decided to opt for a workaround instead

    pro tip:    don't generate items that generate pickups before the level loads or else the game will crash
]]