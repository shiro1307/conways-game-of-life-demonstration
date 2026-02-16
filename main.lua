local lui = require "lui"

local c = {}
local sx = 300
local sy = 100
local size = 20
local running = false
local f = 0

local ssx,ssy = love.graphics.getDimensions()

local cx=0
local cy=0

function clear(k)

    k = k or 0

    for y = 1,sy do

        c[y] = {}

        for x = 1,sx do

            c[y][x] = math.floor(math.random(0,k)/k)

        end

    end
end

clear()

local cir = {
    {1,0},
    {1,1},
    {0,1},
    {-1,1},
    {-1,0},
    {-1,-1},
    {0,-1},
    {1,-1}
}

function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

function check()

    local p = copy(c)

    for y = 1,sy do
    
        for x = 1,sx do

            local nei = 0

            for i,v in pairs(cir) do

                if c[y + v[2]] and c[y + v[2]][x + v[1]] and c[y + v[2]][x + v[1]] > 0 then

                    nei = nei + 1

                end

            end

            if nei < 2 then
                p[y][x] = 0
            elseif nei > 3 then
                p[y][x] = 0
            elseif nei == 3 and nei == 2 then
                p[y][x] = c[y][x]
            elseif nei == 3 then
                p[y][x] = 1
            end
    
        end
    
    end

    c = p

end

function drawgrid()

    love.graphics.rectangle( 'line' , -cx + size , -cy + size , sx*size, sy*size )

    for y = 1,sy do

        for x = 1,sx do
    
            if c[y][x] > 0 then

                love.graphics.rectangle( 'fill' , x*size - cx  , y*size - cy , size, size )

            end
    
        end
    
    end

end

local toggle = lui.button("toggle")
local stp = lui.button("step")
local clr = lui.button("clear")
local ra = lui.button("spawn")
function t() running = not running end
function r() clear(5) end

ra.onclick = r
toggle.onclick = t
stp.onclick = check
clr.onclick = clear

local speed = lui.slider(40)
speed.step = 1

local interval = 10

local ve = lui.vert({toggle,speed,stp,clr,ra})

function love.wheelmoved(x, y)
    size = size + 2*y
end

function love.mousemoved( x, y, dx, dy, istouch )
    if love.mouse.isDown(3) then
        cx = cx - dx
        cy = cy - dy
    end
end

function love.draw()

    toggle.text = "running: " .. (running and "true" or "false")

    local mx,my = love.mouse.getPosition()
    
    local xx = math.ceil((mx+cx-size)/size)
    local yy = math.ceil((my+cy-size)/size)

    if c[yy] and c[yy][xx] then

        love.graphics.rectangle( 'line' , xx*size -cx , yy*size -cy, size, size )

        if love.mouse.isDown(1) then
            c[yy][xx] = 1
        end
        if love.mouse.isDown(2) then
            c[yy][xx] = 0
        end
    end

    interval = math.ceil(100/speed.val)

    if running and math.ceil(f/interval)*interval - f == 0 then
        check()
    end

    f = f + 1

    drawgrid()

    lui.draw(ve)

end