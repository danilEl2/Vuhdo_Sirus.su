-- Smooth health bar animation (lerp SetValue), similar to ElvUI Smoothie.
-- Scale is VuhDo's 0..100 custom status bars.
--
-- Driver is a plain Frame that stays shown: VuhDo's main frame is SecureFrameTemplate
-- (XML OnUpdate elapsed is unreliable on 3.3.5), and Hide()+Show() on a 0-size
-- frame often never starts OnUpdate on this client.

local pairs = pairs;
local abs = abs;
local next = next;
local GetTime = GetTime;

local VUHDO_SMOOTH_AMOUNT = 0.18;
local VUHDO_SMOOTH_TARGET_FPS = 60;
local VUHDO_SMOOTH_MAX_STEP = 0.32;
local VUHDO_SMOOTH_CLOSE_EPS = 0.12;

local sActiveBars = {};
local sLastTime = GetTime();
local sDriver = CreateFrame("Frame");
local VUHDO_barSetSmoothedValue;



local function VUHDO_smoothClampValue(aValue)
	if ((aValue or -1) < 0) then
		return 0;
	elseif (aValue > 100) then
		return 100;
	end
	return aValue;
end



local function VUHDO_barGetDisplayed(aBar)
	if (aBar["vuhdoSmoothCur"] ~= nil) then
		return aBar["vuhdoSmoothCur"];
	end
	return aBar["value"] or 0;
end



local function VUHDO_barIsSmoothEnabled(aBar)
	local tPanel = aBar["vuhdoSmoothPanel"];
	if (tPanel == nil or VUHDO_PANEL_SETUP == nil) then
		return false;
	end
	local tSetup = VUHDO_PANEL_SETUP[tPanel];
	local tScaling = tSetup and tSetup["SCALING"];
	return tScaling ~= nil and tScaling["isSmooth"];
end



local function VUHDO_barPaintInstant(aBar, aValue)
	aValue = VUHDO_smoothClampValue(aValue);
	aBar["vuhdoSmoothCur"] = aValue;
	aBar["vuhdoSmoothTarget"] = aValue;
	sActiveBars[aBar] = nil;
	if (aBar["SetValueInstant"] ~= nil) then
		aBar["SetValueInstant"](aBar, aValue);
	end
end



VUHDO_barSetSmoothedValue = function(self, aValue)
	aValue = VUHDO_smoothClampValue(aValue);

	if (not VUHDO_barIsSmoothEnabled(self)) then
		VUHDO_barPaintInstant(self, aValue);
		return;
	end

	if (self["vuhdoSmoothCur"] == nil) then
		self["vuhdoSmoothCur"] = self["value"] or 0;
	end
	self["vuhdoSmoothTarget"] = aValue;
	sActiveBars[self] = true;
end



--
function VUHDO_updateSmoothBars(aTimeDelta)
	if (not next(sActiveBars)) then
		sLastTime = GetTime();
		return;
	end

	local tNow = GetTime();
	local tDelta = aTimeDelta;
	if (tDelta == nil or tDelta <= 0) then
		tDelta = tNow - sLastTime;
	end
	sLastTime = tNow;

	if (tDelta > 0.08) then
		tDelta = 0.08;
	end

	local tAmount = VUHDO_SMOOTH_AMOUNT * tDelta * VUHDO_SMOOTH_TARGET_FPS;
	if (tAmount > VUHDO_SMOOTH_MAX_STEP) then
		tAmount = VUHDO_SMOOTH_MAX_STEP;
	elseif (tAmount < 0) then
		tAmount = 0;
	end

	local tBar, tTarget, tCur, tNew;

	for tBar, _ in pairs(sActiveBars) do
		tTarget = tBar["vuhdoSmoothTarget"];
		if (tTarget == nil or not VUHDO_barIsSmoothEnabled(tBar)) then
			if (tTarget ~= nil) then
				VUHDO_barPaintInstant(tBar, tTarget);
			else
				sActiveBars[tBar] = nil;
			end
		else
			tCur = VUHDO_barGetDisplayed(tBar);
			tNew = (1 - tAmount) * tCur + tAmount * tTarget;

			if (abs(tNew - tTarget) <= VUHDO_SMOOTH_CLOSE_EPS) then
				tNew = tTarget;
				sActiveBars[tBar] = nil;
			end

			tBar["vuhdoSmoothCur"] = tNew;

			if (tBar["SetValueInstant"] ~= nil) then
				tBar["SetValueInstant"](tBar, tNew);
			end

			if (tBar["vuhdoOnSmoothStep"] ~= nil) then
				tBar["vuhdoOnSmoothStep"](tBar);
			end
		end
	end
end



sDriver:SetScript("OnUpdate", function(_, aElapsed)
	VUHDO_updateSmoothBars(aElapsed);
end);



--
function VUHDO_setHealthBarValueInstant(aBar, aValue)
	if (aBar == nil or aBar == VuhDoDummyStatusBar) then
		return;
	end

	aValue = VUHDO_smoothClampValue(aValue);
	sActiveBars[aBar] = nil;
	aBar["vuhdoSmoothCur"] = aValue;
	aBar["vuhdoSmoothTarget"] = aValue;

	aBar["vuhdoOverlay"] = nil;
	aBar["vuhdoOnSmoothStep"] = nil;

	if (aBar["SetValueInstant"] ~= nil) then
		aBar["SetValueInstant"](aBar, aValue);
	else
		aBar["SetValue"](aBar, aValue);
	end
end



-- Always wrap HP SetValue. Live-read SCALING.isSmooth (aPanelNum from redraw).
function VUHDO_setHealthBarSmooth(aBar, aPanelNum)
	if (aBar == nil or aBar == VuhDoDummyStatusBar) then
		return;
	end

	aBar["vuhdoSmoothPanel"] = aPanelNum;
	aBar["vuhdoOverlay"] = nil;
	aBar["vuhdoOnSmoothStep"] = nil;

	if (aBar["SetValue"] ~= VUHDO_barSetSmoothedValue) then
		if (aBar["SetValueInstant"] == nil) then
			aBar["SetValueInstant"] = aBar["SetValue"];
		end
		aBar["SetValue"] = VUHDO_barSetSmoothedValue;
	end

	if (aBar["vuhdoSmoothCur"] == nil) then
		aBar["vuhdoSmoothCur"] = aBar["value"] or 0;
		aBar["vuhdoSmoothTarget"] = aBar["vuhdoSmoothCur"];
	end
end
