local bonusItems = RegisterMod("Bonus Items!", 1)

local bi_blacklist = include("bi_blacklist")
local toyBox = Isaac.GetEntityTypeByName("Toy Box")
local toyboxVar = Isaac.GetEntityVariantByName("Toy Box")

local jacob_type = 19
local tforgotten_type = 35
local destroyed = false
local toyboxEntity = nil
-- local invUI = nil

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
    local level = Game():GetLevel()
    local pos = Isaac.GetFreeNearPosition(player.Position, 70)
    bonusItems:choosePool(player)
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
    local room = Game():GetRoom()
    toyboxEntity = Isaac.Spawn(toyBox,toyboxVar,0,room:GetGridPosition(101), Vector(0,0), Isaac.GetPlayer(0));

    for i = 1, Game():GetNumPlayers() do
		player = Isaac.GetPlayer(i-1)
		dist = toyboxEntity.Position:Distance(player.Position)
        s = toyboxEntity:GetSprite()
		if (dist < 25) and destroyed == false then

            player.Position = toyboxEntity.Position + Vector(0,-30)
			player.Velocity = Vector(0,0)
			for i = 1, #entities do
				if (entities[i].Type == 3) then
					entities[i].Position = toyboxEntity.Position + Vector(0,20)
					entities[i].Velocity = Vector(0,0)
				end
			end

			s = toyboxEntity:GetSprite()
			if destroyed == false then
				s:Play("Use",true)
			end

        elseif (dist >= 25) and destroyed == false then
            s:Play("Idle", true)
            destroyed = false
		end
    end

	local ent = Isaac.FindByType(toyBox, toyboxVar)
	if #ent > 0 then
		toyboxEntity = ent[1]
		if destroyed == true then
			s = toyboxEntity:GetSprite()
			s:Play("Destroyed",true)
		end
		return
	end

end
----------------------------------------------------------------------
local function DamageBox(p1, p2, p3, flags, p4)
	if toyboxEntity ~= nil then
		if (flags & DamageFlag.DAMAGE_EXPLOSION) ~= 0 then
			local s = toyboxEntity:GetSprite()
			s:Play("Destroyed",true)
			destroyed = true
		end
		return false
	end
end
bonusItems:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DamageBox, toyBox)
----------------------------------------------------------------------

bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bonusItems.itemsPlease)
bonusItems:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bonusItems.generateToybox)


--[[
    I orginally tried to program a real solution to give Jacob and Esau compatibility, but there is so much
    bullshit I don't understand when it came to callback logic I used to give/spawn items, I decided to opt for a workaround instead

    pro tip: don't generate items that generate pickups before the level loads or else the game will crash
    note: lil delirium and red key may also have game crashing properties, but I am completely oblivious as to why
]]