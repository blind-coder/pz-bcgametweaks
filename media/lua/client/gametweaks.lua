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

BCGT.ISToolTipInvRender = ISToolTipInv.render;

function ISToolTipInv:render()
	BCGT.ISToolTipInvRender(self);

	if self.item:getFullType() ~= "Base.Doorknob" then return end;
	if self.item:getKeyId() == nil then return end;
	if ISContextMenu.instance and ISContextMenu.instance.visibleCheck then return end;

	local tw = self.width;
	local th = self.height;
	local r = 0;
	local g = 0;

	if getSpecificPlayer(0):getInventory():haveThisKeyId(self.item:getKeyId()) then
		g = 1;
		text = "You have a key for this knob.";
	else
		r = 1;
		text = "You don't have a key for this knob.";
	end

	local textHeight = getTextManager():MeasureStringY(UIFont.Small, text);
	local textWidth = getTextManager():MeasureStringX(UIFont.Small, text);
	self:drawText(text, 3, th+3, r, g, 0, 1, UIFont.Small);

	self:drawRect(0, th, math.max(self.width, 6+textWidth), 6+textHeight,
		self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	self:drawRectBorder(0, th, math.max(self.width, 6+textWidth), 6+textHeight,
		self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
end
