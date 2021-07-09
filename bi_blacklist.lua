--[=[ 
 
To add items to the item blacklist add them to the list separated by a space.
e.g:

local itemsBlacklistString = [[
3
]]

Would result in the items with the id 3 (Spoon Bender) being blacklisted from item rolls.

Credit goes to Mr. Worldwide and respectable name chosen by Chips of the Tainted Lazaruz Buff v2 mod 
https://steamcommunity.com/sharedfiles/filedetails/?id=2491666917&searchtext=tainted+laz+v2
for serving as inspiration for this mod and the concept of including a blacklist!

list comes loaded with 20 relatively game changing items:

my reflection
ipecac
anti-gravity
missing no.
bob's brain
isaac's heart
libra
strange attractor
cursed eye
the ludovico technique
soy milk
the wiz
curse of the tower
no. 2
chaos
almond milk
blood oath
eye of the occult
glitched crown
TMTRAINER

--]=]

local itemsBlacklistString = [[
    5 
    149
    222
    258
    273
    276
    304
    315
    316
    329
    330
    358
    371
    378
    402
    561
    569
    572
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

return bi_blacklist