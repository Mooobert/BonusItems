--[=[ 
 
to add items to the item blacklist add them to the list separated by a space.
e.g:

local itemsBlacklistString = [[
258
721
]]

would result in the items with the ids 258 (Missing No) and 721 (TMTRAINER) being blacklisted from the other Tainted Lazarus.

Note that the mod generates items based on the previous item pool used, so it shouldn't give items that aren't in the pool/have been removed from the pool/have been taken already.
--]=]

local itemsBlacklistString = [[
]]

local bi_items_blacklist = {} -- module

local generateBlacklist = {}

local illegalItems = {
    -- undesirable/run ruining items
    [273]=true, -- Bob's brain
    [358]=true, -- Wiz
    [209]=true, -- Butt Bombs
    [371]=true, -- Curse of the Tower
    -- potentially major run altering items
    [81]=true, -- Dead Cat
    [721]=true, -- TMTRAINER
    [149]=true, -- Ipecac
    [330]=true, -- Soy Milk
    [258]=true, -- Missing No
    [169]=true, -- Polyphemus
    [304]=true, -- Libra
    [402]=true, -- Chaos
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