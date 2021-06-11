local bonusItems = RegisterMod("Bonus Items!", 1)

function bonusItems:givePlayeritem(player)
    local level = Game():GetLevel():GetStage()
    local roomType = Game():GetRoom():GetType()
    player = Isaac.GetPlayer(0);

    if roomType == RoomType.ROOM_DEFAULT then
        roomPool = ItemPoolType.POOL_GOLDEN_CHEST
    else
        roomPool = Game():GetItemPool():GetPoolForRoom(roomType, seed)
    end
    if roomPool == ItemPoolType.POOL_NULL then
        roomPool = ItemPoolType.POOL_TREASURE 
    end
    findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)
    
    -- for stage in level do
    --     player:AddCollectible(findCollectible)
    --     print("item given!")
    -- end
    cap = math.random(1, 5)
    i = 0
    while i < cap do 
        player:AddCollectible(findCollectible)
        i = i + 1
    end
end
-- TODO: fix this so the game doesn't crash

bonusItems:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, bonusItems.givePlayeritem)