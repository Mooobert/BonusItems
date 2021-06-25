local bonusItems = RegisterMod("Bonus Items!", 1)

-- local bi_blaklist = include("bi_blacklist")
-- local bonusItems_blacklist

function bonusItems:choosePool(player)
    local item_pools = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_DEVIL,
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_ANGEL,
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SECRET,
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GOLDEN_CHEST,
        ItemPoolType.POOL_TREASURE
    }
    roomPool = item_pools[math.random(1,9)]
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

    cap = math.random(1, 3)
    counter = 0
    for num = 1,cap do
        bonusItems:choosePool(player)
        bonusItems:giveNewItem(player)
        print(findCollectible .. " was given")
    end
    print("-----")
    -- TODO: make it so that you can't get active items since currently held active items trump ones given by the mod
end

bonusItems:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, bonusItems.itemsPlease)

-- TODO: find a way to receive item(s) each floor rather than the first time you generate your character
-- TODO: add game-crashing items to blacklist 