VuhDoHealComms = {};

-- BURST CACHE ---------------------------------------------------
local floor = floor;
local select = select;
local pairs = pairs;

local VUHDO_CONFIG;
local VUHDO_RAID_GUID_NAMES;

local VUHDO_updateHealthBarsFor;

local GetTime = GetTime;
local UnitGUID = UnitGUID;
local strsub = strsub;
local sIsCasted, sIsChannelled, sIsHots, sIsBombed;
local sIsOthers, sIsOwn;
local sCastedSecs, sChannelledSecs, sHotsSecs, sBombedSecs;
local sPlayerGUID;
function VUHDO_healCommAdapterInitBurst()
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	VUHDO_RAID_GUID_NAMES = VUHDO_GLOBAL["VUHDO_RAID_GUID_NAMES"];
	VUHDO_updateHealthBarsFor = VUHDO_GLOBAL["VUHDO_updateHealthBarsFor"];
	sIsCasted = VUHDO_CONFIG["SHOW_INC_CASTED"];
	sIsChannelled = VUHDO_CONFIG["SHOW_INC_CHANNELLED"];
	sIsHots = VUHDO_CONFIG["SHOW_INC_HOTS"];
	sIsBombed = VUHDO_CONFIG["SHOW_INC_BOMBED"];
	sIsOthers = VUHDO_CONFIG["SHOW_INCOMING"];
	sIsOwn = VUHDO_CONFIG["SHOW_OWN_INCOMING"];
	sCastedSecs = VUHDO_CONFIG["INC_CASTED_SECS"]
	sChannelledSecs = VUHDO_CONFIG["INC_CHANNELLED_SECS"];
	sHotsSecs = VUHDO_CONFIG["INC_HOTS_SECS"]
	sBombedSecs = VUHDO_CONFIG["INC_BOMBED_SECS"]
	sPlayerGUID = UnitGUID("player");
end

----------------------------------------------------

local VUHDO_INC_HEAL_OWN = {};
local VUHDO_INC_HEAL_OTHERS = {};
local VUHDO_INC_END = {};

--
function VUHDO_getOwnIncHealOnUnit(aName)
	return VUHDO_INC_HEAL_OWN[aName] or 0;
end

--
function VUHDO_getOthersIncHealOnUnit(aName)
	return VUHDO_INC_HEAL_OTHERS[aName] or 0;
end

--
function VUHDO_getIncHealOnUnit(aName)
	return VUHDO_getOwnIncHealOnUnit(aName) + VUHDO_getOthersIncHealOnUnit(aName);
end

--
local sHealComm = LibStub("LibHealComm-4.0");
local VUHDO_DIRECT_HEALS = sHealComm.DIRECT_HEALS;
local VUHDO_CHANNEL_HEALS = sHealComm.CHANNEL_HEALS;
local VUHDO_HOT_HEALS = sHealComm.HOT_HEALS;
local VUHDO_BOMB_HEALS = sHealComm.BOMB_HEALS;

--
local tAmount;
local function VUHDO_sumHealAmount(aTargetGUID, aHealType, aTime, aCasterGUID)
	if (not aHealType) then
		return 0;
	end

	return sHealComm:GetHealAmount(aTargetGUID, aHealType, aTime, aCasterGUID) or 0;
end

--
local tOwn, tTotal, tOthers, tModifier;
local function VUHDO_computeIncHealAmounts(aTargetGUID, aNow)
	tOwn = 0;
	tTotal = 0;

	if (not sIsOthers and not sIsOwn) then
		return 0, 0;
	end

	if (sPlayerGUID == nil) then
		sPlayerGUID = UnitGUID("player");
	end

	if (sIsCasted) then
		if (sIsOwn and sPlayerGUID ~= nil) then
			tOwn = tOwn + VUHDO_sumHealAmount(aTargetGUID, VUHDO_DIRECT_HEALS, aNow + sCastedSecs, sPlayerGUID);
		end
		if (sIsOwn or sIsOthers) then
			tTotal = tTotal + VUHDO_sumHealAmount(aTargetGUID, VUHDO_DIRECT_HEALS, aNow + sCastedSecs, nil);
		end
	end

	if (sIsChannelled) then
		if (sIsOwn and sPlayerGUID ~= nil) then
			tOwn = tOwn + VUHDO_sumHealAmount(aTargetGUID, VUHDO_CHANNEL_HEALS, aNow + sChannelledSecs, sPlayerGUID);
		end
		if (sIsOwn or sIsOthers) then
			tTotal = tTotal + VUHDO_sumHealAmount(aTargetGUID, VUHDO_CHANNEL_HEALS, aNow + sChannelledSecs, nil);
		end
	end

	if (sIsHots) then
		if (sIsOwn and sPlayerGUID ~= nil) then
			tOwn = tOwn + VUHDO_sumHealAmount(aTargetGUID, VUHDO_HOT_HEALS, aNow + sHotsSecs, sPlayerGUID);
		end
		if (sIsOwn or sIsOthers) then
			tTotal = tTotal + VUHDO_sumHealAmount(aTargetGUID, VUHDO_HOT_HEALS, aNow + sHotsSecs, nil);
		end
	end

	if (sIsBombed) then
		if (sIsOwn and sPlayerGUID ~= nil) then
			tOwn = tOwn + VUHDO_sumHealAmount(aTargetGUID, VUHDO_BOMB_HEALS, aNow + sBombedSecs, sPlayerGUID);
		end
		if (sIsOwn or sIsOthers) then
			tTotal = tTotal + VUHDO_sumHealAmount(aTargetGUID, VUHDO_BOMB_HEALS, aNow + sBombedSecs, nil);
		end
	end

	tModifier = sHealComm:GetHealModifier(aTargetGUID);
	tOwn = floor(tOwn * tModifier);
	tTotal = floor(tTotal * tModifier);

	if (not sIsOwn) then
		tOwn = 0;
	end

	tOthers = 0;
	if (sIsOthers) then
		tOthers = tTotal - tOwn;
		if (tOthers < 0) then
			tOthers = 0;
		end
	end

	return tOwn, tOthers;
end

--
local function VUHDO_setIncHeal(aTargetName, anOwnAmount, anOthersAmount, anEndTime)
	VUHDO_INC_HEAL_OWN[aTargetName] = anOwnAmount;
	VUHDO_INC_HEAL_OTHERS[aTargetName] = anOthersAmount;
	if (anEndTime ~= nil and (VUHDO_INC_END[aTargetName] == nil or VUHDO_INC_END[aTargetName] < anEndTime)) then
		VUHDO_INC_END[aTargetName] = anEndTime + 1;
	end
	VUHDO_updateHealthBarsFor(VUHDO_RAID_NAMES[aTargetName], 9); -- VUHDO_UPDATE_INC
end

--
local tName, tTime, tNow;
function VUHDO_clearObsoleteInc()
	tNow = GetTime();
	-- Clear obsolete ending times
	for tName, tTime in pairs(VUHDO_INC_END) do
		if (tTime < tNow) then
			VUHDO_setIncHeal(tName, 0, 0, nil);
			VUHDO_INC_END[tName] = nil;
		end
	end
end

--
local tArgNum, tTargetGUID;
local tTargetName;
local tNow;
local tCnt;
function VuhDoHealComms:HealComm_HealStarted(_, aCasterGUID, _, aHealType, anEndTime, ...)
	if (not sIsOthers and not sIsOwn) then
		return;
	end

	tNow = GetTime();
	tArgNum = select("#", ...);

	for tCnt = 1, tArgNum do
		tTargetGUID = select(tCnt, ...);
		tTargetName = VUHDO_RAID_GUID_NAMES[tTargetGUID];
		if (tTargetName ~= nil) then
			tOwn, tOthers = VUHDO_computeIncHealAmounts(tTargetGUID, tNow);
			VUHDO_setIncHeal(tTargetName, tOwn, tOthers, anEndTime);
		end
	end
end

--
function VuhDoHealComms:HealComm_HealStopped(_, aCasterGUID, aSpellID, aHealType, anIsInterrupted, ...)
	VuhDoHealComms:HealComm_HealStarted(nil, aCasterGUID, aSpellID, aHealType, nil, ...);
end
