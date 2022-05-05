local sizex,sizey,scale = 320,180,4
local speed = 0.5
local color = {1,1,1,1}

local sensor = 10

local temp = love.graphics.newCanvas(sizex,sizey)
local trailMap = love.graphics.newCanvas(sizex,sizey)
local processedTrailMap = love.graphics.newCanvas(sizex,sizey)
local displayMap = love.graphics.newCanvas(sizex,sizey)

local blur = love.graphics.newShader("blur.glsl")
local evap = love.graphics.newShader("evap.glsl")

displayMap:setFilter("nearest","nearest")

local agents = {}

local function makeAgents(num)
	for i=1,num do
		agents[#agents+1] = {
			x = sizex/2,
			y = sizey/2,
			dir = math.random() * 360,
		}
	end
end

local function clamp(min,max,val)
	if val > max then
		return max,true
	elseif val < min then
		return min,true
	end
	return val,false
end

local function sense(agent,idata)
	local angles = {}
	for _,v in ipairs({-2,-1,0,1,2}) do
		local angle = agent.dir + (sensor * v)

		local dx = math.cos(math.rad(angle))*5
		local dy = math.sin(math.rad(angle))*5

		local px = clamp(1,sizex-1,agent.x + dx)
		local py = clamp(1,sizey-1,agent.y + dy)

		local r,g,b,a = idata:getPixel(px, py)
		local avg = r+g+b

		angles[angle] = avg
	end

	angles[0] = 0

	local h = 0
	for i,v in pairs(angles) do
		if v > angles[h] and math.random() > 0.01 then
			h = i
		end
	end

	return h
end

local function updateAgent(agent,idata)
	local dx = math.cos(math.rad(agent.dir))*speed
	local dy = math.sin(math.rad(agent.dir))*speed

	local nx,xc = clamp(1,sizex,agent.x + dx)
	local ny,yc = clamp(1,sizey,agent.y + dy)

	agent.x = nx
	agent.y = ny

	if xc or yc then
		agent.dir = math.random() * 360
	else
		--agent.dir = sense(agent,idata)
	end
end

local function drawAgent(agent,canvas)
	canvas:renderTo(function()
		love.graphics.setColor(color)
		love.graphics.points(math.floor(agent.x),math.floor(agent.y))
	end)
end

function love.load()
	love.window.setMode(sizex*scale,sizey*scale)

	pcall(function()
		blur:send("imageSize",{sizex,sizey})
		evap:send("evapRate",200)
		evap:send("defaultColor",color)
	end)

	makeAgents(250)

	temp:renderTo(function()
		love.graphics.clear()
	end)
	trailMap:renderTo(function()
		love.graphics.clear()
	end)
	processedTrailMap:renderTo(function()
		love.graphics.clear()
	end)
	displayMap:renderTo(function()
		love.graphics.clear()
	end)
end


function love.update()
	print(love.timer.getFPS())

	temp:renderTo(function()
		love.graphics.clear()
		love.graphics.draw(trailMap)
	end)

	trailMap:renderTo(function()
		love.graphics.setShader(evap)
		love.graphics.draw(temp)
		love.graphics.setShader()
	end)

	processedTrailMap:renderTo(function()
		love.graphics.clear()
		love.graphics.setShader(blur)
		love.graphics.draw(trailMap)
		love.graphics.setShader()
	end)

	displayMap:renderTo(function()
		love.graphics.clear()
		love.graphics.draw(trailMap)
		love.graphics.draw(processedTrailMap)
	end)

	local idata = processedTrailMap:newImageData()
	for _,v in ipairs(agents) do
		updateAgent(v,idata)
		drawAgent(v,trailMap)
	end
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(scale,scale)
	love.graphics.draw(displayMap)
	love.graphics.pop()
end