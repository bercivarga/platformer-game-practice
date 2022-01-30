function love.load()
	wf = require('libraries.windfield.windfield')
	world = wf.newWorld(0, 500, false)

	world:addCollisionClass('Player')
	world:addCollisionClass('Platform')
	world:addCollisionClass('Danger')

	world:setQueryDebugDrawing(true)

	player = world:newRectangleCollider(360, 100, 80, 80, {collision_class = "Player"})
	player.speed = 240
	player.maxJumps = 2
	player.jumpsLeft = 2

	player:setFixedRotation(true)

	platform = world:newRectangleCollider(250, 400, 300, 100, {collision_class = "Platform"})
	platform:setType('static')

	dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
	dangerZone:setType('static')
end

function love.update(dt)
	world:update(dt)

	if player.body then
		local px = player:getPosition()

		if love.keyboard.isDown('d') then
			player:setX(px + player.speed * dt)
		end

		if love.keyboard.isDown('a') then
			player:setX(px - player.speed * dt)
		end

		if player:enter('Danger') then
			player:destroy()
		end
	end
end

function love.draw()
	world:draw()
end

function love.keypressed(key)
	if key == 'space' or key == 'w' then
		local colliders = world:queryRectangleArea(player:getX() - 40, player:getY() + 40, 80, 2, {'Platform'})

		if #colliders > 0 then
			player:applyLinearImpulse(0, -5000)
			player.jumpsLeft = player.maxJumps
		else
			player.jumpsLeft = player.jumpsLeft - 1
			if player.jumpsLeft > 0 then
				player:applyLinearImpulse(0, -5000)
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

