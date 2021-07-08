--[=[ 
 
to add items to the item blacklist add them to the list separated by a space.
e.g:

local itemsBlacklistString = [[
3
]]

would result in the items with the id 3 (Spoon Bender) being blacklisted from item rolls.

Credit goes to Mr. Worldwide and respectable name chosen by Chips of the Tainted Lazaruz Buff v2 mod 
https://steamcommunity.com/sharedfiles/filedetails/?id=2491666917&searchtext=tainted+laz+v2
for serving as inspiration for this mod!
--]=]

local itemsBlacklistString = [[
    5
    81
    149
    169
    206
    209
    222
    258
    273
    276
    304
    315
    316
    330
    358
    371
    378
    402
    561
    689
    721
]]

local bi_blacklist = {} -- module

local generateBlacklist = {}

for i in string.gmatch(itemsBlacklistString, "%S+") do
	generateBlacklist[tonumber(i)] = true
end

function bi_blacklist.canRollInto(ID)
    return generateBlacklist[ID]
end

-- for index, id in pairs(generateBlacklist) do
--     print(index)
-- end

return bi_blacklist