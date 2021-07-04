local toolID = "superhot_pistol"

local bullets = {}
local bulletVelocity = 40
local bulletSmokeTime = 0.1
local bulletTraceTime = 0.25
local bulletTTL = 10
local shotDelay = 0.5
pistolRecoilTimer = 0
pistolShootTimer = 0
pistolUIScale = 1

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
  local pos, dir, gunPos = getBulletPosition(Vec(0.3, -0.3, -1.8))
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

function pistolTick()
	if enableDebug then
  	DebugWatch('pistol bullets', #bullets)
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
		if InputDown("usetool") and pistolShootTimer <= 0 and not GetBool("game.player.grabbing") then
			createBullet()
			PlaySound(fireSound, GetPlayerTransform().pos, 1)

			local shotTime = shotDelay
			if toolHacks.quickshot then
				shotTime = shotDelay / 2
			end

			pistolShootTimer = shotTime
			SetValue("pistolShootTimer", 0, "linear", shotTime)
			pistolRecoilTimer = shotTime
			SetValue("pistolRecoilTimer", 0, "easeout", shotTime)
      pistolUIScale = 0.8
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
			if pistolRecoilTimer > 0 then
				local t = Transform(Vec(0, 0, pistolRecoilTimer), QuatEuler(pistolRecoilTimer * 50, 0, 0))
				SetToolTransform(t)
			end
		end
	end
end

function pistolDraw()
  if hasTool() and not GetBool("game.player.grabbing") and not GetBool("game.player.usescreen") then
    if pistolUIScale == 0.8 and pistolShootTimer == 0 then
      pistolUIScale = 1.2
      UiSound('MOD/assets/snd/gun_tick.ogg', 1)
    end

    SetBool("hud.aimdot", false)
    UiPush()
      UiAlign("center middle")
      UiTranslate(UiCenter(), UiMiddle())
      UiScale(pistolUIScale)
      UiRotate((pistolShootTimer / shotDelay) * 90)
      UiImageBox("MOD/assets/ui/crosshair.png", 100, 100, 0, 0)
    UiPop()
  end

  if pistolUIScale > 1 then
    pistolUIScale = math.max(1, pistolUIScale - 0.01)
  end
end

registerSuperhotTool("pistol", "SUPERHOT Pistol", "pistol")