local bonusItems = RegisterMod("Bonus Items!", 1)

function bonusItems:givePlayeritem(player)
    local level = Game():GetLevel():GetStage()
    -- local roomType = Game():GetRoom():GetType()
    player = Isaac.GetPlayer(0);
    roomPool = ItemPoolType.POOL_ANGEL
    -- TODO: randomize the item pools that you can get an item from
    findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)
    
    -- for stage in level do
    --     player:AddCollectible(findCollectible)
    --     print("item given!")
    -- end
    cap = math.random(1, 3)
    -- print(cap)
    counter = 0
    for num = 1,cap do
        player:AddCollectible(findCollectible)
        counter = counter + 1
    end
    -- TODO: make it so that you can't get active items, just to avoid potentially losing an already godd active item

    if counter == 1 then
        print(counter .. " item was given!")
    else
        print(counter .. " items were given!")
    end
end
-- TODO: find a way to get a variety of items instead of duplicates of one

bonusItems:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, bonusItems.givePlayeritem)
-- TODO: find a way to receive item(s) each floor rather than the first time you generate your character
