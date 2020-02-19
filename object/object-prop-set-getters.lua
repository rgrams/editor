
local getters, setters = {}, {}

function getters.default(obj, key, subKey)
	if subKey then  return obj[key][subKey]
	else  return obj[key]  end
end

function setters.default(obj, key, val, subKey)
	if subKey then  obj[key][subKey] = val
	else  obj[key] = val  end
end

function getters.worldPos(obj, key, subKey)
	if not subKey then  return {x=obj._to_world.x,y=obj._to_world.y}
	else  return obj._to_world[subKey]  end
end

function setters.worldPos(obj, key, val, subKey)
	assert(obj.parent, "setters.worldPos - Object does not have a parent. " .. tostring(obj))
	local oldx, oldy = obj.pos.x, obj.pos.y
	local lx, ly
	if not subKey then
		lx, ly = obj.parent:toLocal(val.x, val.y)
	elseif subKey == "x" then
		lx, ly = obj.parent:toLocal(val, obj._to_world.y)
	elseif subKey == "y" then
		lx, ly = obj.parent:toLocal(obj._to_world.x, val)
	end
	obj.pos.x, obj.pos.y = lx, ly
end

function getters.assetParams(obj, key)
	local params = new.paramsFor[obj[key]]
	if not params then
		print("Couldn't get parameters for asset: '" .. tostring(asset) .. "'.")
		return
	end
	if #params == 1 then  params = params[1]  end
	return params
end

function setters.imageData(obj, key, val)
	-- Have to update offset for new image size.
	local oldImgW, oldImgH = obj.image:getDimensions()
	local ox, oy = obj.ox / oldImgW, obj.oy / oldImgH
	local image = new.image(val)
	local imgW, imgH = image:getDimensions()
	obj.ox, obj.oy = ox * imgW, oy * imgH
	obj[key] = image
end

function setters.font(obj, key, val)
	local font = new.font(val[1], val[2])
	obj[key] = font
end

function getters.imgOffsetFraction(obj, key)
	local pixelOffset = obj[key]
	local imgW, imgH = obj.image:getDimensions()
	if key == "ox" then  return pixelOffset / imgW
	else  return pixelOffset / imgH  end
end

function setters.imgOffsetFraction(obj, key, val)
	local imgW, imgH = obj.image:getDimensions()
	if key == "ox" then  obj[key] = imgW * val
	else  obj[key] = imgH * val  end
end

function getters.quadParams(obj, key)
	return { obj[key]:getViewport() }
end

function setters.quadParams(obj, key, val)
	-- TODO: Probably need to recalculate ox and oy for the new quad size.
	local imgW, imgH = obj.image:getDimensions()
	local quad = obj[key]
	local x, y, w, h = unpack(val)
	quad:setViewport(x, y, w, h, imgW, imgH)
end

function getters.gravity(obj, key)
	local x, y = obj.world:getGravity()
	if key == "xg" then  return x
	else  return y  end
end

function setters.gravity(obj, key, val)
	local x, y = obj.world:getGravity()
	if key == "xg" then  x = val
	else  y = val  end
	obj.world:setGravity(x, y)
end

function getters.sleepingAllowed(obj, key)
	return obj.world:isSleepingAllowed()
end

function setters.sleepingAllowed(obj, key, val)
	obj.world:setSleepingAllowed(val)
end

function getters.worldCallbackEnabled(obj, key)
	local beginContact, endContact, preSolve, postSolve = obj.world:getCallbacks()
	if key == "disableBegin" then  return beginContact == nil
	elseif key == "disableEnd" then  return endContact == nil
	elseif key == "disablePre" then  return preSolve == nil
	elseif key == "disablePost" then  return postSolve == nil
	end
end

-- Placeholder for actual callback function.
--   The real callback functions won't be used in the editor, so just set them to this.
local function emptyFn()  end

function setters.worldCallbackEnabled(obj, key, val)
	local beginContact, endContact, preSolve, postSolve = obj.world:getCallbacks()
	if key == "disableBegin" then  beginContact = val and emptyFn or nil
	elseif key == "disableEnd" then  endContact = val and emptyFn or nil
	elseif key == "disablePre" then  preSolve = val and emptyFn or nil
	elseif key == "disablePost" then  postSolve = val and emptyFn or nil
	end
	obj.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

return { get = getters, set = setters }