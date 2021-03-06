﻿local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

function E:EnableAddon(addon)
	local _, _, _, _, _, reason, _ = GetAddOnInfo(addon)
	if reason ~= "MISSING" then 
		EnableAddOn(addon) 
		ReloadUI() 
	else 
		print("|cffff0000Error, Addon '"..addon.."' not found.|r") 
	end	
end

function E:DisableAddon(addon)
	local _, _, _, _, _, reason, _ = GetAddOnInfo(addon)
	if reason ~= "MISSING" then 
		DisableAddOn(addon) 
		ReloadUI() 
	else 
		print("|cffff0000Error, Addon '"..addon.."' not found.|r") 
	end
end

function FarmMode()
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT); return; end
	if E.private.general.minimap.enable ~= true then return; end
	if Minimap:IsShown() then
		UIFrameFadeOut(Minimap, 0.3)
		UIFrameFadeIn(FarmModeMap, 0.3) 
		Minimap.fadeInfo.finishedFunc = function() Minimap:Hide(); _G.MinimapZoomIn:Click(); _G.MinimapZoomOut:Click(); Minimap:SetAlpha(1) end
		FarmModeMap.enabled = true
	else
		UIFrameFadeOut(FarmModeMap, 0.3)
		UIFrameFadeIn(Minimap, 0.3) 
		FarmModeMap.fadeInfo.finishedFunc = function() FarmModeMap:Hide(); _G.MinimapZoomIn:Click(); _G.MinimapZoomOut:Click(); Minimap:SetAlpha(1) end
		FarmModeMap.enabled = false
	end
end

function E:FarmMode(msg)
	if E.private.general.minimap.enable ~= true then return; end
	if msg and type(tonumber(msg))=="number" and tonumber(msg) <= 500 and tonumber(msg) >= 20 and not InCombatLockdown() then
		E.db.farmSize = tonumber(msg)
		FarmModeMap:Size(tonumber(msg))
	end
	
	FarmMode()
end

local channel = 'PARTY'
local target = nil;
function E:DevChannel(chnl)
	channel = chnl
	E:Print(format('Developer channel has been changed to %s.', chnl))
end

function E:DevTarget(tgt)
	target = tgt
	E:Print(format('Developer target has been changed to %s.', tgt))
end

function E:DevSays(msg)
	if channel == 'WHISPER' and target == nil then
		E:Print('You need to set a whisper target.')
		return
	end
	SendAddonMessage('ELVUI_DEV_SAYS', msg, channel, target)
end

function E:DevCommand(msg)
	if channel == 'WHISPER' and target == nil then
		E:Print('You need to set a whisper target.')
		return
	end
	SendAddonMessage('ELVUI_DEV_CMD', msg, channel, target)
end

function E:Grid(msg)
	if msg and type(tonumber(msg))=="number" and tonumber(msg) <= 256 and tonumber(msg) >= 4 then
		E.db.gridSize = msg
		E:Grid_Show()
	else 
		if EGrid then		
			E:Grid_Hide()
		else 
			E:Grid_Show()
		end
	end
end

function E:LuaError(msg)
	msg = lower(msg)
	if (msg == 'on') then
		DisableAllAddOns()
		EnableAddOn("ElvUI");
		EnableAddOn("ElvUI_Config");
		SetCVar("scriptErrors", 1)
		ReloadUI()
	elseif (msg == 'off') then
		SetCVar("scriptErrors", 0)
		E:Print("Lua errors off.")
	else
		E:Print("/luaerror on - /luaerror off")
	end
end

function E:BGStats()
	local DT = E:GetModule('DataTexts')
	DT.ForceHideBGStats = nil;
	DT:LoadDataTexts()
	
	E:Print(L['Battleground datatexts will now show again if you are inside a battleground.'])
end

local function OnCallback(command)
	MacroEditBox:GetScript("OnEvent")(MacroEditBox, "EXECUTE_CHAT_LINE", command)
end

function E:DelayScriptCall(msg)
	local secs, command = msg:match("^([^%s]+)%s+(.*)$")
	secs = tonumber(secs)
	if (not secs) or (#command == 0) then
		self:Print("usage: /in <seconds> <command>")
		self:Print("example: /in 1.5 /say hi")
	else
		E:ScheduleTimer(OnCallback, secs, command)
	end
end

local num_frames = 0
local function OnUpdate()
	num_frames = num_frames + 1
end
local f = CreateFrame("Frame")
f:Hide()
f:SetScript("OnUpdate", OnUpdate)

local toggleMode = false
function E:GetCPUImpact()
	if(not toggleMode) then
		ResetCPUUsage()
		num_frames = 0;
		debugprofilestart()
		f:Show()
		toggleMode = true
		self:Print("CPU Impact being calculated, type /cpuimpact to get results when you are ready.")
	else
		f:Hide()
		local ms_passed = debugprofilestop()
		UpdateAddOnCPUUsage()

		self:Print("Consumed "..(GetAddOnCPUUsage("ElvUI") / num_frames).." milliseconds per frame. Each frame took "..(ms_passed / num_frames).." to render.");
		toggleMode = false
	end
end

function E:LoadCommands()
	self:RegisterChatCommand("in", "DelayScriptCall")
	self:RegisterChatCommand("ec", "ToggleConfig")
	self:RegisterChatCommand("elvui", "ToggleConfig")
	
	self:RegisterChatCommand('cpuimpact', 'GetCPUImpact')
	self:RegisterChatCommand('cpuusage', 'GetTopCPUFunc')
	self:RegisterChatCommand('bgstats', 'BGStats')
	self:RegisterChatCommand('aprilfools', 'AprilFoolsToggle')
	self:RegisterChatCommand('luaerror', 'LuaError')
	self:RegisterChatCommand('egrid', 'Grid')
	self:RegisterChatCommand("moveui", "ToggleConfigMode")
	self:RegisterChatCommand("resetui", "ResetUI")
	self:RegisterChatCommand("enable", "EnableAddon")
	self:RegisterChatCommand("disable", "DisableAddon")
	self:RegisterChatCommand('farmmode', 'FarmMode')
	self:RegisterChatCommand('devsays', 'DevSays')
	self:RegisterChatCommand('devchannel', 'DevChannel')
	self:RegisterChatCommand('devcmd', 'DevCommand')
	self:RegisterChatCommand('devtarget', 'DevTarget')
	self:RegisterChatCommand('cleanguild', 'MassGuildKick')
	if E:GetModule('ActionBars') then
		self:RegisterChatCommand('kb', E:GetModule('ActionBars').ActivateBindMode)
	end
end