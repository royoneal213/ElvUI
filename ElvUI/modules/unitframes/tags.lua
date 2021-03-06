local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")
------------------------------------------------------------------------
--	Tags
------------------------------------------------------------------------

ElvUF.TagEvents['afk'] = 'PLAYER_FLAGS_CHANGED'
ElvUF.Tags['afk'] = function(unit)
	local isAFK = UnitIsAFK(unit)
	if isAFK then
		return ('|cffFFFFFF[|r|cffFF0000%s|r|cFFFFFFFF]|r'):format(DEFAULT_AFK_MESSAGE)
	else
		return ''
	end
end

ElvUF.TagEvents['healthcolor'] = 'UNIT_HEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags['healthcolor'] = function(unit)
	if not unit then return end
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		return Hex(0.84, 0.75, 0.65)
	else
		local r, g, b = ElvUF.ColorGradient(UnitHealth(unit), UnitHealthMax(unit), 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
		return Hex(r, g, b)
	end
end

ElvUF.TagEvents['health:current'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags['health:current'] = function(unit)
	if not unit then return end
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']
	if (status) then
		return status
	else
		return E:GetFormattedText('CURRENT', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.TagEvents['health:deficit'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags['health:deficit'] = function(unit)
	if not unit then return end
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']

	if (status) then
		return status
	else
		return E:GetFormattedText('DEFICIT', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.TagEvents['health:current-percent'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags['health:current-percent'] = function(unit)
	if not unit then return end
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']

	if (status) then
		return status
	else
		return E:GetFormattedText('CURRENT_PERCENT', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.TagEvents['health:current-max'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags['health:current-max'] = function(unit)
	if not unit then return end
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']

	if (status) then
		return status
	else
		return E:GetFormattedText('CURRENT_MAX', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.TagEvents['health:current-max-percent'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags['health:current-max-percent'] = function(unit)
	if not unit then return end
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']

	if (status) then
		return status
	else
		return E:GetFormattedText('CURRENT_MAX_PERCENT', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.TagEvents['health:max'] = 'UNIT_MAXHEALTH'
ElvUF.Tags['health:max'] = function(unit)
	if not unit then return end
	local max = UnitHealthMax(unit)

	return E:GetFormattedText('CURRENT', max, max)
end

ElvUF.TagEvents['health:percent'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
ElvUF.Tags['health:percent'] = function(unit)
	if not unit then return end
	local status = UnitIsDead(unit) and DEAD or UnitIsGhost(unit) and L['Ghost'] or not UnitIsConnected(unit) and L['Offline']

	if (status) then
		return status
	else
		return E:GetFormattedText('PERCENT', UnitHealth(unit), UnitHealthMax(unit))
	end
end

ElvUF.TagEvents['powercolor'] = 'UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER'
ElvUF.Tags['powercolor'] = function(unit)
	if not unit then return end
	local pType, pToken, altR, altG, altB = UnitPowerType(unit)	
	local color = ElvUF['colors'].power[pToken]
	if color then
		return Hex(color[1], color[2], color[3])
	else
		return Hex(altR, altG, altB)
	end
end

ElvUF.TagEvents['power:current'] = 'UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER'
ElvUF.Tags['power:current'] = function(unit)
	if not unit then return end
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)
	
	return min == 0 and ' ' or	E:GetFormattedText('CURRENT', min, UnitPowerMax(unit, pType))
end

ElvUF.TagEvents['power:current-max'] = 'UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER'
ElvUF.Tags['power:current-max'] = function(unit)
	if not unit then return end
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and ' ' or	E:GetFormattedText('CURRENT_MAX', min, UnitPowerMax(unit, pType))
end

ElvUF.TagEvents['power:current-percent'] = 'UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER'
ElvUF.Tags['power:current-percent'] = function(unit)
	if not unit then return end
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and ' ' or	E:GetFormattedText('CURRENT_PERCENT', min, UnitPowerMax(unit, pType))
end

ElvUF.TagEvents['power:current-max-percent'] = 'UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER'
ElvUF.Tags['power:current-max-percent'] = function(unit)
	if not unit then return end
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and ' ' or	E:GetFormattedText('CURRENT_MAX_PERCENT', min, UnitPowerMax(unit, pType))
end

ElvUF.TagEvents['power:percent'] = 'UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER'
ElvUF.Tags['power:percent'] = function(unit)
	if not unit then return end
	local pType = UnitPowerType(unit)
	local min = UnitPower(unit, pType)

	return min == 0 and ' ' or	E:GetFormattedText('PERCENT', min, UnitPowerMax(unit, pType))
end

ElvUF.TagEvents['power:deficit'] = 'UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXPOWER'
ElvUF.Tags['power:deficit'] = function(unit)
	if not unit then return end
	local pType = UnitPowerType(unit)
		
	return E:GetFormattedText('DEFICIT', UnitPower(unit, pType), UnitPowerMax(unit, pType), r, g, b)
end

ElvUF.TagEvents['power:max'] = 'UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_MAXRUNIC_POWER'
ElvUF.Tags['power:max'] = function(unit)
	if not unit then return end
	local max = UnitPowerMax(unit, UnitPowerType(unit))
			
	return E:GetFormattedText('CURRENT', max, max)
end

ElvUF.TagEvents['difficultycolor'] = 'UNIT_LEVEL PLAYER_LEVEL_UP'
ElvUF.Tags['difficultycolor'] = function(unit)
	if not unit then return end
	local r, g, b = 0.69, 0.31, 0.31
	local level = UnitLevel(unit)
	if (level > 1) then
		local DiffColor = UnitLevel(unit) - UnitLevel('player')
		if (DiffColor >= 5) then
			r, g, b = 0.69, 0.31, 0.31
		elseif (DiffColor >= 3) then
			r, g, b = 0.71, 0.43, 0.27
		elseif (DiffColor >= -2) then
			r, g, b = 0.84, 0.75, 0.65
		elseif (-DiffColor <= GetQuestGreenRange()) then
			r, g, b = 0.33, 0.59, 0.33
		else
			r, g, b = 0.55, 0.57, 0.61
		end
	end
	
	return Hex(r, g, b)
end

ElvUF.TagEvents['namecolor'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags['namecolor'] = function(unit)
	if not unit then return end
	local unitReaction = UnitReaction(unit, 'player')
	local _, unitClass = UnitClass(unit)
	if (UnitIsPlayer(unit)) then
		local class = ElvUF.colors.class[unitClass]
		if not class then return "" end
		return Hex(class[1], class[2], class[3])
	elseif (unitReaction) then
		local reaction = ElvUF['colors'].reaction[unitReaction]
		return Hex(reaction[1], reaction[2], reaction[3])
	else
		return '|cFFC2C2C2'
	end
end

ElvUF.TagEvents['smartlevel'] = 'UNIT_LEVEL PLAYER_LEVEL_UP'
ElvUF.Tags['smartlevel'] = function(unit)
	if not unit then return end
	local level = UnitLevel(unit)
	if level == UnitLevel('player') then
		return ''
	elseif(level > 0) then
		return level
	else
		return '??'
	end
end

ElvUF.TagEvents['name:veryshort'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags['name:veryshort'] = function(unit)
	if not unit then return end
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 5) or ''
end

ElvUF.TagEvents['name:short'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags['name:short'] = function(unit)
	if not unit then return end
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 10) or ''
end

ElvUF.TagEvents['name:medium'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags['name:medium'] = function(unit)
	if not unit then return end
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 15) or ''
end

ElvUF.TagEvents['name:long'] = 'UNIT_NAME_UPDATE'
ElvUF.Tags['name:long'] = function(unit)
	if not unit then return end
	local name = UnitName(unit)
	return name ~= nil and E:ShortenString(name, 20) or ''
end

ElvUF.TagEvents['threat:percent'] = 'UNIT_THREAT_SITUATION_UPDATE'
ElvUF.Tags['threat:percent'] = function(unit)
	if not unit then return end
	local _, _, percent = UnitDetailedThreatSituation('player', unit)
	if(percent and percent > 0) and (GetNumPartyMembers() or UnitExists('pet')) then
		return format('%.0f%%', percent)
	else 
		return ''
	end
end

ElvUF.TagEvents['threat:current'] = 'UNIT_THREAT_SITUATION_UPDATE'
ElvUF.Tags['threat:current'] = function(unit)
	if not unit then return end
	local _, _, percent, _, threatvalue = UnitDetailedThreatSituation('player', unit)
	if(percent and percent > 0) and (GetNumPartyMembers() or UnitExists('pet')) then
		return E:ShortValue(threatvalue)
	else 
		return ''
	end
end

ElvUF.TagEvents['threatcolor'] = 'UNIT_THREAT_SITUATION_UPDATE'
ElvUF.Tags['threatcolor'] = function(unit)
	if not unit then return end
	local _, status = UnitDetailedThreatSituation('player', unit)
	if (status) and (GetNumPartyMembers() or UnitExists('pet')) then
		return Hex(GetThreatStatusColor(status))
	else 
		return ''
	end
end

local unitStatus = {}
ElvUF.OnUpdateThrottle['statustimer'] = 1
ElvUF.Tags['statustimer'] = function(unit)
	local guid = UnitGUID(unit)
	if (UnitIsAFK(unit)) then
		if not unitStatus[guid] then unitStatus[guid] = {'AFK', GetTime()} end
	elseif(UnitIsDND(unit)) then
		if not unitStatus[guid] then unitStatus[guid] = {'DND', GetTime()} end
	elseif(UnitIsDead(unit)) or (UnitIsGhost(unit))then
		if not unitStatus[guid] then unitStatus[guid] = {'Dead', GetTime()} end
	elseif(not UnitIsConnected(unit)) then
		if not unitStatus[guid] then unitStatus[guid] = {'Offline', GetTime()} end
	else
		unitStatus[guid] = nil
	end

	if unitStatus[guid] ~= nil then
		local status = unitStatus[guid][1]
		local timer = GetTime() - unitStatus[guid][2]
		local mins = floor(timer / 60)
		local secs = floor(timer - (mins * 60))
		return ("%s (%01.f:%02.f)"):format(status, mins, secs)
	else
		return ''
	end
end

ElvUF.OnUpdateThrottle['pvptimer'] = 1
ElvUF.Tags['pvptimer'] = function(unit)
	if (UnitIsPVPFreeForAll(unit) or UnitIsPVP(unit)) then
		local timer = GetPVPTimer()

		if timer ~= 301000 and timer ~= -1 then	
			local mins = floor((timer / 1000) / 60)
			local secs = floor((timer / 1000) - (mins * 60))
			return ("%s (%01.f:%02.f)"):format(PVP, mins, secs)
		else
			return PVP
		end
	else
		return ""
	end
end