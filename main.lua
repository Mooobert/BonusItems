local bonusItems = RegisterMod("Bonus Items!", 1)

local bi_blacklist = include("bi_blacklist")

local jacob_type = 19
local esau_type = 20

----------------------------------------------------------------------
function bonusItems:choosePool(player)
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
    -- print(roomPool)
end

function bonusItems:giveNewItem(player)
    if playerType == jacob_type or playerType == esau_type then
        print("tada")
    else
        local pos = Isaac.GetFreeNearPosition(player.Position, 70)
        bonusItems:choosePool(player)
        findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)
        -- print(findCollectible)
        local itemConfig = Isaac.GetItemConfig()
        collectibleType = itemConfig:GetCollectible(findCollectible).Type
        -- print(collectibleType)
        -- items fall into 3 categories: collectibleType 1 is passive, 3 is active, and 4 is familiar

        if collectibleType == 3 then -- if the chosen item is active, we reroll until we get a decent item
            print("active item " .. findCollectible .. " was found, rerolling...")
            bonusItems:giveNewItem(player)
        elseif bi_blacklist.canRollInto(findCollectible) == true then -- if the chosen item is blacklisted, we also reroll until we get a decent item
            print("blacklisted item " .. findCollectible .. " was found, rerolling...")
            bonusItems:giveNewItem(player)
        else    
            print("passive item/familiar found!")
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, findCollectible, pos, Vector(0, 0), player);
            -- player:AddCollectible(findCollectible)
            print(findCollectible .. " was given")
            print("-----")
        end
    end
end
----------------------------------------------------------------------
function bonusItems:itemsPlease(player)
    local player = Isaac.GetPlayer(0)
    local playerType = player:GetPlayerType()
    print(playerType)
    for i = 1, Game():GetNumPlayers() do
        player = Isaac.GetPlayer(i-1)
        cap = math.random(1, 3)
        for num = 1,cap do
            bonusItems:giveNewItem(player)
        end
    end
end
----------------------------------------------------------------------
function bonusItems:playerCheck(player)
    local player = Isaac.GetPlayer(0)
    local playerType = player:GetPlayerType()
    if playerType == jacob_type then
        -- player:AddCollectible(CollectibleType.COLLECTIBLE_GENESIS, 0, false);
        -- Isaac.ExecuteCommand("goto s.isaacs")
        Isaac.ExecuteCommand("gridspawn 1900 22")
        Isaac.ExecuteCommand("gridspawn 1900 61")
        Isaac.ExecuteCommand("gridspawn 1900 73")
        Isaac.ExecuteCommand("gridspawn 1900 112")
        -- try spawning blocks using specific coordinates
    end
end
----------------------------------------------------------------------
function bonusItems:test()
end
----------------------------------------------------------------------

-- bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bonusItems.itemsPlease)
-- bonusItems:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, bonusItems.playerCheck)
bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bonusItems.itemsPlease)
-- bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bonusItems.test)


--[[
    pro tip: don't generate items that generate pickups before the level loads or else the game will crash
    note: lil delirium and red key may have game crashing properties, but I am completely oblivious as to why

    note 2: Esau is imbued with magic and prevents game crashes because I guess he gets rendered after the floor loads.
    Using the ModCallbacks.MC_POST_PLAYER_INIT enumeration will give both Jacob and Esau items, which I want the 
    current callback to do, so that'll be WIP
]]