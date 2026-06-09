VuhDoAbsorbComms = {};

local select = select;
local UnitExists = UnitExists;
local UnitGUID = UnitGUID;

local LibAbsorb = LibStub("SpecializedAbsorbs-1.0", true);

local VUHDO_CONFIG;
local VUHDO_RAID_GUIDS;
local VUHDO_updateHealthBarsFor;
local VUHDO_updateAllRaidBars;

function VUHDO_absorbAdapterInitBurst()
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	VUHDO_RAID_GUIDS = VUHDO_GLOBAL["VUHDO_RAID_GUIDS"];
	VUHDO_updateHealthBarsFor = VUHDO_GLOBAL["VUHDO_updateHealthBarsFor"];
	VUHDO_updateAllRaidBars = VUHDO_GLOBAL["VUHDO_updateAllRaidBars"];
end

--
local function VUHDO_isAbsorbsNative()
	return type(_G["UnitGetTotalAbsorbs"]) == "function";
end

--
local function VUHDO_unitGetTotalAbsorbs(aUnit)
	if not aUnit or not UnitExists(aUnit) then
		return 0;
	end

	if LibAbsorb then
		return LibAbsorb.UnitTotal(UnitGUID(aUnit)) or 0;
	end

	return 0;
end

do
	local tNativeAbsorbs = _G["UnitGetTotalAbsorbs"];

	if tNativeAbsorbs == nil or not VUHDO_isAbsorbsNative() then
		_G["UnitGetTotalAbsorbs"] = VUHDO_unitGetTotalAbsorbs;
	else
		VUHDO_unitGetTotalAbsorbs = tNativeAbsorbs;
	end
end

--
function VUHDO_getAbsorbOnUnit(aUnit)
	if (VUHDO_CONFIG["SHOW_ABSORBS"] == false) then
		return 0;
	end

	return VUHDO_unitGetTotalAbsorbs(aUnit);
end

--
local min = math.min;

function VUHDO_getUnitEffectiveHealth(aUnit, anInfo)
	if (anInfo == nil) then
		return 0, 0;
	end

	local tAbsorb = VUHDO_getAbsorbOnUnit(aUnit);
	return anInfo["health"] + tAbsorb, tAbsorb;
end

--
function VUHDO_getUnitHealthPlusAbsorbPercent(aUnit, anInfo)
	if (anInfo == nil or anInfo["healthmax"] == 0) then
		return 0;
	end

	local tEffective = VUHDO_getUnitEffectiveHealth(aUnit, anInfo);
	return min(100, tEffective / anInfo["healthmax"] * 100);
end

--
local tUnit;
local tCnt;
local function VUHDO_absorbUpdateGUIDs(...)
	for tCnt = 1, select("#", ...) do
		tUnit = VUHDO_RAID_GUIDS[select(tCnt, ...)];
		if (tUnit ~= nil) then
			VUHDO_updateHealthBarsFor(tUnit, 9); -- VUHDO_UPDATE_INC
		end
	end
end

--
function VuhDoAbsorbComms:EffectApplied(_, _, _, aDstGUID)
	VUHDO_absorbUpdateGUIDs(aDstGUID);
end

--
function VuhDoAbsorbComms:EffectUpdated(_, aGUID)
	VUHDO_absorbUpdateGUIDs(aGUID);
end

--
function VuhDoAbsorbComms:EffectRemoved(_, aGUID)
	VUHDO_absorbUpdateGUIDs(aGUID);
end

--
function VuhDoAbsorbComms:AreaCreated()
	VUHDO_updateAllRaidBars();
end

--
function VuhDoAbsorbComms:AreaCleared()
	VUHDO_updateAllRaidBars();
end

--
function VuhDoAbsorbComms:UnitUpdated(_, aGUID)
	VUHDO_absorbUpdateGUIDs(aGUID);
end

--
function VuhDoAbsorbComms:UnitCleared(_, aGUID)
	VUHDO_absorbUpdateGUIDs(aGUID);
end

--
function VuhDoAbsorbComms:UnitAbsorbed(_, aGUID)
	VUHDO_absorbUpdateGUIDs(aGUID);
end

--
function VUHDO_setAbsorbEnabled()
	if (LibAbsorb == nil or VUHDO_isAbsorbsNative()) then
		return;
	end

	if (VUHDO_CONFIG["SHOW_ABSORBS"] ~= false) then
		LibAbsorb.RegisterCallback(VuhDoAbsorbComms, "EffectApplied", "EffectApplied");
		LibAbsorb.RegisterCallback(VuhDoAbsorbComms, "EffectUpdated", "EffectUpdated");
		LibAbsorb.RegisterCallback(VuhDoAbsorbComms, "EffectRemoved", "EffectRemoved");
		LibAbsorb.RegisterCallback(VuhDoAbsorbComms, "AreaCreated", "AreaCreated");
		LibAbsorb.RegisterCallback(VuhDoAbsorbComms, "AreaCleared", "AreaCleared");
		LibAbsorb.RegisterCallback(VuhDoAbsorbComms, "UnitUpdated", "UnitUpdated");
		LibAbsorb.RegisterCallback(VuhDoAbsorbComms, "UnitCleared", "UnitCleared");
		LibAbsorb.RegisterCallback(VuhDoAbsorbComms, "UnitAbsorbed", "UnitAbsorbed");
	else
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "EffectApplied");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "EffectUpdated");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "EffectRemoved");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "AreaCreated");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "AreaCleared");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "UnitUpdated");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "UnitCleared");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "UnitAbsorbed");
		VUHDO_updateAllRaidBars();
	end
end
