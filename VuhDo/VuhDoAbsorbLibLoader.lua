VUHDO_IS_NATIVE_ABSORBS = type(UnitGetTotalAbsorbs) == "function";
VUHDO_HAS_ABSORB_EVENT = false;

if (VUHDO_IS_NATIVE_ABSORBS) then
	return;
end

local tAddonPath = "Interface\\AddOns\\VuhDo\\";

local function VUHDO_loadLibScript(aPath, ...)
	local tLoader, tErr = loadfile(aPath);
	if (tLoader == nil) then
		return;
	end

	tLoader(...);
end

VUHDO_loadLibScript(tAddonPath .. "Libs\\SpecializedAbsorbs-1.0\\SpecializedAbsorbs-1.0.lua", "VuhDo", { ["Compat"] = {} });
VUHDO_loadLibScript(tAddonPath .. "Libs\\LibShieldLeft-1.0\\LibShieldLeft.lua");
