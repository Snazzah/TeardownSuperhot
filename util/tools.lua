tools = {}

function registerSuperhotTool(id, name, model, tick, draw, init)
  table.insert(tools, {
    id = id,
    name = name,
    model = model,
    init = init
  })
end

function canShoot()
	if GetBool("game.player.usescreen") then return false end
	local vehicle = GetPlayerVehicle()
	if vehicle ~= 0 then
		local driverPos = GetVehicleDriverPos(vehicle)
		local t = GetVehicleTransform(vehicle)
		local worldPos = TransformToParentPoint(t, driverPos)
		local cameraPos = GetCameraTransform().pos
		local length = VecLength(VecSub(cameraPos, worldPos))

		if length < 1 then
			return true
		else
			return false
		end
	end
	return true
end

function GetToolTransform()
  return GetBodyTransform(GetToolBody())
end

function getBulletPosition(offset, xOffset, yOffset)
	offset = offset or Vec(0, 0, 0)
	xOffset = xOffset or 0
	yOffset = yOffset or 0

	local ct = GetCameraTransform()
	local forwardPos = TransformToParentPoint(ct, Vec(xOffset, yOffset, 0.7))
  local gunPos = TransformToParentPoint(GetToolTransform(), offset)
	local dir = VecDirection(forwardPos, ct.pos)

  return ct.pos, dir, gunPos
end

function getToolDirection(pos)
	local toolPos = VecCopy(GetToolTransform().pos)
	return VecDirection(TransformToParentPoint(GetToolTransform(), pos), toolPos)
end

function getCameraFacingTransform(pos)
	local cameraPos = VecCopy(GetCameraTransform().pos)
	local spriteRot = QuatLookAt(pos, cameraPos)
	return Transform(pos, spriteRot)
end

function drawBullet(bullet, nextPosition)
  -- local spriteRot = QuatLookAt(bullet.pos, nextPosition)
  -- local spriteTransform = Transform(nextPosition, spriteRot)
  DrawSprite(circleSprite, getCameraFacingTransform(bullet.pos), 0.05, 0.05, 0, 0, 0.05, 1, true, false)
end

function toolsInit()
  for key, tool in ipairs(tools) do
    local id = "superhot_" .. tool.id
		local enabled = false
		if toolsEnabled[tool.id] then enabled = true end
    RegisterTool(id, tool.name, "MOD/assets/vox/" .. tool.model .. ".vox")
    SetBool("game.tool." .. id .. ".enabled", enabled)

    if tool.init then tool.init() end
  end
end