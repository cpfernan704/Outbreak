Player = Class{}

function Player:init()
    self.rightImage = love.graphics.newImage('assets/PlayerSprite.png')
    self.leftImage = love.graphics.newImage('assets/PlayerSpriteLeft.png')
    self.image = love.graphics.newImage('assets/PlayerSprite.png')

    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.x = WINDOW_WIDTH / 2 
    self.y = WINDOW_HEIGHT / 2 

    self.dy = 0
    self.dx = 0

    

end

function Player:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Player:drown(r,g,b)
    if math.abs(r - 0.15294117647059) < 0.0001 
        and math.abs(g - 0.8) < 0.0001 
        and math.abs(b - 0.87450980392157) < 0.0001 then
        
        return true
    end

    if self.x < 5 then
        self.x = 5
    end

    if self.y < 5 then
        self.y = 5
    end

    if self.y > WINDOW_HEIGHT - self.height - 5 then
        self.y = WINDOW_HEIGHT - self.height - 5
    end

    if self.x > WINDOW_WIDTH - self.width - 5 then
        self.x = WINDOW_WIDTH - self.width - 5
    end 
end

function Player:move(dt)
    if love.keyboard.isDown('w') then
        self.y = self.y + -CHARACTER_SPEED * dt
    end
    if love.keyboard.isDown('s') then
        self.y = self.y + CHARACTER_SPEED * dt
    end
    if love.keyboard.isDown('a') then
        self.x = self.x + -CHARACTER_SPEED * dt
        self.image = self.leftImage
    end
    if love.keyboard.isDown('d') then
        self.x = self.x + CHARACTER_SPEED * dt
        self.image = self.rightImage
    end
end


function Player:render()
    love.graphics.draw(self.image, self.x, self.y)
end 

function Player:reset()
    self.x = WINDOW_WIDTH / 2 
    self.y = WINDOW_HEIGHT / 2
end

function Player:die(zombie)
    if (zombie.x + zombie.width/2) > self.x and (zombie.x + zombie.width/2) < self.x + self.width then
        if (zombie.y + zombie.height/2) > self.y and (zombie.y + zombie.height/2) < self.y + self.height then
            return true
        end
    end
end