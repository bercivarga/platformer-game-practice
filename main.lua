function love.load()
	wf = require('libraries.windfield.windfield')
	anim8 = require('libraries.anim8.anim8')

	sprites = {}
	sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')

	local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

	animations = {}
	animations.idle = anim8.newAnimation(grid('1-15', 1), .05)
	animations.jump = anim8.newAnimation(grid('1-7', 2), .05)
	animations.run = anim8.newAnimation(grid('1-15', 3), .05)

	world = wf.newWorld(0, 500, false)

	world:addCollisionClass('Player')
	world:addCollisionClass('Platform')
	world:addCollisionClass('Danger')

	world:setQueryDebugDrawing(true)

	player = world:newRectangleCollider(360, 100, 40, 100, {collision_class = "Player"})
	player.speed = 240
	player.maxJumps = 2
	player.jumpsLeft = 2
	player.animation = animations.idle
	player.isMoving = false
	player.direction = 1 -- 1 is right, -1 is left
	player.grounded = true

	player:setFixedRotation(true)

	platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "Platform"})
	platform:setType('static')

	dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
	dangerZone:setType('static')
end

function love.update(dt)
	world:update(dt)

	if player.body then
		local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'Platform'})
		if #colliders > 0 then
			player.grounded = true
		else
			player.grounded = false
		end

		player.isMoving = false

		local px = player:getPosition()

		if love.keyboard.isDown('d') then
			player:setX(px + player.speed * dt)
			player.isMoving = true
			player.direction = 1
		end

		if love.keyboard.isDown('a') then
			player:setX(px - player.speed * dt)
			player.isMoving = true
			player.direction = -1
		end

		if player:enter('Danger') then
			player:destroy()
		end
	end

if player.grounded then
	if player.isMoving then
		player.animation = animations.run
	else
		player.animation = animations.idle
	end
else
	player.animation = animations.jump
end

	player.animation:update(dt)
end

function love.draw()
	world:draw()

	if player.body == nil then
		return
	end

	local px, py = player:getPosition()
	player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 300)
end

function love.keypressed(key)
	if key == 'space' or key == 'w' then
		if player.body == nil then
			return
		end

		local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, {'Platform'})

		if player.grounded then
			player:applyLinearImpulse(0, -3000)
			player.jumpsLeft = player.maxJumps
		else
			player.jumpsLeft = player.jumpsLeft - 1
			if player.jumpsLeft > 0 then
				player:applyLinearImpulse(0, -3000)
			end
		end
	end
end

function love.mousepressed(x, y, button)
	if button == 1 then
		local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})
		for _,v in ipairs(colliders) do
			v:destroy()
		end
	end
end

