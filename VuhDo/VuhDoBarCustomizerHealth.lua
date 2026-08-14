local VUHDO_NAME_TEXTS = {};

-- BURST CACHE ---------------------------------------------------

local VUHDO_getHealthBar;
local VUHDO_getIncHealBar;
local VUHDO_getOtherIncHealBar;
local VUHDO_getBarText;
local VUHDO_getIncHealOnUnit;
local VUHDO_getOwnIncHealOnUnit;
local VUHDO_getOthersIncHealOnUnit;
local VUHDO_getAbsorbOnUnit;
local VUHDO_getUnitEffectiveHealth;
local VUHDO_getUnitHealthPlusAbsorbPercent;
local VUHDO_getDiffColor;
local VUHDO_isPanelVisible;
local VUHDO_updateManaBars;
local VUHDO_updateAllHoTs;
local VUHDO_refreshHotBarsRange;
local VUHDO_removeAllHots;
local VUHDO_getUnitHealthPercent;
local VUHDO_getPanelButtons;
local VUHDO_updateBouquetsForEvent;
local VUHDO_utf8Cut;
local VUHDO_resolveVehicleUnit;
local VUHDO_getOverhealPanel;
local VUHDO_getOverhealText;
local VUHDO_getUnitButtons;
local VUHDO_getBarRoleIcon;
local VUHDO_getBarIconFrame;
local VUHDO_updateClusterHighlights;
local VUHDO_setLlcStatusBarTexture;
local VUHDO_refreshHlBarBorderForButton;

local VUHDO_PANEL_SETUP;
local VUHDO_BUTTON_CACHE;
local VUHDO_RAID;
local VUHDO_CONFIG;
local VUHDO_INDICATOR_CONFIG;
local VUHDO_BAR_COLOR;
local VUHDO_THREAT_CFG;
local VUHDO_IN_RAID_TARGET_BUTTONS;
local VUHDO_INTERNAL_TOGGLES;

local abs = abs;
local floor = floor;
local min = math.min;
local max = math.max;
local strlen = strlen;
local strfind = strfind;
local strbyte = strbyte;
local GetRaidTargetIndex = GetRaidTargetIndex;
local UnitIsUnit = UnitIsUnit;
local pairs = pairs;
local twipe = table.wipe;
local _ = _;
local sIsOverhealText;
local sIsAggroText;

function VUHDO_customHealthInitBurst()
	-- variables
	VUHDO_PANEL_SETUP = VUHDO_GLOBAL["VUHDO_PANEL_SETUP"];
	VUHDO_BUTTON_CACHE = VUHDO_GLOBAL["VUHDO_BUTTON_CACHE"];
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	VUHDO_INDICATOR_CONFIG = VUHDO_GLOBAL["VUHDO_INDICATOR_CONFIG"];
	VUHDO_getUnitButtons = VUHDO_GLOBAL["VUHDO_getUnitButtons"];
	VUHDO_BAR_COLOR = VUHDO_PANEL_SETUP["BAR_COLORS"];
	VUHDO_THREAT_CFG = VUHDO_CONFIG["THREAT"];
	VUHDO_IN_RAID_TARGET_BUTTONS = VUHDO_GLOBAL["VUHDO_IN_RAID_TARGET_BUTTONS"];
	VUHDO_INTERNAL_TOGGLES = VUHDO_GLOBAL["VUHDO_INTERNAL_TOGGLES"];

	-- functions
	VUHDO_getHealthBar = VUHDO_GLOBAL["VUHDO_getHealthBar"];
	VUHDO_getIncHealBar = VUHDO_GLOBAL["VUHDO_getIncHealBar"];
	VUHDO_getOtherIncHealBar = VUHDO_GLOBAL["VUHDO_getOtherIncHealBar"];
	VUHDO_getBarText = VUHDO_GLOBAL["VUHDO_getBarText"];
	VUHDO_getIncHealOnUnit = VUHDO_GLOBAL["VUHDO_getIncHealOnUnit"];
	VUHDO_getOwnIncHealOnUnit = VUHDO_GLOBAL["VUHDO_getOwnIncHealOnUnit"];
	VUHDO_getOthersIncHealOnUnit = VUHDO_GLOBAL["VUHDO_getOthersIncHealOnUnit"];
	VUHDO_getAbsorbOnUnit = VUHDO_GLOBAL["VUHDO_getAbsorbOnUnit"];
	VUHDO_getUnitEffectiveHealth = VUHDO_GLOBAL["VUHDO_getUnitEffectiveHealth"];
	VUHDO_getUnitHealthPlusAbsorbPercent = VUHDO_GLOBAL["VUHDO_getUnitHealthPlusAbsorbPercent"];
	VUHDO_getDiffColor = VUHDO_GLOBAL["VUHDO_getDiffColor"];
	VUHDO_isPanelVisible = VUHDO_GLOBAL["VUHDO_isPanelVisible"];
	VUHDO_updateManaBars = VUHDO_GLOBAL["VUHDO_updateManaBars"];
	VUHDO_removeAllHots = VUHDO_GLOBAL["VUHDO_removeAllHots"];
	VUHDO_updateAllHoTs = VUHDO_GLOBAL["VUHDO_updateAllHoTs"];
	VUHDO_refreshHotBarsRange = VUHDO_GLOBAL["VUHDO_refreshHotBarsRange"];
	VUHDO_getUnitHealthPercent = VUHDO_GLOBAL["VUHDO_getUnitHealthPercent"];
	VUHDO_getPanelButtons = VUHDO_GLOBAL["VUHDO_getPanelButtons"];
	VUHDO_updateBouquetsForEvent = VUHDO_GLOBAL["VUHDO_updateBouquetsForEvent"];
	VUHDO_utf8Cut = VUHDO_GLOBAL["VUHDO_utf8Cut"];
	VUHDO_resolveVehicleUnit = VUHDO_GLOBAL["VUHDO_resolveVehicleUnit"];
	VUHDO_getOverhealPanel = VUHDO_GLOBAL["VUHDO_getOverhealPanel"];
	VUHDO_getOverhealText = VUHDO_GLOBAL["VUHDO_getOverhealText"];
	VUHDO_getBarRoleIcon = VUHDO_GLOBAL["VUHDO_getBarRoleIcon"];
	VUHDO_getBarIconFrame = VUHDO_GLOBAL["VUHDO_getBarIconFrame"];
	VUHDO_updateClusterHighlights = VUHDO_GLOBAL["VUHDO_updateClusterHighlights"];
	VUHDO_setLlcStatusBarTexture = VUHDO_GLOBAL["VUHDO_setLlcStatusBarTexture"];
	VUHDO_refreshHlBarBorderForButton = VUHDO_GLOBAL["VUHDO_refreshHlBarBorderForButton"];

	-- statics
	sIsOverhealText = VUHDO_CONFIG["SHOW_TEXT_OVERHEAL"]
	sIsAggroText = VUHDO_CONFIG["THREAT"]["AGGRO_USE_TEXT"];

	-- custom
	twipe(VUHDO_NAME_TEXTS);
end

----------------------------------------------------

function VUHDO_resetNameTextCache()
	twipe(VUHDO_NAME_TEXTS);
end

local tIncColor = {
	["useBackground"] = true
};

local tOtherIncColor = {
	["useBackground"] = true
};

local tAbsColor = {
	["useBackground"] = true
};

local VUHDO_ABSORB_TEXTURE_DEFAULT = "Blizzard - Shield Fill";
local VUHDO_ABSORB_SHIELD_OVERLAY = [[Interface\RaidFrame\Shield-Overlay]];
local VUHDO_ABSORB_SHIELD_OVERSHIELD = [[Interface\RaidFrame\Shield-Overshield]];
local VUHDO_ABSORB_SEAM_OVERLAP_PX = 1;
local VUHDO_INC_SEAM_OVERLAP_PX = 1;
local tBarWidth;
local tStart;
local tAbsStart;

local tDefaultAbsorbColor = {
	["R"] = 0.66, ["G"] = 0.93, ["B"] = 1, ["O"] = 0.78,
	["useBackground"] = true, ["useOpacity"] = true,
};

--
local function VUHDO_getIncOverlapStartPct(anIncBar, aStartPct, aHealthPct)
	if (anIncBar == nil or anIncBar == VuhDoDummyStatusBar or aStartPct <= 0) then
		return aStartPct;
	end

	if (abs(aStartPct - aHealthPct) > 0.001) then
		return aStartPct;
	end

	tBarWidth = anIncBar:GetWidth();
	if (tBarWidth <= 0) then
		return aStartPct;
	end

	tStart = aStartPct - (100 * VUHDO_INC_SEAM_OVERLAP_PX / tBarWidth);
	if (tStart < 0) then
		return 0;
	end

	return tStart;
end

-- Smooth HP: shift absorb/inc by (displayed HP - target healthPct) so overlays
-- stay on the visible tip while SetValue lerps.
local VUHDO_refreshSmoothHealOverlay;

local function VUHDO_getSmoothOverlayDelta(aHlBar, aHealthPct)
	if (aHlBar == nil or aHlBar["SetValueInstant"] == nil) then
		return 0;
	end
	local tDisplayed = aHlBar["vuhdoSmoothCur"];
	if (tDisplayed == nil) then
		tDisplayed = aHlBar["value"] or 0;
	end
	return tDisplayed - (aHealthPct or 0);
end

-- Follow displayed HP. If start+width would pass 100, pin the same width from
-- the right (overshield) instead of clamping 100–130 → 100–100 (щит пропадает).
local function VUHDO_setShiftedValueRange(aBar, aStartPct, aEndPct, aDelta)
	if (aBar == nil or aBar == VuhDoDummyStatusBar) then
		return;
	end

	local tWidth = (aEndPct or 0) - (aStartPct or 0);
	if (tWidth <= 0) then
		aBar:SetValueRange(0, 0);
		return;
	end

	aDelta = aDelta or 0;
	if (aDelta == 0) then
		aBar:SetValueRange(aStartPct, aEndPct);
		return;
	end

	local tStart = aStartPct + aDelta;
	local tEnd = tStart + tWidth;
	if (tEnd > 100) then
		tStart = max(0, 100 - tWidth);
		tEnd = 100;
	elseif (tStart < 0) then
		tStart = 0;
		tEnd = tWidth;
		if (tEnd > 100) then
			tEnd = 100;
		end
	end

	aBar:SetValueRange(tStart, tEnd);
end

local function VUHDO_ensureSmoothHealOverlay(aHlBar, aButton, aHealthPct)
	if (aHlBar == nil or aHlBar["SetValueInstant"] == nil) then
		if (aHlBar ~= nil) then
			aHlBar["vuhdoOverlay"] = nil;
			aHlBar["vuhdoOnSmoothStep"] = nil;
		end
		return 0;
	end

	local tO = aHlBar["vuhdoOverlay"];
	if (tO == nil) then
		tO = {};
		aHlBar["vuhdoOverlay"] = tO;
		aHlBar["vuhdoOnSmoothStep"] = VUHDO_refreshSmoothHealOverlay;
	end

	tO["button"] = aButton;
	tO["healthPct"] = aHealthPct or 0;
	local tDisplayed = aHlBar["vuhdoSmoothCur"];
	if (tDisplayed == nil) then
		tDisplayed = aHlBar["value"] or 0;
	end
	return tDisplayed - tO["healthPct"];
end

local function VUHDO_paintSmoothHealOverlayRanges(aHlBar, aOverlay, aDelta)
	if (aHlBar == nil or aOverlay == nil or aOverlay["button"] == nil) then
		return;
	end

	local tButton = aOverlay["button"];
	local tAbsBar = VUHDO_getHealthBar(tButton, 17);
	local tIncBar = VUHDO_getIncHealBar(tButton);
	local tOtherIncBar = VUHDO_getOtherIncHealBar(tButton);

	if (aOverlay["hasAbsorb"] and aOverlay["absorbEndPct"] > aOverlay["absorbStartPct"]) then
		if (aOverlay["absorbFollowHealth"] == false) then
			VUHDO_setShiftedValueRange(tAbsBar, aOverlay["absorbStartPct"], aOverlay["absorbEndPct"], 0);
		else
			VUHDO_setShiftedValueRange(tAbsBar, aOverlay["absorbStartPct"], aOverlay["absorbEndPct"], aDelta);
		end
	end

	if (aOverlay["hasOtherInc"] and aOverlay["otherIncEndPct"] > aOverlay["otherIncStartPct"]) then
		VUHDO_setShiftedValueRange(tOtherIncBar, aOverlay["otherIncStartPct"], aOverlay["otherIncEndPct"], aDelta);
	end

	if (aOverlay["hasInc"] and aOverlay["incEndPct"] > aOverlay["incStartPct"]) then
		VUHDO_setShiftedValueRange(tIncBar, aOverlay["incStartPct"], aOverlay["incEndPct"], aDelta);
	end
end

VUHDO_refreshSmoothHealOverlay = function(aHlBar)
	local tO = aHlBar and aHlBar["vuhdoOverlay"];
	if (tO == nil) then
		return;
	end

	VUHDO_paintSmoothHealOverlayRanges(aHlBar, tO, VUHDO_getSmoothOverlayDelta(aHlBar, tO["healthPct"]));
end

--
local function VUHDO_getAbsorbBarColor(aIsHealthFull, aHasOverAbsorb)
	local tColors = VUHDO_PANEL_SETUP["BAR_COLORS"];

	if (aHasOverAbsorb) then
		return tColors["ABSORBS_OVER"] or tColors["ABSORBS"] or tDefaultAbsorbColor;
	end

	local tColor = tColors["ABSORBS"];

	if (aIsHealthFull) then
		tColor = tColors["ABSORBS_FULL"] or tColor;
	end

	return tColor or tDefaultAbsorbColor;
end

--
local function VUHDO_getAbsorbBarTextureName(aIsHealthFull)
	if (aIsHealthFull) then
		return VUHDO_CONFIG["ABSORB_TEXTURE_FULL"] or VUHDO_CONFIG["ABSORB_TEXTURE"] or VUHDO_ABSORB_TEXTURE_DEFAULT;
	end

	return VUHDO_CONFIG["ABSORB_TEXTURE"] or VUHDO_ABSORB_TEXTURE_DEFAULT;
end

--
local function VUHDO_applyAbsorbBarTexture(anAbsBar, aIsHealthFull)
	local tTextureName;
	local tTex;

	if (anAbsBar == nil) then
		return;
	end

	tTextureName = VUHDO_getAbsorbBarTextureName(aIsHealthFull);
	if (tTextureName == nil) then
		tTex = anAbsBar:GetStatusBarTexture();
		if (tTex ~= nil) then
			tTex:Hide();
		end
		return;
	end

	VUHDO_setLlcStatusBarTexture(anAbsBar, tTextureName);
	tTex = anAbsBar:GetStatusBarTexture();
	if (tTex ~= nil) then
		tTex:Show();
	end
end

--
local function VUHDO_getOrCreateAbsorbOverlay(anAbsBar)
	if (anAbsBar["vuhdoAbsorbOverlay"] == nil) then
		anAbsBar["vuhdoAbsorbOverlay"] = anAbsBar:CreateTexture(nil, "OVERLAY", nil, 7);
		anAbsBar["vuhdoAbsorbOverlay"]:SetTexture(VUHDO_ABSORB_SHIELD_OVERLAY, true, true);
		anAbsBar["vuhdoAbsorbOverlay"]["tileSize"] = 32;
	end

	return anAbsBar["vuhdoAbsorbOverlay"];
end

--
local tAbsBarTex;
local function VUHDO_updateAbsorbOverlay(anAbsBar, aShow, aHealthBar)
	local tOverlay = anAbsBar["vuhdoAbsorbOverlay"];

	if (tOverlay == nil) then
		return;
	end

	if (not aShow) then
		tOverlay:Hide();
		return;
	end

	tAbsBarTex = anAbsBar:GetStatusBarTexture();
	if (tAbsBarTex == nil) then
		tOverlay:Hide();
		return;
	end

	tOverlay:ClearAllPoints();
	tOverlay:SetAllPoints(tAbsBarTex);

	if (aHealthBar ~= nil) then
		tHlO = select(4, aHealthBar:GetStatusBarColor());
		tOverlay:SetAlpha(tHlO or 1);
	else
		tOverlay:SetAlpha(1);
	end

	tOverlay:Show();
end

--
local function VUHDO_getOrCreateOverAbsorbGlow(anAbsBar)
	if (anAbsBar["vuhdoOverAbsorbGlow"] == nil) then
		anAbsBar["vuhdoOverAbsorbGlow"] = anAbsBar:CreateTexture(nil, "OVERLAY", nil, 8);
		anAbsBar["vuhdoOverAbsorbGlow"]:SetTexture(VUHDO_ABSORB_SHIELD_OVERSHIELD);
		anAbsBar["vuhdoOverAbsorbGlow"]:SetBlendMode("ADD");
	end

	return anAbsBar["vuhdoOverAbsorbGlow"];
end

--
local function VUHDO_updateOverAbsorbGlow(anAbsBar, aShow, aHealthBar)
	local tGlow = anAbsBar["vuhdoOverAbsorbGlow"];
	local tAnchor;
	local tHlTex;

	if (tGlow == nil) then
		return;
	end

	if (not aShow or VUHDO_CONFIG["ABSORB_OVER_GLOW"] == false) then
		tGlow:Hide();
		return;
	end

	tAbsBarTex = anAbsBar:GetStatusBarTexture();
	tAnchor = tAbsBarTex;
	if (aHealthBar ~= nil) then
		tHlTex = aHealthBar:GetStatusBarTexture();
		if (tHlTex ~= nil and (tAbsBarTex == nil or not tAbsBarTex:IsShown() or tAbsBarTex:GetWidth() < 1)) then
			tAnchor = tHlTex;
		end
	end

	if (tAnchor == nil) then
		tGlow:Hide();
		return;
	end

	tGlow:SetWidth(16);
	tGlow:SetHeight(anAbsBar:GetHeight() + 5);
	tGlow:ClearAllPoints();

	if (VUHDO_INDICATOR_CONFIG["CUSTOM"]["HEALTH_BAR"]["invertGrowth"]) then
		tGlow:SetPoint("RIGHT", tAnchor, "LEFT", -7, 0);
	else
		tGlow:SetPoint("LEFT", tAnchor, "RIGHT", -7, 0);
	end

	if (aHealthBar ~= nil) then
		tGlow:SetAlpha(select(4, aHealthBar:GetStatusBarColor()) or 1);
	else
		tGlow:SetAlpha(1);
	end

	tGlow:Show();
end

--
function VUHDO_initAbsorbBarVisuals(anAbsBar)
	if (anAbsBar == nil) then
		return;
	end

	VUHDO_applyAbsorbBarTexture(anAbsBar, false);
	VUHDO_getOrCreateAbsorbOverlay(anAbsBar):Hide();
	VUHDO_getOrCreateOverAbsorbGlow(anAbsBar):Hide();
end

--
local function VUHDO_getUnitHealthModiPercent(anInfo, aModifier)
	if (anInfo["healthmax"] == 0) then
		return 0;
	else
		return 100 * (anInfo["health"] + aModifier) / anInfo["healthmax"];
	end
end

--
local tOpacity;
local tHlO;
local function VUHDO_setStatusBarColor(aBar, aColor)
	if (aColor["useOpacity"]) then
		tOpacity = aColor["O"];
	else
		tOpacity = nil;
	end

	if (aColor["useBackground"]) then
		aBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], tOpacity);
	elseif (tOpacity ~= nil) then
		aBar:SetAlpha(tOpacity);
	end
end

--
local function VUHDO_setStatusBarColorWithHealthAlpha(aBar, aColor, aHealthBar)
	if (aColor["useOpacity"]) then
		tOpacity = aColor["O"] or 1;
		if (aHealthBar ~= nil) then
			tHlO = select(4, aHealthBar:GetStatusBarColor());
			if (tHlO ~= nil) then
				tOpacity = tOpacity * tHlO;
			end
		end
	else
		tOpacity = nil;
	end

	if (aColor["useBackground"]) then
		aBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], tOpacity);
	elseif (tOpacity ~= nil) then
		aBar:SetAlpha(tOpacity);
	end
end

--
local function VUHDO_getKiloText(aNumber, aSetup)
	if (abs(aNumber) < 100 or aSetup["LIFE_TEXT"]["verbose"]) then
		return aNumber;
	end

	return floor(aNumber * 0.01) * 0.1 .. "k";
end

--
local tHealBarLayout = {
	["healthPct"] = 0,
	["absorbStartPct"] = 0,
	["absorbEndPct"] = 0,
	["incStartPct"] = 0,
	["incEndPct"] = 0,
	["myIncStartPct"] = 0,
	["myIncEndPct"] = 0,
	["otherIncStartPct"] = 0,
	["otherIncEndPct"] = 0,
	["amountAbs"] = 0,
	["hasAbsorb"] = false,
	["hasOverAbsorb"] = false,
	["isHealthFull"] = false,
	["absorbOverlayFromRight"] = false,
};

-- ИНВАРИАНТЫ overshield:
-- 1) tBarDenom ВСЕГДА = max HP. Нельзя tBarDenom = health + absorb.
--    Иначе full HP + щит ≥ max → HP сжимается, abs-бар максимум ~половина фрейма.
-- 2) Если absorbStart >= max HP — overlay СПРАВА поверх HP:
--    absorbEndPct = 100, absorbStartPct = 100 - 100 * absorb / maxHP.
-- 3) Этот overlay не клеить к smooth-lerp (absorbFollowHealth = false).
-- 4) Пока HP едет вниз и HP+щит > max: не клампить сдвиг в 100–100.
--    Overflow справа той же шириной, как overshield.
local function VUHDO_computeHealBarLayout(anInfo, aUnit, aMyInc, aOtherInc)
	if (anInfo == nil) then
		return nil;
	end

	if (aUnit ~= nil and UnitExists(aUnit)) then
		local tLiveMax = UnitHealthMax(aUnit);
		local tLiveHealth = UnitHealth(aUnit);
		if (tLiveMax > 0 and tLiveMax ~= anInfo["healthmax"]) then
			anInfo["healthmax"] = tLiveMax;
		end
		if (tLiveHealth >= 0) then
			anInfo["health"] = tLiveHealth;
		end
	end

	if (anInfo["healthmax"] <= 0) then
		return nil;
	end

	tHealBarLayout["amountAbs"] = 0;
	if (VUHDO_CONFIG["SHOW_ABSORBS"] ~= false) then
		tHealBarLayout["amountAbs"] = VUHDO_getAbsorbOnUnit(aUnit);
	end

	local tMax = anInfo["healthmax"];
	local tHealth = anInfo["health"];
	local tAbs = tHealBarLayout["amountAbs"];
	aMyInc = aMyInc or 0;
	aOtherInc = aOtherInc or 0;

	local tEffectiveMy = 0;
	local tEffectiveOther = 0;
	if (anInfo["connected"] and not anInfo["dead"]) then
		if (aMyInc > 0) then
			tEffectiveMy = aMyInc;
		end
		if (aOtherInc > 0) then
			tEffectiveOther = aOtherInc;
		end
	end

	local tEffectiveInc = tEffectiveMy + tEffectiveOther;

	local tHealthPlusMyInc = tHealth + tEffectiveMy;
	local tHealthPlusInc = tHealth + tEffectiveInc;

	-- Шкала всегда от max HP. Не расширять denom до health+absorb (бар 50/50).
	local tBarDenom = tMax;

	tHealBarLayout["healthPct"] = min(100, 100 * tHealth / tBarDenom);
	tHealBarLayout["myIncStartPct"] = tHealBarLayout["healthPct"];
	tHealBarLayout["myIncEndPct"] = tHealBarLayout["myIncStartPct"];
	if (tEffectiveMy > 0) then
		tHealBarLayout["myIncEndPct"] = min(100, 100 * tHealthPlusMyInc / tBarDenom);
	end

	tHealBarLayout["otherIncStartPct"] = tHealBarLayout["myIncEndPct"];
	tHealBarLayout["otherIncEndPct"] = tHealBarLayout["otherIncStartPct"];
	if (tEffectiveOther > 0) then
		tHealBarLayout["otherIncEndPct"] = min(100, 100 * tHealthPlusInc / tBarDenom);
	end

	tHealBarLayout["incStartPct"] = tHealBarLayout["healthPct"];
	tHealBarLayout["incEndPct"] = tHealBarLayout["otherIncEndPct"];

	-- Абсорб после входящего исцеления (как Blizzard), иначе при большом direct heal
	-- полоса поглощения рисуется поверх входящего и визуально «встаёт» между HP и хилом.
	local tAbsorbStart = tHealth + tEffectiveInc;
	tHealBarLayout["hasAbsorb"] = tAbs > 0 and anInfo["connected"] and not anInfo["dead"];
	tHealBarLayout["isHealthFull"] = tHealth >= tMax;

	local tHealthPlusIncAbs = tHealth + tEffectiveInc + tAbs;
	tHealBarLayout["hasOverAbsorb"] = tHealBarLayout["hasAbsorb"] and tHealthPlusIncAbs >= tMax;

	if (tHealBarLayout["hasAbsorb"] and tAbsorbStart >= tMax) then
		tHealBarLayout["absorbEndPct"] = 100;
		tHealBarLayout["absorbStartPct"] = max(0, 100 - 100 * tAbs / tMax);
		tHealBarLayout["absorbOverlayFromRight"] = true;
	else
		tHealBarLayout["absorbStartPct"] = min(100, 100 * tAbsorbStart / tBarDenom);
		tHealBarLayout["absorbEndPct"] = min(100, 100 * (tAbsorbStart + tAbs) / tBarDenom);
		tHealBarLayout["absorbOverlayFromRight"] = false;
	end

	return tHealBarLayout;
end

--
local tAbsBar;
local tHlBar;
local tLayout;
local tSmoothDelta;
local tOverlay;
local function _VUHDO_applyAbsorbBar(aLayout, tAllButtons)
	if (aLayout == nil or tAllButtons == nil) then
		return;
	end

	if (VUHDO_CONFIG["SHOW_ABSORBS"] == false or not aLayout["hasAbsorb"]
		or aLayout["absorbEndPct"] <= aLayout["absorbStartPct"]) then
		for _, tButton in pairs(tAllButtons) do
			tAbsBar = VUHDO_getHealthBar(tButton, 17);
			tHlBar = VUHDO_getHealthBar(tButton, 1);
			if (VUHDO_INDICATOR_CONFIG["CUSTOM"]["HEALTH_BAR"]["invertGrowth"]) then
				tAbsBar:SetValueRange(0, 0);
			else
				tAbsBar:SetValue(0);
			end
			VUHDO_updateAbsorbOverlay(tAbsBar, false);
			VUHDO_updateOverAbsorbGlow(tAbsBar, false);

			tOverlay = tHlBar and tHlBar["vuhdoOverlay"];
			if (tOverlay ~= nil) then
				tOverlay["hasAbsorb"] = false;
			end
		end
		return;
	end

	tAbsColor = VUHDO_getAbsorbBarColor(aLayout["isHealthFull"], aLayout["hasOverAbsorb"]);

	for _, tButton in pairs(tAllButtons) do
		tAbsBar = VUHDO_getHealthBar(tButton, 17);
		tHlBar = VUHDO_getHealthBar(tButton, 1);
		VUHDO_applyAbsorbBarTexture(tAbsBar, aLayout["isHealthFull"]);

		tAbsStart = aLayout["absorbStartPct"];
		if (aLayout["incEndPct"] > aLayout["incStartPct"] and not aLayout["absorbOverlayFromRight"]) then
			tBarWidth = tAbsBar:GetWidth();
			if (tBarWidth > 0) then
				tAbsStart = tAbsStart - (100 * VUHDO_ABSORB_SEAM_OVERLAP_PX / tBarWidth);
				if (tAbsStart < 0) then
					tAbsStart = 0;
				end
			end
		end

		tSmoothDelta = VUHDO_ensureSmoothHealOverlay(tHlBar, tButton, aLayout["healthPct"]);
		tOverlay = tHlBar and tHlBar["vuhdoOverlay"];
		if (tOverlay ~= nil) then
			tOverlay["hasAbsorb"] = true;
			tOverlay["absorbStartPct"] = tAbsStart;
			tOverlay["absorbEndPct"] = aLayout["absorbEndPct"];
			tOverlay["absorbFollowHealth"] = not aLayout["absorbOverlayFromRight"];
		end

		if (aLayout["absorbOverlayFromRight"]) then
			VUHDO_setShiftedValueRange(tAbsBar, tAbsStart, aLayout["absorbEndPct"], 0);
		else
			VUHDO_setShiftedValueRange(tAbsBar, tAbsStart, aLayout["absorbEndPct"], tSmoothDelta);
		end
		VUHDO_setStatusBarColorWithHealthAlpha(tAbsBar, tAbsColor, tHlBar);
		VUHDO_updateAbsorbOverlay(tAbsBar, not aLayout["isHealthFull"], tHlBar);
		VUHDO_updateOverAbsorbGlow(tAbsBar, aLayout["hasOverAbsorb"] and aLayout["isHealthFull"], tHlBar);
	end
end

--
local function VUHDO_clearIncBar(aBar)
	if (aBar == nil) then
		return;
	end

	if (VUHDO_INDICATOR_CONFIG["CUSTOM"]["HEALTH_BAR"]["invertGrowth"]) then
		aBar:SetValueRange(0, 0);
	else
		aBar:SetValue(0);
	end
end

--
local tOverheal;
local tRatio;
local tIsOverhealText;
local tScale;
local tAllButtons;
local tIncBar;
local tOtherIncBar;
local tButton;
local tMyInc;
local tOtherInc;
local tAmountInc;
local tInfo;
local tOverhealSetup;
local tSetup;
local function _VUHDO_updateIncHeal(aUnit)
	tInfo = VUHDO_RAID[aUnit];
	tAllButtons = VUHDO_getUnitButtons(VUHDO_resolveVehicleUnit(aUnit));

	if (tInfo == nil or tAllButtons == nil) then
		return;
	end

	tMyInc = VUHDO_getOwnIncHealOnUnit(tInfo["name"]);
	tOtherInc = VUHDO_getOthersIncHealOnUnit(tInfo["name"]);
	tAmountInc = tMyInc + tOtherInc;
	tLayout = VUHDO_computeHealBarLayout(tInfo, aUnit, tMyInc, tOtherInc);

	if (tLayout == nil) then
		for _, tButton in pairs(tAllButtons) do
			VUHDO_clearIncBar(VUHDO_getIncHealBar(tButton));
			VUHDO_clearIncBar(VUHDO_getOtherIncHealBar(tButton));
			tHlBar = VUHDO_getHealthBar(tButton, 1);
			tHlBar["vuhdoOverlay"] = nil;
			tHlBar["vuhdoOnSmoothStep"] = nil;
			if (not tInfo["connected"] or tInfo["dead"]) then
				VUHDO_setHealthBarValueInstant(tHlBar, 100);
			else
				tHlBar:SetValue(VUHDO_getUnitHealthPercent(tInfo));
			end
			VUHDO_refreshHlBarBorderForButton(tButton, aUnit);
		end
		return;
	end

	if (tInfo["healthmax"] > 0) then
		tOverheal = tAmountInc - tInfo["healthmax"] + tInfo["health"];
		tRatio = tOverheal / tInfo["healthmax"];
	else
		tOverheal = 0;
		tRatio = 0;
	end

	if (tAmountInc > 0 and tInfo["connected"] and not tInfo["dead"] and tLayout["incEndPct"] > tLayout["incStartPct"]) then
		tIncColor["R"] = -1;
		tOtherIncColor["R"] = -1;

		for _, tButton in pairs(tAllButtons) do
			tIncBar = VUHDO_getIncHealBar(tButton);
			tOtherIncBar = VUHDO_getOtherIncHealBar(tButton);
			tHlBar = VUHDO_getHealthBar(tButton, 1);
			tSmoothDelta = VUHDO_ensureSmoothHealOverlay(tHlBar, tButton, tLayout["healthPct"]);
			tOverlay = tHlBar and tHlBar["vuhdoOverlay"];

			if (VUHDO_CONFIG["ABSORB_SHOW_MY_INC"]) then
				if (tLayout["otherIncEndPct"] > tLayout["otherIncStartPct"]) then
					tStart = VUHDO_getIncOverlapStartPct(tOtherIncBar, tLayout["otherIncStartPct"], tLayout["healthPct"]);
					if (tOverlay ~= nil) then
						tOverlay["hasOtherInc"] = true;
						tOverlay["otherIncStartPct"] = tStart;
						tOverlay["otherIncEndPct"] = tLayout["otherIncEndPct"];
					end
					VUHDO_setShiftedValueRange(tOtherIncBar, tStart, tLayout["otherIncEndPct"], tSmoothDelta);

					if (tOtherIncColor["R"] == -1) then
						tOtherIncColor["R"], tOtherIncColor["G"], tOtherIncColor["B"] = tHlBar:GetStatusBarColor();
						tOtherIncColor = VUHDO_getDiffColor(tOtherIncColor, VUHDO_PANEL_SETUP["BAR_COLORS"]["INCOMING_OTHERS"]);
					end

					VUHDO_setStatusBarColorWithHealthAlpha(tOtherIncBar, tOtherIncColor, tHlBar);
				else
					VUHDO_clearIncBar(tOtherIncBar);
					if (tOverlay ~= nil) then
						tOverlay["hasOtherInc"] = false;
					end
				end

				if (tLayout["myIncEndPct"] > tLayout["myIncStartPct"]) then
					tStart = VUHDO_getIncOverlapStartPct(tIncBar, tLayout["myIncStartPct"], tLayout["healthPct"]);
					if (tOverlay ~= nil) then
						tOverlay["hasInc"] = true;
						tOverlay["incStartPct"] = tStart;
						tOverlay["incEndPct"] = tLayout["myIncEndPct"];
					end
					VUHDO_setShiftedValueRange(tIncBar, tStart, tLayout["myIncEndPct"], tSmoothDelta);

					if (tIncColor["R"] == -1) then
						tIncColor["R"], tIncColor["G"], tIncColor["B"] = tHlBar:GetStatusBarColor();
						tIncColor = VUHDO_getDiffColor(tIncColor, VUHDO_PANEL_SETUP["BAR_COLORS"]["INCOMING"]);
					end

					VUHDO_setStatusBarColorWithHealthAlpha(tIncBar, tIncColor, tHlBar);
				else
					VUHDO_clearIncBar(tIncBar);
					if (tOverlay ~= nil) then
						tOverlay["hasInc"] = false;
					end
				end
			else
				VUHDO_clearIncBar(tOtherIncBar);
				tStart = VUHDO_getIncOverlapStartPct(tIncBar, tLayout["incStartPct"], tLayout["healthPct"]);
				if (tOverlay ~= nil) then
					tOverlay["hasOtherInc"] = false;
					tOverlay["hasInc"] = true;
					tOverlay["incStartPct"] = tStart;
					tOverlay["incEndPct"] = tLayout["incEndPct"];
				end
				VUHDO_setShiftedValueRange(tIncBar, tStart, tLayout["incEndPct"], tSmoothDelta);

				if (tIncColor["R"] == -1) then
					tIncColor["R"], tIncColor["G"], tIncColor["B"] = tHlBar:GetStatusBarColor();
					tIncColor = VUHDO_getDiffColor(tIncColor, VUHDO_PANEL_SETUP["BAR_COLORS"]["INCOMING"]);
				end

				VUHDO_setStatusBarColorWithHealthAlpha(tIncBar, tIncColor, tHlBar);
			end

			tOverhealSetup = VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[tButton]]["OVERHEAL_TEXT"];
			tIsOverhealText = tOverhealSetup["show"];

			if (tIsOverhealText) then
				tScale = tOverhealSetup["scale"];
				if (tOverheal > 0) then
					if (tRatio < 1) then
						VUHDO_getOverhealPanel(tHlBar):SetScale((0.5 + tRatio) * tScale);
					else
						VUHDO_getOverhealPanel(tHlBar):SetScale(1.5 * tScale);
					end

					VUHDO_getOverhealText(tHlBar):SetText(
						"+" .. floor(tOverheal * 0.01) * 0.1 .. "k");
				else
					VUHDO_getOverhealText(tHlBar):SetText("");
				end
			end

		end

	else
		for _, tButton in pairs(tAllButtons) do
			VUHDO_clearIncBar(VUHDO_getIncHealBar(tButton));
			VUHDO_clearIncBar(VUHDO_getOtherIncHealBar(tButton));
			tHlBar = VUHDO_getHealthBar(tButton, 1);
			tOverlay = tHlBar and tHlBar["vuhdoOverlay"];
			if (tOverlay ~= nil) then
				tOverlay["hasInc"] = false;
				tOverlay["hasOtherInc"] = false;
			end
			tOverhealSetup = VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[tButton]]["OVERHEAL_TEXT"];
			if (tOverhealSetup["show"]) then
				VUHDO_getOverhealText(tHlBar):SetText("");
			end
		end
	end

	_VUHDO_applyAbsorbBar(tLayout, tAllButtons);

	for _, tButton in pairs(tAllButtons) do
		tHlBar = VUHDO_getHealthBar(tButton, 1);
		-- Dead / DC: full bar is intentional; never lerp up/down into that state.
		if (not tInfo["connected"] or tInfo["dead"]) then
			tHlBar["vuhdoOverlay"] = nil;
			tHlBar["vuhdoOnSmoothStep"] = nil;
			VUHDO_setHealthBarValueInstant(tHlBar, 100);
		else
			tHlBar:SetValue(tLayout["healthPct"]);
			if (tHlBar["vuhdoOnSmoothStep"] ~= nil) then
				tHlBar["vuhdoOnSmoothStep"](tHlBar);
			end
		end
		VUHDO_refreshHlBarBorderForButton(tButton, aUnit);
		if (VUHDO_CONFIG["SHOW_ABSORBS"] ~= false) then
			VUHDO_customizeText(tButton, 2, false);
		end
	end
end

--
local function VUHDO_updateIncHeal(aUnit)
	_VUHDO_updateIncHeal(aUnit)

	if (UnitIsUnit(aUnit, "target")) then
		_VUHDO_updateIncHeal("target");
	end

	if (UnitIsUnit(aUnit, "focus")) then
		_VUHDO_updateIncHeal("focus");
	end
end

--
VUHDO_CUSTOM_INFO = {
	["number"] = 1,
	["range"] = true,
	["debuff"] = 0,
	["isPet"] = false,
	["charmed"] = false,
	["aggro"] = false,
	["group"] = 0,
	["afk"] = false,
	["threat"] = 0,
	["threatPerc"] = 0,
	["isVehicle"] = false,
	["ownerUnit"] = nil,
	["petUnit"] = nil,
	["missbuff"] = nil,
	["mibucateg"] = nil,
	["mibuvariants"] = nil,
	["raidIcon"] = nil,
	["visible"] = true,
	["baseRange"] = true
};
local VUHDO_CUSTOM_INFO = VUHDO_CUSTOM_INFO;

--
local tUnit;
local function VUHDO_getDisplayUnit(aButton)
	tUnit = aButton:GetAttribute("unit");

	if (strfind(tUnit, "target", 1, true) and tUnit ~= "target") then
		if (VUHDO_CUSTOM_INFO["fixResolveId"] == nil) then
			return tUnit, VUHDO_CUSTOM_INFO;
		else
			return VUHDO_CUSTOM_INFO["fixResolveId"], VUHDO_RAID[VUHDO_CUSTOM_INFO["fixResolveId"]];
		end
	else
		if (VUHDO_RAID[tUnit] ~= nil and VUHDO_RAID[tUnit]["isVehicle"]) then
			tUnit = VUHDO_RAID[tUnit]["petUnit"];
		end
		return tUnit, VUHDO_RAID[tUnit];
	end
end

--
local tMissLife;
local tIsName, tIsLife, tIsLifeInName;
local tTextString;
local tHealthBar;
local tSetup;
local tLifeConfig;
local tAmountInc;
local tAmountAbs;
local tOwnerInfo;
local tMaxChars;
local tLifeString;
local tUnit, tInfo;
local tIsShowLife;
local tLifeAmount;
local tIsHideIrrel;
local tIndex;
function VUHDO_customizeText(aButton, aMode, anIsTarget)
	tUnit, tInfo = VUHDO_getDisplayUnit(aButton);
	tHealthBar = VUHDO_getHealthBar(aButton, 1);

	if (tInfo == nil) then
		if ("focus" == tUnit) then
			VUHDO_getBarText(tHealthBar):SetText(VUHDO_I18N_NO_FOCUS);
		elseif ("target" == tUnit) then
			VUHDO_getBarText(tHealthBar):SetText(VUHDO_I18N_NO_TARGET);
		else
			VUHDO_getBarText(tHealthBar):SetText(VUHDO_I18N_NOT_AVAILABLE);
		end
		VUHDO_getLifeText(tHealthBar):SetText("");
		return;
	end

	tSetup = VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[aButton]];
	tLifeConfig = tSetup["LIFE_TEXT"];

	tIsHideIrrel = tLifeConfig["hideIrrelevant"] and VUHDO_getUnitHealthPercent(tInfo) >=
					   VUHDO_CONFIG["EMERGENCY_TRIGGER"];
	tIsShowLife = tLifeConfig["show"] and not tIsHideIrrel;

	tIsLifeInName = tLifeConfig["show"] and (1 == tLifeConfig["position"] -- VUHDO_LT_POS_RIGHT
	or 2 == tLifeConfig["position"]); -- VUHDO_LT_POS_LEFT

	tIsName = aMode ~= 2 or tIsLifeInName; -- VUHDO_UPDATE_HEALTH
	tIsLife = aMode ~= 7 or tIsLifeInName; -- VUHDO_UPDATE_AGGRO

	tTextString = "";
	-- Basic name text
	if (tIsName) then

		tOwnerInfo = VUHDO_RAID[tInfo["ownerUnit"]];
		tIndex = tInfo["name"] .. (tInfo["ownerUnit"] or "");
		if (VUHDO_NAME_TEXTS[tIndex] == nil) then
			if (tSetup["ID_TEXT"]["showName"]) then
				if (tSetup["ID_TEXT"]["showClass"] and not tInfo["isPet"]) then
					tTextString = tInfo["className"] .. ": ";
				else
					tTextString = "";
				end

				if (tOwnerInfo == nil or not tSetup["ID_TEXT"]["showPetOwners"]) then
					tTextString = tTextString .. tInfo["name"];
				else
					tTextString = tTextString .. tOwnerInfo["name"] .. ": " .. tInfo["name"];
				end
			else
				if (tSetup["ID_TEXT"]["showClass"] and not tInfo["isPet"]) then
					tTextString = tInfo["className"];
				else
					tTextString = "";
				end

				if (tOwnerInfo ~= nil and tSetup["ID_TEXT"]["showPetOwners"]) then
					tTextString = tTextString .. tOwnerInfo["name"];
				end
			end
			tMaxChars = tSetup["PANEL_COLOR"]["TEXT"]["maxChars"];
			if (tMaxChars > 0 and strlen(tTextString) > tMaxChars) then
				tTextString = VUHDO_utf8Cut(tTextString, tMaxChars);
			end
			VUHDO_NAME_TEXTS[tIndex] = tTextString;
		else
			tTextString = VUHDO_NAME_TEXTS[tIndex];
		end

		-- Add player flags
		if (tSetup["ID_TEXT"]["showTags"]) then
			if (not tInfo["connected"]) then
				tTextString = "d/c-" .. tTextString;
			elseif (tInfo["dead"]) then
				if (UnitIsGhost(tUnit)) then
					tTextString = "|cffff0000ghost|r-" .. tTextString;
				else
					tTextString = "rip-" .. tTextString;
				end
			else
				if ("focus" == tUnit) then
					tTextString = "|cffff0000foc|r-" .. tTextString;
				elseif ("target" == tUnit) then
					tTextString = "|cffff0000tar|r-" .. tTextString;
				elseif (tInfo["afk"]) then
					tTextString = "afk-" .. tTextString;
				elseif (tOwnerInfo ~= nil and tOwnerInfo["isVehicle"]) then
					tTextString = "|cffff0000pet|r-" .. tTextString;
				end
			end
		end
		if (tMaxChars > 0 and strlen(tTextString) > tMaxChars and strbyte(tTextString, 1) ~= 124) then -- |
			tTextString = VUHDO_utf8Cut(tTextString, tMaxChars);
		end
	end

	-- Life Text
	if (tIsLife and tIsShowLife) then
		tAmountInc = VUHDO_getIncHealOnUnit(tInfo["name"]);
		tAmountAbs = VUHDO_getAbsorbOnUnit(tUnit);

		tLifeAmount = tInfo["health"] + tAmountAbs;
		if (sIsOverhealText) then
			tLifeAmount = tLifeAmount + tAmountInc;
		end

		if (1 == tLifeConfig["mode"] or anIsTarget) then -- VUHDO_LT_MODE_PERCENT
			tLifeString = floor(VUHDO_getUnitHealthModiPercent(tInfo, tLifeAmount - tInfo["health"])) .. "%";
		elseif (3 == tLifeConfig["mode"]) then -- VUHDO_LT_MODE_MISSING
			tMissLife = tLifeAmount - tInfo["healthmax"];
			if (tMissLife < -10) then
				tLifeString = VUHDO_getKiloText(tMissLife, tSetup);
			else
				tLifeString = "";
			end
		else -- VUHDO_LT_MODE_LEFT
			tLifeString = VUHDO_getKiloText(tLifeAmount, tSetup) .. " / " ..
							  VUHDO_getKiloText(tInfo["healthmax"], tSetup);
		end

		if (not tIsLifeInName) then
			VUHDO_getLifeText(tHealthBar):SetText(tLifeString);
		elseif (not tIsHideIrrel) then
			if (2 == tLifeConfig["position"]) then -- VUHDO_LT_POS_LEFT
				tTextString = tLifeString .. " " .. tTextString;
			else
				tTextString = tTextString .. " " .. tLifeString;
			end
		end
	elseif (tIsLife and tIsHideIrrel) then
		VUHDO_getLifeText(tHealthBar):SetText("");
	end

	-- Aggro Text
	if (tIsName) then
		if (tInfo["aggro"] and sIsAggroText) then
			tTextString = "|cffff2020" .. VUHDO_THREAT_CFG["AGGRO_TEXT_LEFT"] .. "|r" .. tTextString .. "|cffff2020" ..
							  VUHDO_THREAT_CFG["AGGRO_TEXT_RIGHT"] .. "|r";
		end

		VUHDO_getBarText(tHealthBar):SetText(tTextString);
	end
end

local VUHDO_customizeText = VUHDO_customizeText;

--
local tUnit;
local tInfo;
local tDeadHlBar;
function VUHDO_customizeBarSize(aButton)
	tUnit, tInfo = VUHDO_getDisplayUnit(aButton);

	if (tInfo == nil) then
		tDeadHlBar = VUHDO_getHealthBar(aButton, 1);
		tDeadHlBar["vuhdoOverlay"] = nil;
		tDeadHlBar["vuhdoOnSmoothStep"] = nil;
		VUHDO_setHealthBarValueInstant(tDeadHlBar, 100);
		VUHDO_getHealthBar(aButton, 3):SetValue(100);
		VUHDO_getHealthBar(aButton, 8):SetValue(100);
		VUHDO_getIncHealBar(aButton):SetValue(0);
		VUHDO_getOtherIncHealBar(aButton):SetValue(0);
		VUHDO_getHealthBar(aButton, 17):SetValue(0);
		VUHDO_getHealthBar(aButton, 2):SetValue(0);
	elseif (not tInfo["connected"] or tInfo["dead"]) then
		tDeadHlBar = VUHDO_getHealthBar(aButton, 1);
		tDeadHlBar["vuhdoOverlay"] = nil;
		tDeadHlBar["vuhdoOnSmoothStep"] = nil;
		VUHDO_setHealthBarValueInstant(tDeadHlBar, 100);
		VUHDO_getHealthBar(aButton, 3):SetValue(100);
		VUHDO_getHealthBar(aButton, 8):SetValue(100);
		VUHDO_getIncHealBar(aButton):SetValue(0);
		VUHDO_getOtherIncHealBar(aButton):SetValue(0);
		VUHDO_getHealthBar(aButton, 17):SetValue(0);
		VUHDO_getHealthBar(aButton, 2):SetValue(0);
	else
		if (VUHDO_CONFIG["SHOW_ABSORBS"] ~= false) then
			tLayout = VUHDO_computeHealBarLayout(tInfo, tUnit,
				VUHDO_getOwnIncHealOnUnit(tInfo["name"]), VUHDO_getOthersIncHealOnUnit(tInfo["name"]));
			if (tLayout ~= nil) then
				tDeadHlBar = VUHDO_getHealthBar(aButton, 1);
				tDeadHlBar:SetValue(tLayout["healthPct"]);
				_VUHDO_applyAbsorbBar(tLayout, { aButton });
				if (tDeadHlBar["vuhdoOnSmoothStep"] ~= nil) then
					tDeadHlBar["vuhdoOnSmoothStep"](tDeadHlBar);
				end
				return;
			end
		end
		VUHDO_getHealthBar(aButton, 1):SetValue(VUHDO_getUnitHealthPercent(tInfo));
	end
end

--
local tFlashBar;
local tScaling;
local function VUHDO_customizeDamageFlash(aButton, aLossPercent)
	if (aLossPercent ~= nil) then
		tScaling = VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[aButton]]["SCALING"];
		if (tScaling["isDamFlash"] and tScaling["damFlashFactor"] >= aLossPercent) then
			tFlashBar = VUHDO_GLOBAL[aButton:GetName() .. "BgBarIcBarHlBarFlBar"];
			UIFrameFlash(tFlashBar, 0.05, 0.3, 0.45, false, 0.1, 0);
		end
	end
end

--
local tAllButtons, tButton, tHealthBar, tQuota, tTargetQuota;
local tRaidInfo;
function VUHDO_healthBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName,
	aBouquetName, aLevel, aCurrValue2)
	aMaxValue = aMaxValue or 0;
	aCurrValue = aCurrValue or 0;

	if (aCurrValue == 0 and aMaxValue == 0) then
		if (anIsActive) then
			tQuota = 100;
		else
			tQuota = 0;
		end
	elseif (aMaxValue > 1) then
		tQuota = 100 * aCurrValue / aMaxValue;
	else
		tQuota = 0;
	end

	tRaidInfo = VUHDO_RAID[aUnit];

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			if (VUHDO_INDICATOR_CONFIG["BOUQUETS"]["HEALTH_BAR_PANEL"][VUHDO_BUTTON_CACHE[tButton]] == "") then
				tHealthBar = VUHDO_getHealthBar(tButton, 1);

				if (tRaidInfo ~= nil and (not tRaidInfo["connected"] or tRaidInfo["dead"])) then
					if (tQuota > 0 and aColor ~= nil) then
						tHealthBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
						if (aColor["useText"]) then
							VUHDO_getBarText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"],
								aColor["TO"]);
							VUHDO_getLifeText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"],
								aColor["TO"]);
						end
					end
					VUHDO_setHealthBarValueInstant(tHealthBar, 100);
				elseif (tQuota > 0) then
					if (aColor ~= nil) then
						tHealthBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
						if (aColor["useText"]) then
							VUHDO_getBarText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"],
								aColor["TO"]);
							VUHDO_getLifeText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"],
								aColor["TO"]);
						end
					end
					tHealthBar:SetValue(tQuota);
				else
					tHealthBar:SetValue(0);
				end
			end
		end
	end

	if (VUHDO_CONFIG["SHOW_ABSORBS"] ~= false and VUHDO_RAID[aUnit] ~= nil) then
		_VUHDO_updateIncHeal(aUnit);
	end

	if (VUHDO_RAID[aUnit] == nil) then
		return;
	end

	tTargetQuota = nil;

	-- Targets und targets-of-target, die im Raid sind
	tAllButtons = VUHDO_IN_RAID_TARGET_BUTTONS[VUHDO_RAID[aUnit]["name"]];
	if (tAllButtons == nil) then
		return;
	end
	tRaidInfo = VUHDO_RAID[aUnit];
	for _, tButton in pairs(tAllButtons) do
		if (tTargetQuota == nil and aCurrValue2 ~= nil and aCurrValue2 ~= aCurrValue) then
			if (aCurrValue2 == 0 and aMaxValue == 0) then
				if (anIsActive) then
					tQuota = 100;
				else
					tQuota = 0;
				end
			elseif (aMaxValue > 1) then
				tQuota = 100 * aCurrValue2 / aMaxValue;
			else
				tQuota = 0;
			end
		end
		tTargetQuota = tQuota;
		tHealthBar = VUHDO_getHealthBar(tButton, 1);
		if (tRaidInfo ~= nil and (not tRaidInfo["connected"] or tRaidInfo["dead"])) then
			VUHDO_setHealthBarValueInstant(tHealthBar, 100);
		elseif (tQuota > 0) then
			tHealthBar:SetValue(tQuota);
		else
			tHealthBar:SetValue(0);
		end
	end

end

--
function VUHDO_healthBarBouquetCallbackCustom(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor,
	aBuffName, aBouquetName)
	aMaxValue = aMaxValue or 0;
	aCurrValue = aCurrValue or 0;

	if (aCurrValue == 0 and aMaxValue == 0) then
		if (anIsActive) then
			tQuota = 100;
		else
			tQuota = 0;
		end
	elseif (aMaxValue > 1) then
		tQuota = 100 * aCurrValue / aMaxValue;
	else
		tQuota = 0;
	end

	tRaidInfo = VUHDO_RAID[aUnit];

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			if (VUHDO_INDICATOR_CONFIG["BOUQUETS"]["HEALTH_BAR_PANEL"][VUHDO_BUTTON_CACHE[tButton]] == aBouquetName) then
				tHealthBar = VUHDO_getHealthBar(tButton, 1);

				if (tRaidInfo ~= nil and (not tRaidInfo["connected"] or tRaidInfo["dead"])) then
					if (tQuota > 0 and aColor ~= nil) then
						tHealthBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
						if (aColor["useText"]) then
							VUHDO_getBarText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"],
								aColor["TO"]);
							VUHDO_getLifeText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"],
								aColor["TO"]);
						end
					end
					VUHDO_setHealthBarValueInstant(tHealthBar, 100);
				elseif (tQuota > 0) then
					if (aColor ~= nil) then
						tHealthBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
						if (aColor["useText"]) then
							VUHDO_getBarText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"],
								aColor["TO"]);
							VUHDO_getLifeText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"],
								aColor["TO"]);
						end
					end
					tHealthBar:SetValue(tQuota);
				else
					tHealthBar:SetValue(0);
				end
			end
		end
	end

	if (VUHDO_CONFIG["SHOW_ABSORBS"] ~= false and VUHDO_RAID[aUnit] ~= nil) then
		_VUHDO_updateIncHeal(aUnit);
	end
end

--
local tAllButtons, tButton, tAggroBar;
function VUHDO_aggroBarBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName,
	aBouquetName)
	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			if (anIsActive) then
				tAggroBar = VUHDO_getHealthBar(tButton, 4);
				tAggroBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
				tAggroBar:SetValue(100);
			else
				VUHDO_getHealthBar(tButton, 4):SetValue(0);
			end
		end
	end
end

--
local tAllButtons, tButton, tBar, tQuota;
function VUHDO_backgroundBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor,
	aBuffName, aBouquetName)
	aMaxValue = aMaxValue or 0;
	aCurrValue = aCurrValue or 0;

	if (aCurrValue == 0 and aMaxValue == 0) then
		if (anIsActive) then
			tQuota = 100;
		else
			tQuota = 0;
		end
	elseif (aMaxValue > 1 and anIsActive) then
		tQuota = 100;
	else
		tQuota = 0;
	end

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			tBar = VUHDO_getHealthBar(tButton, 3);
			if (aColor ~= nil) then
				tBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
			end
			tBar:SetValue(tQuota);
		end
	end
end

--
local tTexture;
local tIcon;
local tUnit;
function VUHDO_customizeHealButton(aButton)
	VUHDO_customizeText(aButton, 1, false); -- VUHDO_UPDATE_ALL

	tUnit, _ = VUHDO_getDisplayUnit(aButton);
	-- Raid icon
	if (VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[aButton]]["RAID_ICON"]["show"] and tUnit ~= nil) then
		tIcon = GetRaidTargetIndex(tUnit);
		if (tIcon ~= nil and VUHDO_PANEL_SETUP["RAID_ICON_FILTER"][tIcon]) then
			tTexture = VUHDO_getBarRoleIcon(aButton, 50);
			VUHDO_setRaidTargetIconTexture(tTexture, tIcon);
			tTexture:Show();
		else
			VUHDO_getBarRoleIcon(aButton, 50):Hide();
		end
	end
end
local VUHDO_customizeHealButton = VUHDO_customizeHealButton;

--
local tInfo, tCnt, tAlpha;
local function VUHDO_customizeDebuffIconsRange(aButton)
	_, tInfo = VUHDO_getDisplayUnit(aButton);

	if (tInfo ~= nil) then
		if (tInfo["range"]) then
			tAlpha = 1;
		else
			tAlpha = VUHDO_BAR_COLOR["OUTRANGED"]["O"];
		end

		for tCnt = 40, 44 do
			VUHDO_getBarIconFrame(aButton, tCnt):SetAlpha(tAlpha);
		end
	end
end

--
local tInfo;
local tAllButtons;
local tButton;
function VUHDO_updateHealthBarsFor(aUnit, anUpdateMode)
	VUHDO_updateBouquetsForEvent(aUnit, anUpdateMode);

	if (4 == anUpdateMode) then -- VUHDO_UPDATE_DEBUFF
		return;
	end

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	tInfo = VUHDO_RAID[aUnit];
	if (tInfo == nil or tAllButtons == nil) then
		return;
	end

	if (2 == anUpdateMode) then -- VUHDO_UPDATE_HEALTH
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, false); -- VUHDO_UPDATE_HEALTH
			VUHDO_customizeDamageFlash(tButton, tInfo["lifeLossPerc"]);
		end
		tInfo["lifeLossPerc"] = nil;
		VUHDO_updateIncHeal(aUnit);

	elseif (9 == anUpdateMode) then -- VUHDO_UPDATE_INC
		if (sIsOverhealText or VUHDO_CONFIG["SHOW_ABSORBS"] ~= false) then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_customizeText(tButton, 2, false); -- VUHDO_UPDATE_HEALTH
			end
		end
		VUHDO_updateIncHeal(aUnit);

	elseif (7 == anUpdateMode) then -- VUHDO_UPDATE_AGGRO
		if (sIsAggroText) then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_customizeText(tButton, 7, false); -- VUHDO_UPDATE_AGGRO
			end
		end

	elseif (5 == anUpdateMode) then -- VUHDO_UPDATE_RANGE
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 7, false); -- f�r d/c tag -- VUHDO_UPDATE_AGGRO
			VUHDO_customizeDebuffIconsRange(tButton);
		end
		VUHDO_updateIncHeal(aUnit);
		VUHDO_refreshHotBarsRange(aUnit);

	elseif (3 == anUpdateMode) then -- VUHDO_UPDATE_HEALTH_MAX
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, false); -- VUHDO_UPDATE_HEALTH
		end
		VUHDO_updateIncHeal(aUnit);

	elseif (6 == anUpdateMode) then -- VUHDO_UPDATE_AFK
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 7, false); -- VUHDO_UPDATE_AGGRO
		end
	elseif (10 == anUpdateMode) then -- VUHDO_UPDATE_ALIVE
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 1, false); -- VUHDO_UPDATE_ALL
		end
		VUHDO_updateIncHeal(aUnit);

	elseif (25 == anUpdateMode) then -- VUHDO_UPDATE_RESURRECTION
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 1, false); -- VUHDO_UPDATE_ALL
		end

	elseif (1 == anUpdateMode) then -- VUHDO_UPDATE_ALL
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeHealButton(tButton);
		end

		VUHDO_updateIncHeal(aUnit);
	end

	------------------
	-- In-Raid Targets
	------------------

	tAllButtons = VUHDO_IN_RAID_TARGET_BUTTONS[tInfo["name"]];
	if (tAllButtons == nil) then
		return;
	end

	VUHDO_CUSTOM_INFO["fixResolveId"] = aUnit;
	if (2 == anUpdateMode) then -- VUHDO_UPDATE_HEALTH
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, true); -- VUHDO_UPDATE_HEALTH
		end

	elseif (3 == anUpdateMode) then -- VUHDO_UPDATE_HEALTH_MAX
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, true); -- VUHDO_UPDATE_HEALTH
		end

	elseif (10 == anUpdateMode) then -- VUHDO_UPDATE_ALIVE
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 1, true); -- VUHDO_UPDATE_ALL
		end
	elseif (1 == anUpdateMode) then -- VUHDO_UPDATE_ALL
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 1, true); -- VUHDO_UPDATE_ALL
		end
	end
end

--
local VUHDO_getHealButton = VUHDO_getHealButton;
local tButton;
local tUnit;
local tPanelButtons;
function VUHDO_updateAllPanelBars(aPanelNum)
	tPanelButtons = VUHDO_getPanelButtons(aPanelNum);
	for _, tButton in pairs(tPanelButtons) do
		if (tButton:GetAttribute("unit") == nil) then
			break
		end
		VUHDO_customizeHealButton(tButton);
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateIncHeal(tUnit);
		VUHDO_updateManaBars(tUnit, 3);
	end
end
local VUHDO_updateAllPanelBars = VUHDO_updateAllPanelBars;

--
local tCnt;
VUHDO_REMOVE_HOTS = true;
function VUHDO_updateAllRaidBars()
	for tCnt = 1, 10 do -- VUHDO_MAX_PANELS
		if (VUHDO_isPanelVisible(tCnt)) then
			VUHDO_updateAllPanelBars(tCnt);
		end
	end

	if (VUHDO_REMOVE_HOTS) then
		VUHDO_removeAllHots();
		VUHDO_updateAllHoTs();
		if (VUHDO_INTERNAL_TOGGLES[18]) then -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
			VUHDO_updateClusterHighlights();
		end
	else
		VUHDO_REMOVE_HOTS = true;
	end
end
