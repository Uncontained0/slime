local sizex,sizey,scale = 200,200,4

local shader = love.graphics.newShader("pixel.glsl")
local canvas1 = love.graphics.newCanvas(sizex,sizey)
local canvas2 = love.graphics.newCanvas(sizex,sizey)

function love.load()
	love.window.setMode(sizex*scale,sizey*scale)

	pcall(function()
		shader:send("imageSize",{love.graphics.getDimensions()})
		shader:send("r",25)
	end)

	love.graphics.setCanvas(canvas1)

	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("fill",50,50,50,50)

	love.graphics.setCanvas()
end

local t = 0
function love.update(dt)
	t = t + dt

	if t > 1 then
		print("update")

		t = 0

		canvas2:renderTo( function()
			love.graphics.draw(canvas1)
		end)
	end
end

function love.draw()
	love.graphics.scale(scale)
	love.graphics.draw(canvas2)
end