--[=[ 
 
to add items to the item blacklist add them to the list separated by a space.
e.g:

local itemsBlacklistString = [[
258
721
]]

would result in the items with the ids 258 (Missing No) and 721 (TMTRAINER) being blacklisted.
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
222
]]

local bi_items_blacklist = {} -- module

local generateBlacklist = {}

for i in string.gmatch(itemsBlacklistString, "%S+") do
	generateBlacklist[tonumber(i)] = true
end

function bi_items_blacklist.canRollInto(ID)
-- 	-- return generateBlacklist[ID] == nil
    return generateBlacklist[ID]
end

for index, id in pairs(generateBlacklist) do
    print(index, id)
end

return bi_items_blacklist
-- return generateBlacklist