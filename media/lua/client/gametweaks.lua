require 'BuildingObjects/ISUI/ISBuildMenu'
require 'TimedActions/ISInventoryTransferAction'

BCGT = {};

BCGT.canBuildOrig = ISBuildMenu.canBuild;
ISBuildMenu.canBuild = function(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player)
	-- getText("ContextMenu_Rain_Collector_Barrel")
	if option.name == getText("ContextMenu_Rain_Collector_Barrel") then
		-- reduce required carp skill a bit
		return BCGT.canBuildOrig(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, math.max(2, carpentrySkill - 3), option, player);
	end
	return BCGT.canBuildOrig(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player);
end

BCGT.ISITAisValid = ISInventoryTransferAction.isValid;
ISInventoryTransferAction.isValid = function(self)
	-- floor can have as many items as the player wants, ignore 50 units limit
	if not self.srcContainer:contains(self.item) then
		return false;
	end
	if self.srcContainer == self.destContainer then return false; end

	if self.destContainer:getType()=="floor" then return true; end
	return BCGT.ISITAisValid(self);
end

