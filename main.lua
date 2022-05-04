local sizex,sizey,scale = 200,200,4

local shader = love.graphics.newShader("pixel.glsl")
local canvas1 = love.graphics.newCanvas(sizex,sizey)
local canvas2 = love.graphics.newCanvas(sizex,sizey)

function love.load()
	love.window.setMode(sizex*scale,sizey*scale)

	shader:send("imageSize",{love.graphics.getDimensions()})
	shader:send("r",2)

	love.graphics.setCanvas(canvas1)

	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("fill",50,50,50,50)

	love.graphics.setCanvas()
end

function love.draw()
	love.graphics.scale(scale)

	love.graphics.setCanvas(canvas2)
	love.graphics.clear()
	love.graphics.setShader(shader)
	love.graphics.draw(canvas1)
	love.graphics.setShader()
	love.graphics.setCanvas()

	canvas1,canvas2 = canvas2,canvas1
end