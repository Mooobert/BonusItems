local bonusItems = RegisterMod("Bonus Items!", 1)

local bi_blacklist = include("bi_blacklist")

local pickupIncoming = {}
local playerCounter = 1

function bonusItems:choosePool(player)
    local item_pools = {
        ItemPoolType.POOL_TREASURE, -- 0
        ItemPoolType.POOL_DEVIL, -- 3
        ItemPoolType.POOL_TREASURE, -- 0
        ItemPoolType.POOL_ANGEL, -- 4
        ItemPoolType.POOL_TREASURE, -- 0
        ItemPoolType.POOL_SECRET, -- 5
        ItemPoolType.POOL_TREASURE, -- 0
        ItemPoolType.POOL_GOLDEN_CHEST, -- 8
        ItemPoolType.POOL_TREASURE -- 0
    }
    roomPool = item_pools[math.random(1,9)]
    print(roomPool)
end

function bonusItems:giveNewItem(player)
    local queuedItem = player.QueuedItem.Item
    if queuedItem ~= nil and playerData["pickupIncoming"] ~= true then
        local qID = queuedItem.ID
        if not bi_items_blacklist.isIllegalItem(qID) then
            playerData["pickupIncoming"] = true
        end
    end

    if playerData["pickupIncoming"] == true then
        if queuedItem == nil then
            local level = Game():GetLevel():GetStage()
            local roomType = Game():GetRoom():GetType()
            local itemConfig = Isaac.GetItemConfig()
            bonusItems:choosePool(player)
            findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)
        end
    end
    -- bonusItems:choosePool(player)
    player:AddCollectible(findCollectible)
end

function bonusItems:removeItem(player)
    local stop = false
    while stop == false do
        -- findCollectible = Game():GetItemPool():GetCollectible(roomPool, false, seed, CollectibleType.COLLECTIBLE_NULL)
        if bi_items_blacklist.canRollInto(findCollectible) == true then -- is this item blacklisted?
            if collectibleType == ItemType.ITEM_PASSIVE or collectibleType == ItemType.ITEM_FAMILIAR then
                Game():GetItemPool():RemoveCollectible(findCollectible)
                stop = true
            end
        else
            print("bad thing found, looping again!")
        end
    end
end

function bonusItems:itemsPlease(player)
    player = Isaac.GetPlayer(0);

    playerData = player:GetData()
    if playerCounter == 1 then
        playerData["pickupIncoming"] = true
    end

    cap = math.random(1, 3)
    for num = 1,cap do
        bonusItems:giveNewItem(player)
        print(findCollectible .. " was given")
    end
    print("-----")
    -- TODO: make it so that you can't get active items, just to avoid potentially losing an already good active item
end

bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bonusItems.itemsPlease, EntityType.ENTITY_PLAYER)