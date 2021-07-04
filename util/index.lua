function VecDist(a, b)
	local directionVector = VecSub(b, a)

	local distance = VecMag(directionVector)

	return distance
end

function VecMag(a)
	return math.sqrt(a[1]^2 + a[2]^2 + a[3]^2)
end

function VecDirection(a, b)
	return VecNormalize(VecSub(b, a))
end