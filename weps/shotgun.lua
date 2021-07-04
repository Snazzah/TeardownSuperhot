local toolID = "superhot_shotgun"

local bullets = {}
local bulletVelocity = 40
local bulletSmokeTime = 0.1
local bulletTraceTime = 0.25
local bulletTTL = 10
local shotRecoilTime = 0.5
local shotDelay = 1
shotgunRecoilTimer = 0
shotgunShootTimer = 0
shotgunUIScale = 1

local function hasTool()
  return GetString("game.player.tool") == toolID
end

local function createGunSmoke(bullet, nextPosition)
  if bullet.time < bulletSmokeTime then
    local spriteLook = VecAdd(bullet.smokepos, bullet.smokedir)
    local spriteRot = QuatLookAt(bullet.smokepos, spriteLook)
    local spriteTransform = Transform(bullet.smokepos, spriteRot)

    DrawSprite(squareSprite, spriteTransform, 0.35, 0.35, 1, 1, 1, 1 - (bullet.time / bulletSmokeTime), true, true)
    PointLight(bullet.smokepos, 1, 1, 1, 1 - (bullet.time / bulletSmokeTime))
  end
end

local function bulletOperation(bullet)
  local nextPosition = VecAdd(bullet.pos, VecScale(bullet.direction, bulletVelocity * GetTimeStep()))
  local hit, dist = QueryRaycast(bullet.pos, bullet.direction, VecLength(VecSub(nextPosition, bullet.pos)))
  createGunSmoke(bullet, nextPosition)

	if not bullet.tracepos then
		bullet.tracepos = nextPosition
	end

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
      -- DebugCross(nextPosition, 0, 1, 0, 1)
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
  local pos, dir, gunPos = getBulletPosition(
		Vec(0.65, -0.4, -3.2),
		math.random(-50, 50) / 1000,
		math.random(-50, 50) / 1000
	)
	local smokeDir = getToolDirection(Vec(0, 0, 1))
  local bullet = {
    pos = pos,
    direction = dir,
    smokedir = smokeDir,
    smokepos = gunPos,
    tracepos = nil,
    time = 0,
    doneTracing = false,
    done = false
  }

  table.insert(bullets, bullet)
end

function shotgunTick()
	if enableDebug then
  	DebugWatch('shotgun bullets', #bullets)
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
		if InputDown("usetool") and shotgunShootTimer <= 0 and not GetBool("game.player.grabbing") then
			for i=1, 8 do
				createBullet()
			end
			PlaySound(shotgunSound, GetPlayerTransform().pos, 1)

			local shotTime = shotDelay
			local shotRecoil = shotRecoilTime
			if toolHacks.quickshot then
				shotTime = shotDelay / 2
				shotRecoil = shotRecoilTime / 2
			end

			shotgunShootTimer = shotTime
			SetValue("shotgunShootTimer", 0, "linear", shotTime)
			shotgunRecoilTimer = shotRecoil
			SetValue("shotgunRecoilTimer", 0, "easeout", shotRecoil)
      shotgunUIScale = 0.8
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
			if shotgunRecoilTimer > 0 then
				local t = Transform(Vec(0, 0, shotgunRecoilTimer), QuatEuler(shotgunRecoilTimer * 25, 0, 0))
				SetToolTransform(t)
			end
		end
	end
end

function shotgunDraw()
  if hasTool() and not GetBool("game.player.grabbing") and not GetBool("game.player.usescreen") then
    if shotgunUIScale == 0.8 and shotgunShootTimer == 0 then
      shotgunUIScale = 1.2
      UiSound('MOD/assets/snd/shotgun_reload.ogg', 1)
    end

    SetBool("hud.aimdot", false)
    UiPush()
      UiAlign("center middle")
      UiTranslate(UiCenter(), UiMiddle())
      UiScale(shotgunUIScale)
      UiRotate((shotgunShootTimer / shotDelay) * 90)
      UiImageBox("MOD/assets/ui/crosshair.png", 100, 100, 0, 0)
    UiPop()
  end

  if shotgunUIScale > 1 then
    shotgunUIScale = math.max(1, shotgunUIScale - 0.01)
  end
end

registerSuperhotTool("shotgun", "SUPERHOT Shotgun", "shotgun")