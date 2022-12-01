Enemy = Class{}
require 'Player'

function Enemy:init(numZombies) 
    self.image = love.graphics.newImage('assets/ZombieSprite.png')
    self.rightImage = love.graphics.newImage('assets/ZombieSpriteRight.png')
    self.leftImage = love.graphics.newImage('assets/ZombieSpriteLeft.png')
    
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    math.randomseed(os.clock())
    tempX = math.random(0,1)
    
    if tempX == 0 then
        self.y = WINDOW_HEIGHT - self.height

    else
        self.y = 5
        
    end
    
    self.x = math.random(5, WINDOW_WIDTH - self.width)

    --print('Zombie initialized at ' .. self.x .. ', ' .. self.y)

end

function Enemy:move(player, dt)
    if self.y > player.y then
        self.y = self.y + -ENEMY_SPEED * dt
    else
        self.y = self.y + ENEMY_SPEED * dt
    end
    
    if self.x > player.x then
        self.x = self.x + -ENEMY_SPEED * dt
        self.image = self.leftImage
    else
        self.x = self.x + ENEMY_SPEED * dt
        self.image = self.rightImage
    end
end

function Enemy:render()
    love.graphics.draw(self.image, self.x, self.y)
end 

function Enemy:splat()
    self.image = love.graphics.newImage('assets/BloodSplat.png')
end

