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
    -- story related items
	[238]=true, -- Key Piece 1
	[239]=true, -- Key Piece 2
	[327]=true, -- The Negative
	[328]=true, -- The Polaroid
	[550]=true, -- Broken Shovel 1
	[551]=true, -- Broken Shovel 2
	[552]=true, -- Mom's Shovel
	[626]=true, -- Knife Piece 1
	[627]=true, -- Knife Piece 2
	[633]=true, -- Dogma
	[668]=true,  -- Dad's Note
    -- undesirable/run ruining items
    [273]=true, -- Bob's brain
    [358]=true, -- Wiz
    -- potentially major run altering items
    [81]=true, -- Dead Cat
    [721]=true, -- TMTRAINER
    [149]=true, -- Ipecac
    [330]=true, -- Soy Milk
    [258]=true, -- Missing No
    [169]=true, -- Polyphemus
    [304]=true -- Libra
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