local sizex,sizey,scale = 400,400,2
local speed = 0.8

local shader = love.graphics.newShader("pixel.glsl")
local canvas1 = love.graphics.newCanvas(sizex,sizey)
local canvas2 = love.graphics.newCanvas(sizex,sizey)

local agents = {}

local function makeAgents(num)
	for i=1,num do
		agents[#agents+1] = {
			x = sizex/2,
			y = sizey/2,
			dir = math.random(0,360),
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

local function updateAgent(agent)
	local dx = math.cos(math.rad(agent.dir))*speed
	local dy = math.sin(math.rad(agent.dir))*speed

	local nx,xc = clamp(1,sizex,agent.x + dx)
	local ny,yc = clamp(1,sizey,agent.y + dy)

	agent.x = nx
	agent.y = ny

	if xc or yc then
		agent.dir = math.random(0,360)
	end
end

local function drawAgent(agent,canvas)
	canvas:renderTo(function()
		love.graphics.setColor(0,1,1,1)
		love.graphics.points(math.floor(agent.x),math.floor(agent.y))
	end)
end

function love.load()
	love.window.setMode(sizex*scale,sizey*scale)

	pcall(function()
		shader:send("imageSize",{love.graphics.getDimensions()})
		shader:send("r",1)
		shader:send("diffuseRate",15)
	end)

	makeAgents(500)

	canvas1:renderTo(function()
		love.graphics.clear()
	end)
	canvas2:renderTo(function()
		love.graphics.clear()
	end)
end


function love.update()
	print(love.timer.getFPS())

	canvas2:renderTo(function()
		love.graphics.setShader(shader)
		love.graphics.draw(canvas1)
		love.graphics.setShader()
	end)

	canvas1:renderTo(function()
		love.graphics.clear()
		love.graphics.draw(canvas2)
	end)

	for _,v in ipairs(agents) do
		updateAgent(v)
		drawAgent(v,canvas1)
	end
end

function love.draw()
	love.graphics.scale(scale,scale)
	love.graphics.draw(canvas1)
end