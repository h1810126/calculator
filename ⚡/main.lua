print("⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡ Draw Speed Test ⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡")

local window = platform.window
local window_width = window:width()
local window_height = window:height()

-- some math lib

local math = math

local sqrt = math.sqrt

local floor = math.floor
local ceil = math.ceil

local abs = math.abs

local max = math.max
local min = math.min

local sin = math.sin
local cos = math.cos

local pi = math.pi

local round = function(n)
    return floor(n + 0.5)
end
    
local bound = function(minimum, maximum, value)
    return max(minimum, min(maximum, value))
end


local function rad_to_deg(angle)
    return angle / pi * 180
end

local function deg_to_rad(angle)
    return angle / 180 * pi
end

local function round_dp(num, dp)
    local dp = dp or 0
    local mult = 10 ^ dp
    return math.floor(num * mult + 0.5) / mult
end

local function log(num)
    return math.log(num) / math.log(10)
end

local suffixes = {
    "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"
}

local function number_to_string(n, sf)

    if n <= 0 then
        return n
    end
    
    local sf = sf or 3
    
    local len = ceil(log(n + 1))
    local i = floor( (len - 1) / 3 ) + 1
    
    local dp = sf - (len - (i - 1) * 3)
    
    return round_dp(n / (1000 ^ (i - 1)), dp) .. suffixes[i]
    
end
    
local function hex_to_rgb(hex)
    local hex = hex:gsub("#","")
    if hex:len() == 3 then
        return {
            (tonumber("0x"..hex:sub(1,1))*17),
            (tonumber("0x"..hex:sub(2,2))*17),
            (tonumber("0x"..hex:sub(3,3))*17)
        }
    else
        return {
            tonumber("0x"..hex:sub(1,2)),
            tonumber("0x"..hex:sub(3,4)),
            tonumber("0x"..hex:sub(5,6))
        }
    end
end

-- part of random lib

local random = { }

random.random = math.random

random.randint = function(a, b)
    local a = floor(a)
    if b ~= nil then
        local b = floor(b)
    end
    
    return random.random(a, b)
end

random.rand = function(a, b)
    if b ~= nil then
        local b = floor(a)
        local a = 0
    end
    
    local range = b - a
    
    return a + range * random.random()
end

random.randreal = random.rand

-- @table library

-- deep copy table using recursion
local function deep_copy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deep_copy(orig_key)] = deep_copy(orig_value)
        end
        setmetatable(copy, deep_copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function better_deep_copy(obj, seen)
    if type(obj) ~= 'table' then
        return obj 
    end
    if seen and seen[obj] then
        return seen[obj] 
    end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do 
        res[better_deep_copy(k, s)] = better_deep_copy(v, s) 
    end
    return res
end

local function fast_copy(o)
    -- not a table
    if type(o) ~= 'table' then
        return o
    end

    -- copy it then
    local copy = {}
    for o_key, o_value in next, o, nil do
        copy[o_key] = fast_copy(o_value)
    end
    return copy
end

function table.to_string(tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
        local sb = {}
        for key, value in pairs (tt) do
            table.insert(sb, string.rep (" ", indent)) -- indent it
            if type (value) == "table" and not done [value] then
                done [value] = true
                table.insert(sb, key .. " = {\n");
                table.insert(sb, table.to_string (value, indent + 2, done))
                table.insert(sb, string.rep (" ", indent)) -- indent it
                table.insert(sb, "}\n");
            elseif "number" == type(key) then
                table.insert(sb, string.format("\"%s\"\n", tostring(value)))
            else
                table.insert(sb, string.format(
                    "%s = \"%s\"\n", tostring (key), tostring(value)))
            end
        end
        return table.concat(sb)
    else
        return tt .. "\n"
    end
end

function table.print(t)
    print(table.to_string(t))
end

-- @color

local color = {
    black = "#000000",
    white = "#FFFFFF",
}

for key, value in pairs(color) do
    if type(value) == "string" then
        color[key] = hex_to_rgb(value)
    elseif value[1] < 1 and value[2] < 1 and value[3] < 1 then
        color[key] = { value[1] * 255, value[2] * 255, value[3] * 255 }
    end
end

function color.grayscale(g)
    if color.darkmode then
        g = 1 - g
    end
    return { g * 255, g * 255, g * 255 }
end

------------------------------------------------------------------------------------------- @gc library -------------------------------------------------------------------------------------------

-- stores number of things drawn on screen
local _context = {

    color = 0,
    font = 0,

    draw = {
        rect = 0,
        circle = 0,
        polygon = 0,
        string = 0,
    },
    
    fill = {
        rect = 0,
        circle = 0,
        polygon = 0,
    },
    
    mix = {
        value = 0,
        color = {},
    }
}

local default_context = deep_copy(_context)

local function clip_rect(gc, x, y, w, h)
    gc:clipRect("set", x, y, w, h)
end

local function clip_reset(gc)
    gc:clipRect("reset")
end
    
local function clip_ignore(gc)
    gc:clipRect("null")
end

-- color functions

local function get_color(c)

    if c == nil then
        error("nil color in get_color!")
        return
    end
    
    if type(c) == "string" then
        if color[c] == nil then
            error("No such color: " .. c)
        end
        c = color[c]
    end
    
    return { c[1] / 255, c[2] / 255, c[3] / 255 }
    
end

local function check_color(r, g, b)

    if r < 0 or g < 0 or b < 0 or r > 255 or g > 255 or b > 255 then
        error("error in color: r=" .. r .. ", g=" .. g .. ", b=" .. b)
    end
    
end


local function hsl_to_rgb(h, s, l)
    if s == 0 then return l, l, l end
    local function to(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < .16667 then return p + (q - p) * 6 * t end
        if t < .5 then return q end
        if t < .66667 then return p + (q - p) * (.66667 - t) * 6 end
        return p
    end
    local q = l < .5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    return to(p, q, h + .33334), to(p, q, h), to(p, q, h - .33334)
end

local function rgb_to_hsl(r, g, b)
    local Xmax, Xmin = math.max(r, g, b), math.min(r, g, b)
    local V = Xmax
    local L = (Xmax + Xmin) / 2
    local C = Xmax - Xmin
    if max == min then return 0, 0, L end
    local S, H
    S = (V - L) / min(L, 1 - L)
    if Xmax == r then H = (g - b) / C + (g < b and 6 or 0)
    elseif Xmax == g then H = (b - r) / C + 2
    elseif Xmax == b then H = (r - g) / C + 4
    end
    return H * .16667, S, L
end

local function check_rgb_to_hsl()
    local correct = true
    for i=1, 5 do
        local a, b, c = random.random(), random.random(), random.random()
        local d, e, f = hsl_to_rgb(rgb_to_hsl(a, b, c))
        if not (abs(a - d) < 0.01 and abs(b - e) < 0.01 and abs(c - f) < 0.01) then
            print(a, b, c, d, e, f)
            correct = false
        end
    end
    return correct
end

if check_rgb_to_hsl() then
    print("[TEST] RGB-HSL conversion accurate!")
else
    print("[TEST] RGB-HSL conversion failed!")
end

local function reset_global_mix(gc)
    
    _context.mix.color = nil
    _context.mix.value = 0
    
end

local function set_global_mix(gc, color, mix_value)
    
    _context.mix.color = get_color(color)
    _context.mix.value = mix_value
    
end

local function set_global_black(gc, amount)
    set_global_mix(gc, {0, 0, 0}, amount)
end
    
local function set_global_white(gc, amount)
    set_global_mix(gc, {1, 1, 1}, amount)
end
    
local function set_color_base(gc, r, g, b)
    
    if _context.mix.value > 0 then
        local t = get_color_mix(gc, {r / 255, g / 255, b / 255}, _context.mix.color, _context.mix.value)
        r, g, b = t[1] * 255, t[2] * 255, t[3] * 255
        check_color(r, g, b)
    end
    
    gc:setColorRGB(r, g, b)
    
    _context.color = _context.color + 1
    
end

local function set_color_rgb(gc, color)
    
    local table = get_color(color)
    
    local r, g, b = table[1], table[2], table[3]
    
    set_color_base(gc, r, g, b)
end

local function set_color(gc, color_string)
    if color_string == nil then
        return
    end
    
    local table = get_color(color_string)
        
    if table == nil then
        error(color_string .. " is not a defined color!")
    end
    
    local r, g, b = table[1], table[2], table[3]
    r, g, b = r * 255, g * 255, b * 255
    set_color_base(gc, r, g, b)
end

function get_color_mix(gc, color_string, mix, amount)
    
    local table = get_color(color_string)
    local mix = get_color(mix)
    
    if table == nil then
        error(color_string .. " is not a defined color!")
    end
    
    local r, g, b = table[1], table[2], table[3]
    local r2, g2, b2 = mix[1], mix[2], mix[3]
    r = r * (1 - amount) + r2 * amount
    g = g * (1 - amount) + g2 * amount
    b = b * (1 - amount) + b2 * amount
    
    if r < 0 or g < 0 or b < 0 then
        error("error in set_color_mix: r=" .. r .. ", g=" .. g .. ", b=" .. b)
    end
    
    return { r, g, b }
end

local function set_color_mix(gc, color_string, mix, amount)
    
    local t = get_color_mix(gc, color_string, mix, amount)
    r, g, b = t[1] * 255, t[2] * 255, t[3] * 255
    
    set_color_base(gc, r, g, b, false)
    
end

local function set_color_mix_real(gc, color_string, mix, amount)
    local table = get_color(color_string)
    local mix = get_color(mix)
    
    if table == nil then
        error(color_string .. " is not a defined color!")
    end
    
    local h, s, l = rgb_to_hsl(table[1], table[2], table[3])
    local h2, s2, l2 = rgb_to_hsl(mix[1], mix[2], mix[3])
    h = h * (1 - amount) + h2 * amount
    s = s * (1 - amount) + s2 * amount
    l = l * (1 - amount) + l2 * amount
    r, g, b = hsl_to_rgb(h, s, l)
    r, g, b = r * 255, g * 255, b * 255
    
    if r < 0 or g < 0 or b < 0 then
        error("error in set_color_mix_real: r=" .. r .. ", g=" .. g .. ", b=" .. b)
    end
    
    set_color_base(gc, r, g, b)
end

local function set_color_black(gc, color_string, amount)
    if amount < 0 then
        set_color_white(gc, color_string, -amount)
    end
    set_color_mix(gc, color_string, {0, 0, 0}, amount)
end

local function set_color_white(gc, color_string, amount)
    if amount < 0 then
        set_color_black(gc, color_string, -amount)
    end
    set_color_mix(gc, color_string, {255, 255, 255}, amount)
end
        
local function set_color_dark(gc, color_string, amount)
    if amount < 0 then
        set_color_bright(gc, color_string, -amount)
    end
    set_color_mix_real(gc, color_string, {0, 0, 0}, amount)
end
    
local function set_color_bright(gc, color_string, amount)
    if amount < 0 then
        set_color_dark(gc, color_string, -amount)
    end
    set_color_mix_real(gc, color_string, {1, 1, 1}, amount)
end

local function draw_image(gc, image_string, x, y, w, h)
    if w == nil and h == nil then
        gc:drawImage(images[image_string], x, y)
    else
        gc:drawImage(image.copy(explore_images[image_string], w, h), x, y)
    end
end

local function draw_rect(gc, x, y, w, h, color)
    -- optimisation checks
    if x > window_width or y > window_height then
        return
    end
    if x + w < 0 or y + h < 0 then
        return
    end
            
    local w = round(w)
    local h = round(h)
    
    if w < 0 or h < 0 then
        error("invalid width (" .. w .. ") or height (" .. h .. ")")
    end
    
    set_color(gc, color)

    gc:drawRect(x, y, w, h)
    
    _context.draw.rect = _context.draw.rect + 1
end

local function fill_rect(gc, x, y, w, h, color1, color2)
    -- optimisation checks
    if x > window_width or y > window_height then
        return
    end
    if x + w < 0 or y + h < 0 then
        return
    end
    
    local x = round(x)
    local y = round(y)
    local w = round(w)
    local h = round(h)
    
    if w < 0 or h < 0 then
        error("invalid width (" .. w .. ") or height (" .. h .. ")")
    end
    
    set_color(gc, color1)
    
    gc:fillRect(x, y, w, h)
    
    _context.fill.rect = _context.fill.rect + 1
    
    if color2 ~= nil then
        draw_rect(gc, x, y, w, h, color2)
    end
end

local function draw_rect_size(gc, x, y, w, h, ratio_size, color)

    local inner_x = w * (1 - ratio_size)
    local inner_y = h * (1 - ratio_size)
    
    draw_rect(gc, x + inner_x / 2, y + inner_y / 2, w - inner_x, h - inner_y, color)
    
end

local function fill_rect_size(gc, x, y, w, h, ratio_size, color1, color2)

    local inner_x = w * (1 - ratio_size)
    local inner_y = h * (1 - ratio_size)
    
    fill_rect(gc, x + inner_x / 2, y + inner_y / 2, w - inner_x, h - inner_y, color1, color2)
    
end

-- paint the screen!
local function draw_screen(gc, color)
    set_color(gc, color)
    fill_rect(gc, 0, 0, window_width, window_height)
end

-- draw a border!
local function draw_border(gc, size, color)
    -- set the color of the border
    set_color(gc, color)
    fill_rect(gc, 0, 0, window_width, size)
    fill_rect(gc, 0, 0, size, window_height)
    fill_rect(gc, window_width - size, 0, size, window_height)
    fill_rect(gc, 0, window_height - size, window_width, size)
end

local function draw_circle(gc, radius, centre_x, centre_y, color)
    set_color(gc, color)
    
    gc:drawArc(centre_x - radius, centre_y - radius, radius * 2, radius * 2, 0, 360)
    
    _context.draw.circle = _context.draw.circle + 1
end
        
local function fill_circle(gc, radius, centre_x, centre_y, color1, color2)
    set_color(gc, color1)
    
    gc:fillArc(centre_x - radius, centre_y - radius, radius * 2, radius * 2, 0, 360)
    
    if color2 ~= nil then
        draw_circle(gc, radius, centre_x, centre_y, color2)
    end
    
    _context.fill.circle = _context.fill.circle + 1
end
    
local function draw_polyline(gc, t, color, ox, oy)
    set_color(gc, color)

    -- the polyline should be closed
    --t[#t + 1] = t[1]
    --t[#t + 1] = t[2]
    
    if ox ~= nil or oy ~= nil then
        t = deep_copy(t)
        local xy = { [0] = oy or 0, [1] = ox or 0 }
        for i = 1, #t do
            t[i] = t[i] + xy[i % 2]
        end
    end

    gc:drawPolyLine(t)
    
    _context.draw.polygon = _context.draw.polygon + 1
end

local function fill_polyline(gc, t, color1, color2)
    set_color(gc, color1)
    
    gc:fillPolygon(t)
    
    _context.fill.polygon = _context.fill.polygon + 1
    
    if color2 ~= nil then
        draw_polyline(gc, t, color2)
    end
end

local function get_shape(gc, shape, radius, centre_x, centre_y, angle)
    
    local new_shape = {}
    for i=1, #shape / 2 do
        local x = shape[i * 2 - 1]
        local y = shape[i * 2]
        local s = sin(angle)
        local c = cos(angle)
        new_shape[i * 2 - 1] = (x * c - y * s) * radius + centre_x
        new_shape[i * 2]     = (x * s + y * c) * radius + centre_y
    end
    return new_shape
    
end

local function draw_shape(gc, shape, radius, centre_x, centre_y, angle, color)

    local t = get_shape(gc, shape, radius, centre_x, centre_y, angle)

    draw_polyline(gc, t, color)
    
end

local function fill_shape(gc, shape, radius, centre_x, centre_y, angle, color1, color2)
    
    local t = get_shape(gc, shape, radius, centre_x, centre_y, angle)

    fill_polyline(gc, t, color1, color2)
    
end

local function rectangle_to_shape(x, y, w, h)
    return { x, y, x + w, y, x + w, y + h, x, y + h }
end

-- used for draw_polygon and fill_polygon
local function get_polygon(gc, sides, radius, centre_x, centre_y, angle)
    -- angle is 0 by default
    local angle = deg_to_rad(angle) or 0

    -- the table to pass to the gc polygon functions
    local polygon_table = {}

    for n=1, sides do
        local x = radius * cos(2*pi * n / sides + angle) + centre_x
        local y = radius * sin(2*pi * n / sides + angle) + centre_y
        
        polygon_table[2 * n - 1] = ceil(x)
        polygon_table[2 * n] = ceil(y)
    end

    return polygon_table
end

local function draw_polygon(gc, sides, radius, centre_x, centre_y, angle, color)
    
    local t = get_polygon(gc, sides, radius, centre_x, centre_y, angle)

    draw_polyline(gc, t, color)
    
end

local function fill_polygon(gc, sides, radius, centre_x, centre_y, angle, color1, color2)
    
    local t = get_polygon(gc, sides, radius, centre_x, centre_y, angle)
    
    fill_polyline(gc, t, color1, color2)
    
end

local function set_font(gc, size, style, family)
    local family = family or "sansserif"
    local style = style or "r"
    local size = size or 12
    
    gc:setFont(family, style, bound(6, 255, size))
    
    _context.font = _context.font + 1
end

-- draw string (alignment) functions

local draw_string, draw_string_plop, draw_string_plop_both, draw_string_plop_left, draw_string_plop_right

function draw_string(gc, string, x, y, color, align)
    -- optimisation checks
    if x > window_width or y > window_height or string == nil then
        return
    end
    
    if align == nil or align == "" then
    
    elseif align == "centre" or align == "center" then
        draw_string_plop_both(gc, string, x, y, color)
        return
    elseif align == "left" then
        draw_string_plop_left(gc, string, x, y, color)
        return
    elseif align == "right" then
        draw_string_plop_right(gc, string, x, y, color)
        return
    else
        
    end
    
    if type(string) == "number" then
        string = number_to_string(string)
    end
    
    set_color(gc, color)
    
    gc:drawString(string, x, y)
    
    _context.draw.string = _context.draw.string + 1
end

function draw_string_plop(gc, string, x, y, color)
    if type(string) == "number" then
        string = number_to_string(string)
    end
    
    set_color(gc, color)
    
    draw_string(gc, string, x - gc:getStringWidth(string) / 2, y)
    
    _context.draw.string = _context.draw.string + 1
end

function draw_string_plop_both(gc, string, x, y, color)    
    if type(string) == "number" then
        string = number_to_string(string)
    end
    
    set_color(gc, color)
    
    draw_string(gc, string, x - gc:getStringWidth(string) / 2, y - gc:getStringHeight(string) / 2)
    
    _context.draw.string = _context.draw.string + 1
end
    
function draw_string_plop_left(gc, string, x, y, color)
    -- optimisation checks
    if x > window_width or y > window_height then
        return
    end
    
    if type(string) == "number" then
        string = number_to_string(string)
    end
    
    set_color(gc, color)
    
    draw_string(gc, string, x, y - gc:getStringHeight(string) / 2)
    
    _context.draw.string = _context.draw.string + 1
end

function draw_string_plop_right(gc, string, x, y, color)
    -- optimisation checks
    if x > window_width or y > window_height then
        return
    end
    
    if type(string) == "number" then
        string = number_to_string(string)
    end
    
    set_color(gc, color)
    
    draw_string(gc, string, x - gc:getStringWidth(string), y - gc:getStringHeight(string) / 2)
    
    _context.draw.string = _context.draw.string + 1
end

local function draw_string_left(gc, string, y, color)
    local x = 0
    draw_string(gc, string, x, y, color)
end

local function draw_string_middle(gc, string, y, color)
    
    if type(string) == "number" then
        string = number_to_string(string)
    end
    
    local x = (window_width - gc:getStringWidth(string)) / 2
    draw_string(gc, string, x, y, color)
end

local function draw_string_right(gc, string, y, color)
    
    if type(string) == "number" then
        string = number_to_string(string)
    end
    
    local x = window_width - gc:getStringWidth(string)
    draw_string(gc, string, x, y, color)
    
end

local function draw_string_top(gc, string, x, color)
    local y = 0
    draw_string(gc, string, x, y, color)
end

local function draw_string_center(gc, string, x, color)
    local y = (window_height - gc:getStringHeight(string)) / 2
    draw_string(gc, string, x, y, color)
end

local function draw_string_bottom(gc, string, x, color)
    local y = window_height - gc:getStringHeight(string)
    draw_string(gc, string, x, y, color)
end

local function draw_string_dump(gc, string, color)

    if type(string) == "number" then
        string = number_to_string(string)
    end
    
    local x = (window_width - gc:getStringWidth(string)) / 2
    local y = (window_height - gc:getStringHeight(string)) / 2
    draw_string(gc, string, x, y, color)
    
end

-- key redirects

function on.enterKey()
    on.charIn("enter")
end

function on.escapeKey()
    on.charIn("esc")
end
    
function on.tabKey()
    on.charIn("tab")
end
        
function on.returnKey()
    on.charIn("return")
end
            
function on.backspaceKey()
    on.charIn("del")
end
                
function on.clearKey()
    on.charIn("clear")
end
                
function on.deleteKey()
    on.charIn("backspace")
end

function on.arrowDown()
    on.charIn("down")
end

function on.arrowUp()
    on.charIn("up")
end

function on.arrowLeft()
    on.charIn("left")
end

function on.arrowRight()
    on.charIn("right")
end

-- load images

local images = { }
local image_names = {
    "1", "2"
}
local image_error = ""

local function load_images()
    for key, name in pairs(image_names) do
        image_error = "Image " .. name .. " (#" .. key .. ") is missing!"
        images[name] = image.new(_R.IMG[name])
    end
end

if pcall(load_images) then
    print("[ test ] Images working!")
else
    error("[ test ] Images not working!\nError: " .. image_error)
end

-- load pixels

local pixels = {
    ["1"] = {
        "  0  ",
        " 00  ",
        "  0  ",
        "  0  ",
        "  0  ",
        "  0  ",
        "  0  ",
        "  0  ",
        " 000 ",
    },
    ["2"] = {
        " 000 ",
        "0   0",
        "0   0",
        "    0",
        "   0 ",
        "  0  ",
        " 0   ",
        "0    ",
        "00000",
    },
}

-- load lines

local lines = {
    ["1"] = {
        { 2, 2,    3, 1,    3, 8 },
        { 2, 9,    4, 9 },
    },
    ["2"] = {
        { 1, 3,    1, 2 },
        { 2, 1,    4, 1 },
        { 5, 2,    5, 4,    1, 7 },
        { 1, 8,    5, 8 },
    },
}

-- main test functions

local test = 1
local tests = { "1", "2", }
local init_num = 3
local num = init_num
local nums = { 1, 5, 10, 25, 50, 100, 150, 200, 300, 400, 500, 750, 1000, 1250, 1500, 2000, 3000, 4000, 5000, 7500, 10000, 12500, 15000, 20000, 30000, 40000, 50000 }
local mode = 1
local modes = { "none", "image", "pixel", "pixel2", "lines" }
local mode_names = { "None", "Image", "Rectangle", "Circle", "Polyline" }
local ax = 0
local ay = 0
local total_time = 0
local old_time = 0
local new_time = 0
local ticks = 0
local topbar_height = 20
local bottombar_height = 20

local function reset_time()
    total_time = 0
    ticks = 0
end

local function reset_mode()
    num = init_num
    reset_time()
end

local function paint_overlay(gc)
    local disp_mode = mode_names[mode]
    local disp_time = tostring(new_time - old_time) .. " ms"
    local disp_num = "n=" .. tostring(nums[num])
    local y = 8
    fill_rect(gc, 0, 0, window_width, topbar_height, "black")
    set_font(gc, 10)
    draw_string(gc, disp_mode, 8, y, "white", "left")
    draw_string(gc, disp_time, window_width / 2, y, "white", "centre")
    draw_string(gc, disp_num, window_width - 8, y, "white", "right")
    local avg_time = round(total_time / ticks)
    local time_per_draw = round(total_time / ticks / nums[num] * 1000)
    y = window_height - 11
    fill_rect(gc, 0, window_height - bottombar_height, window_width, bottombar_height, "black")
    draw_string(gc, "Average:", 8, y, "white", "left")
    draw_string(gc, avg_time .. " ms", window_width / 2, y, "white", "centre")
    draw_string(gc, time_per_draw .. " µs/draw", window_width - 8, y, "white", "right")
end

local function randomise_xy()
    ax = random.randint(0, window_width)
    ay = random.randint(topbar_height, window_height - bottombar_height - 1)
end

function on.paint(gc)
    local m = modes[mode]
    local t = tests[test]
    local n = nums[num]
    old_time = timer.getMilliSecCounter()
    if m == "none" or m == nil or m == "" then
        -- do nothing
    elseif m == "image" then
        for i = 1, n do
            randomise_xy()
            gc:drawImage(images[t], ax, ay)
        end
    elseif m == "pixel" or m == "pixel2" then
        local f = nil
        local whiteblack = { "white", "black" }
        if m == "pixel" then
            f = function(p, x, y)
                draw_rect(gc, x, y, 0, 0, whiteblack[p])
            end
        elseif m == "pixel2" then
            f = function(p, x, y)
                draw_circle(gc, 0, x, y, whiteblack[p])
            end
        end
        for i = 1, n do
            randomise_xy()
            for y = 1, 9 do
                local line = pixels[t][y]
                for x = 1, 5 do
                    -- if true, 2, else 1
                    f((line:sub(x, x) ~= " ") and 2 or 1, ax + x, ay + y)
                end
            end
        end
    elseif m == "lines" then
        for i = 1, n do
            randomise_xy()
            fill_rect(gc, ax, ay, 5, 9, "white")
            local L = lines[t]
            for j = 1, #L do
                draw_polyline(gc, L[j], "black", ax, ay)
            end
        end
    end
    new_time = timer.getMilliSecCounter()
    ticks = ticks + 1
    total_time = total_time + new_time - old_time
    paint_overlay(gc)
end

function on.timer()
    window:invalidate()
end

function on.charIn(char)
    if char == "left" or char == "4" then
        mode = mode - 1
        reset_mode()
    elseif char == "right" or char == "6" then
        mode = mode + 1
        reset_mode()
    elseif char == "up" or char == "8" then
        test = test + 1
        reset_time()
    elseif char == "down" or char == "2" then
        test = test - 1
        reset_time()
    elseif char == "+" then
        num = num + 1
        reset_time()
    elseif char == "-" then
        num = num - 1
        reset_time()
    elseif char == "esc" or char == "q" then
        mode = 1
        reset_mode()
    end
    mode = (mode - 1) % #modes + 1
    test = (test - 1) % #tests + 1
    num = (num - 1) % #nums + 1
end

print("[  ok  ] Starting timer...")
timer.start(0.05)

print("⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡ Done! ⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡⚡\n")
