local bonusItems = RegisterMod("Bonus Items!", 1)

function bonusItems:givePlayeritem(player)
    local level = Game():GetLevel():GetStage()
    local roomType = Game():GetRoom():GetType()
    player = Isaac.GetPlayer(0);
    roomPool = Game():GetItemPool():GetPoolForRoom(roomType, seed)  
    findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)
    
    -- for stage in level do
    --     player:AddCollectible(findCollectible)
    --     print("item given!")
    -- end
    cap = math.random(1, 5)
    for num in cap do 
        player:AddCollectible(findCollectible)
    end
    -- if ((not player:HasCollectible(CollectibleType.COLLECTIBLE_SPOON_BENDER, true))) then
    --     player:AddCollectible(CollectibleType.COLLECTIBLE_SPOON_BENDER, 0, false);
    -- end
end

bonusItems:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, bonusItems.givePlayeritem)
