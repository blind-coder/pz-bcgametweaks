if not BCGT then BCGT = {} end

BCGT.OnFillContainer = function(roomtype, containertype, container)
	local unlucky, lucky = false, false;
	if ItemPicker and ItemPicker.player then
		lucky = ItemPicker.player:HasTrait("Lucky");
		unlucky = ItemPicker.player:HasTrait("Unlucky");
	end

	local idx;
	for idx=0,container:getItems():size()-1 do
		local perfect = false;
		local broken = false;

		if unlucky then
			if ZombRand(10) == 5 then -- 10% chance
				broken = true;
			end
		else
			if ZombRand(50) == 17 then -- 2% chance
				broken = true;
			end
		end
		if not broken then
			if lucky then
				if ZombRand(10) == 7 then -- 10% chance
					perfect = true;
				end
			else
				if ZombRand(50) == 43 then -- 2% chance
					perfect = true;
				end
			end
		end

		if instanceof(item, "HandWeapon") then
			local item = container:getItems():get(idx);
			if broken then
				item:setCondition(0, false);
			elseif perfect then
				item:setCondition(item:getConditionMax(), false);
			else
				item:setCondition(item:getConditionMax() * (5+ZombRand(90)) / 100, false);
			end

			if unlucky then
				if ZombRand(20) == 12 then -- 5% chance
					item:setHaveBeenRepaired(1+ZombRand(3));
				end
			end
		end

		if instanceof(item, "DrainableComboItem") then
			if broken then
				item:setUsedDelta(0.0);
			elseif perfect then
				item:setUsedDelta(1.0);
			else
				item:setUsedDelta(0.05 + (ZombRand(90) / 100));
			end
		end
	end
end

Events.OnFillContainer.Add(BCGT.OnFillContainer);
