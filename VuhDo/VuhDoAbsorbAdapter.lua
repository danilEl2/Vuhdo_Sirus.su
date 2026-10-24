VuhDoAbsorbComms = {};

local select = select;
local UnitExists = UnitExists;
local UnitGUID = UnitGUID;
local GetTime = GetTime;
local pairs = pairs;
local wipe = table.wipe;

local LibAbsorb = LibStub("SpecializedAbsorbs-1.0", true);

local VUHDO_CONFIG;
local VUHDO_RAID;
local VUHDO_RAID_GUIDS;
local VUHDO_TIMERS;
local VUHDO_updateHealthBarsFor;
local VUHDO_updateAllRaidBars;

local VUHDO_ABSORB_CACHE = {};
-- GetTime() when a positive cache value was last written (for sticky TTL).
local VUHDO_ABSORB_CACHE_TIME = {};
-- Soft-zero confirm: count + GetTime of first soft zero in the streak.
-- Second soft zero counts only after ZERO_CONFIRM_SEC (avoids UNIT_MAXHEALTH+UNIT_HEALTH same-tick wipe).
local VUHDO_ABSORB_ZERO_STREAK = {};
local VUHDO_ABSORB_ZERO_STREAK_AT = {};
local VUHDO_ABSORB_ZERO_CONFIRM_SEC = 0.25;
-- Dirty units awaiting a single coalesced VUHDO_UPDATE_INC redraw.
local VUHDO_ABSORB_DIRTY = {};
local VUHDO_ABSORB_DIRTY_PENDING = false;
local VUHDO_ABSORB_DIRTY_FLUSH = {};

function VUHDO_absorbAdapterInitBurst()
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_RAID_GUIDS = VUHDO_GLOBAL["VUHDO_RAID_GUIDS"];
	VUHDO_TIMERS = VUHDO_GLOBAL["VUHDO_TIMERS"];
	VUHDO_updateHealthBarsFor = VUHDO_GLOBAL["VUHDO_updateHealthBarsFor"];
	VUHDO_updateAllRaidBars = VUHDO_GLOBAL["VUHDO_updateAllRaidBars"];
end

--
local function VUHDO_isAbsorbsNative()
	return VUHDO_IS_NATIVE_ABSORBS;
end

--
function VUHDO_getAbsorbPollIntervalMs()
	return VUHDO_CONFIG["ABSORB_REFRESH_MS"] or 3000;
end

--
-- Local wrapper only — never publish to _G (other addons must not see a fake native API).
local VUHDO_unitGetTotalAbsorbs;
do
	local tNativeAbsorbs = _G["UnitGetTotalAbsorbs"];

	if (tNativeAbsorbs ~= nil and VUHDO_isAbsorbsNative()) then
		VUHDO_unitGetTotalAbsorbs = tNativeAbsorbs;
	else
		VUHDO_unitGetTotalAbsorbs = function(aUnit)
			if not aUnit or not UnitExists(aUnit) then
				return 0;
			end

			if LibAbsorb then
				return LibAbsorb.UnitTotal(UnitGUID(aUnit)) or 0;
			end

			return 0;
		end;
	end
end

--
-- Also used by HealComm for coalesced mode-9 redraws (same dirty queue).
function VUHDO_markAbsorbDirty(aUnit)
	if (aUnit == nil) then
		return;
	end

	VUHDO_ABSORB_DIRTY[aUnit] = true;
	VUHDO_ABSORB_DIRTY_PENDING = true;
end

--
-- Flush coalesced absorb/inc redraws (call from OnUpdate; not synchronously from poll).
function VUHDO_flushAbsorbDirty()
	if (not VUHDO_ABSORB_DIRTY_PENDING) then
		return;
	end

	VUHDO_ABSORB_DIRTY_PENDING = false;

	-- Swap so markAbsorbDirty during flush cannot mutate the set being iterated.
	local tFlush = VUHDO_ABSORB_DIRTY;
	VUHDO_ABSORB_DIRTY = VUHDO_ABSORB_DIRTY_FLUSH;
	VUHDO_ABSORB_DIRTY_FLUSH = tFlush;

	if (VUHDO_updateHealthBarsFor == nil) then
		wipe(tFlush);
		return;
	end

	local tUnit;
	for tUnit in pairs(tFlush) do
		VUHDO_updateHealthBarsFor(tUnit, 9); -- VUHDO_UPDATE_INC
	end
	wipe(tFlush);
end

--
-- Display read: prefer live API, but keep last known amount when the API briefly
-- returns 0 (common on Sirus during max-HP aura application). Cleared by
-- authoritative refresh, TTL (~one poll interval), or soft-zero confirm after delay.
function VUHDO_getAbsorbOnUnit(aUnit)
	if (VUHDO_CONFIG["SHOW_ABSORBS"] == false) then
		return 0;
	end

	local tLive = VUHDO_unitGetTotalAbsorbs(aUnit) or 0;
	if (tLive > 0) then
		VUHDO_ABSORB_CACHE[aUnit] = tLive;
		VUHDO_ABSORB_CACHE_TIME[aUnit] = GetTime();
		VUHDO_ABSORB_ZERO_STREAK[aUnit] = 0;
		VUHDO_ABSORB_ZERO_STREAK_AT[aUnit] = nil;
		return tLive;
	end

	local tCached = VUHDO_ABSORB_CACHE[aUnit] or 0;
	if (tCached <= 0) then
		return 0;
	end

	local tCachedAt = VUHDO_ABSORB_CACHE_TIME[aUnit];
	local tTtl = VUHDO_getAbsorbPollIntervalMs() * 0.001;
	if (tCachedAt ~= nil and (GetTime() - tCachedAt) > tTtl) then
		VUHDO_ABSORB_CACHE[aUnit] = 0;
		VUHDO_ABSORB_CACHE_TIME[aUnit] = nil;
		VUHDO_ABSORB_ZERO_STREAK[aUnit] = 0;
		VUHDO_ABSORB_ZERO_STREAK_AT[aUnit] = nil;
		return 0;
	end

	return tCached;
end

--
local tUnit;
local tCnt;
local function VUHDO_absorbUpdateGUIDs(...)
	for tCnt = 1, select("#", ...) do
		tUnit = VUHDO_RAID_GUIDS[select(tCnt, ...)];
		if (tUnit ~= nil) then
			VUHDO_ABSORB_CACHE[tUnit] = VUHDO_unitGetTotalAbsorbs(tUnit) or 0;
			VUHDO_ABSORB_CACHE_TIME[tUnit] = GetTime();
			VUHDO_ABSORB_ZERO_STREAK[tUnit] = 0;
			VUHDO_ABSORB_ZERO_STREAK_AT[tUnit] = nil;
			VUHDO_markAbsorbDirty(tUnit);
		end
	end
end

--
function VUHDO_clearAbsorbCache()
	for tUnit in pairs(VUHDO_ABSORB_CACHE) do
		VUHDO_ABSORB_CACHE[tUnit] = nil;
	end
	wipe(VUHDO_ABSORB_CACHE_TIME);
	wipe(VUHDO_ABSORB_ZERO_STREAK);
	wipe(VUHDO_ABSORB_ZERO_STREAK_AT);
	wipe(VUHDO_ABSORB_DIRTY);
	wipe(VUHDO_ABSORB_DIRTY_FLUSH);
	VUHDO_ABSORB_DIRTY_PENDING = false;
end

--
-- anIsAuthoritative: true for UNIT_ABSORB_AMOUNT_CHANGED / poll — trust live 0.
-- Soft (health/max): keep sticky cache on a one-frame live 0; a second soft zero
-- only after ZERO_CONFIRM_SEC becomes authoritative (not same-tick MAXHEALTH+HEALTH).
function VUHDO_refreshAbsorbOnUnit(aUnit, anIsAuthoritative)
	if (VUHDO_CONFIG["SHOW_ABSORBS"] == false or aUnit == nil) then
		return false;
	end

	local tLive = VUHDO_unitGetTotalAbsorbs(aUnit) or 0;
	local tCached = VUHDO_ABSORB_CACHE[aUnit] or 0;
	local tNow = GetTime();

	if (tLive == 0 and tCached > 0 and not anIsAuthoritative) then
		local tStreak = VUHDO_ABSORB_ZERO_STREAK[aUnit] or 0;
		local tFirstAt = VUHDO_ABSORB_ZERO_STREAK_AT[aUnit];

		if (tStreak < 1 or tFirstAt == nil) then
			VUHDO_ABSORB_ZERO_STREAK[aUnit] = 1;
			VUHDO_ABSORB_ZERO_STREAK_AT[aUnit] = tNow;
			return false;
		end

		if ((tNow - tFirstAt) < VUHDO_ABSORB_ZERO_CONFIRM_SEC) then
			-- Still inside the confirm window (e.g. paired MAXHEALTH+HEALTH).
			return false;
		end

		VUHDO_ABSORB_ZERO_STREAK[aUnit] = 0;
		VUHDO_ABSORB_ZERO_STREAK_AT[aUnit] = nil;
		anIsAuthoritative = true;
	else
		VUHDO_ABSORB_ZERO_STREAK[aUnit] = 0;
		VUHDO_ABSORB_ZERO_STREAK_AT[aUnit] = nil;
	end

	if (tLive ~= tCached) then
		VUHDO_ABSORB_CACHE[aUnit] = tLive;
		if (tLive > 0) then
			VUHDO_ABSORB_CACHE_TIME[aUnit] = tNow;
		else
			VUHDO_ABSORB_CACHE_TIME[aUnit] = nil;
		end
		VUHDO_markAbsorbDirty(aUnit);
		return true;
	end

	-- Keep TTL fresh while the shield is stable (no value change, no redraw).
	if (tLive > 0) then
		VUHDO_ABSORB_CACHE_TIME[aUnit] = tNow;
	end

	return false;
end

--
local tInfo;
function VUHDO_refreshAllAbsorbs()
	if (VUHDO_CONFIG["SHOW_ABSORBS"] == false or VUHDO_RAID == nil) then
		return;
	end

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (tInfo["connected"] and not tInfo["dead"]) then
			VUHDO_refreshAbsorbOnUnit(tUnit, true);
		else
			VUHDO_ABSORB_CACHE[tUnit] = 0;
			VUHDO_ABSORB_CACHE_TIME[tUnit] = nil;
			VUHDO_ABSORB_ZERO_STREAK[tUnit] = 0;
			VUHDO_ABSORB_ZERO_STREAK_AT[tUnit] = nil;
		end
	end

	-- Flush is deferred to OnUpdate (≤50 ms) to avoid a same-frame poll spike.
end

--
local function VUHDO_setAbsorbRefreshTimer(anIsEnabled)
	if (VUHDO_TIMERS == nil) then
		return;
	end

	if (anIsEnabled) then
		VUHDO_TIMERS["UPDATE_ABSORBS"] = 0.5;
	else
		VUHDO_TIMERS["UPDATE_ABSORBS"] = -1;
		VUHDO_clearAbsorbCache();
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
		if (VUHDO_CONFIG["SHOW_ABSORBS"] ~= false) then
			VUHDO_setAbsorbRefreshTimer(true);
			VUHDO_refreshAllAbsorbs();
		else
			VUHDO_setAbsorbRefreshTimer(false);
			if (VUHDO_updateAllRaidBars ~= nil) then
				VUHDO_updateAllRaidBars();
			end
		end
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
		VUHDO_setAbsorbRefreshTimer(true);
		VUHDO_refreshAllAbsorbs();
	else
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "EffectApplied");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "EffectUpdated");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "EffectRemoved");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "AreaCreated");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "AreaCleared");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "UnitUpdated");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "UnitCleared");
		LibAbsorb.UnregisterCallback(VuhDoAbsorbComms, "UnitAbsorbed");
		VUHDO_setAbsorbRefreshTimer(false);
		if (VUHDO_updateAllRaidBars ~= nil) then
			VUHDO_updateAllRaidBars();
		end
	end
end

--
-- Register the event only. VUHDO_HAS_ABSORB_EVENT stays false until the first
-- UNIT_ABSORB_AMOUNT_CHANGED arrives (see VuhDoEventHandler) so UNIT_AURA
-- soft-refresh remains active on builds where the API exists but the event does not.
function VUHDO_registerAbsorbEvents(anInstance)
	if (VUHDO_IS_NATIVE_ABSORBS and anInstance ~= nil) then
		anInstance:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED");
	end
end
