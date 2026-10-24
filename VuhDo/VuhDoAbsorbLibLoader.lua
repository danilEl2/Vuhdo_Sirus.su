-- Feature-detect only. Heavy absorb libs are loaded via <Script> in VuhDo.xml
-- (SpecializedAbsorbs / LibShieldLeft early-return when native API exists).
-- Do not use loadfile — unavailable in the WoW 3.3.5 addon sandbox.
VUHDO_IS_NATIVE_ABSORBS = type(UnitGetTotalAbsorbs) == "function";
VUHDO_HAS_ABSORB_EVENT = false;
