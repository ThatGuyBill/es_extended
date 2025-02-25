local Config = json.decode(GetConvar('es_extended', '{}'))

-- Convar overrides (add to server.cfg)
--[[
setr primary_identifier "license"
setr es_extended {
  "Multichar": true,
  "NPWD": true,
  "EnableHud": false
}
]]

Config = {
	Locale = Config.Locale or 'en',
	StartingAccountMoney = Config.StartingAccountMoney or {bank = 50000},

	-- Players receive payment from their employer society account (requires: esx_society)
	EnableSocietyPayouts = Config.EnableSocietyPayouts or false,

	-- Display the default hud, showing current job and accounts
	EnableHud = Config.EnableHud or true,

	-- The amount of weight a player can carry
	MaxWeight = Config.MaxWeight or 30000,

	-- The frequency that paychecks are triggered by the server in milliseconds (default: 7 minutes)
	PaycheckInterval = Config.PaycheckInterval or (7 * 60000),

	-- Enable debug options
	EnableDebug = Config.EnableDebug or false,

	-- Use GTA's wanted level
	EnableWantedLevel = Config.EnableWantedLevel or false,

	-- Allow player versus player combat
	EnablePVP = Config.EnablePVP or true,

	-- Enable compatability for esx_multicharacter
	Multichar = Config.Multichar or false,

	-- Load character identity data during initial player loading (requires: esx_identity, not required with Config.Multichar)
	Identity = Config.Identity or false,

	-- Enable support when using NPWD
	NPWD = Config.NPWD or false,
}

_G.Config = Config

Config.Accounts = {
	bank = _U('account_bank'),
	black_money = _U('account_black_money'),
	money = _U('account_money')
}

-- Set identifier to ip when using FxDK or sv_lan
Config.Identifier = GetConvar('sv_lan', '') == 'true' and 'ip' or GetConvar('primary_identifier', 'license')
