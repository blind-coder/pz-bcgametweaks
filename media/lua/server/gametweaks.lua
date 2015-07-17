require('Items/SuburbsDistributions');

if not BCGT then BCGT = {} end

BCGT.populateSpawnChances = function()--{{{
	BCGT.spawnChances = {};
	for k,v in pairs(SuburbsDistributions) do
		BCGT.spawnChances[k] = {};
		local t = BCGT.spawnChances[k];
		local itemid = nil;
		if v.items then
			for k2,v2 in pairs(v.items) do
				if k2 % 2 == 1 then
					itemid = v2;
				else
					t[itemid] = math.max(t[itemid] or 0, v2); -- keep the bigger chance
				end
			end
		else
			for k2,v2 in pairs(v) do
				if k2 ~= "rolls" and v2.items then
					BCGT.spawnChances[k][k2] = {};
					local t = BCGT.spawnChances[k][k2];
					local itemid = nil;
					for k3,v3 in ipairs(v2.items) do
						if k3 % 2 == 1 then
							itemid = v3;
						else
							t[itemid] = math.max(t[itemid] or 0, v3); -- keep the bigger chance
						end
					end
				end
			end
		end
	end
end--}}}
function BCGT.randomizeCondition(item, spawnChance)--{{{
	-- defaults for all items
	local breakChance   =  20; -- 2% chance to be broken
	local perfectChance =  20; -- 2% chance to be perfect condition
	local conditionMin  =   0; -- may be broken
	local perfect       = false;
	local broken        = false;

	if spawnChance < 1 then
		-- items with less than 5% spawn chance never spawn broken
		breakChance   =   0; -- 0%, never broken
		conditionMin  =  25; -- lower limit for condition is 25%
		perfectChance = 100; -- may be mint condition more often, 10% chance
	elseif spawnChance < 3 then
		breakChance   =  10; -- lower chance to be broken, 1%
		conditionMin  =  10; -- lower limit for condition is 10%
		perfectChance =  50; -- may be mint condition more often,  5% chance
	elseif spawnChance > 85 then
		breakChance   =  50; -- higher chance to be broken, 5%
		conditionMin  =   0; -- lower limit for condition is  0%
		perfectChance =  10; -- may be mint condition less often,  1% chance
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
		if broken then
			item:setCondition(0, false);
		elseif perfect then
			item:setCondition(item:getConditionMax(), false);
		else
			-- I guess this might still translate to perfect condition.
			local newCondition = item:getConditionMax() * (conditionMin+ZombRand(100 - conditionMin) / 100);
			item:setCondition(newCondition, false);
		end

		--[[ TODO
		if unlucky then
			if ZombRand(20) == 12 then -- 5% chance
				item:setHaveBeenRepaired(1+ZombRand(3));
			end
		end
		--]]
	end

	if instanceof(item, "DrainableComboItem") then
		if broken then
			item:setUsedDelta(0.1); -- safeguard
		elseif perfect then
			item:setUsedDelta(1.0);
		else
			-- I guess this might still translate to 100% fill level
			local newCondition = (math.max(conditionMin, 0.1) + ZombRand(100 - conditionMin)) / 100;
			item:setUsedDelta(newCondition);
		end
	end

	if instanceof(item, "Drainable") then
		if broken then
			item:setUsedDelta(0.1);
		elseif perfect then
			item:setUsedDelta(1.0);
		else
			-- I guess this might still translate to 100% fill level
			local newCondition = (math.max(conditionMin, 0.1) + ZombRand(100 - conditionMin)) / 100;
			item:setUsedDelta(newCondition);
		end
	end
end--}}}
BCGT.OnFillContainer = function(roomtype, containertype, container)--{{{
	if not BCGT.spawnChances then BCGT.populateSpawnChances() end
	if not BCGT.spawnChances[roomtype] then BCGT.spawnChances[roomtype] = {} end
	if not BCGT.spawnChances[roomtype][containertype] then BCGT.spawnChances[roomtype][containertype] = {} end

	local unlucky, lucky = false, false;
	if ItemPicker and ItemPicker.player then
		lucky = ItemPicker.player:HasTrait("Lucky");
		unlucky = ItemPicker.player:HasTrait("Unlucky");
	end

	local idx;
	for idx=0,container:getItems():size()-1 do
		local item = container:getItems():get(idx);

		BCGT.randomizeCondition(item, BCGT.spawnChances[roomtype][containertype][item:getFullType()] or ZombRand(100));
		if BCGT.spawnChances[item:getType()] then
			print("inside container randomiser");
			for cntIdx=0,item:getItemContainer():getItems():size()-1 do
				local cItem = item:getItemContainer():getItems():get(cntIdx);
				BCGT.randomizeCondition(item, BCGT.spawnChances[item:getType()][cItem:getFullType()] or ZombRand(100));
			end
			print("leaving container randomiser");
		end
	end
end--}}}

Events.OnFillContainer.Add(BCGT.OnFillContainer);
