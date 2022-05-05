local sizex,sizey,scale = 320,180,4
local speed = 1
local color = {1,1,1,1}

local sensor = 10

local tempMap = love.graphics.newCanvas(sizex,sizey)
local agentMap = love.graphics.newCanvas(sizex,sizey)
local trailMap = love.graphics.newCanvas(sizex,sizey)
local displayMap = love.graphics.newCanvas(sizex,sizey)

displayMap:setFilter("nearest","nearest")

local process = love.graphics.newShader("process.glsl")

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

local function updateAgent(agent,idata)
	local dx = math.cos(math.rad(agent.dir))*speed
	local dy = math.sin(math.rad(agent.dir))*speed

	local nx,xc = clamp(1,sizex,agent.x + dx)
	local ny,yc = clamp(1,sizey,agent.y + dy)

	agent.x = nx
	agent.y = ny

	if xc or yc then
		agent.dir = math.random() * 360
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
		process:send("imageSize",{sizex,sizey})
		process:send("evapRate",0.1)
		process:send("defaultColor",color)
	end)

	makeAgents(20)

	tempMap:renderTo(function()
		love.graphics.clear()
	end)
	trailMap:renderTo(function()
		love.graphics.clear()
	end)
	agentMap:renderTo(function()
		love.graphics.clear()
	end)
end


function love.update()
	print(love.timer.getFPS())

	tempMap:renderTo(function()
		love.graphics.clear()
		love.graphics.draw(trailMap)
	end)

	trailMap:renderTo(function()
		love.graphics.setShader(process)
		love.graphics.draw(tempMap)
		love.graphics.setShader()
		love.graphics.draw(agentMap)
	end)

	agentMap:renderTo(function()
		love.graphics.clear()
	end)

	displayMap:renderTo(function()
		love.graphics.draw(trailMap)
	end)

	local idata = trailMap:newImageData()
	for _,v in ipairs(agents) do
		updateAgent(v,idata)
		drawAgent(v,agentMap)
	end
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(scale,scale)
	love.graphics.draw(displayMap)
	love.graphics.pop()
end