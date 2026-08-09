-- Smooth health bar animation (lerp SetValue), similar to ElvUI Smoothie.
-- Scale is VuhDo's 0..100 custom status bars.

local pairs = pairs;
local abs = abs;
local next = next;

local VUHDO_SMOOTH_AMOUNT = 0.28;
local VUHDO_SMOOTH_TARGET_FPS = 60;
local VUHDO_SMOOTH_CLOSE_EPS = 0.05; -- of 0..100 range

local sActiveBars = {};
local sHasActive = false;



local function VUHDO_smoothClampValue(aValue)
	if ((aValue or -1) < 0) then
		return 0;
	elseif (aValue > 100) then
		return 100;
	end
	return aValue;
end



local function VUHDO_barSetSmoothedValue(self, aValue)
	aValue = VUHDO_smoothClampValue(aValue);
	sActiveBars[self] = aValue;
	sHasActive = true;
end



--
function VUHDO_updateSmoothBars(aTimeDelta)
	if (not sHasActive) then
		return;
	end

	local tAmount = VUHDO_SMOOTH_AMOUNT * aTimeDelta * VUHDO_SMOOTH_TARGET_FPS;
	if (tAmount > 1) then
		tAmount = 1;
	elseif (tAmount < 0) then
		tAmount = 0;
	end

	local tStillActive = false;
	local tBar, tTarget, tCur, tNew;

	for tBar, tTarget in pairs(sActiveBars) do
		tCur = tBar["value"] or 0;
		tNew = (1 - tAmount) * tCur + tAmount * tTarget;

		if (abs(tNew - tTarget) <= VUHDO_SMOOTH_CLOSE_EPS) then
			tNew = tTarget;
			sActiveBars[tBar] = nil;
		else
			tStillActive = true;
		end

		if (tBar["SetValueInstant"] ~= nil) then
			tBar["SetValueInstant"](tBar, tNew);


		end

		-- Keep absorb / incoming glued to the visible HP tip while lerping.
		if (tBar["vuhdoOnSmoothStep"] ~= nil) then
			tBar["vuhdoOnSmoothStep"](tBar);
		end
	end

	sHasActive = tStillActive;
end



--
-- Snap HP without lerp (dead / DC / empty slot). Cancels an in-flight smooth.
function VUHDO_setHealthBarValueInstant(aBar, aValue)
	if (aBar == nil or aBar == VuhDoDummyStatusBar) then
		return;
	end

	aValue = VUHDO_smoothClampValue(aValue);

	if (sActiveBars[aBar] ~= nil) then
		sActiveBars[aBar] = nil;
		if (not next(sActiveBars)) then
			sHasActive = false;
		end
	end

	-- Drop stale absorb/inc glue (bouquet Instant paths may not clear it).
	aBar["vuhdoOverlay"] = nil;
	aBar["vuhdoOnSmoothStep"] = nil;

	if (aBar["SetValueInstant"] ~= nil) then
		aBar["SetValueInstant"](aBar, aValue);
	else
		aBar["SetValue"](aBar, aValue);
	end
end



--
function VUHDO_setHealthBarSmooth(aBar, anEnable)
	if (aBar == nil or aBar == VuhDoDummyStatusBar) then
		return;
	end

	if (anEnable) then
		-- Always drop stale overlay on (re)enable / redraw; wrap may already exist.
		aBar["vuhdoOverlay"] = nil;
		aBar["vuhdoOnSmoothStep"] = nil;

		if (aBar["SetValueInstant"] == nil) then
			aBar["SetValueInstant"] = aBar["SetValue"];
			aBar["SetValue"] = VUHDO_barSetSmoothedValue;
		end
	else
		if (sActiveBars[aBar] ~= nil) then
			local tTarget = sActiveBars[aBar];
			sActiveBars[aBar] = nil;
			if (aBar["SetValueInstant"] ~= nil) then
				aBar["SetValueInstant"](aBar, tTarget);
			end
		end

		if (aBar["vuhdoOnSmoothStep"] ~= nil) then
			aBar["vuhdoOnSmoothStep"](aBar);
		end

		if (aBar["SetValueInstant"] ~= nil) then
			aBar["SetValue"] = aBar["SetValueInstant"];
			aBar["SetValueInstant"] = nil;
		end

		aBar["vuhdoOverlay"] = nil;
		aBar["vuhdoOnSmoothStep"] = nil;

		if (not next(sActiveBars)) then
			sHasActive = false;
		end
	end
end
