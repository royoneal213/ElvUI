﻿local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local join = string.join;

local lastPanel;
local displayNumberString = '';

local function OnEvent(self, event)
	self.text:SetFormattedText(displayNumberString, ACHIEVEMENT_TITLE, GetTotalAchievementPoints());

	lastPanel = self;
end

local function Click(self)
	ToggleAchievementFrame();
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = join('', '%s: ', hex, '%d|r');
	
	if ( lastPanel ~= nil ) then
		OnEvent(lastPanel);
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;

DT:RegisterDatatext(ACHIEVEMENT_TITLE, { 'ACHIEVEMENT_EARNED' }, OnEvent, nil, Click);