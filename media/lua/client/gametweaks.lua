require 'BuildingObjects/ISUI/ISBuildMenu'
require 'TimedActions/ISInventoryTransferAction'
require 'ISUI/ISToolTipInv'

BCGT = {};

BCGT.canBuildOrig = ISBuildMenu.canBuild;
ISBuildMenu.canBuild = function(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player) -- {{{
	if option.name == getText("ContextMenu_Rain_Collector_Barrel") then
		-- reduce required carp skill a bit
		return BCGT.canBuildOrig(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, math.max(2, carpentrySkill - 3), option, player);
	end
	return BCGT.canBuildOrig(plankNb, nailsNb, hingeNb, doorknobNb, baredWireNb, carpentrySkill, option, player);
end
-- }}}

BCGT.ISITAisValid = ISInventoryTransferAction.isValid;
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

BCGT.dump = function(o, lvl) --  Small function to dump an object. {{{
  if lvl == nil then lvl = 5 end
  if lvl < 0 then return "SO ("..tostring(o)..")" end

  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if k == "prev" or k == "next" then
        s = s .. '['..k..'] = '..tostring(v);
      else
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. BCGT.dump(v, lvl - 1) .. ',\n'
      end
    end
    return s .. '}\n'
  else
    return tostring(o)
  end
end
-- }}}
BCGT.pline = function (text) --  Print text to logfile -- {{{
  print(tostring(text));
end
-- }}}
