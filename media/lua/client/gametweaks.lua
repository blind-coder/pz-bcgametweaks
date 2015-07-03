require 'BuildingObjects/ISUI/ISBuildMenu'
require 'TimedActions/ISInventoryTransferAction'
require 'TimedActions/ISReadABook'
require 'ISUI/ISToolTipInv'
require 'ISUI/ISToolTipInv'

BCGT = {};

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
