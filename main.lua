local sizex,sizey,scale = 960,540,2
local color = {1,0,1,1}
local evapRate = 750
local agentNum = 50000

local senseAngle = 30
local senseDist = 20

local agentBatch

local spawnType = 1
local drawType = 2

math.randomseed(os.clock())

local tempMap = love.graphics.newCanvas(sizex,sizey)
local trailMap = love.graphics.newCanvas(sizex,sizey)
local displayMap = love.graphics.newCanvas(sizex,sizey)

displayMap:setFilter("nearest","nearest")

local process = love.graphics.newShader("process.glsl")

local agents = {}

local function makeAgents(num)
	for i=1,num do
		if spawnType == 2 then
			local dir = math.random() * 360

			local finalDir
			if dir > 180 then
				finalDir = dir-180
			else
				finalDir = dir+180
			end

			local x = (math.cos(math.rad(dir))*400)+sizex/2
			local y = (math.sin(math.rad(dir))*400)+sizey/2

			agents[#agents+1] = {
				x = x,
				y = y,
				dir = finalDir,
				id = agentBatch:add(sizex/2,sizey/2),
			}
		elseif spawnType == 1 then
			agents[#agents+1] = {
				x = sizex/2,
				y = sizey/2,
				dir = math.random() * 360,
				id = agentBatch:add(sizex/2,sizey/2),
			}
		end
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

local function updateAgent(agent,idata)
	local dx = math.cos(math.rad(agent.dir))
	local dy = math.sin(math.rad(agent.dir))

	local nx,xc = clamp(1,sizex,agent.x + dx)
	local ny,yc = clamp(1,sizey,agent.y + dy)

	agent.x = nx
	agent.y = ny

	if xc or yc then
		agent.dir = math.random() * 360
	else
		agent.dir = agent.dir + math.random(-100,100) * 0.05
	end
end

local function drawAgent(agent)
	agentBatch:set(agent.id,agent.x,agent.y)
end

local function senseAgent(agent,idata)
	local results = {}

	for _,v in ipairs({-1,0,1}) do
		local angle = v * senseAngle + agent.dir

		local dx = math.cos(math.rad(angle))*senseDist
		local dy = math.sin(math.rad(angle))*senseDist

		local nx = clamp(0,sizex-1,dx + agent.x)
		local ny = clamp(0,sizey-1,dy + agent.y)

		local r,g,b,a = idata:getPixel(nx,ny)

		results[angle] = r+g+b+a
	end

	local h = 0

	for i,v in pairs(results) do
		if results[h] == nil then
			h = i
		elseif v > results[h] then
			h = i
		end
	end

	return h
end

function love.update()

	tempMap:renderTo(function()
		love.graphics.clear()
		love.graphics.draw(trailMap)
	end)

	trailMap:renderTo(function()
		love.graphics.setShader(process)
		love.graphics.draw(tempMap)
		love.graphics.setShader()
		love.graphics.draw(agentBatch,0,0)
	end)

	displayMap:renderTo(function()
		love.graphics.clear()
		if drawType == 1 then
			love.graphics.draw(agentBatch,0,0)
		elseif drawType == 2 then
			love.graphics.draw(trailMap)
		end
	end)

	local idata = trailMap:newImageData()
	for _,v in ipairs(agents) do
		v.dir = senseAgent(v,idata)
		updateAgent(v)
		drawAgent(v)
	end
end

function love.load()
	love.window.setMode(sizex*scale,sizey*scale,{
		fullscreen = true,
		--fullscreentype = "exclusive",
	})

	pcall(function()
		process:send("imageSize",{sizex,sizey})
		process:send("evapRate",{color[1]/evapRate,color[2]/evapRate,color[3]/evapRate,color[4]/evapRate})
		process:send("defaultColor",color)
	end)

	local ac = love.graphics.newCanvas(2,2)
	ac:renderTo(function()
		love.graphics.setColor(color)
		love.graphics.points(1,1)
	end)

	agentBatch = love.graphics.newSpriteBatch(ac,agentNum,"dynamic")

	makeAgents(agentNum)

	tempMap:renderTo(function()
		love.graphics.clear()
	end)
	trailMap:renderTo(function()
		love.graphics.clear()
	end)
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(scale,scale)
	love.graphics.draw(displayMap)
	love.graphics.pop()
end