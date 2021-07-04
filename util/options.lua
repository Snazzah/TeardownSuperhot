local pagePad = nUiPadding * 2

function pageRenderMain()
	UiTranslate(pagePad, pagePad)
	local h = pagePad

	-- Time Scaling
		local tsClicked, tsW, tsH = nUiCheckbox(
			"SUPERHOT Mechanic",
			"Time moves when you move.",
			timescaling,
			UiWidth() - (pagePad * 2)
		)
		h = h + tsH + 30
		if tsClicked then
			timescaling = not timescaling
		end
		UiTranslate(0, tsH + 30)
	-----

	-- Register Tools
		local rtClicked, rtW, rtH = nUiCheckbox(
			"Add SUPERHOT Weapons",
			"Add weapons tailored for this mod. Check the 'Tools' tab to enable specific weapons.",
			registerTools,
			UiWidth() - (pagePad * 2)
		)
		h = h + rtH + 30
		if rtClicked then
			registerTools = not registerTools
		end
		UiTranslate(0, rtH + 30)
	-----

	-- Debug
		h = h + 50
		UiTranslate(0, 50)

		local deClicked, deW, deH = nUiCheckbox(
			"Debug Info",
			"Enables the top-right overlay that displays debug information.",
			enableDebug,
			UiWidth() - (pagePad * 2)
		)
		h = h + deH + 10
		if deClicked then
			enableDebug = not enableDebug
		end
		UiTranslate(0, deH + 10)
	-----

	-- Data Version
		UiPush()
			UiAlign("top left")
			UiFont("MOD/assets/ui/Roboto-Regular.ttf", 20)
			UiColor(0.2, 0.2, 0.2)
			local dvW, dvW = UiGetTextSize('Data Version ' .. dataVersion)
			UiText('Data Version ' .. dataVersion)
		UiPop()
		h = h + dvW + 20
	-----

	return h
end

function pageRenderTools()
	UiTranslate(pagePad, pagePad)
	local h = pagePad

	-- Tools
		local toolList = {
			{"pistol", "Pistol"},
			{"shotgun", "Shotgun"},
			{"rifle", "Rifle"}
			-- {"railgun", "Railgun"}
		}

		for i=1, #toolList do
			local tool = toolList[i]
			local enabled = false
			if toolsEnabled[tool[1]] then
				enabled = true
			end

			local tClicked, tW, tH = nUiCheckbox(
				tool[2], nil,
				enabled,
				UiWidth() - (pagePad * 2),
				50, 40
			)
			h = h + tH + 20
			if tClicked then
				toolsEnabled[tool[1]] = not enabled
			end
			UiTranslate(0, tH + 20)
		end
	-----

	h = h + 50
	return h
end

function pageRenderHacks()
	UiTranslate(pagePad, pagePad)
	local h = pagePad

	h = h + 10
	UiTranslate(0, 10)

	local text = "'Hacks' are modifiers to the mod and it's weapons. Try some out."
	UiFont("MOD/assets/ui/Roboto-Italic.ttf", 30)
	UiColor(0.25, 0.25, 0.25)
	UiTextShadow(0, 0, 0, 0.5, 2.0)
	UiWordWrap(UiWidth() - (pagePad * 2))
	local dw, dh = UiGetTextSize(text)
	UiText(text)

	h = h + dh + 10
	UiTranslate(0, dh + 10)

	-- Hacks
		local hackList = {
			{"powershot", "powershot.hack", "Bullets from SUPERHOT weapons are more powerful."},
			{"xplosive", "xplodeshot.hack", "Bullets from SUPERHOT weapons explode on impact."},
			{"quickshot", "quickshot.hack", "SUPERHOT weapons have less reload time and shot delay."}
		}

		for i=1, #hackList do
			local hack = hackList[i]
			local enabled = false
			if toolHacks[hack[1]] then
				enabled = true
			end

			local hClicked, hW, hH = nUiCheckbox(
				hack[2], hack[3],
				enabled,
				UiWidth() - (pagePad * 2)
			)
			h = h + hH + 20
			if hClicked then
				toolHacks[hack[1]] = not enabled
			end
			UiTranslate(0, hH + 20)
		end
	-----

	h = h + 50
	return h
end

optionPages = {
	main = pageRenderMain,
	tools = pageRenderTools,
	hacks = pageRenderHacks
}