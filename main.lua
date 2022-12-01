-- main file of Outbreak
-- A game by Ethan Ramchandani and Chris Fernandes

Class = require 'class'
push = require 'push'

require 'Enemy'
require 'Player'
require 'Bullet'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

CHARACTER_SPEED = 200
ENEMY_SPEED = 100

local player = Player()
wave = 1

enemies = {}
splats = {}

math.randomseed(os.clock())

--populates table with given number of zombies
function createZombies(n)
    for i=1, n do
        
        table.insert(enemies, Enemy())
    end
end

createZombies(5*wave)

gameState = 'start'

function love.load()
    --font init
    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('font/font.ttf', 20)
    
    --background and other images init
    backgroundData1 = love.image.newImageData('maps/Map4.png')
    background1 = love.graphics.newImage(backgroundData1)
    backgroundData2 = love.image.newImageData('maps/Map5.png')
    background2 = love.graphics.newImage(backgroundData2)
    backgroundData3 = love.image.newImageData('maps/Map6.png')
    background3 = love.graphics.newImage(backgroundData3)
    backgroundData4 = love.image.newImageData('maps/Map7.png')
    background4 = love.graphics.newImage(backgroundData4)
    backgroundTable = {backgroundData1, backgroundData2, backgroundData3, backgroundData4}


    splat = love.graphics.newImage('assets/BloodSplat.png')

    beginningScreen = love.graphics.newImage('screens/StartScreen.png')

    love.window.setTitle('Outbreak')

    math.randomseed(os.clock())

    --sounds init and music loop
    sounds = {
        ['music'] = love.audio.newSource('sounds/ZombieScore.mp3', 'static'),
        ['zombiedie'] = love.audio.newSource('sounds/deadZombie.wav', 'static'),
        ['playerhit'] = love.audio.newSource('sounds/deadPlayer.wav', 'static'),
        ['betweenwaves'] = nil
    }

    sounds['music']:setLooping(true)
    sounds['music']:play()

    points = 0
    currentSecond = 0
    secondTimer = 0

    --screen setup
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true,
        canvas = false
    })    
end

function love.draw()  
    --draws the start screen
    if gameState == 'start' then        
        love.graphics.draw(beginningScreen, 0, 0)
        backgroundData = backgroundTable[math.random(#backgroundTable)]
        background = love.graphics.newImage(backgroundData)
        
    end

    --resets the game 
    if gameState == 'playagain' then 
        love.graphics.setColor(0,0,0,0)
        player:reset()
        wave = 1
        enemies = {}
        createZombies(wave*5)
        bullet.draw()
        backgroundData = backgroundTable[math.random(#backgroundTable)]
        background = love.graphics.newImage(backgroundData)
        
        gameState = 'play'
        
    end

    --draws players and enemies and bullets
    if gameState == 'play' or gameState == 'dead' then
        --draw map, players, zombies, bullets, wave, and splat
        --    background = backgroundTable[math.random(#backgroundTable)]
        love.graphics.draw(background, 0, 0)
        
        player:render()
        for num, zombie in ipairs(enemies) do
            zombie:render()
        end

        bullet.draw()
    

        displayWave()
        for i,v in pairs(splats) do
            love.graphics.draw(splat, v.x, v.y)
        end
        --displayRGB()

        --display death screen
        if gameState == 'dead' then
            deadScreen = love.graphics.newImage('screens/DeadScreen.png')
            love.graphics.draw(deadScreen)
            love.graphics.setColor(0.5, 0, 0, 1)
            bullet.empty()
            splats = {}
        end
        
    end

    if gameState == 'waveBreakBegin' then
        love.graphics.draw(background, 0, 0)
        player.x = WINDOW_WIDTH / 2
        player.y = WINDOW_HEIGHT / 2
        player:render()
        splats = {}
        bullet.empty()
        displayWave()
        displayTimer()
        
    end

    if gameState == 'newWave' then
        createZombies(wave*5)
        -- delete background
        math.randomseed(os.clock())
        backgroundData = backgroundTable[math.random(#backgroundTable)]
        print("picking new background")
        background = love.graphics.newImage(backgroundData)
        love.graphics.draw(background, 0, 0)
        player:render()
        splats = {}
        displayWave()
    end



end

function love.update(dt)
    
    if gameState == 'play' then
        --player update
        player:move(dt)

        --error checking and enemy update
        for i = 1, table.getn(enemies) do
            if enemies[i] == nil then
                print (i .. ' is nil')
            
            else
                enemies[i]:move(player, dt)
            end
        end
        
        --enemy collision with eachother
        for i = 1, table.getn(enemies) do
            for x = 1, table.getn(enemies) do
                if i ~= x then
                    collide(enemies[i], enemies[x])
                end
            end
        end
        

        r, g, b, a = backgroundData:getPixel(player.x + player.width/2, player.y + player.height/2)
        
        --collision with player and water
        if (player:drown(r,g,b)) then
            gameState = 'dead'
            sounds['playerhit']:play()
        end

        --collision with enemy and player
        for i = 1, table.getn(enemies) do
            if player:die(enemies[i]) then
                gameState = 'dead'
                sounds['playerhit']:play()
            end
        end


        --bullet update
        bullet.update(dt)

        enemiesCopy = {}

        --collision with enemy and bullet
        for i = 1, table.getn(enemies) do
            
            if not bullet.hit(enemies[i]) then
                table.insert(enemiesCopy, enemies[i])
            else
                --add a splat where the enemy died RIP
                table.insert(splats, {x=enemies[i].x, y=enemies[i].y})
                sounds['zombiedie']:play()
            end
        end
        enemies = enemiesCopy

        --display splats


        --new wave
        if table.getn(enemies) == 0 then
            splats = {}
            currentSecond = 0
            secondTimer = 0
            gameState = 'waveBreakBegin'
        end
    end

    if gameState == 'waveBreakBegin' then
        secondTimer = secondTimer + dt
        if secondTimer > 1 then
            currentSecond = currentSecond + 1
            secondTimer = secondTimer % 1
        end

        if currentSecond == 3 then
            gameState = "newWave"
        end
    end

    if gameState == 'newWave' then
        wave = wave + 1
        createZombies(wave*5)
        gameState = 'play'
    end
end

function love.keypressed(key)
    --quit the game
    if (key == 'escape') then
        love.event.quit()
    end
    
    --init bullet
    bullet.shoot(key, player)
    
    updateState(key)
end

--enemy collide function given two enemies
function collide(enemyA, enemyB)
    if enemyA.y == enemyB.y and enemyA.x == enemyB.x then
        enemyA.y = enemyA.y + enemyA.height
    end
end

--displays wave at the top of the screen
function displayWave()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 0, 0, 255/255)
    if gameState == 'waveBreakBegin' then
        love.graphics.print('Wave: ' .. tostring(wave) .. ' Complete!', WINDOW_WIDTH/2,5)
    else
        love.graphics.print('Wave: ' .. tostring(wave), WINDOW_WIDTH/2,5)
    end
    love.graphics.setColor(255, 255, 255, 255)
end

function displayTimer()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 0, 0, 255/255)
    love.graphics.print('Timer: ' .. tostring(currentSecond) .. ' seconds', WINDOW_WIDTH/2, 30)
    love.graphics.setColor(255, 255, 255, 255)
end


function displayRGB()
    
    -- simple RGB display 
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('RGB: ' .. tostring(r) .. ' ' .. tostring(g) .. ' ' .. tostring(b), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
    
end

function updateState(key)
    if key == 'return' and gameState == 'start' then
        gameState = 'play'
    end
    if key == 'return' and gameState == 'dead' then
        gameState = 'playagain'
    end
end

