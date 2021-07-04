moddataPrefix = "savegame.mod."
currentDataVersion = 1

-- Save Utils
	function GetDataValue(path, stype)
		if stype == "string" then
			return GetString(moddataPrefix .. path)
		elseif stype == "bool" then
			return GetBool(moddataPrefix .. path)
		elseif stype == "int" then
			return GetInt(moddataPrefix .. path)
		elseif stype == "float" then
			return GetFloat(moddataPrefix .. path)
		end
	end

	function SetDataValue(path, value, useInt)
		local vtype = type(value)
		if vtype == "string" then
			return SetString(moddataPrefix .. path, value)
		elseif vtype == "boolean" then
			return SetBool(moddataPrefix .. path, value)
		elseif vtype == "number" then
			if useInt then
				return SetInt(moddataPrefix .. path, value)
			else
				return SetFloat(moddataPrefix .. path, value)
			end
		end
	end

	function SaveBool(path, value)
		SetBool(moddataPrefix .. path, value)
	end

	function SaveInt(path, value)
		SetInt(moddataPrefix .. path, value)
	end

	function SaveFloat(path, value)
		SetFloat(moddataPrefix .. path, value)
	end

	function SaveString(path, value)
		SetString(moddataPrefix .. path, value)
	end
-----

function migrateData()
	dataVersion = GetDataValue("version", "int")

	if dataVersion < 1 then
		SetDataValue("timescaling", true)
		SetDataValue("registerTools", true)
		SetDataValue("debug", false)
		SetDataValue("toolsEnabled.pistol", true)
		SetDataValue("toolsEnabled.shotgun", true)
		SetDataValue("toolsEnabled.rifle", true)
		SetDataValue("toolsEnabled.railgun", true)
		SetDataValue("hacks.powershot", false)
		SetDataValue("hacks.xplosive", false)
		SetDataValue("hacks.quickshot", false)
		SetDataValue("hacks.ricochet", false)
		SetDataValue("hacks.lightreflex", false)
	end

	SetDataValue("version", currentDataVersion, true)
	dataVersion = currentDataVersion
end

function revertToDefaultData()
	SetDataValue("timescaling", true)
	SetDataValue("registerTools", true)
	SetDataValue("debug", false)
	SetDataValue("toolsEnabled.pistol", true)
	SetDataValue("toolsEnabled.shotgun", true)
	SetDataValue("toolsEnabled.rifle", true)
	SetDataValue("toolsEnabled.railgun", true)
	SetDataValue("hacks.powershot", false)
	SetDataValue("hacks.xplosive", false)
	SetDataValue("hacks.quickshot", false)
	SetDataValue("hacks.ricochet", false)
	SetDataValue("hacks.lightreflex", false)
end

function applyData()
	timescaling = GetDataValue("timescaling", "bool")
	registerTools = GetDataValue("registerTools", "bool")
	enableDebug = GetDataValue("debug", "bool")

	toolsEnabled = {}
	toolsEnabled.pistol = GetDataValue("toolsEnabled.pistol", "bool")
	toolsEnabled.shotgun = GetDataValue("toolsEnabled.shotgun", "bool")
	toolsEnabled.rifle = GetDataValue("toolsEnabled.rifle", "bool")
	toolsEnabled.railgun = GetDataValue("toolsEnabled.railgun", "bool")

	toolHacks = {}
	toolHacks.powershot = GetDataValue("hacks.powershot", "bool")
	toolHacks.xplosive = GetDataValue("hacks.xplosive", "bool")
	toolHacks.quickshot = GetDataValue("hacks.quickshot", "bool")
	toolHacks.ricochet = GetDataValue("hacks.ricochet", "bool")
	toolHacks.lightreflex = GetDataValue("hacks.lightreflex", "bool")
end

function saveData()
	SetDataValue("timescaling", timescaling)
	SetDataValue("registerTools", registerTools)
	SetDataValue("debug", enableDebug)
	SetDataValue("powerBullets", powerBullets)
	SetDataValue("explosiveBullets", explosiveBullets)
	SetDataValue("toolsEnabled.pistol", toolsEnabled.pistol)
	SetDataValue("toolsEnabled.shotgun", toolsEnabled.shotgun)
	SetDataValue("toolsEnabled.rifle", toolsEnabled.rifle)
	SetDataValue("toolsEnabled.railgun", toolsEnabled.railgun)
	SetDataValue("hacks.powershot", toolHacks.powershot)
	SetDataValue("hacks.xplosive", toolHacks.xplosive)
	SetDataValue("hacks.quickshot", toolHacks.quickshot)
	SetDataValue("hacks.ricochet", toolHacks.ricochet)
	SetDataValue("hacks.lightreflex", toolHacks.lightreflex)
end

function initData()
	migrateData()
	applyData()
end