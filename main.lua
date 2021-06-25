local bonusItems = RegisterMod("Bonus Items!", 1)

-- local bi_blaklist = include("bi_blacklist")

-- local bonusItems_blacklist

function bonusItems:choosePool(player)
    item_pools = {
        ItemPoolType.POOL_TREASURE, -- 0
        ItemPoolType.POOL_DEVIL, -- 3
        ItemPoolType.POOL_ANGEL, -- 4
        ItemPoolType.POOL_GOLDEN_CHEST, -- 8
        ItemPoolType.POOL_SECRET, -- 10
        ItemPoolType.POOL_BEGGAR -- 
    }
    chosen_pool = math.random(1,6)
    roomPool = item_pools[chosen_pool]
    print(roomPool)
end

function bonusItems:giveNewItem(player)
    findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)
    player:AddCollectible(findCollectible)
end

-- function bonusItems:removeItem(player)
--     if findCollectible == ItemType.ITEM_ACTIVE then
--         player:RemoveCollectible(findCollectible)
--         print(findCollectible .. " was removed!")
--     end
-- end

function bonusItems:itemsPlease(player)
    local level = Game():GetLevel():GetStage()
    -- local roomType = Game():GetRoom():GetType()
    player = Isaac.GetPlayer(0);
    findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)

    cap = math.random(1, 3)
    counter = 0
    for num = 1,cap do
        -- player:AddCollectible(findCollectible)
        bonusItems:giveNewItem(player)
        bonusItems:choosePool(player)
        -- if findCollectible == CollectibleType.COLLECTIBLE_REVELATION then
        --     player:RemoveCollectible(findCollectible)
        --     print(findCollectible .. " was removed!")
        --     bonusItems:giveNewItem(player) 
        -- end
        print(findCollectible .. " was given")

    end
    print("-----")
    -- TODO: make it so that you can't get active items, just to avoid potentially losing an already good active item
end

bonusItems:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, bonusItems.itemsPlease)

-- TODO: find a way to receive item(s) each floor rather than the first time you generate your character
-- TODO: find out why random crashes are occuring
