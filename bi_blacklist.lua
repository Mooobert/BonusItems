--[=[ 
 
to add items to the item blacklist add them to the list separated by a space.
e.g:

local itemsBlacklistString = [[
258
721
]]

would result in the items with the ids 258 (Missing No) and 721 (TMTRAINER) being blacklisted.

Note that the mod generates items based on the previous item pool used, so it shouldn't give items that aren't in the pool/have been removed from the pool/have been taken already.
--]=]

local itemsBlacklistString = [[
    273
    358
    209
    371
    5
    81
    721
    149
    330
    258
    169
    304
    402
    561
    689
    316
    315
    276
]]

local bi_items_blacklist = {} -- module

local generateBlacklist = {}

local illegalItems = {
    -- undesirable/run ruining items
    [273]=true, -- Bob's brain
    [358]=true, -- Wiz
    [209]=true, -- Butt Bombs
    [371]=true, -- Curse of the Tower
    [5]=true, -- My Reflection
    [316]=true, -- Cursed Eye
    [315]=true, -- Strange Attractor
    [276]=true, -- Isaac's Heart
    -- potentially major run altering items
    [81]=true, -- Dead Cat
    [721]=true, -- TMTRAINER
    [149]=true, -- Ipecac
    [330]=true, -- Soy Milk
    [258]=true, -- Missing No
    [169]=true, -- Polyphemus
    [304]=true, -- Libra
    [402]=true, -- Chaos
    [561]=true, -- Almond Milk
    [689]=true -- Glitched Crown
}

for i in string.gmatch(itemsBlacklistString, "%S+") do
	generateBlacklist[tonumber(i)] = true
end

function bi_items_blacklist.canRollInto(ID)
	return generateBlacklist[ID] == nil
end

function bi_items_blacklist.isIllegalItem(ID)
	return illegalItems[ID] ~= nil
end 

return bi_items_blacklist