local bonusItems = RegisterMod("Bonus Items!", 1)

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
end

function bonusItems:giveNewItem(player)
    bonusItems:choosePool(player)
    findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)
    local itemConfig = Isaac.GetItemConfig()
    collectibleType = itemConfig:GetCollectible(findCollectible).Type
    -- items fall into 3 categories: collectibleType 1 is passive, 3 is active, and 4 is familiar

    if collectibleType == 3 then -- if the chosen item is active, we reroll until we get a non-active item
        bonusItems:giveNewItem(player)
    else
        player:AddCollectible(findCollectible)
    end
end

function bonusItems:itemsPlease(player)
    player = Isaac.GetPlayer(0)
    cap = math.random(1, 3)
    for num = 1,cap do
        bonusItems:giveNewItem(player)
    end
end

bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bonusItems.itemsPlease, EntityType.ENTITY_PLAYER)

--[[
    pro tip: don't generate items that generate pickups before the level loads or else the game will crash
    note: lil delirium and red key may have game crashing properties, but I am completely oblivious as to why

    note 2: Esau is imbued with magic and prevents game crashes because I guess he gets rendered after the floor loads.
    Using the ModCallbacks.MC_POST_PLAYER_INIT enumeration will give both Jacob and Esau items, which I want the 
    current callback to do, so that'll be WIP
]]