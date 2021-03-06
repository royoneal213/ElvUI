local E, L, V, P, G = unpack(select(2, ...));
local TT = E:NewModule('Tooltip', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0');

local _G = getfenv(0)
local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]
local find, format = string.find, string.format
local floor = math.floor
local twipe, tinsert, tconcat = table.wipe, table.insert, table.concat

local playerGUID = UnitGUID("player")
local targetList, inspectCache, current = {}, {}, {}
local NIL_COLOR = { r=1, g=1, b=1 }
local TAPPED_COLOR = { r=.6, g=.6, b=.6 }
local AFK_LABEL = " |cffFFFFFF[|r|cffE7E716"..L["AFK"].."|r|cffFFFFFF]|r"
local DND_LABEL = " |cffFFFFFF[|r|cffFF0000"..L["DND"].."|r|cffFFFFFF]|r"
local TALENTS_PREFIX = TALENTS..":|cffffffff ";

local tooltips = {
	GameTooltip,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	ItemRefShoppingTooltip3,
	AutoCompleteBox,
	FriendsTooltip,
	ConsolidatedBuffsTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3,
	DropDownList1MenuBackdrop,
	DropDownList2MenuBackdrop,
	DropDownList3MenuBackdrop,
	BNToastFrame
}

local classification = {
	worldboss = format("|cffAF5050 %s|r", BOSS),
	rareelite = format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC)
}

local SlotName = {
	"Head","Neck","Shoulder","Back","Chest","Wrist",
	"Hands","Waist","Legs","Feet","Finger0","Finger1",
	"Trinket0","Trinket1","MainHand","SecondaryHand"
}

--All this does is increase the spacing between tooltips when you compare items
function TT:GameTooltip_ShowCompareItem(tt, shift)
	if ( not tt ) then
		tt = GameTooltip;
	end
	local item, link = tt:GetItem();
	if ( not link ) then
		return;
	end
	
	local shoppingTooltip1, shoppingTooltip2, shoppingTooltip3 = unpack(tt.shoppingTooltips);

	local item1 = nil;
	local item2 = nil;
	local item3 = nil;
	local side = "left";
	if ( shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, tt) ) then
		item1 = true;
	end
	if ( shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, tt) ) then
		item2 = true;
	end
	if ( shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, tt) ) then
		item3 = true;
	end

	-- find correct side
	local rightDist = 0;
	local leftPos = tt:GetLeft();
	local rightPos = tt:GetRight();
	if ( not rightPos ) then
		rightPos = 0;
	end
	if ( not leftPos ) then
		leftPos = 0;
	end

	rightDist = GetScreenWidth() - rightPos;

	if (leftPos and (rightDist < leftPos)) then
		side = "left";
	else
		side = "right";
	end

	-- see if we should slide the tooltip
	if ( tt:GetAnchorType() and tt:GetAnchorType() ~= "ANCHOR_PRESERVE" ) then
		local totalWidth = 0;
		if ( item1  ) then
			totalWidth = totalWidth + shoppingTooltip1:GetWidth();
		end
		if ( item2  ) then
			totalWidth = totalWidth + shoppingTooltip2:GetWidth();
		end
		if ( item3  ) then
			totalWidth = totalWidth + shoppingTooltip3:GetWidth();
		end

		if ( (side == "left") and (totalWidth > leftPos) ) then
			tt:SetAnchorType(tt:GetAnchorType(), (totalWidth - leftPos), 0);
		elseif ( (side == "right") and (rightPos + totalWidth) >  GetScreenWidth() ) then
			tt:SetAnchorType(tt:GetAnchorType(), -((rightPos + totalWidth) - GetScreenWidth()), 0);
		end
	end

	-- anchor the compare tooltips
	if ( item3 ) then
		shoppingTooltip3:SetOwner(tt, "ANCHOR_NONE");
		shoppingTooltip3:ClearAllPoints();
		if ( side and side == "left" ) then
			shoppingTooltip3:SetPoint("TOPRIGHT", tt, "TOPLEFT", -2, -10);
		else
			shoppingTooltip3:SetPoint("TOPLEFT", tt, "TOPRIGHT", 2, -10);
		end
		shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, tt);
		shoppingTooltip3:Show();
	end
	
	if ( item1 ) then
		if( item3 ) then
			shoppingTooltip1:SetOwner(shoppingTooltip3, "ANCHOR_NONE");
		else
			shoppingTooltip1:SetOwner(tt, "ANCHOR_NONE");
		end
		shoppingTooltip1:ClearAllPoints();
		if ( side and side == "left" ) then
			if( item3 ) then
				shoppingTooltip1:SetPoint("TOPRIGHT", shoppingTooltip3, "TOPLEFT", -2, 0);
			else
				shoppingTooltip1:SetPoint("TOPRIGHT", tt, "TOPLEFT", -2, -10);
			end
		else
			if( item3 ) then
				shoppingTooltip1:SetPoint("TOPLEFT", shoppingTooltip3, "TOPRIGHT", 2, 0);
			else
				shoppingTooltip1:SetPoint("TOPLEFT", tt, "TOPRIGHT", 2, -10);
			end
		end
		shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, tt);
		shoppingTooltip1:Show();

		if ( item2 ) then
			shoppingTooltip2:SetOwner(shoppingTooltip1, "ANCHOR_NONE");
			shoppingTooltip2:ClearAllPoints();
			if ( side and side == "left" ) then
				shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT", -2, 0);
			else
				shoppingTooltip2:SetPoint("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 2, 0);
			end
			shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, tt);
			shoppingTooltip2:Show();
		end
	end
end

function TT:GameTooltip_SetDefaultAnchor(tt, parent)
	if E.private.tooltip.enable ~= true then return end
	if(tt:GetAnchorType() ~= "ANCHOR_NONE") then return end
	if InCombatLockdown() and self.db.visibility.combat then
		tt:Hide()
		return
	end

	if(parent) then
		if(self.db.cursorAnchor) then
			tt:SetOwner(parent, "ANCHOR_CURSOR")	
			if(not GameTooltipStatusBar.anchoredToTop) then
				GameTooltipStatusBar:ClearAllPoints()
				GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", E.Border, (E.Spacing * 3))
				GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -E.Border, (E.Spacing * 3))
				GameTooltipStatusBar.text:Point("CENTER", GameTooltipStatusBar, 0, 3)
				GameTooltipStatusBar.anchoredToTop = true
			end
			return
		else
			tt:SetOwner(parent, "ANCHOR_NONE")
			tt:ClearAllPoints()
			if(GameTooltipStatusBar.anchoredToTop) then
				GameTooltipStatusBar:ClearAllPoints()
				GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
				GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))
				GameTooltipStatusBar.text:Point("CENTER", GameTooltipStatusBar, 0, -3)
				GameTooltipStatusBar.anchoredToTop = nil
			end			
		end
	end

	if(not E:HasMoverBeenMoved('TooltipMover')) then
		if ElvUI_ContainerFrame and ElvUI_ContainerFrame:IsShown() then
			tt:SetPoint('BOTTOMRIGHT', ElvUI_ContainerFrame, 'TOPRIGHT', 0, 18)	
		elseif RightChatPanel:GetAlpha() == 1 and RightChatPanel:IsShown() then
			tt:SetPoint('BOTTOMRIGHT', RightChatPanel, 'TOPRIGHT', 0, 18)		
		else
			tt:SetPoint('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', 0, 18)
		end
	else
		local point = E:GetScreenQuadrant(TooltipMover)
		if point == "TOPLEFT" then
			tt:SetPoint("TOPLEFT", TooltipMover, "BOTTOMLEFT", 1, -4)
		elseif point == "TOPRIGHT" then
			tt:SetPoint("TOPRIGHT", TooltipMover, "BOTTOMRIGHT", -1, -4)
		elseif point == "BOTTOMLEFT" or point == "LEFT" then
			tt:SetPoint("BOTTOMLEFT", TooltipMover, "TOPLEFT", 1, 18)
		else
			tt:SetPoint("BOTTOMRIGHT", TooltipMover, "TOPRIGHT", -1, 18)
		end
	end
end

function TT:RemoveTrashLines(tt)
	for i=3, tt:NumLines() do
		local tiptext = _G[("GameTooltipTextLeft%d"):format(i)]
		while tiptext and tiptext:GetText() and (tiptext:GetText() == PVP_ENABLED or tiptext:GetText() == FACTION_HORDE or tiptext:GetText() == FACTION_ALLIANCE) do
			if tiptext:GetText() == PVP_ENABLED then
				local text = _G[("GameTooltipTextLeft%d"):format(i - 1)]:GetText()
				if text then
					_G[("GameTooltipTextLeft%d"):format(i - 1)]:SetText(("%s (%s)"):format(text, PVP_ENABLED))
				end
			end 		
			tiptext:SetText()
			break
		end
	end
end

function TT:GetLevelLine(tt, offset)
	for i=offset, tt:NumLines() do
		local tipText = _G["GameTooltipTextLeft"..i]
		if(tipText:GetText() and tipText:GetText():find(LEVEL)) then
			return tipText
		end
	end
end

function TT:GatherTalents(isInspect)
	local group = GetActiveTalentGroup(isInspect);
	local maxTree, _ = 1;
	
	for i = 1, 3 do
		_, _, current[i] = GetTalentTabInfo(i, isInspect, nil, group);
		if (current[i] > current[maxTree]) then
			maxTree = i;
		end
	end
	current.tree = GetTalentTabInfo(maxTree, isInspect, nil, group);
	
	local talentFormat = self.db.talentFormat or 1;
	if (current[maxTree] == 0) then
		current.format = L["No Talents"];
	elseif (talentFormat == 1) then
		current.format = current.tree.." ("..current[1].."/"..current[2].."/"..current[3]..")";
	elseif (talentFormat == 2) then
		current.format = current.tree;
	elseif (talentFormat == 3) then
		current.format = current[1].."/"..current[2].."/"..current[3];
	end
	
	if (not isInspect) then
		GameTooltip:AddLine(TALENTS_PREFIX..current.format);
	elseif (GameTooltip:GetUnit()) then
		for i = 2, GameTooltip:NumLines() do
			if ((_G["GameTooltipTextLeft"..i]:GetText() or ""):match("^"..TALENTS_PREFIX)) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("%s%s",TALENTS_PREFIX,current.format);
				if (not GameTooltip.fadeOut) then
					GameTooltip:Show();
				end
				break;
			end
		end
	end
end

function TT:GameTooltip_OnTooltipSetUnit(tt)
	local unit = select(2, tt:GetUnit())
	if((tt:GetOwner() ~= UIParent) and self.db.visibility.unitFrames ~= 'NONE') then 
		local modifier = self.db.visibility.unitFrames
		
		if(modifier == 'ALL' or not ((modifier == 'SHIFT' and IsShiftKeyDown()) or (modifier == 'CTRL' and IsControlKeyDown()) or (modifier == 'ALT' and IsAltKeyDown()))) then
			tt:Hide() 
			return
		end
	end

	if(not unit) then
		local GMF = GetMouseFocus()
		if(GMF and GMF:GetAttribute("unit")) then
			unit = GMF:GetAttribute("unit")
		end
		if(not unit or not UnitExists(unit)) then
			return
		end
	end

	self:RemoveTrashLines(tt) --keep an eye on this may be buggy
	local level = UnitLevel(unit)
	local isShiftKeyDown = IsShiftKeyDown()
	
	local color
	if(UnitIsPlayer(unit)) then
		local localeClass, class = UnitClass(unit)
		local name, realm = UnitName(unit)
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local pvpName = UnitPVPName(unit)
		color = RAID_CLASS_COLORS[class]

		if(self.db.playerTitles and pvpName) then
			name = pvpName
		end
		
		if(realm and realm ~= "") then
			name = name.."-"..realm
		end
		
		if(UnitIsAFK(unit)) then
			name = name..AFK_LABEL
		elseif(UnitIsDND(unit)) then
			name = name..DND_LABEL
		end
		
		GameTooltipTextLeft1:SetFormattedText("%s%s", E:RGBToHex(color.r, color.g, color.b), name)
		
		local lineOffset = 2
		if(guildName) then
			if(guildRealm and isShiftKeyDown) then
				guildName = guildName.."-"..guildRealm
			end

			if(self.db.guildRanks) then
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r> [|cff00ff10%s|r]"):format(guildName, guildRankName))
			else
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r>"):format(guildName))
			end
			lineOffset = 3
		end
		
		local levelLine = self:GetLevelLine(tt, lineOffset)
		if(levelLine) then
			local diffColor = GetQuestDifficultyColor(level)
			local race = UnitRace(unit)		
			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s|r", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", race, E:RGBToHex(color.r, color.g, color.b), localeClass)
		end	
	else
		if(UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
			color = TAPPED_COLOR
		else
			color = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		end

		local levelLine = self:GetLevelLine(tt, 2)
		if(levelLine) then
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local pvpFlag = ""
			local diffColor = GetQuestDifficultyColor(level)
	
			if(UnitIsPVP(unit)) then
				pvpFlag = format(" (%s)", PVP)
			end

			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classification[creatureClassification] or "", creatureType or "", pvpFlag)
		end
	end

	local unitTarget = unit.."target"
	local targetColor
	if(self.db.targetInfo and unit ~= "player" and UnitExists(unitTarget)) then
		if(UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget)) then
			targetColor = RAID_CLASS_COLORS[select(2, UnitClass(unitTarget))]
		else
			targetColor = FACTION_BAR_COLORS[UnitReaction(unitTarget, "player")]	
		end

		GameTooltip:AddDoubleLine(format("%s:", TARGET), format("|cff%02x%02x%02x%s|r", targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget)))
	end
	
	local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers();
	if(self.db.targetInfo and (numParty > 0 or numRaid > 0)) then
		for i = 1, (numRaid > 0 and numRaid or numParty) do
			local groupUnit = (numRaid > 0 and "raid"..i or "party"..i);
			if (UnitIsUnit(groupUnit.."target", unit)) and (not UnitIsUnit(groupUnit,"player")) then
				local _, class = UnitClass(groupUnit);
				tinsert(targetList, format("%s%s", E:RGBToHex(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b), UnitName(groupUnit)))
			end
		end
		local numList = #targetList
		if (numList > 0) then
			GameTooltip:AddLine(format("%s (|cffffffff%d|r): %s", L['Targeted By:'], numList, tconcat(targetList, ", ")), nil, nil, nil, true);
			twipe(targetList);
		end	
	end

	if(color) then
		GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		GameTooltipStatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end
	
	if unit and self.db.Talent and isShiftKeyDown then
		if (not unit) then
			local mFocus = GetMouseFocus();
			if (mFocus) and (mFocus.unit) then
				unit = mFocus.unit;
			end
		end
		
		if (UnitIsPlayer(unit)) and (UnitLevel(unit) > 9 or UnitLevel(unit) == -1) and (CanInspect(unit)) then
			twipe(current);
			current.name = UnitName(unit);
			
			if (UnitIsUnit(unit,"player")) then
				TT:GatherTalents();
			else
				local allowInspect = (not InspectFrame or not InspectFrame:IsShown()) and (not Examiner or not Examiner:IsShown());
				if (allowInspect) then
					self:RegisterEvent("INSPECT_TALENT_READY");
					NotifyInspect(unit);
				end
				for _, entry in ipairs(inspectCache) do
					if (current.name == entry.name) then
						GameTooltip:AddLine(TALENTS_PREFIX..entry.format);
						current.tree = entry.tree;
						current.format = entry.format;
						current[1], current[2], current[3] = entry[1], entry[2], entry[3];
						return;
					end
				end
				if (allowInspect) then
					GameTooltip:AddLine(TALENTS_PREFIX..L["Loading..."]);
				end
			end
		end
	end
end

function TT:INSPECT_TALENT_READY(event, ...)
	self:UnregisterEvent("INSPECT_TALENT_READY");
	if (GameTooltip:GetUnit() == current.name) then
		TT:GatherTalents(1);
	end
end

function TT:GameTooltipStatusBar_OnValueChanged(tt, value)
	if not value or not self.db.healthBar.text or not tt.text then return end
	local unit = select(2, tt:GetParent():GetUnit())
	if(not unit) then
		local GMF = GetMouseFocus()
		if(GMF and GMF:GetAttribute("unit")) then
			unit = GMF:GetAttribute("unit")
		end
	end

	local min, max = tt:GetMinMaxValues()
	if(value > 0 and max == 1) then
		tt.text:SetText(format("%d%%", floor(value * 100)))
		tt:SetStatusBarColor(TAPPED_COLOR.r, TAPPED_COLOR.g, TAPPED_COLOR.b) --most effeciant?
	elseif(value == 0 or (unit and UnitIsDeadOrGhost(unit))) then
		tt.text:SetText(DEAD)
	else
		tt.text:SetText(E:ShortValue(value).." / "..E:ShortValue(max))
	end
end

function TT:GameTooltip_OnTooltipCleared(tt)
	tt.itemCleared = nil
end

function TT:GameTooltip_OnTooltipSetItem(tt)
	if not tt.itemCleared then
		local item, link = tt:GetItem()
		local num = GetItemCount(link)
		local left = ""
		local right = ""
		
		if link ~= nil and self.db.spellID then
			left = (("|cFFCA3C3C%s|r %s"):format(ID, link)):match(":(%w+)")
		end
		
		if num > 1 and self.db.itemCount then
			right = ("|cFFCA3C3C%s|r %d"):format(L['Count'], num)
		end
		
		if left ~= "" or right ~= "" then
			tt:AddLine(" ")
			tt:AddDoubleLine(left, right)
		end
		
		tt.itemCleared = true
	end
end

function TT:GameTooltip_ShowStatusBar(tt, min, max, value, text)
	local statusBar = _G[tt:GetName().."StatusBar"..tt.shownStatusBars];
	if statusBar and not statusBar.skinned then
		statusBar:StripTextures()
		statusBar:SetStatusBarTexture(E['media'].normTex)
		statusBar:CreateBackdrop('Default')
		statusBar.skinned = true;
	end
end

function TT:SetStyle(tt)
	tt:SetTemplate("Transparent")
end

function TT:MODIFIER_STATE_CHANGED(event, key)
	if((key == "LSHIFT" or key == "RSHIFT") and UnitExists("mouseover")) then
		GameTooltip:SetUnit('mouseover')
	end
end

function TT:SetUnitAura(tt, ...)
	local _, _, _, _, _, _, _, caster, _, _, id = UnitAura(...)
	if id and self.db.spellID then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = RAID_CLASS_COLORS[class]
			tt:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, id), format("%s%s", E:RGBToHex(color.r, color.g, color.b), name))
		else
			tt:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		end

		tt:Show()
	end	
end

function TT:GameTooltip_OnTooltipSetSpell(tt)
	local id = select(3, tt:GetSpell())
	if not id or not self.db.spellID then return end

	local displayString = ("|cFFCA3C3C%s|r %d"):format(ID, id)
	local lines = tt:NumLines()
	local isFound
	for i= 1, lines do
		local line = _G[("GameTooltipTextLeft%d"):format(i)]
		if line and line:GetText() and line:GetText():find(displayString) then
			isFound = true;
			break
		end
	end
	
	if not isFound then
		tt:AddLine(displayString)
		tt:Show()
	end
end

function TT:SetItemRef(link, ...)
	local id = tonumber(link:match("spell:(%d+)"))
	if id and self.db.spellID then
		ItemRefTooltip:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		ItemRefTooltip:Show()
	end
end

function TT:RepositionBNET(frame, point, anchor, anchorPoint, xOffset, yOffset)
	if anchor ~= BNETMover then
		BNToastFrame:ClearAllPoints()
		BNToastFrame:Point('TOPLEFT', BNETMover, 'TOPLEFT');
	end
end

function TT:CheckBackdropColor()
	local r, g, b = GameTooltip:GetBackdropColor()
	r = E:Round(r, 1)
	g = E:Round(g, 1)
	b = E:Round(b, 1)
	local red, green, blue, alpha = unpack(E.media.backdropfadecolor)

	if(r ~= red or g ~= green or b ~= blue) then
		GameTooltip:SetBackdropColor(red, green, blue, alpha)
	end
end

function TT:Initialize()
	self.db = E.db.tooltip

	BNToastFrame:Point('TOPRIGHT', MMHolder, 'BOTTOMRIGHT', 0, -10);
	E:CreateMover(BNToastFrame, 'BNETMover', L['BNet Frame'])
	self:SecureHook(BNToastFrame, "SetPoint", "RepositionBNET")

	if E.private.tooltip.enable ~= true then return end
	E.Tooltip = TT

	GameTooltipStatusBar:Height(self.db.healthBar.height)
	GameTooltipStatusBar:SetStatusBarTexture(E["media"].normTex)
	GameTooltipStatusBar:CreateBackdrop('Transparent')
	GameTooltipStatusBar:SetScript("OnValueChanged", self.OnValueChanged)
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
	GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))
	GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
	GameTooltipStatusBar.text:Point("CENTER", GameTooltipStatusBar, 0, -3)
	GameTooltipStatusBar.text:FontTemplate(E.LSM:Fetch("font", self.db.healthBar.font), self.db.healthBar.fontSize, "OUTLINE")
	
	local GameTooltipAnchor = CreateFrame('Frame', 'GameTooltipAnchor', E.UIParent)
	GameTooltipAnchor:Point('BOTTOMRIGHT', RightChatToggleButton, 'BOTTOMRIGHT')
	GameTooltipAnchor:Size(130, 20)
	GameTooltipAnchor:SetFrameLevel(GameTooltipAnchor:GetFrameLevel() + 50)
	E:CreateMover(GameTooltipAnchor, 'TooltipMover', L['Tooltip'])
	
	self:SecureHook('GameTooltip_SetDefaultAnchor')
	self:SecureHook('GameTooltip_ShowStatusBar')
	self:SecureHook("SetItemRef")
	self:SecureHook("GameTooltip_ShowCompareItem")
	self:SecureHook(GameTooltip, "SetUnitAura")
	self:SecureHook(GameTooltip, "SetUnitBuff", "SetUnitAura")
	self:SecureHook(GameTooltip, "SetUnitDebuff", "SetUnitAura")
	self:HookScript(GameTooltip, "OnTooltipSetSpell", "GameTooltip_OnTooltipSetSpell")
	self:HookScript(GameTooltip, 'OnTooltipCleared', 'GameTooltip_OnTooltipCleared')
	self:HookScript(GameTooltip, 'OnTooltipSetItem', 'GameTooltip_OnTooltipSetItem')
	self:HookScript(GameTooltip, 'OnTooltipSetUnit', 'GameTooltip_OnTooltipSetUnit')
	self:HookScript(GameTooltip, "OnSizeChanged", "CheckBackdropColor")
	
	self:HookScript(GameTooltipStatusBar, 'OnValueChanged', 'GameTooltipStatusBar_OnValueChanged')
	
	self:RegisterEvent("INSPECT_TALENT_READY")
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	self:RegisterEvent("CURSOR_UPDATE", "CheckBackdropColor")
	E.Skins:HandleCloseButton(ItemRefCloseButton)
	for _, tt in pairs(tooltips) do
		self:HookScript(tt, 'OnShow', 'SetStyle')
	end
end

E:RegisterModule(TT:GetName())