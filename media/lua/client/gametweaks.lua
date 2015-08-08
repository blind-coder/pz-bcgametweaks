require 'BuildingObjects/ISUI/ISBuildMenu'
require 'TimedActions/ISInventoryTransferAction'
require 'TimedActions/ISReadABook'
require 'ISUI/ISToolTipInv'

if not BCGT then BCGT = {} end

BCGT.canBuildOrig = ISBuildMenu.canBuild;
-- reduce requirements for raincollectors
ISBuildMenu.canBuild = function(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player) -- {{{
	if option.name == getText("ContextMenu_Rain_Collector_Barrel") then
		-- reduce required carp skill a bit
		return BCGT.canBuildOrig(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, math.max(2, carpentrySkill - 3), option, player);
	end
	return BCGT.canBuildOrig(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player);
end
-- }}}

BCGT.ISITAisValid = ISInventoryTransferAction.isValid;
-- transfer as much as you want onto the floor
ISInventoryTransferAction.isValid = function(self) -- {{{
	-- floor can have as many items as the player wants, ignore 50 units limit
	if not self.srcContainer:contains(self.item) then
		return false;
	end
	if self.srcContainer == self.destContainer then return false; end

	if self.destContainer:getType() == "floor" then return true; end
	return BCGT.ISITAisValid(self);
end
-- }}}

BCGT.ISReadABookUpdate = ISReadABook.update;
BCGT.ISReadABookStart = ISReadABook.start;
-- freeze boredom and unhappyness while reading a skill book
function ISReadABook.update(self) -- {{{
	self.character:getBodyDamage():setBoredomLevel(ISReadABook.boredom);
	self.character:getBodyDamage():setUnhappynessLevel(ISReadABook.boredom);
	BCGT.ISReadABookUpdate(self);
end
-- }}}
function ISReadABook.start(self) -- {{{
	ISReadABook.boredom = self.character:getBodyDamage():getBoredomLevel();
	ISReadABook.unhappy = self.character:getBodyDamage():getUnhappynessLevel();
	BCGT.ISReadABookStart(self);
end
-- }}}

BCGT.CombineItemsDoIt = function(item, player, allItems)--{{{
	local fullType = item:getFullType();
	local inv = getSpecificPlayer(player):getInventory();
	local fillstate = 0;
	for i=0,allItems:size()-1 do
		fillstate = fillstate + allItems:get(i):getUsedDelta()*100;
	end
	while inv:FindAndReturn(fullType) ~= nil do
		local it = inv:FindAndReturn(fullType);
		inv:Remove(it);
	end

	while fillstate > 0 do
		local it = inv:AddItem(fullType);
		if fillstate < 100 then
			it:setUsedDelta(fillstate / 100);
			fillstate = 0;
		else
			fillstate = fillstate - 100;
		end
	end
end
--}}}
BCGT.CombineItems = function(player, context, items)--{{{
	if #items > 1 then return end; -- we only create an entry for the first object

	item = items[1];
	if not instanceof(item, "InventoryItem") then
		item = item.items[1];
	end
	if item == nil then return end;

	local allItems = getSpecificPlayer(player):getInventory():FindAndReturn(item:getFullType(), 99999);
	if allItems:size() <= 1 then return end;

	local subMenu = ISContextMenu:getNew(context);
	local buildOption = context:addOption("Combine into one", item, BCGT.CombineItemsDoIt, player, allItems);
end
--}}}
Events.OnFillInventoryObjectContextMenu.Add(BCGT.CombineItems);
