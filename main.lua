#include "util/index.lua"
#include "util/data.lua"

#include "util/tools.lua"
#include "weps/pistol.lua"
#include "weps/rifle.lua"
#include "weps/shotgun.lua"
-- #include "ui/hoppometer.lua"
-- #include "ui/compat.lua"

-- Options
timescaling = true
registerTools = true
toolsEnabled = {}

-- Variables
disableMod = false
tempSpeed = 0
lastCamRot = nil
died = false
justDied = false

function init()
	fireSound = LoadSound("MOD/assets/snd/player_pistol_fire.ogg")
	shotgunSound = LoadSound("MOD/assets/snd/shotgun_blast.ogg")
	bulletHitSound = LoadSound("MOD/assets/snd/bullet_hit_wall.ogg")
	squareSprite = LoadSprite("MOD/assets/ui/square.png")
	circleSprite = LoadSprite("MOD/assets/ui/circle.png")

	initData()
	if registerTools then
		toolsInit()
	end

	-- PlayMusic("MOD/assets/snd/ambient.ogg")
	deathSound = LoadSound("MOD/assets/snd/death.ogg")
	-- ambientLoop = LoadLoop("MOD/assets/snd/ambient.ogg")
	-- UiSoundLoop("MOD/assets/snd/ambient.ogg", 1)

	-- Disable Mod in certain levels
	local id = GetString("game.levelid")
	if id == "about" then
		disableMod = true
		return
	end
end

function tick(dt)
	if registerTools then
		pistolTick()
		rifleTick()
		shotgunTick()
	end

	if disableMod or GetBool("level.disableSuperhot") then return end
	if GetBool("game.player.usescreen") or GetBool("game.map.enabled") or GetBool("game.disableinput") then return end
	-- PlayMusic("MOD/assets/snd/ambient.ogg")

	-- PlayLoop(ambientLoop)
	-- if died and GetPlayerHealth() ~= 0 then died = false end

	if timescaling then
		-- Add temporary speedup on click
		if InputPressed("usetool") then tempSpeed = 0.5 end

		-- Calculate effect for camera turn and velocity
		local currCamRot = GetPlayerCameraTransform().rot
		local velocitySpeed = VecDist(Vec(0, 0, 0), GetPlayerVelocity())
		local camSpeed = 0
		if lastCamRot ~= nil then
			camSpeed = math.min(VecDist(Vec(0, 0, 0), VecSub(currCamRot, lastCamRot)), 0.5) * 50
		end
		lastCamRot = currCamRot
		local totalSpeed = velocitySpeed + camSpeed + tempSpeed

		-- Apply effect
		local baseTimeScale = 0.01
		if GetPlayerVehicle() ~= 0 or GetBool("game.player.grabbing") then
			baseTimeScale = 0.1
		elseif InputDown("jump") then
			baseTimeScale = 0.5
		end
		local timeScale = baseTimeScale + (math.min(totalSpeed / 7, 1) * (1 - baseTimeScale))
		if enableDebug then
			DebugWatch('timeScale', timeScale)
			DebugWatch('tempSpeed', tempSpeed)
			DebugWatch('camSpeed', camSpeed)
		end
		if GetPlayerHealth() ~= 0 then
			SetTimeScale(timeScale)
			SetFloat("level.superhot.timescale", timeScale)
		else
			SetTimeScale(0.5)
			SetFloat("level.superhot.timescale", 0.5)
		end

		-- slowly lessen temp speed overtime
		if tempSpeed > 0 then
			tempSpeed = tempSpeed - 0.01
		else
			tempSpeed = 0
		end

		if GetPlayerHealth() == 0 and not died then
			died = true
			justDied = true
		elseif GetPlayerHealth() == 1 and died then
			died = false
		end
	end
end

function draw()
	if registerTools then
		pistolDraw()
		rifleDraw()
		shotgunDraw()
	end

	-- UiSoundLoop("MOD/assets/snd/ambient.ogg", 1)
	-- UiSoundLoop("MOD/assets/snd/gun_tick.ogg", 1)
	if justDied then
		justDied = false
		UiSound("MOD/assets/snd/player_death.ogg")
	end
end
