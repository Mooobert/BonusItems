local bonusItems = RegisterMod("Bonus Items!", 1)

local bi_blacklist = include("bi_blacklist")
local toyBox = Isaac.GetEntityTypeByName("Toy Box")
local toyboxVar = Isaac.GetEntityVariantByName("Toy Box")

local jacob_type = 19
local tforgotten_type = 35
local destroyed = false
local room = Game():GetRoom()

-- local invUI = nil

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
    -- item collectibles fall into 3 categories: collectibleType 1 is passive, 3 is active, and 4 is familiar (2 is trinkets)

    if collectibleType == 3 then -- if the chosen item is active, we reroll until we get a decent item
        bonusItems:giveNewItem(player)
    elseif bi_blacklist.canRollInto(findCollectible) == true then -- if the chosen item is blacklisted, we also reroll until we get a decent item
        bonusItems:giveNewItem(player)
    else   
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, findCollectible, pos, Vector(0, 0), player);
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
function bonusItems:generateToybox()
    player = Isaac.GetPlayer(0)
    toyboxEntity = Isaac.Spawn(toyBox, toyboxVar, 0, room:GetGridPosition(101), Vector(0,0), player);
    destroyed = false
end
----------------------------------------------------------------------
function bonusItems:updateToybox()
    for i = 1, Game():GetNumPlayers() do
		player = Isaac.GetPlayer(i-1)
		dist = toyboxEntity.Position:Distance(player.Position)
        if (dist >= 25) then
            s = toyboxEntity:GetSprite()
            s:Play("Idle", true)
        else
            s = toyboxEntity:GetSprite()
            s:Play("Use", true)
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
    for i = 1, 3 do
        pickupChoice = choosePickupPool()
        if i == 1 then 
            Isaac.Spawn(5, pickupChoice, 0, room:GetGridPosition(86), Vector(0,0), nil)
        elseif i == 2 then 
            Isaac.Spawn(5, pickupChoice, 0, room:GetGridPosition(100), Vector(0,0), nil)
        else 
            Isaac.Spawn(5, pickupChoice, 0, room:GetGridPosition(102), Vector(0,0), nil) -- obscene way to generate pickups, but I couldn't figure out how to make 
        end                                                                              -- them "fly" from the toybox like you'd see a normal chest do
    end
end
----------------------------------------------------------------------
local function DamageBox(p1, p2, p3, flags, p4)
	if toyboxEntity ~= nil then
		if (flags & DamageFlag.DAMAGE_EXPLOSION) ~= 0 then
			local s = toyboxEntity:GetSprite()
			s:Play("Destroyed",true)
			destroyed = true
            Isaac.Spawn(1000, 15, 0, toyboxEntity.Position, Vector(0,0), player)
            local spawnpos = Game():GetRoom():FindFreePickupSpawnPosition(toyboxEntity.Position, 1, false)
            generatePickups(spawnpos)
        end
		return false
	end
end
bonusItems:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DamageBox, toyBox)
----------------------------------------------------------------------

bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bonusItems.itemsPlease)
bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bonusItems.generateToybox)
bonusItems:AddCallback(ModCallbacks.MC_NPC_UPDATE, bonusItems.updateToybox, toyBox)


--[[
    I orginally tried to program a real solution to give Jacob and Esau compatibility, but there is so much
    bullshit I don't understand when it came to callback logic I used to give/spawn items, I decided to opt for a workaround instead

    pro tip: don't generate items that generate pickups before the level loads or else the game will crash
    note: lil delirium and red key may also have game crashing properties, but I am completely oblivious as to why
]]