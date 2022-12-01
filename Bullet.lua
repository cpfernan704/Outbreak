Bullet = Class{}
Weapon = Class{}
bullet = {}
bullet_speed = 200

image = love.graphics.newImage('assets/BulletLeft.png')
rightImage = love.graphics.newImage('assets/BulletLeft.png')
leftImage = love.graphics.newImage('assets/BulletRight.png')
upImage = love.graphics.newImage('assets/BulletUp.png')
downImage = love.graphics.newImage('assets/BulletDown.png')

function bullet.spawn(x, y, dir)
    table.insert(bullet, {x = x, y = y, dir = dir})
end

function bullet.draw()
    if bullet == {} then
        return
    end
    for i,v in ipairs(bullet) do
        --[[
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle('fill', v.x, v.y, 60, 20)
        --]]
        if v.dir == "right" then
            love.graphics.draw(leftImage, v.x, v.y)
        end
        
        if v.dir == "left" then
            love.graphics.draw(rightImage, v.x, v.y)
        end
        
        if v.dir == "up" then
            love.graphics.draw(upImage, v.x, v.y)
        end

        if v.dir == "down" then
            love.graphics.draw(downImage, v.x, v.y)
        end
        
    end
end

function bullet.update(dt)
    for i,v in ipairs(bullet) do
            
        if v.dir == "right" then
            v.x = v.x + bullet_speed * dt
        end
        
        if v.dir == 'left' then
            v.x = v.x - bullet_speed * dt
        end

        if v.dir == "up" then
            v.y = v.y - bullet_speed * dt
        end 

        if v.dir == "down" then
            v.y = v.y + bullet_speed * dt
        end


        if v.x < 5 or v.x > WINDOW_WIDTH - 5 then
            table.remove(bullet, i)
            --print("bullet despawned")
        end
        
    end
end

function bullet.shoot(key, player)
    if key == "right" then
        bullet.spawn(player.x + player.width, player.y + player.height / 2, 'right')
    end
    
    if key == "left" then
        bullet.spawn(player.x, player.y + player.height / 2, 'left')
    end

    if key == "up" then
        bullet.spawn(player.x + player.width / 2, player.y + player.height / 2, 'up')
    end 

    if key == "down" then
        bullet.spawn(player.x+ player.width / 2, player.y + player.height / 2, 'down')
    end
end

function bullet.hit(zombie)
    for i,v in ipairs(bullet) do
        if zombie ~= nil and v.x > zombie.x and v.x < zombie.x + zombie.width and
        v.y > zombie.y and v.y < zombie.y + zombie.height then
            table.remove(bullet, i)
            return true
        end
    end
end

function bullet.empty()
    
    bulletClone = bullet
    for i,v in ipairs(bulletClone) do
        table.remove (bullet, 1)
        
    end
    --[[
    thing = {}
    bullet = thing
    print (table.getn(bullet))
    --]]
end

function bullet.isEmpty()
    thing = {}
    return thing == bullet
end


