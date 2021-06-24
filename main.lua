local bonusItems = RegisterMod("Bonus Items!", 1)

-- local bi_blaklist = include("bi_blacklist")

-- local bonusItems_blacklist

function bonusItems:giveNewItem(player)
    roomPool = ItemPoolType.POOL_DEVIL
    findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)
    player:AddCollectible(findCollectible)
end

-- function bonusItems:removeItem(player)
--     if findCollectible == ItemType.ITEM_ACTIVE then
--         player:RemoveCollectible(findCollectible)
--         print(findCollectible .. " was removed!")
--     end
-- end

function bonusItems:givePlayeritem(player)
    local level = Game():GetLevel():GetStage()
    -- local roomType = Game():GetRoom():GetType()
    player = Isaac.GetPlayer(0);
    roomPool = ItemPoolType.POOL_ANGEL
    findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)

    -- TODO: randomize the item pools that you can get an item from
    cap = math.random(1, 3)
    counter = 0
    for num = 1,cap do
        -- player:AddCollectible(findCollectible)
        bonusItems:giveNewItem(player)
        -- if findCollectible == CollectibleType.COLLECTIBLE_REVELATION then
        --     print(findCollectible .. " was given!")
        --     player:RemoveCollectible(findCollectible)
        --     print(findCollectible .. " was removed!")
        --     bonusItems:giveNewItem(player) 
        -- end
        print(findCollectible .. " was given")
    end
    print("-----")
    -- TODO: make it so that you can't get active items, just to avoid potentially losing an already good active item
end

bonusItems:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, bonusItems.givePlayeritem)

-- TODO: find a way to receive item(s) each floor rather than the first time you generate your character
-- TODO: find out why random crashes are occuring