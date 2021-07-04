local toolID = "superhot_rifle"

local bullets = {}
local bulletVelocity = 40
local bulletSmokeTime = 0.1
local bulletTraceTime = 0.25
local bulletTTL = 10
local shotDelay = 1
local autoShotDelay = 0.2
local autoShots = 0
rifleRecoilTimer = 0
rifleShootTimer = 0
rifleAutoShootTimer = 0
rifleUIScale = 1

local function hasTool()
  return GetString("game.player.tool") == toolID
end

local function createGunSmoke(bullet, nextPosition)
  if bullet.time < bulletSmokeTime then
    local spriteLook = VecAdd(bullet.smokepos, bullet.direction)
    local spriteRot = QuatLookAt(bullet.smokepos, spriteLook)
    local spriteTransform = Transform(bullet.smokepos, spriteRot)

    DrawSprite(squareSprite, spriteTransform, 0.25, 0.25, 1, 1, 1, 1 - (bullet.time / bulletSmokeTime), true, true)
    PointLight(bullet.smokepos, 1, 1, 1, 1 - (bullet.time / bulletSmokeTime))
  end
end

local function bulletOperation(bullet)
  local nextPosition = VecAdd(bullet.pos, VecScale(bullet.direction, bulletVelocity * GetTimeStep()))
  local hit, dist = QueryRaycast(bullet.pos, bullet.direction, VecLength(VecSub(nextPosition, bullet.pos)))
  createGunSmoke(bullet, nextPosition)

  if not bullet.hit then
    if hit then
      bullet.hit = true
      local hitPos = VecAdd(bullet.pos, VecScale(VecNormalize(VecSub(nextPosition, bullet.pos)), dist))
      -- PlaySound(bulletHitSound, bullet.pos, 0.5)
			if toolHacks.xplosive then
				Shoot(bullet.pos, bullet.direction, 1)
			elseif toolHacks.powershot then
				Shoot(bullet.pos, bullet.direction, 0)
			else
				MakeHole(hitPos, 0.5, 0.375, 0.25)
			end
    elseif bullet.time > bulletTTL then
      bullet.hit = true
    else
      drawBullet(bullet, nextPosition)
      bullet.pos = nextPosition
    end
  end

  bullet.time = bullet.time + GetTimeStep()
  if bullet.time > bulletTraceTime and not bullet.doneTracing then
    local nextTracePos = VecAdd(bullet.tracepos, VecScale(bullet.direction, bulletVelocity * GetTimeStep()))
    bullet.tracepos = nextTracePos
  end

  local traceLength = VecLength(VecSub(bullet.pos, bullet.tracepos))
  if traceLength <= 1 and bullet.hit then
    bullet.doneTracing = true
  else
    local tracePos2 = VecAdd(bullet.tracepos, VecScale(bullet.direction, traceLength * 0.1))
    local tracePos3 = VecAdd(bullet.tracepos, VecScale(bullet.direction, traceLength * 0.25))
    DrawLine(nextPosition, bullet.tracepos, 1, 0, 0)
    DrawLine(nextPosition, tracePos2, 1, 0, 0)
    DrawLine(nextPosition, tracePos3, 1, 0, 0)
  end

  if bullet.doneTracing and bullet.time > bulletSmokeTime then
    bullet.done = true
  end
end

local function createBullet()
  local pos, dir, gunPos = getBulletPosition(Vec(0.4, -0.3, -3.2))
  local bullet = {
    pos = pos,
    direction = dir,
    smokepos = gunPos,
    tracepos = pos,
    time = 0,
    doneTracing = false,
    done = false
  }

  table.insert(bullets, bullet)
end

function rifleTick()
	if enableDebug then
		DebugWatch('rifle bullets', #bullets)
		DebugWatch('rifle autoshots', autoShots)
	end

  SetString("game.tool." .. toolID .. ".ammo.display", "")

  for i, bullet in ipairs(bullets) do
    if bullet.done then
      table.remove(bullets, i)
    else
      bulletOperation(bullet)
    end
  end


	if hasTool() and canShoot() then
		if InputDown("usetool") and rifleShootTimer <= 0 and not GetBool("game.player.grabbing") then
			createBullet()
			PlaySound(fireSound, GetPlayerTransform().pos, 1)

			local shotTime = shotDelay
			local autoShotTime = autoShotDelay
			if toolHacks.quickshot then
				shotTime = shotDelay / 2
				autoShotTime = autoShotDelay / 2
			end

			rifleShootTimer = shotTime
			SetValue("rifleShootTimer", 0, "linear", shotTime)
			rifleAutoShootTimer = autoShotTime
			SetValue("rifleAutoShootTimer", 0, "linear", autoShotTime)
			rifleRecoilTimer = autoShotTime
			SetValue("rifleRecoilTimer", 0, "easeout", autoShotTime)
      rifleUIScale = 0.8
    elseif rifleShootTimer > 0 and rifleAutoShootTimer <= 0 and autoShots < 3 then
			createBullet()
			PlaySound(fireSound, GetPlayerTransform().pos, 1)
      autoShots = autoShots + 1

			local autoShotTime = autoShotDelay
			if toolHacks.quickshot then
				shotTime = shotDelay / 2
				autoShotTime = autoShotDelay / 2
			end

			rifleAutoShootTimer = autoShotTime
			SetValue("rifleAutoShootTimer", 0, "linear", autoShotTime)
			rifleRecoilTimer = autoShotTime
			SetValue("rifleRecoilTimer", 0, "easeout", autoShotTime)
    elseif autoShots >= 3 and rifleAutoShootTimer <= 0 and rifleShootTimer <= 0 then
      autoShots = 0
    end

		-- if InputPressed("lmb") and not reloading then
		-- 	if ammo == 0 then
		-- 		PlaySound(dryfiresound, GetPlayerTransform().pos, 1, false)
		-- 	end
		-- end

		-- if InputReleased("lmb") and ammo > 0 then
		-- 	-- SpawnParticle("darksmoke", gunpos, Vec(0, 1.0+math.random(1,10)*0.1, 0), 0.3, 0.5)
		-- end

		local b = GetToolBody()
		if b ~= 0 then
      local t = Transform(Vec(0.1, -0.1, rifleRecoilTimer/2), QuatEuler(rifleRecoilTimer * 25, 0, 0))
      SetToolTransform(t)
		end
	end
end

function rifleDraw()
  if hasTool() and not GetBool("game.player.grabbing") and not GetBool("game.player.usescreen") then
    if rifleUIScale == 0.8 and rifleShootTimer == 0 then
      rifleUIScale = 1.2
      UiSound('MOD/assets/snd/gun_tick.ogg', 1)
    end

    SetBool("hud.aimdot", false)
    UiPush()
      UiAlign("center middle")
      UiTranslate(UiCenter(), UiMiddle())
      UiScale(rifleUIScale)
      UiRotate((rifleShootTimer / shotDelay) * 90)
      UiImageBox("MOD/assets/ui/crosshair.png", 100, 100, 0, 0)
    UiPop()
  end

  if rifleUIScale > 1 then
    rifleUIScale = math.max(1, rifleUIScale - 0.01)
  end
end

registerSuperhotTool("rifle", "SUPERHOT Rifle", "rifle")