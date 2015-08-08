require('Items/SuburbsDistributions');

table.insert(SuburbsDistributions.kitchen.counter.items, "Base.EmptyJar");
table.insert(SuburbsDistributions.kitchen.counter.items, 4);
table.insert(SuburbsDistributions.kitchen.counter.items, "Base.JarLid");
table.insert(SuburbsDistributions.kitchen.counter.items, 4);

if not BCGT then BCGT = {} end
-- Extend this if you want items to have specific min/max conditions
-- Min condition is ignored if you roll a broken condition
-- Default min condition: 0
-- Syntax is: [Fulltype] = % condition
BCGT.minConditions = {
	["Base.Axe"] = 25,
	["Base.HuntingKnife"] = 33
};
-- Max condition is ignored if you roll a perfect condition
-- Default max condition: 100
-- Syntax is: [Fulltype] = % condition
BCGT.maxConditions = {
	--[[
	["Base.Axe"] = 75,
	["Base.HuntingKnife"] = 100
	--]]
};
-- Extend this if you want items to have specific chances to break or
-- have perfect condition.
-- Default break chance: 25
-- Syntax is: [Fulltype] = chance in thousand
BCGT.breakChance = {
	["Base.Axe"] = 0,
	["Base.HuntingKnife"] = 0
}
-- Default perfect Chance: 25
-- Syntax is: [Fulltype] = chance in thousand
BCGT.perfectChance = {
	--[[
	["Base.Spoon"] = 100, -- 10%
	--]]
	["Base.HuntingKnife"] = 250 -- 25%, made for endurance
}

function BCGT.randomizeCondition(item)--{{{
	if not instanceof(item, "HandWeapon") and not instanceof(item, "DrainableComboItem") and not instanceof(item, "Drainable") then return end
	print("Randomising condition of a "..item:getDisplayName());
	-- defaults for all items
	local breakChance   = BCGT.breakChance[item:getFullType()]   or  25; -- default: 2.5%
	local perfectChance = BCGT.perfectChance[item:getFullType()] or  25; -- default: 2.5%
	local minCondition  = BCGT.minConditions[item:getFullType()] or   0;
	local maxCondition  = BCGT.maxConditions[item:getFullType()] or 100;
	local perfect       = false;
	local broken        = false;
	local chunk         = false;

	-- Account for zombie density in area
	if ItemPicker.player ~= nil then
		chunk = getWorld():getMetaChunk((ItemPicker.player:getX()/10), (ItemPicker.player:getY()/10));
	end
	if chunk then
		zombieDensity = math.min(ItemPicker.zombieDensityCap, chunk:getLootZombieIntensity());
	end
	if zombieDensity >= ItemPicker.zombieDensityCap / 4 * 3 then
		minCondition = math.max(minCondition, 50); -- at least 50% condition
		breakChance = 0; -- nothing broken in densest areas
		perfectChance = math.max(perfectChance, 300); -- at least 30% chance to be in mint condition
	elseif zombieDensity >= ItemPicker.zombieDensityCap / 2 then
		minCondition = math.max(minCondition, 33); -- at least 33% condition
		breakChance = math.min(breakChance, 10); -- still 1% chance
		perfectChance = math.max(perfectChance, 150); -- at least 15% chance to be in mint condition
	end

	if unlucky then
		breakChance = breakChance * 2; -- just double it
	end
	if ZombRand(1000) < breakChance then
		broken = true;
	end

	if not broken then
		if lucky then
			perfectChance = perfectChance * 2; -- just double it
		end
		if ZombRand(1000) < perfectChance then
			perfect = true;
		end
	end

	if instanceof(item, "HandWeapon") then
		-- setCondition uses integers representing remainder from getConditionMax()
		-- so getConditionMax() * newCondition / 100 return valid results.
		if broken then
			item:setCondition(0, false);
		elseif perfect then
			item:setCondition(item:getConditionMax(), false);
		else
			local newCondition = ZombRand(100);
			newCondition = math.min(maxCondition, newCondition); -- make sure minCondition <= newCondition <= maxCondition
			newCondition = math.max(minCondition, newCondition);
			newCondition = item:getConditionMax() * newCondition / 100;
			item:setCondition(newCondition, false);
		end

		--[[ TODO {{{
		if unlucky then
			if ZombRand(20) == 12 then -- 5% chance
				item:setHaveBeenRepaired(1+ZombRand(3));
			end
		end
		--]]-- }}}
	end

	-- setUsedDelta uses floats representing remainder from 1 (meaning "full")
	-- so 0.5 means half full, 0.1 means 10% full, etc.
	if instanceof(item, "DrainableComboItem") or instanceof(item, "Drainable") then
		local oneUse = item:getUseDelta(); -- getUseDelta returns a percentage in float (f.e.: 0.04)
		local maxUses = 1 / oneUse;
		minCondition = math.max(oneUse * 100, minCondition); -- safeguard for not handling empty items
		if broken then
			item:setUsedDelta(minCondition/100);
		elseif perfect then
			item:setUsedDelta(1.0);
		else
			local newCondition = ZombRand(minCondition, maxUses-1); -- used at least once
			newCondition = math.min(maxCondition, newCondition); -- make sure minCondition <= newCondition <= maxCondition
			item:setUsedDelta(newCondition/100);
		end
	end
end--}}}
BCGT.OnFillContainer = function(roomtype, containertype, container)--{{{
	local unlucky, lucky = false, false;
	if ItemPicker and ItemPicker.player then
		lucky = ItemPicker.player:HasTrait("Lucky");
		unlucky = ItemPicker.player:HasTrait("Unlucky");
	end

	local idx;
	for idx=0,container:getItems():size()-1 do
		local item = container:getItems():get(idx);

		BCGT.randomizeCondition(item);
		if SuburbsDistributions[item:getType()] then -- item is a generated container containing items to randomise
			BCGT.OnFillContainer(nil, nil, item:getItemContainer());
		end
	end
end--}}}

Events.OnFillContainer.Add(BCGT.OnFillContainer);
