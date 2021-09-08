print("------------------ Tetris ------------------")

-- @window

local window = platform.window
local window_width = window:width()
local window_height = window:height()

-- @math library

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

local sqr = function(n)
    return n ^ 2
end

local round = function(n)
    return floor(n + 0.5)
end

local bound = function(minimum, maximum, value)
    return max(minimum, min(maximum, value))
end

local random = { }

random.random = math.random

random.pureseed = math.randomseed

random.seed = function(seed)
    random.pureseed(seed)
    random.random()
    random.random()
    random.random()
end

random.randseed = function()
    random.seed(random.random())
end

random.randint = function(a, b)
    local a = floor(a)
    if b ~= nil then
        local b = floor(b)
    end
    
    return random.random(a, b)
end

random.randbool = function()
    return random.random() <= 0.5
end

random.rand = function(a, b)
    if b ~= nil then
        local b = floor(a)
        local a = 0
    end
    
    local range = b - a
    
    return a + range * random.random()
end

random.randpick = function(set)
    return set[random.randint(1, #set)]
end

random.shuffle = function(list)
    shuffled = {}
    for i, v in ipairs(list) do
        local pos = random.randint(1, #shuffled + 1)
        table.insert(shuffled, pos, v)
    end
    return shuffled
end

random.randreal = random.rand

random.random_angle = function()
    return random.rand(0, 2 * pi)
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

local function random_round(n)
    local real = floor(n)
    local remainder = n - real
    if random.random() < remainder then
        real = real + 1
    end
    return real
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

------------------------------------------------------------------------------------------- convenience functions -------------------------------------------------------------------------------------------

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function capitalise(s)

    s = s:sub(1, 1):upper() .. s:sub(2, #s)
    
    s = s:gsub("_%l", function(w)
        return " " .. w:sub(2, 2):upper()
    end)
    
    return s
    
end

local function smooth(oldvalue, newvalue, smoothness)
    return (oldvalue * smoothness + newvalue) / (smoothness + 1)
end

local function bounce(time, period)
    return abs(period - (time % (period * 2))) / period
end

local function safeloop(check_f, maxloops, do_f)
    local loop = 0
    local maxloops = maxloops
    while not check_f() do
        if do_f ~= nil then
            do_f()
        end
        loop = loop + 1
        if loop > maxloops then
            return false -- failure!
        end
    end
    return true -- success!
end

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

function table.remove_value(table1, value)
    for k, v in pairs(table1) do
        if v == value then
            table.remove(table1, k)
            break
        end
    end
end

-- serialization
local function serialize(o)
    local code = {}
    if type(o) == "number" then
        table.insert(code, o)
    elseif type(o) == "string" then
        table.insert(code, string.format("%q", o))
    elseif type(o) == "table" then
        table.insert(code, "{")
        for k,v in pairs(o) do
            table.insert(code, "[")
            table.insert(code, serialize(k))
            table.insert(code, "]=")
            table.insert(code, serialize(v))
            table.insert(code, ",")
        end
        table.insert(code, "}")
    else
        error("cannot serialize a " .. type(o))
        return nil
    end
    return table.concat(code)
end

local function deserialize(o)
    local f = loadstring("return " .. o)
    return f()
end

local function serialize_numbers(o)
    local code = {}
    if type(o) == "number" then
        table.insert(code, o)
    elseif type(o) == "string" then
        table.insert(code, string.format("%q", o))
    elseif type(o) == "table" then
        table.insert(code, "{")
        for i, v in ipairs(o) do
            table.insert(code, serialize_numbers(v))
            table.insert(code, ",")
        end
        table.insert(code, "}")
    else
        error("cannot serialize a " .. type(o))
        return nil
    end
    return table.concat(code)
end

-- iterate through table in sorted order (for towers)
local function sorted_pairs(t, order)
    -- collect the keys
    local keys = { }
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order == nil then
        table.sort(keys)
    else
        table.sort(keys, function(a,b) return order(t, a, b) end)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- @queue library

local function make_deque()
    -- Deque implementation by Pierre 'catwell' Chapuis
    -- MIT licensed
    
    local push_right = function(self, x)
        assert(x ~= nil)
        self.tail = self.tail + 1
        self[self.tail] = x
    end
    
    local push_left = function(self, x)
        assert(x ~= nil)
        self[self.head] = x
        self.head = self.head - 1
    end
    
    local peek_right = function(self)
        return self[self.tail]
    end
    
    local peek_left = function(self)
        return self[self.head+1]
    end
    
    local pop_right = function(self)
        if self:is_empty() then return nil end
        local r = self[self.tail]
        self[self.tail] = nil
        self.tail = self.tail - 1
        return r
    end
    
    local pop_left = function(self)
        if self:is_empty() then return nil end
        local r = self[self.head+1]
        self.head = self.head + 1
        local r = self[self.head]
        self[self.head] = nil
        return r
    end
    
    local rotate_right = function(self, n)
        n = n or 1
        if self:is_empty() then return nil end
        for i=1,n do self:push_left(self:pop_right()) end
    end
    
    local rotate_left = function(self, n)
        n = n or 1
        if self:is_empty() then return nil end
        for i=1,n do self:push_right(self:pop_left()) end
    end
    
    local _remove_at_internal = function(self, idx)
        for i=idx, self.tail do self[i] = self[i+1] end
        self.tail = self.tail - 1
    end
    
    local remove_right = function(self, x)
        for i=self.tail,self.head+1,-1 do
            if self[i] == x then
                _remove_at_internal(self, i)
                return true
            end
        end
        return false
    end
    
    local remove_left = function(self, x)
        for i=self.head+1,self.tail do
            if self[i] == x then
                _remove_at_internal(self, i)
                return true
            end
        end
        return false
    end
    
    local length = function(self)
        return self.tail - self.head
    end
    
    local is_empty = function(self)
        return self:length() == 0
    end
    
    local contents = function(self)
        local r = {}
        for i = self.head + 1, self.tail do
            r[i - self.head] = self[i]
        end
        return r
    end
    
    local get = function(self, i)
        return self[i + self.head]
    end
    
    local iter_right = function(self)
        local i = self.tail+1
        return function()
            if i > self.head+1 then
                i = i-1
                return self[i]
            end
        end
    end
    
    local iter_left = function(self)
        local i = self.head
        return function()
            if i < self.tail then
                i = i+1
                return self[i]
            end
        end
    end
    
    local methods = {
        push_right = push_right,
        push_left = push_left,
        peek_right = peek_right,
        peek_left = peek_left,
        pop_right = pop_right,
        pop_left = pop_left,
        rotate_right = rotate_right,
        rotate_left = rotate_left,
        remove_right = remove_right,
        remove_left = remove_left,
        iter_right = iter_right,
        iter_left = iter_left,
        length = length,
        is_empty = is_empty,
        contents = contents,
        get = get,
    }
    
    local new = function()
        local r = {head = 0, tail = 0}
        return setmetatable(r, {__index = methods})
    end
    
    return {
        new = new,
    }
end

local queue_lib = make_deque()
local make_queue = queue_lib.new

-- @image template

local image_names = {
    -- "name",
}

local images = {}

local function load_images()
    for key, name in pairs(image_names) do
        images[name] = image.new(_R.IMG[name])
    end
end

if pcall(load_images) then
    print("[TEST] Images working!")
else
    error("[TEST] Images not working!")
end

-- @color template

local color = {
    aliceblue = {0.94117647058824, 0.97254901960784, 1},
    antiquewhite = {0.98039215686275, 0.92156862745098, 0.84313725490196},
    aqua = {0, 1, 1},
    aquamarine = {0.49803921568627, 1, 0.83137254901961},
    azure = {0.94117647058824, 1, 1},
    beige = {0.96078431372549, 0.96078431372549, 0.86274509803922},
    bisque = {1, 0.89411764705882, 0.76862745098039},
    black = {0, 0, 0},
    blanchedalmond = {1, 0.92156862745098, 0.80392156862745},
    blue = {0, 0, 1},
    blueviolet = {0.54117647058824, 0.16862745098039, 0.88627450980392},
    brown = {0.64705882352941, 0.16470588235294, 0.16470588235294},
    burlywood = {0.87058823529412, 0.72156862745098, 0.52941176470588},
    cadetblue = {0.37254901960784, 0.61960784313725, 0.62745098039216},
    chartreuse = {0.49803921568627, 1, 0},
    chocolate = {0.82352941176471, 0.41176470588235, 0.11764705882353},
    coral = {1, 0.49803921568627, 0.31372549019608},
    cornflowerblue = {0.3921568627451, 0.5843137254902, 0.92941176470588},
    cornsilk = {1, 0.97254901960784, 0.86274509803922},
    crimson = {0.86274509803922, 0.07843137254902, 0.23529411764706},
    cyan = {0, 1, 1},
    darkblue = {0, 0, 0.54509803921569},
    darkcyan = {0, 0.54509803921569, 0.54509803921569},
    darkgoldenrod = {0.72156862745098, 0.52549019607843, 0.043137254901961},
    gray = {0.66274509803922, 0.66274509803922, 0.66274509803922},
    darkgreen = {0, 0.3921568627451, 0},
    grey = {0.66274509803922, 0.66274509803922, 0.66274509803922},
    darkkhaki = {0.74117647058824, 0.71764705882353, 0.41960784313725},
    darkmagenta = {0.54509803921569, 0, 0.54509803921569},
    darkolivegreen = {0.33333333333333, 0.41960784313725, 0.1843137254902},
    darkorange = {1, 0.54901960784314, 0},
    darkorchid = {0.6, 0.19607843137255, 0.8},
    darkred = {0.54509803921569, 0, 0},
    darksalmon = {0.91372549019608, 0.58823529411765, 0.47843137254902},
    darkseagreen = {0.56078431372549, 0.73725490196078, 0.56078431372549},
    darkslateblue = {0.28235294117647, 0.23921568627451, 0.54509803921569},
    darkslategray = {0.1843137254902, 0.30980392156863, 0.30980392156863},
    darkslategrey = {0.1843137254902, 0.30980392156863, 0.30980392156863},
    darkturquoise = {0, 0.8078431372549, 0.81960784313725},
    darkviolet = {0.58039215686275, 0, 0.82745098039216},
    deeppink = {1, 0.07843137254902, 0.57647058823529},
    deepskyblue = {0, 0.74901960784314, 1},
    dimgray = {0.41176470588235, 0.41176470588235, 0.41176470588235},
    dimgrey = {0.41176470588235, 0.41176470588235, 0.41176470588235},
    dodgerblue = {0.11764705882353, 0.56470588235294, 1},
    firebrick = {0.69803921568627, 0.13333333333333, 0.13333333333333},
    floralwhite = {1, 0.98039215686275, 0.94117647058824},
    forestgreen = {0.13333333333333, 0.54509803921569, 0.13333333333333},
    fuchsia = {1, 0, 1},
    gainsboro = {0.86274509803922, 0.86274509803922, 0.86274509803922},
    ghostwhite = {0.97254901960784, 0.97254901960784, 1},
    gold = {1, 0.84313725490196, 0},
    goldenrod = {0.85490196078431, 0.64705882352941, 0.12549019607843},
    darkgray = {0.50196078431373, 0.50196078431373, 0.50196078431373},
    green = {0, 0.50196078431373, 0},
    greenyellow = {0.67843137254902, 1, 0.1843137254902},
    darkgrey = {0.50196078431373, 0.50196078431373, 0.50196078431373},
    honeydew = {0.94117647058824, 1, 0.94117647058824},
    hotpink = {1, 0.41176470588235, 0.70588235294118},
    indianred = {0.80392156862745, 0.36078431372549, 0.36078431372549},
    indigo = {0.29411764705882, 0, 0.50980392156863},
    ivory = {1, 1, 0.94117647058824},
    khaki = {0.94117647058824, 0.90196078431373, 0.54901960784314},
    lavender = {0.90196078431373, 0.90196078431373, 0.98039215686275},
    lavenderblush = {1, 0.94117647058824, 0.96078431372549},
    lawngreen = {0.48627450980392, 0.98823529411765, 0},
    lemonchiffon = {1, 0.98039215686275, 0.80392156862745},
    lightblue = {0.67843137254902, 0.84705882352941, 0.90196078431373},
    lightcoral = {0.94117647058824, 0.50196078431373, 0.50196078431373},
    lightcyan = {0.87843137254902, 1, 1},
    lightgoldenrodyellow = {0.98039215686275, 0.98039215686275, 0.82352941176471},
    lightgray = {0.82745098039216, 0.82745098039216, 0.82745098039216},
    lightgreen = {0.56470588235294, 0.93333333333333, 0.56470588235294},
    lightgrey = {0.82745098039216, 0.82745098039216, 0.82745098039216},
    lightpink = {1, 0.71372549019608, 0.75686274509804},
    lightsalmon = {1, 0.62745098039216, 0.47843137254902},
    lightseagreen = {0.12549019607843, 0.69803921568627, 0.66666666666667},
    lightskyblue = {0.52941176470588, 0.8078431372549, 0.98039215686275},
    lightslategray = {0.46666666666667, 0.53333333333333, 0.6},
    lightslategrey = {0.46666666666667, 0.53333333333333, 0.6},
    lightsteelblue = {0.69019607843137, 0.76862745098039, 0.87058823529412},
    lightyellow = {1, 1, 0.87843137254902},
    lime = {0, 1, 0},
    limegreen = {0.19607843137255, 0.80392156862745, 0.19607843137255},
    linen = {0.98039215686275, 0.94117647058824, 0.90196078431373},
    magenta = {1, 0, 1},
    maroon = {0.50196078431373, 0, 0},
    mediumaquamarine = {0.4, 0.80392156862745, 0.66666666666667},
    mediumblue = {0, 0, 0.80392156862745},
    mediumorchid = {0.72941176470588, 0.33333333333333, 0.82745098039216},
    mediumpurple = {0.57647058823529, 0.43921568627451, 0.85882352941176},
    mediumseagreen = {0.23529411764706, 0.70196078431373, 0.44313725490196},
    mediumslateblue = {0.48235294117647, 0.4078431372549, 0.93333333333333},
    mediumspringgreen = {0, 0.98039215686275, 0.60392156862745},
    mediumturquoise = {0.28235294117647, 0.81960784313725, 0.8},
    mediumvioletred = {0.78039215686275, 0.082352941176471, 0.52156862745098},
    midnightblue = {0.098039215686275, 0.098039215686275, 0.43921568627451},
    mintcream = {0.96078431372549, 1, 0.98039215686275},
    mistyrose = {1, 0.89411764705882, 0.88235294117647},
    moccasin = {1, 0.89411764705882, 0.70980392156863},
    navajowhite = {1, 0.87058823529412, 0.67843137254902},
    navy = {0, 0, 0.50196078431373},
    oldlace = {0.9921568627451, 0.96078431372549, 0.90196078431373},
    olive = {0.50196078431373, 0.50196078431373, 0},
    olivedrab = {0.41960784313725, 0.55686274509804, 0.13725490196078},
    orange = {1, 0.64705882352941, 0},
    orangered = {1, 0.27058823529412, 0},
    orchid = {0.85490196078431, 0.43921568627451, 0.83921568627451},
    palegoldenrod = {0.93333333333333, 0.90980392156863, 0.66666666666667},
    palegreen = {0.59607843137255, 0.9843137254902, 0.59607843137255},
    paleturquoise = {0.68627450980392, 0.93333333333333, 0.93333333333333},
    palevioletred = {0.85882352941176, 0.43921568627451, 0.57647058823529},
    papayawhip = {1, 0.93725490196078, 0.83529411764706},
    peachpuff = {1, 0.85490196078431, 0.72549019607843},
    peru = {0.80392156862745, 0.52156862745098, 0.24705882352941},
    pink = {1, 0.75294117647059, 0.79607843137255},
    plum = {0.86666666666667, 0.62745098039216, 0.86666666666667},
    powderblue = {0.69019607843137, 0.87843137254902, 0.90196078431373},
    purple = {0.50196078431373, 0, 0.50196078431373},
    red = {1, 0, 0},
    rosybrown = {0.73725490196078, 0.56078431372549, 0.56078431372549},
    royalblue = {0.25490196078431, 0.41176470588235, 0.88235294117647},
    saddlebrown = {0.54509803921569, 0.27058823529412, 0.074509803921569},
    salmon = {0.98039215686275, 0.50196078431373, 0.44705882352941},
    sandybrown = {0.95686274509804, 0.64313725490196, 0.37647058823529},
    seagreen = {0.18039215686275, 0.54509803921569, 0.34117647058824},
    seashell = {1, 0.96078431372549, 0.93333333333333},
    sienna = {0.62745098039216, 0.32156862745098, 0.17647058823529},
    silver = {0.75294117647059, 0.75294117647059, 0.75294117647059},
    skyblue = {0.52941176470588, 0.8078431372549, 0.92156862745098},
    slateblue = {0.4156862745098, 0.35294117647059, 0.80392156862745},
    slategray = {0.43921568627451, 0.50196078431373, 0.56470588235294},
    slategrey = {0.43921568627451, 0.50196078431373, 0.56470588235294},
    snow = {1, 0.98039215686275, 0.98039215686275},
    springgreen = {0, 1, 0.49803921568627},
    steelblue = {0.27450980392157, 0.50980392156863, 0.70588235294118},
    tan = {0.82352941176471, 0.70588235294118, 0.54901960784314},
    teal = {0, 0.50196078431373, 0.50196078431373},
    thistle = {0.84705882352941, 0.74901960784314, 0.84705882352941},
    tomato = {1, 0.38823529411765, 0.27843137254902},
    turquoise = {0.25098039215686, 0.87843137254902, 0.8156862745098},
    violet = {0.93333333333333, 0.50980392156863, 0.93333333333333},
    wheat = {0.96078431372549, 0.87058823529412, 0.70196078431373},
    white = {1, 1, 1},
    whitesmoke = {0.96078431372549, 0.96078431372549, 0.96078431372549},
    yellow = {1, 1, 0},
    yellowgreen = {0.60392156862745, 0.80392156862745, 0.19607843137255}
}

for key, value in pairs(color) do
    color[key] = { value[1] * 255, value[2] * 255, value[3] * 255 }
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
    
local function draw_polyline(gc, t, color)
    set_color(gc, color)

    -- the polyline should be closed
    t[#t + 1] = t[1]
    t[#t + 1] = t[2]

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

local function draw_textbox(gc, x, y, w, h, text, color, font, align, bullet)

    set_color(gc, color)
    set_font(gc, font)
    
    local max_width = w
    local drawtext = nil
    local bullet = bullet or " "
    local old_y = y
    
    if align == "centre" or align == "center" then
        drawtext = function(s)
            draw_string_plop_both(gc, s, x + w / 2, y, color)
        end
    elseif align == nil or align == "" or align == "left" then
        drawtext = function(s)
            draw_string_plop_left(gc, s, x, y, color)
        end
    elseif align == "right" then
        drawtext = function(s)
            draw_string_plop_right(gc, s, x + w, y, color)
        end
    else
        drawtext = function(s)
            print(s)
        end
    end
    
    for key, text in pairs(text) do
        -- key must be a number
        if type(key) == "number" then
            if gc:getStringWidth(text) < max_width then
                -- draw the string safely!
                drawtext(text)
                --draw_string(gc, text, x, y, nil, align)
                y = y + font * 2
            else
                -- draw the string... er... in O(N * large constant) time 
                local text_left = {}
                for i in text:gmatch("%S+") do
                    table.insert(text_left, i)
                end
                
                local loops = 0
                while gc:getStringWidth(table.concat(text_left, " ")) >= max_width and loops < 10000 do
                    local text_done = {}
                    for k, i in ipairs(text_left) do
                        table.insert(text_done, i)
                    end
                    while gc:getStringWidth(table.concat(text_done, " ")) >= max_width and loops < 10000 do
                        table.remove(text_done, #text_done)
                        loops = loops + 1
                    end
                    text_left = {unpack(text_left, #text_done + 1, #text_left)}
                    drawtext(table.concat(text_done, " "))
                    y = y + font * 2
                end
                drawtext(table.concat(text_left, " "))
                y = y + font * 2
            end
        end
        
    end
    
    return y - old_y - font * 2
    
end

------------------------------------------------------------------------------------------- @key to direction functions -------------------------------------------------------------------------------------------
    
local function char_to_dir(char)
    if char == "8" or char == "up" then
        return "up"
    elseif char == "6"  or char == "right" then
        return "right"
    elseif char == "4"  or char == "left" then
        return "left"
    elseif char == "2"  or char == "down" then
        return "down"
    elseif char == "enter" then
        return "enter"
    else
        return "none"
    end
end

local function char_to_dirnum(char)
    if char == "up" then
        return "8"
    elseif char == "right" then
        return "6"
    elseif char == "left" then
        return "4"
    elseif char == "down" then
        return "2"
    elseif char == "enter" then
        return "enter"
    elseif ("123456789"):find(char) then
        return char
    else
        return none
    end
end

local function dir_to_xy(dir)
    local x, y = 0, 0
    if dir == "up" then
        y = -1
    elseif dir == "down" then
        y = 1
    elseif dir == "left" then
        x = -1
    elseif dir == "right" then
        x = 1
    end
    return x, y
end

local function dirnum_to_xy(dir)
    local x, y = 0, 0
    if dir == "8" then
        y = -1
    elseif dir == "2" then
        y = 1
    elseif dir == "4" then
        x = -1
    elseif dir == "6" then
        x = 1
    end
    return x, y
end

local function dirnum_to_xy_extended(dir)
    local x, y = 0, 0
    if dir == "8" then
        y = -1
    elseif dir == "2" then
        y = 1
    elseif dir == "4" then
        x = -1
    elseif dir == "6" then
        x = 1
    elseif dir == "7" then
        x = -1
        y = -1
    elseif dir == "9" then
        x = 1
        y = -1
    elseif dir == "1" then
        x = -1
        y = 1
    elseif dir == "3" then
        x = 1
        y = 1
    end
    return x, y
end

-- @handles

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

-- @globals

local main_menu = {}
local menu = {}
local play = {}
local play_end = {}
local settings = {}
local lb = {}
local lbs = {}
local replays = {}

local mode = "main_menu"
local modes = { main_menu = main_menu, menu = menu, play = play, play_end = play_end, settings = settings, lb = lb }


-- @handles #2

function on.paint(gc)
    _context = deep_copy(default_context)
    
    modes[mode].paint(gc)
end

function on.timer()
    modes[mode].timer()
end

function on.charIn(char)
    
    if char == "," then
        timer.stop()
        timer.start(0.05)
    end
    
    modes[mode].charIn(char)
    
    window:invalidate()
end


-- @tetris

local board = {}
local t = {
    tile_size = 10,
    board = {
        width = 10,
        height = 20,
        height_ex = 24,
        offset_x = 0,
        offset_y = 0,
    }
}

local block_storage = { -- BLOCKS

    -- the 7 tetrominoes
    normal = {
        mode = "normal",
        length = 7,
        offset = {0, 0, 0, 0, 0, 0, 1},
        multiplier = {1, 1, 1, 1, 1, 1, 1},
        letters = {"I", "L", "J", "Z", "S", "T", "O"},
        mirror = false,
        rep = 6,
        [1] = 
        { 0, 0, 0, 0,
          1, 1, 1, 1,
          0, 0, 0, 0,
          0, 0, 0, 0 }, -- I
        [2] = 
        { 0, 0, 1,
          1, 1, 1,
          0, 0, 0 },    -- L
        [3] =        
        { 1, 0, 0,
          1, 1, 1,
          0, 0, 0 },    -- J
        [4] =  
        { 1, 1, 0,
          0, 1, 1,
          0, 0, 0 },    -- Z
        [5] =       
        { 0, 1, 1,
          1, 1, 0,
          0, 0, 0 },    -- S
        [6] =  
        { 0, 1, 0,
          1, 1, 1,
          0, 0, 0, },   -- T
        [7] =  
        { 0, 0, 0, 0,
          0, 1, 1, 0,
          0, 1, 1, 0,
          0, 0, 0, 0 }, -- O
    },
    funny = {
        mode = "funny",
        length = 8,
        offset = {1, 0, 0, 0, 0, 0, 1, 4},
        multiplier = {1, 1, 1, 1, 1, 1, 1, 1},
        letters = {"I", "L", "J", "Z", "S", ".", "O", "_"},
        mirror = false,
        rep = 7,
        [1] = 
        { 0, 0, 0, 0,
          1, 1, 1, 1,
          1, 0, 0, 0,
          0, 0, 0, 0 }, -- I
        [2] = 
        { 0, 0, 0,
          1, 1, 1,
          0, 0, 0 },    -- L
        [3] =        
        { 0, 0, 0,
          1, 0, 1,
          0, 0, 0 },    -- J
        [4] =  
        { 0, 1, 0,
          0, 1, 1,
          0, 0, 0 },    -- Z
        [5] =       
        { 0, 1, 1,
          1, 1, 0,
          0, 1, 0 },    -- S
        [6] =  
        { 0, 1, 0,
          0, 0, 0,
          0, 0, 0, },   -- T
        [7] =  
        { 0, 0, 0, 0,
          0, 1, 1, 0,
          0, 1, 1, 0,
          1, 0, 0, 0 }, -- O
        [8] =  
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, -- !!!!!!!!!!
    },
    penta = {
        mode = "penta",
        length = 12,
        offset = {1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0},
        multiplier = {1, 2, 2, 2, 2, 1, 1, 2, 1, 1, 2, 1},
        letters = {"I", "L", "P", "Z", "F", "T", "U", "N", "V", "W", "Y", "X"},
        mirror = true,
        rep = 8,
        [1] = 
        { 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0,
          1, 1, 1, 1, 1,
          0, 0, 0, 0, 0,
          0, 0, 0, 0, 0 }, -- I (I)
        [2] = 
        { 0, 0, 0, 0,
          1, 1, 1, 1,
          1, 0, 0, 0,
          0, 0, 0, 0 },    -- L (L)
        [3] =        
        { 0, 0, 0,
          1, 1, 1,
          0, 1, 1 },    -- P (J)
        [4] =  
        { 1, 1, 0,
          0, 1, 0,
          0, 1, 1 },    -- Z (Z)
        [5] =       
        { 0, 1, 1,
          1, 1, 0,
          0, 1, 0 },    -- F (S)
        [6] =  
        { 1, 1, 1,
          0, 1, 0,
          0, 1, 0, },   -- T (T)
        [7] =  
        { 0, 0, 0,
          1, 0, 1,
          1, 1, 1 }, -- U (O)
        [8] = 
          { 0, 0, 0, 0,
            1, 1, 0, 0,
            0, 1, 1, 1,
            0, 0, 0, 0 }, -- N
        [9] = 
          { 1, 0, 0,
            1, 0, 0,
            1, 1, 1 }, -- V
        [10] = 
          { 1, 0, 0,
            1, 1, 0,
            0, 1, 1 }, -- W
        [11] = 
          { 0, 0, 0, 0,
            0, 0, 1, 0,
            1, 1, 1, 1,
            0, 0, 0, 0 }, -- Y
        [12] =  
          { 0, 1, 0,
            1, 1, 1,
            0, 1, 0 }, -- X
    },
}

local blocks = block_storage["normal"]

-- unused?
local block_letter = {
    [1] = "I",
    [2] = "L",
    [3] = "J",
    [4] = "Z",
    [5] = "S",
    [6] = "T",
    [7] = "O",
    [8] = "8",
    [9] = "9",
    [10] = "10",
    [11] = "11",
    [12] = "12",
    [13] = "13",
    [14] = "14",
    [15] = "15",
    [16] = "16",
    [17] = "17",
    [18] = "18",
    [19] = "19",
    [20] = "20",
    [21] = "21",
}

local function new_blocks_rotated()
    local temp = { }
    for i = 1, 20 do
        temp[i] = {}
    end
    return temp
end

local blocks_rotated = new_blocks_rotated()

local blocks_x_check = {
    4, 5, 3, 6, 2, 7, 1, 8, 0, 9,
}

local block_colors = {
    [-1] = {161, 161, 161}, -- ? grey
    [0]  = {25, 25, 25},    -- B black
    [1]  = {101, 233, 184}, -- I cyan
    [2]  = {233, 150, 101}, -- L orange
    [3]  = {95, 77, 176},   -- J purple
    [4]  = {218, 88, 95},   -- Z red
    [5]  = {176, 223, 96},  -- S green
    [6]  = {193, 92, 183},  -- T pink
    [7]  = {216, 190, 88},  -- O yellow
    [8]  = {150, 105, 86},  -- #8 brown
    [9]  = {255, 51, 0},    -- #9 orange red
    [10] = {99, 199, 90},   -- #10 leaf colour
    [11] = {14, 117, 37},   -- #11 dark green
    [12] = {9, 158, 217},   -- #12 blue
    [13] = {201, 34, 106},  -- #13 pink red
    [14] = {63, 82, 23},    -- #14 olive?
    [15] = {135, 179, 255}, -- #15 light blue
}

local lines_score = {
    [0] = 0,
    [1] = 100,
    [2] = 300,
    [3] = 500,
    [4] = 800,
    [5] = 2000,
    [6] = 3000,
    [7] = 5000,
    [8] = 7500,
    [9] = 10000,
    [10] = 15000,
    [11] = 20000,
    ["?0"] = 400,
    ["?1"] = 800,
    ["?2"] = 1200,
    ["?3"] = 1600,
    ["?4"] = 2000,
    ["?5"] = 3000,
    ["?6"] = 4000,
    ["?7"] = 5000,
    ["?8"] = 6500,
    ["?9"] = 8000,
    ["?10"] = 10000,
    ["T0"] = 400,
    ["T1"] = 800,
    ["T2"] = 1200,
    ["T3"] = 1600,
    ["S0"] = 400,
    ["S1"] = 800,
    ["S2"] = 1200,
    ["S3"] = 1600,
    ["Z0"] = 400,
    ["Z1"] = 800,
    ["Z2"] = 1200,
    ["Z3"] = 1600,
    ["I0"] = 450,
    ["I1"] = 850,
    ["I2"] = 1250,
    ["I3"] = 1750,
    ["I4"] = 2500,
    ["I5"] = 3500,
    ["J0"] = 300,
    ["J1"] = 800,
    ["J2"] = 1200,
    ["J3"] = 1600,
    ["L0"] = 300,
    ["L1"] = 800,
    ["L2"] = 1200,
    ["L3"] = 1600,
    ["O0"] = 500,
    ["O1"] = 1000,
    ["O2"] = 1500,
    ["O3"] = 10000,
    ["PC1"] = 3500, -- all clear
    ["PC2"] = 3000,
    ["PC3"] = 3750,
    ["PC4"] = 4000,
    ["PC5"] = 4000,
}
    
local lines_string = {
    [0] = "",
    [1] = "x1",
    [2] = "x2",
    [3] = "x3",
    [4] = "x4",
    [5] = "x5",
    [6] = "x6",
    [7] = "x7",
    [8] = "x8",
    [9] = "x9",
    [10] = "x10",
    ["?0"] = "spin",
    ["?1"] = "spin x1",
    ["?2"] = "spin x2",
    ["?3"] = "spin x3",
    ["?4"] = "spin x4",
    ["?5"] = "spin x5!",
    ["?6"] = "spin x6!",
    ["?7"] = "spin x7!",
    ["?8"] = "spin x8!",
    ["?9"] = "spin x9!",
    ["?10"] = "spin x10!",
    ["T0"] = "t-spin",
    ["T1"] = "t-spin x1",
    ["T2"] = "t-spin x2",
    ["T3"] = "t-spin x3",
    ["Z0"] = "Z-spin",
    ["Z1"] = "Z-spin x1",
    ["Z2"] = "Z-spin x2",
    ["Z3"] = "z-spin x3",
    ["S0"] = "S-spin",
    ["S1"] = "S-spin x1",
    ["S2"] = "S-spin x2",
    ["S3"] = "S-spin x3",
    ["J0"] = "J-spin",
    ["J1"] = "J-spin x1",
    ["J2"] = "J-spin x2",
    ["J3"] = "J-spin x3",
    ["L0"] = "L-spin",
    ["L1"] = "L-spin x1",
    ["L2"] = "L-spin x2",
    ["L3"] = "L-spin x3",
    ["I0"] = "I-spin",
    ["I1"] = "I-spin x1",
    ["I2"] = "I-spin x2",
    ["I3"] = "I-spin x3",
    ["I4"] = "tetris-spin!",
    ["I5"] = "I-spin x5!",
    ["O0"] = ":O-spin",
    ["O1"] = ":O-spin x1",
    ["O2"] = ":O-spin x2",
    ["O3"] = "impossible!",
    ["O4"] = ":O spin x4",
    ["PC1"] = "all clear",
    ["PC2"] = "all clear",
    ["PC3"] = "all clear",
    ["PC4"] = "all clear",
    ["PC5"] = "all clear",
}

local lines_garbage = {
    [2] = 1,
    [3] = 2,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,
    [10] = 10,
    [11] = 11,
    ["T1"] = 2,
    ["T2"] = 4,
    ["T3"] = 6,
    ["PC1"] = 10, -- all clear
    ["PC2"] = 11,
    ["PC3"] = 12,
    ["PC4"] = 14,
    ["PC5"] = 15,
}

local level_lines = {
    [0] = 1,
    [1] = 3,
    [2] = 8,
    [3] = 15,
    [4] = 24,
    [5] = 35,
    [6] = 48,
    [7] = 63,
    [8] = 80,
    [9] = 99,
    [10] = 120,
    [11] = 144,
    [12] = 170,
    [13] = 197,
    [14] = 230,
    [15] = 260,
}
    
local level_time = {
    [0] = 0,
    [1] = 15,
    [2] = 30,
    [3] = 45,
    [4] = 60,
    [5] = 80,
    [6] = 100,
    [7] = 120,
    [8] = 140,
    [9] = 160,
    [10] = 180,
    [11] = 210,
    [12] = 240,
    [13] = 270,
    [14] = 300,
    [15] = 330,
}
        
local level_score = {
    [0] = 0,
    [1] = 100,
    [2] = 300,
    [3] = 1000,
    [4] = 2000,
    [5] = 3000,
    [6] = 4000,
    [7] = 5000,
    [8] = 6000,
    [9] = 7000,
    [10] = 8000,
    [11] = 9000,
    [12] = 10000,
    [13] = 12000,
    [14] = 14000,
    [15] = 16000,
}

total_levels = 15

--[[
SRS data https://tetris.wiki/Super_Rotation_System
0->R    ( 0, 0)	(-1, 0)	(-1,+1)	( 0,-2)	(-1,-2)
R->0	( 0, 0)	(+1, 0)	(+1,-1)	( 0,+2)	(+1,+2)
R->2	( 0, 0)	(+1, 0)	(+1,-1)	( 0,+2)	(+1,+2)
2->R	( 0, 0)	(-1, 0)	(-1,+1)	( 0,-2)	(-1,-2)
2->L	( 0, 0)	(+1, 0)	(+1,+1)	( 0,-2)	(+1,-2)
L->2	( 0, 0)	(-1, 0)	(-1,-1)	( 0,+2)	(-1,+2)
L->0	( 0, 0)	(-1, 0)	(-1,-1)	( 0,+2)	(-1,+2)
0->L	( 0, 0)	(+1, 0)	(+1,+1)	( 0,-2)	(+1,-2)
I
0->R	( 0, 0)	(-2, 0)	(+1, 0)	(+1,+2)	(-2,-1)
R->0	( 0, 0)	(+2, 0)	(-1, 0)	(+2,+1)	(-1,-2)
R->2	( 0, 0)	(-1, 0)	(+2, 0)	(-1,+2)	(+2,-1)
2->R	( 0, 0)	(-2, 0)	(+1, 0)	(-2,+1)	(+1,-1)
2->L	( 0, 0)	(+2, 0)	(-1, 0)	(+2,+1)	(-1,-1)
L->2	( 0, 0)	(+1, 0)	(-2, 0)	(+1,+2)	(-2,-1)
L->0	( 0, 0)	(-2, 0)	(+1, 0)	(-2,+1)	(+1,-2)
0->L	( 0, 0)	(+2, 0)	(-1, 0)	(-1,+2)	(+2,-1)
--]]

local srs = {
    ["0 1"] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2} },
    ["1 0"] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2} },
    ["1 2"] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2} },
    ["2 1"] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2} },
    ["2 3"] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2} },
    ["3 2"] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2} },
    ["3 0"] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2} },
    ["0 3"] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2} },
    -- 180s
    ["0 2"] = { {0, 0}, {0, 1}, {0, -1}, {-1, 0}, {1, 0} },
    ["1 3"] = { {0, 0}, {0, 1}, {0, -1}, {-1, 0}, {1, 0} },
    ["2 0"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
    ["3 1"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
    -- mirrors
    ["0 0"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
    ["1 1"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
    ["2 2"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
    ["3 3"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
}

local srsi = {
    ["0 1"] = { {0, 0}, {-2, 0}, {1, 0}, {1, 2}, {-2, -1} },
    ["1 0"] = { {0, 0}, {2, 0}, {-1, 0}, {2, 1}, {-1, -2} },
    ["1 2"] = { {0, 0}, {-1, 0}, {2, 0}, {-1, 2}, {2, -1} },
    ["2 1"] = { {0, 0}, {-2, 0}, {1, 0}, {-2, 1}, {1, -1} },
    ["2 3"] = { {0, 0}, {2, 0}, {-1, 0}, {2, 1}, {-1, -1} },
    ["3 2"] = { {0, 0}, {1, 0}, {-2, 0}, {1, 2}, {-2, -1} },
    ["3 0"] = { {0, 0}, {-2, 0}, {1, 0}, {-2, 1}, {1, -2} },
    ["0 3"] = { {0, 0}, {2, 0}, {-1, 0}, {-1, 2}, {2, -1} },
    -- 180s
    ["0 2"] = { {0, 0}, {0, 1}, {0, -1}, {-1, 0}, {1, 0} },
    ["1 3"] = { {0, 0}, {0, 1}, {0, -1}, {-1, 0}, {1, 0} },
    ["2 0"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
    ["3 1"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
    -- mirrors
    ["0 0"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
    ["1 1"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
    ["2 2"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
    ["3 3"] = { {0, 0}, {0, -1}, {0, 1}, {1, 0}, {-1, 0} },
}

function t.reset()
    t.fill_board(10, 20, 0)
    t.board.start_x = (window_width - t.board.width * t.tile_size) / 2 - t.tile_size
    t.board.start_y = (window_height - t.board.height * t.tile_size) / 2 - t.tile_size
    t.board.end_x = t.board.start_x + t.board.width * t.tile_size
    t.board.end_y = t.board.start_y + t.board.height * t.tile_size
end

function t.fill_board(width, height, n)
    t.board.width = width
    t.board.height = height
    -- height extended
    t.board.height_ex = height + 6
    t.tile_size = 10
    board = {}
    local x, y
    for y = 1, height + 6 do
        board[y] = {}
        for x = 1, width do
            board[y][x] = n
        end
    end
    --[[
    board[5][5] = 7
    board[5][6] = 7
    board[6][5] = 7
    board[6][6] = 7
    -- ]]
end

function t.set_board_full(height, same) -- what is n???
    local width = t.board.width
    local same = same or false
    local pos = random.randint(1, width)
    
    for y = 1, height do
        for x = 1, width do
            t.set(x, y, -1)
        end
        if same then
            t.set(pos, y, 0)
        else
            t.set(random.randint(1, width), y, 0)
        end
    end
end
    
function t.send_garbage(height)
    t.print_board()
    local width = t.board.width
    local board_height = t.board.height_ex
    local max_height = 0
    
    for y = board_height, 1, -1 do
        for x = 1, width do
            local got = t.get(x, y)
            if got ~= nil then
                if max_height < y + height then
                    max_height = y + height
                end
                t.set(x, y + height, got)
            end
        end
    end
    if max_height > 20 then
        -- fail? actually, no
    end
    t.set_board_full(height, true)
    t.print_board()
end

function t.get(x, y)
    if board[y] == nil then
        return nil
    end
    return board[y][x]
end

function t.check(x, y)
    local b = t.get(x, y)
    return (b == nil or b ~= 0)
end
    
function t.check_line(y)
    for x = 1, t.board.width do
        if not (t.get(x, y) ~= 0) then
            return false
        end
    end
    return true
end
        
function t.check_line_empty(y)
    for x = 1, t.board.width do
        if (t.get(x, y) ~= 0) then
            return false
        end
    end
    return true
end
            
function t.check_clear_empty()
    for x = 1, t.board.width do
        if (t.get(x, 1) == -1) then
            return false
        end
    end
    return true
end

function t.set(x, y, piece_type)
    if t.get(x, y) == nil then
        return
    end
    board[y][x] = piece_type
end

function t.clear_line(h)
    for y = h, t.board.height_ex - 1 do
        for x = 1, t.board.width do
            local got = t.get(x, y + 1)
            t.set(x, y, got)
        end
    end
    return true
end

--[[

notation
x = i: / 1 2 3 \
y = j: 1 - - - 1
       2 - - - 2
       3 - - - 3
       \ 1 2 3 /

## rot 0 ##
1 2 3
4 5 6
7 8 9
Formula: i+(j-1)*s

## rot 1 ##
7 4 1
8 5 2
9 6 3
Formula: (s-i)*s+j

## rot 2 ##
9 8 7
6 5 4
3 2 1
Formula: (s+1-i)+(s-j)*s

## rot 3 ##
3 6 9
2 5 8
1 4 7
Formula: (i-1)*s+(s+1-j)

##############################

## rot 4 ## (0)
3 2 1
6 5 4
9 8 7
Formula: (s+1-i)+(j-1)*s

## rot 5 ## (1)
1 4 7
2 5 8
3 6 9
Formula: (i-1)*s+j

## rot 6 ## (2)
7 8 9
4 5 6
1 2 3
Formula: i+(s-j)*s

## rot 7 ## (3)
9 6 3
8 5 2
7 4 1
Formula: (s-i)*s+(s+1-j)

--]]
    
function t.rotate_piece(piece_type, rot)
    if blocks_rotated[piece_type][rot] == nil then
        local b = deep_copy(blocks[piece_type]) -- non-rotated block
        local s = round(sqrt(#b))    -- size
        if rot == 0 then
            return b
        else
            local ans = {}
            local store = 0
            for i = 1, s do
                for j = 1, s do
                    if rot == 1 then
                        store = b[(s-i)*s+j]
                    elseif rot == 2 then
                        store = b[(s+1-i)+(s-j)*s]
                    elseif rot == 3 then
                        store = b[(i-1)*s+(s+1-j)]
                    elseif rot == 4 then
                        store = b[(s+1-i)+(j-1)*s]
                    elseif rot == 5 then
                        store = b[(i-1)*s+j]
                    elseif rot == 6 then
                        store = b[i+(s-j)*s]
                    elseif rot == 7 then
                        store = b[(s-i)*s+(s+1-j)]
                    end
                    ans[i+(j-1)*s] = store
                    --[[
                    store = b[i+(j-1)*s]
                    if rot == 1 then
                        ans[(s-i)*s+j] = store
                    elseif rot == 2 then
                        ans[(s+1-i)+(s-j)*s] = store
                    elseif rot == 3 then
                        ans[(i-1)*s+(s+1-j)] = store
                    end
                    --]]
                end
            end
            blocks_rotated[piece_type][rot] = ans
            return ans
        end
    else
        return blocks_rotated[piece_type][rot]
    end
end

function t.print_piece(piece)
    local s = floor(sqrt(#piece)) -- size
    local p = "" -- to print
    for j = 0, s - 1 do
        for i = 0, s - 1 do 
            if piece[i + j * s + 1] == 1 then
                p = p .. "#"
            elseif piece[i + j * s + 1] == 0 then
                p = p .. "-"
            end
        end
        p = p .. "\n"
    end
    print(p)
    return
end
    
function t.print_board()
    local p = "" -- to print
    for j = 0, t.board.height do
        for i = 0, t.board.width do
            if t.get(i, j) == nil then
                p = p .. " "
            elseif t.get(i, j) == -1 then
                p = p .. "X"
            elseif t.get(i, j) < 10 then
                p = p .. t.get(i, j)
            elseif t.get(i, j) ~= 0 then
                p = p .. "O"
            else
                p = p .. "-"
            end
        end
        p = p .. "\n"
    end
    print(p)
    return
end

-- [TEST] (slow concatenation beware!)
--[[
t.print_piece(t.rotate_piece(4, 0))
t.print_board()
--]]

function t.check_piece(piece_type, rot, x, y)
    local b = t.rotate_piece(piece_type, rot) -- block
    local s = round(sqrt(#b)) -- size
    for i = 0, s - 1 do
        for j = 0, s - 1 do
            if b[i + j * s + 1] == 1 and t.check(x + i, y - j) then
                return true
            end
        end
    end
    return false
end
    
function t.check_piece_immobile(piece_type, rot, x, y)
    return 
    t.check_piece(piece_type, rot, x + 1, y) and 
    t.check_piece(piece_type, rot, x - 1, y) and 
    t.check_piece(piece_type, rot, x, y + 1) and
    t.check_piece(piece_type, rot, x, y - 1)
end

function t.add_piece(piece_type, rot, x, y)
    local b = t.rotate_piece(piece_type, rot) -- block
    local s = round(sqrt(#b)) -- size
    for i = 0, s - 1 do
        for j = 0, s - 1 do
            if b[i + j * s + 1] == 1 then
                t.set(x + i, y - j, piece_type)
            end
        end
    end
end
            
function t.remove_piece(piece_type, rot, x, y)
    local b = t.rotate_piece(piece_type, rot) -- block
    local s = round(sqrt(#b)) -- size
    for i = 0, s - 1 do
        for j = 0, s - 1 do
            if b[i + j * s + 1] == 1 then
                t.set(x + i, y - j, 0)
            end
        end
    end
end

function t.set_size(size)
    t.tile_size = size
end

function t.paint(gc, pieces)

    -- add current piece(s) here
    if not play.fail then
        for i, p in ipairs(pieces) do
            t.add_piece(p.type, p.rot, p.x, p.y)
        end
    end
    
    local ox = t.board.offset_x
    local oy = t.board.offset_y
    local width = t.board.width
    local height = t.board.height
    local height_ex = t.board.height_ex
    local size = t.tile_size
    local start_x = t.board.start_x
    local start_y = t.board.start_y
    local b = 0
    local x, y
     
    -- draw ghost
    local p = play.piece
    t.paint_piece(gc, p.type, p.rot, start_x + p.x * size + ox, start_y + window_height - play.ghost * size + oy, play.settings.ghost)
    
    for y = 1, height_ex do
        for x = 1, width do
            b = t.get(x, y)
            if play.settings.graphics == "high" then
                fill_rect(gc, start_x + x * size + ox, start_y + window_height - y * size + oy, size, size, block_colors[b])
                set_color_black(gc, block_colors[b], 0.1)
                draw_rect_size(gc, start_x + x * size + ox, start_y + window_height - y * size + oy, size, size, 0.7)
                set_color_black(gc, block_colors[b], 0.2)
                fill_rect_size(gc, start_x + x * size + ox, start_y + window_height - y * size + oy, size, size, 0.6)
            else
                if b ~= 0 then
                    fill_rect(gc, start_x + x * size + ox, start_y + window_height - y * size + oy, size, size, block_colors[b])
                end
            end
        end
    end
    
    -- the following can actually be combined into one huge polyline though
    draw_polyline(gc, {start_x + size + ox - 1, start_y + size + oy, start_x + size + ox - 1, start_y + size + oy + height * size + 2 }, "white")
    draw_polyline(gc, {start_x + size + ox - 1, start_y + size + oy + height * size + 2, start_x + size + ox - 1 + width * size + 2, start_y + size + oy + height * size + 2 }, "white")
    draw_polyline(gc, {start_x + size + ox - 1 + width * size + 2, start_y + size + oy, start_x + size + ox - 1 + width * size + 2, start_y + size + oy + height * size + 2 }, "white")
    --[[
    draw_rect(gc, start_x + size + ox - 1, start_y + size + oy, width * size + 2, height * size + 2, "white")
    draw_rect(gc, start_x + size + ox - 1, start_y + size + oy, width * size + 2, 1, "black")
    --]]
    
    -- remove current piece(s) here
    if not play.fail then
        for i, p in ipairs(pieces) do
            t.remove_piece(p.type, p.rot, p.x, p.y)
        end
    end
end

function t.paint_piece(gc, piece_type, rot, x, y, mix_value)
    local mix_value = mix_value or 0
    local b = t.rotate_piece(piece_type, rot) -- block
    local s = round(sqrt(#b)) -- block size
    local size = t.tile_size -- tile size
    for i = 0, s - 1 do
        for j = 0, s - 1 do
            if b[i + j * s + 1] == 1 then
                -- square
                if play.settings.graphics == "high" then
                    set_color_black(gc, block_colors[piece_type], 0 + mix_value)
                    fill_rect(gc, x + i * size, y + j * size, size, size)
                    set_color_black(gc, block_colors[piece_type], 0.1 + mix_value)
                    draw_rect_size(gc, x + i * size, y + j * size, size, size, 0.7)
                    set_color_black(gc, block_colors[piece_type], 0.2 + mix_value)
                    fill_rect_size(gc, x + i * size, y + j * size, size, size, 0.6)
                else
                    set_color_black(gc, block_colors[piece_type], 0 + mix_value)
                    fill_rect(gc, x + i * size, y + j * size, size, size)
                end
            end
        end
    end
end

local v = {}

v.t = {}

function v.store()
    v.t.settings = deep_copy(play.settings)
    v.t.replays = deep_copy(replays)
    -- v.t.lbs = deep_copy(lbs)
    local s = serialize(v.t)
    var.store("tetris", s)
end

function v.recall()
    local s = var.recall("tetris")
    if s == nil then
        v.store()
    end
    if s ~= nil then
        v.t = deserialize(s)
        play.settings = deep_copy(v.t.settings)
        replays = deep_copy(v.t.replays)
        -- lbs = deep_copy(v.t.lbs)
    end
end

local version_list = {
    { key = "0.5.0",
        "Started recording changes in a changelog. Previously:",
        "v0.1: game done",
        "v0.2: main menu, different modes",
        "v0.3: settings, controls",
        "v0.4: 180/mirror rotation, funny blocks",
    },
    { key = "0.5.1",
        "Added replays, they record what happens in a game.",
        "Replays can be replayed under settings -> display [-] -> replay [enter].",
        "The speed of replays can be changed.",
        " ",
        "Warning: replays may be unstable.",
        "test",
        "test",
        "test",
        "test",
    },
    { key = "0.5.2",
        "Added some replay-related interface at the top right.",
        "Changed the settings screen to have 6 tabs and added 2 new tabs.",
        "Fixed the 'spam hard drop' crash. (finally!)",
    }
}
local VERSION = version_list[#version_list].key

-- @main menu

function main_menu.start()
    mode = "main_menu"
    main_menu.time = 0
    main_menu.selected = 2
    main_menu.selector = window_width
    main_menu.selector_target = window_width / 2
    v.store()
end

function main_menu.paint(gc)
    draw_screen(gc, "black")
    set_font(gc, 16)
    local title_y = 50 - 6 ^ (2 - min(10, main_menu.time) / 5)
    set_color_white(gc, block_colors[floor((main_menu.time % 140) / 20) + 1], 0.4)
    draw_string_plop(gc, "TETRIS", window_width / 2, title_y)
    t.paint_piece(gc, floor((main_menu.time % 140) / 20) + 1, 0, window_width / 2 - 20, title_y - 30, 0)
    
    -- options
    set_font(gc, 11)
    draw_string_plop_left(gc, "__________", 15, 120, "white")
    draw_string_plop_both(gc, "play", window_width / 2, 120, "white")
    draw_string_plop_right(gc, "settings", window_width - 35, 120, "white")
    -- draw_image(gc, "settings", window_width / 2 + 44, 104)
    
    -- selector
    local select_dx = sin(main_menu.time) * 500 / (main_menu.time ^ 2)
    fill_rect(gc, main_menu.selector - 5 + select_dx, 140, 10, 10, block_colors[-1])
    
    set_font(gc, 8)
    draw_string_plop(gc, "v" .. VERSION, window_width / 2, 200, "white")
end

function main_menu.timer()
    main_menu.time = main_menu.time + 1
    main_menu.selector = smooth(main_menu.selector, main_menu.selector_target, 1.5)
    
    window:invalidate()
end

function main_menu.charIn(char)
    if char == "enter" then
        local s = main_menu.selected
        if s == 1 then
            -- menu.start()
        elseif s == 2 then
            menu.start()
        elseif s == 3 then
            settings.start()
        end
    end
    
    local target_table = {55, window_width / 2, window_width - 60}
    
    if char == "right" or char == "6" then
        main_menu.selected = (main_menu.selected) % 3 + 1
    end
    
    if char == "left" or char == "4" then
        main_menu.selected = (main_menu.selected + 1) % 3 + 1
    end
    
    main_menu.selector_target = target_table[main_menu.selected]
end

-- @menu

menu.options = {
    "Practice", "Lines", "Timed", "Clear", "Level", "Send", "Penta", "Funny"
}

function menu.start()
    mode = "menu"
    menu.time = 0
    menu.selected = 0
    menu.selected_time = 0
    menu.camera_y = 200
    menu.target_y = 60
    v.store()
end

function menu.paint(gc)
    draw_screen(gc, "black")
    
    -- options
    set_font(gc, 11)
    local y = 120
    for i = 1, #menu.options do
        local dy = 0
        if (menu.selected == i) then
            draw_string_plop(gc, menu.options[i], window_width / 2, y - menu.camera_y, "dimgrey")
            set_color_white(gc, block_colors[floor((menu.time % 140) / 20) + 1], 0.4)
            dy = -6 + 2.5 ^ (2 - min(10, (menu.time - menu.selected_time)) / 5)
        else
            set_color(gc, "white")
        end
        draw_string_plop(gc, menu.options[i], window_width / 2 + dy, y + dy - menu.camera_y)
        y = y + 30
    end
    
    local top = 50
    local bottom = 15
    fill_rect(gc, 0, 0, window_width, top, "black")
    fill_rect(gc, 0, window_height - bottom, window_width, bottom, "black")
    
    set_font(gc, 16)
    local title_y = 14 + 6 ^ (2 - min(10, menu.time) / 5)
    if menu.selected == 0 then
        set_color_white(gc, block_colors[floor((menu.time % 140) / 20) + 1], 0.4)
    else
        set_color(gc, "white")
    end
    draw_string_plop(gc, "TETRIS", window_width / 2, title_y)
    
    set_font(gc, 8)
    draw_string_plop(gc, VERSION, window_width / 2, 200, "white")
end

function menu.timer()
    menu.time = menu.time + 1
    
    menu.camera_y = smooth(menu.camera_y, menu.target_y, 0.7)
    
    window:invalidate()
end

function menu.charIn(char)
    if char == "enter" then
        local s = menu.selected
        if s == 0 then
            menu.start()
        elseif s == 1 then
            play.start("practice")
        elseif s == 2 then
            play.start("lines", 40)
        elseif s == 3 then
            play.start("timed", 60)
        elseif s == 4 then
            play.start("clear", 60)
        elseif s == 5 then
            play.start("level", "score")
        elseif s == 6 then
            play.start("send", 0)
        elseif s == 7 then
            play.start("funny", "penta")
        elseif s == 8 then
            play.start("funny", "funny")
        end
    elseif char == "esc" then
        main_menu.start()
    end
    
    local ds = 0
    local mod = #menu.options
    if menu.selected > 0 and (char == "8" or char == "up") then
        ds = -1
        menu.selected_time = menu.time
    elseif char == "2" or char == "down" then
        ds = 1
        menu.selected_time = menu.time
    end
    menu.selected = 1 + (menu.selected + ds + mod - 1) % mod
    menu.target_y = menu.selected * 30
end


-- @play

play.settings = {
    
    -- graphics
    graphics = "medium",
    ghost = 0.5,
    theme = "classic",
    fail_animation = 1,
    
    -- gameplay
    gravity = 10,
    
    -- controls
    move_left = "4",
    move_left_2 = "left",
    move_right = "6",
    move_right_2 = "right",
    move_left_all = "(",
    move_left_all_2 = "^2",
    move_right_all = ")",
    move_right_all_2 = "*",
    hard_drop = "8",
    hard_drop_2 = "up",
    soft_drop = "2",
    soft_drop_2 = "down",
    soft_drop_all = "1",
    soft_drop_all_2 = "enter",
    rotate_left = "7",
    rotate_left_2 = "+",
    rotate_right = "9",
    rotate_right_2 = "-",
    rotate_180 = "3",
    rotate_180_2 = "/",
    rotate_mirror = "−",
    rotate_mirror_2 = "m",
    save_piece = "5",
    save_piece_2 = " ",
    quit = "esc",
    quit_2 = "q",
    pause = ".",
    pause_2 = "p",
    restart = "=",
    restart_2 = "r",
}

function play.start(play_mode, args)
    mode = "play"
    
    -- init replay FIRST
    play.replaying = false
    play.replay = {
        m = play_mode, -- mode
        a = args, -- mode_args
        p = {}, -- pieces
        s = {}, -- moves
        t = 0, -- frame time
        r = 0, -- real time
    }
    play.replay_moves = make_queue()
    
    play.init_board()
    play.init()
    
    play.mode = play_mode
    play.mode_args = args
    play.target_lines = -1
    play.target_time = -1 -- seconds
    
    if play_mode == "funny" then
        play.switch_block_table(args)
    else
        play.switch_block_table("normal")
    end
    if play_mode == "practice" then
        -- do nothing
    elseif play_mode == "clear" then
        t.set_board_full(10)
        play.gravity = 10
    elseif play_mode == "lines" then
        play.target_lines = args
        play.gravity = 10
    elseif play_mode == "timed" then
        play.target_time = args
        play.gravity = 10
    elseif play_mode == "level" then
        play.level = 1
        play.gravity = 10
    elseif play_mode == "send" then
        -- ?
    elseif play_mode == "funny" then
        -- already changed
    end
    
    return
end

function play.restart()
    play.start(play.mode, play.mode_args)
end

function play.start_replay(replay)
    local replay = deep_copy(replay)
    local replay = play.replay_decode(replay)
    play.start(replay.m, replay.a)
    play.replay = deep_copy(replay)
    play.replaying = true
    play.replay_piece = 1
    play.replay_speed = 1
    play.replay_time = 0
    
    -- fix queue
    play.queue = make_queue()
    play.new_piece()
end

function play.replay_encode(r)
    
    -- pieces
    local p = {}
    for i = 1, #r.p do
        p[i] = string.char(64 + r.p[i])
    end
    local p = table.concat(p)
    r.p = p
    
    -- moves (save memory for this!!!)
    local s = {}
    local consequtive = 0 -- Yuan Xi
    local function encode_consequtive()
        if consequtive == 0 then
            -- do nothing
        elseif consequtive <= 26 then
            -- letter
            s[#s + 1] = string.char(96 + consequtive)
        else
            -- number
            s[#s + 1] = tostring(floor(consequtive))
        end
        consequtive = 0
    end
    -- LOOPS
    for i = 1, r.t do
        local b = r.s[i]
        if b == nil then
            consequtive = consequtive + 1
        else
            encode_consequtive()
            s[#s + 1] = b
        end
    end
    encode_consequtive()
    local s = table.concat(s)
    r.s = s
    
    return r
    
end

function play.replay_decode(r)

    table.print(r)

    -- pieces
    local p = {}
    for i = 1, #r.p do
        p[i] = r.p:byte(i) - 64
    end
    r.p = p
    
    -- moves
    local s = {}
    local t = 1
    for i = 1, #r.s do
        local b = r.s:sub(i, i)
        local v = r.s:byte(i)
        if v >= 65 and v <= 90 then
            -- move
            s[t] = b
            t = t + 1
        elseif v >= 96 and v <= 122 then
            t = t + v - 96
            -- consequtive
        elseif v >= 48 and v <= 57 then
            -- number
            local old_i = i
            while (v ~= nil and v >= 48 and v <= 57) do
                i = i + 1
                v = r.s:byte(i)
            end
            t = t + tonumber(r.s:sub(old_i, i - 1))
        end
    end
    r.s = s
    
    return r
    
end

function play.init()
    play.time = 0
    play.score = 0
    play.disp_score = 0
    play.queue = make_queue()
    play.gravity = play.settings.gravity
    play.drop_timer = play.gravity
    play.fail = false
    play.fail_time = -1
    play.fail_time_milli = -1
    play.done = false
    play.done_time = -1
    play.saved_piece = 0
    play.just_saved = false
    play.t_spin = 0
    play.spin = 0
    play.combo = -1
    play.garbage = 0
    play.ghost = 0
    play.lines = 0
    play.disp_lines = 0
    play.disp_lines_time = 0
    play.disp_lines_score = 0
    play.level = 0
    play.paused = false
    play.milliseconds = timer.getMilliSecCounter()
    play.new_piece()
    
    if play.gravity == 17 then
        play.gravity = 20
    elseif play.gravity == 20 then
        play.gravity = 1000000000
    end
end

function play.get_time()
    return (timer.getMilliSecCounter() - play.milliseconds) / 1000
end

function play.switch_block_table(block_mode)
    blocks = block_storage[block_mode]
    blocks_rotated = new_blocks_rotated()
end

function play.new_piece(piece_type, just_saved)
    play.piece = {
        type = piece_type or play.get_piece(1),
        done = -1,
        rot = 0,
        x = -1,
        y = 22,
    }
    
    local p = play.piece
    for i = 1, #blocks_x_check do
        if not t.check_piece(p.type, p.rot, blocks_x_check[i], p.y) then
            p.x = blocks_x_check[i]
            break
        end
    end
    if p.x == -1 then
        play.init_fail()
    end
    
    if piece_type == nil then
        play.queue:pop_left()
    end
    
    if just_saved then
        play.just_saved = true
    else
        play.just_saved = false
    end
    
    play.find_ghost()
end

function play.save_piece()
    if play.just_saved then
        return true -- blocked = true
    else
        local saved = play.saved_piece
        play.saved_piece = play.piece.type
        if saved ~= 0 then
            play.new_piece(saved, true)
        else
            play.new_piece(nil, true)
        end
        return false -- blocked = false
    end
end

function play.find_ghost()
    local p = play.piece
    for y = p.y, 1, -1 do
        if t.check_piece(p.type, p.rot, p.x, y - 1) then
            play.ghost = y
            break
        end
    end
end

function play.init_board()
    t.reset()
    t.board.offset_y = -150
end

function play.init_fail()
    if not play.fail then
        play.fail = true
        play.fail_time = play.time
        play.fail_time_milli = timer.getMilliSecCounter()
    end
end

function play.init_pause()
    play.paused = not play.paused
end

function play.update_gravity()
    if play.mode_args == "time" then
        local sec = play.get_time()
        for i = 0, total_levels do
            if sec < level_time[i] then
                play.level = i
                break
            end
        end
    elseif play.mode_args == "score" then
        for i = 0, total_levels do
            if play.score < level_score[i] then
                play.level = i
                break
            end
        end
    elseif play.mode_args == "lines" then
        for i = 0, total_levels do
            if play.lines < level_lines[i] then
                play.level = i
                break
            end
        end
    end
    play.gravity = 10 ^ ((total_levels - play.level) / total_levels)
    if play.level == total_levels then
        play.gravity = 0
    end
end

-- play pieces

function play.get_piece(index)
    local piece = play.queue:get(index)
    while piece == nil do
        play.add_pieces()
        piece = play.queue:get(index)
    end
    return piece
end

function play.add_pieces()
    if play.replaying then
        local v = play.replay.p[play.replay_piece]
        play.queue:push_right(v)
        play.replay_piece = play.replay_piece + 1
    else -- not replaying
        local shuffle_table = { }
        if blocks.multiplier == nil then
            for i = 1, blocks.length do
                shuffle_table[i] = i
            end
        else
            local index = 1
            local number = 1
            local countdown = blocks.multiplier[number] or 1
            while number <= blocks.length do
                shuffle_table[index] = number
                countdown = countdown - 1
                if countdown <= 0 then
                    number = number + 1
                    countdown = blocks.multiplier[number] or 1
                end
                index = index + 1
            end
        end
        local shuffled = random.shuffle(shuffle_table)
        for i = 1, #shuffled do
            local v = shuffled[i]
            play.replay.p[#play.replay.p + 1] = v -- store in replay
            play.queue:push_right(v)
        end
    end
end

function play.paint(gc)
    draw_screen(gc, "black")
    t.paint(gc, { play.piece })
    
    -- paint score
    
    local ox = t.board.offset_x
    local oy = t.board.offset_y
    local sx = t.board.start_x
    local sy = t.board.start_y
    local ex = t.board.end_x
    local ey = t.board.end_y
    
    set_font(gc, 11)
    
    -- score
    set_font(gc, 10)
    draw_string_plop_left(gc, "Score", 5, oy + sy + 15 + 3, "white")
    set_font(gc, 11)
    draw_string_plop_right(gc, tostring(round(play.disp_score)), ox + sx, oy + sy + 15, "white")
    
    -- save piece
    local mix_value = nil
    if play.just_saved then
        mix_value = 0.5
    end
    if play.saved_piece > 0 then
        t.paint_piece(gc, play.saved_piece, 0, ox + sx - 40, oy + sy + 50 - 10 * blocks.offset[play.saved_piece], mix_value)
    end

    -- lines
    if play.disp_lines ~= 0 and (play.time - play.disp_lines_time) < 60 then
        set_color_black(gc, "white", (play.time - play.disp_lines_time) / 60)
        set_font(gc, 11)
        draw_string_plop_right(gc, lines_string[play.disp_lines], ox + sx, oy + sy + 85)
        set_font(gc, 8)
        draw_string_plop_right(gc, "+" .. round(play.disp_lines_score), ox + sx, oy + sy + 100)
        if play.combo > 0 then
            set_font(gc, 10)
            draw_string_plop_right(gc, "combo x" .. play.combo, ox + sx, oy + sy + 120)
        end
    end
    
    -- lines
    set_font(gc, 10)
    draw_string_plop_left(gc, "Lines", 5, oy + sy + 150 + 3, "white")
    set_font(gc, 11)
    local line_string = tostring(play.lines)
    if play.mode == "lines" then
        line_string = line_string .. "/" .. play.target_lines
    end
    draw_string_plop_right(gc, line_string, ox + sx, oy + sy + 150, "white")
    
    -- timer
    set_font(gc, 10)
    if play.mode == "timed" then
        draw_string_plop_left(gc, "Timer", 5, oy + ey - 15 + 3, "white")
    else
        draw_string_plop_left(gc, "Time", 5, oy + ey - 15 + 3, "white")
    end
    set_font(gc, 11)
    local time = 0
    if play.replaying then
        time = play.replay.r * play.replay_time / play.replay.t / 1000
    else
        if play.mode == "timed" then
            --time = play.target_time - play.time / 20
            time = play.target_time - play.get_time()
        else
            --time = play.time / 20
            time = play.get_time()
        end
    end
    local time_seconds = (time) % 60
    local time_minutes = floor(time / 60)
    local s = tostring(round(time_seconds * 100) / 100)
    local found = s:find("%.")
    if found == nil then
        s = s .. ".00"
    elseif #s - found < 2 then
        s = s .. "0"
    end
    if time_minutes > 0 then
        s = time_minutes .. ":" .. s
    end
    draw_string_plop_right(gc, s, ox + sx, oy + ey - 15, "white")
    
    for i = 1, 5 do
        local piece = play.get_piece(i)
        local piece_offset = 1 + (blocks.offset[piece] or 0)
        t.paint_piece(gc, piece, 0, ox + ex + 30, oy + sy - 10 * piece_offset + 30 * i)
    end
    
    set_font(gc, 11)
    draw_string_plop_left(gc, tostring(play.level), ox + ex + 20, oy + ey - 15, "white")
    set_font(gc, 10)
    draw_string_plop_right(gc, "Level", window_width - 5, oy + ey - 15, "white")
    
    if play.replaying then
        -- draw replay somewhere
        set_font(gc, 10)
        set_color_mix(gc, "white", "red", play.replay_speed / 5 - 0.2)
        draw_string(gc, "x" .. tostring(play.replay_speed), window_width + ox, 11 + oy, nil, "right")
        draw_string(gc, "replay", window_width - 18 + ox, 11 + oy, "white", "right")
        draw_string(gc, tostring(math.min(play.replay_time, play.replay.t)) .. "/" .. tostring(play.replay.t), window_width + ox, 31 + oy, "white", "right")
    end
    
    if play.paused then
        fill_rect(gc, 20, 20, window_width - 40, window_height - 40, "dimgrey")
        set_font(gc, 11)
        draw_string(gc, "PAUSED", window_width / 2, window_height / 2, "white", "centre")
    end
end

function play.timer(meta)
    if play.paused then
        return
    end
    
    play.time = play.time + 1
    
    if not play.done and play.mode == "timed" and play.get_time() >= play.target_time then
        play.done = true
        play.fail_time = play.time
        play.fail_time_milli = timer.getMilliSecCounter()
    end
    
    if play.mode == "level" then
        play.update_gravity()
    end
    
    play.disp_score = smooth(play.disp_score, play.score, 0.7)
    
    local p = play.piece
    local new_piece = false
    
    if play.fail or play.done then
        if play.fail then
            if play.settings.fail_animation == 1 then
                t.board.offset_x = t.board.offset_x * 0.7
                t.board.offset_y = (play.time - play.fail_time) ^ 2
                if (play.time - play.fail_time) > 20 then
                    play_end.start(play.get_info())
                end
            else
                play_end.start(play.get_info())
            end
        else
            if play.settings.fail_animation == 1 then
                t.board.offset_x = t.board.offset_x * 0.7
                t.board.offset_y = - (play.time - play.fail_time) ^ 2
                if (play.time - play.fail_time) > 20 then
                    play_end.start(play.get_info())
                end
            else
                play_end.start(play.get_info())
            end
        end
    else
        t.board.offset_x = t.board.offset_x * 0.7
        t.board.offset_y = t.board.offset_y * 0.7
    end
    
    play.drop_timer = play.drop_timer - 1
    if play.drop_timer <= 0 then
        play.move(0, -1, true)
        play.drop_timer = random_round(play.gravity)
    end
    
    if p.done > -1 then
        p.done = p.done - 1
        if p.done <= 0 and t.check_piece(p.type, p.rot, p.x, p.y - 1) then
            play.add_piece()
            new_piece = true
        end
    end
    
    if not new_piece then
        play.piece = p
    end
    
    if play.replaying then
        -- do move (if replaying)
        play.replay_time = play.replay_time + 1
        local move = play.replay.s[play.replay_time]
        if play.replay_time > play.replay.t then
            play.init_fail()
        end
        if move ~= nil then
            if move == "A" then
                play.move(-1, 0)
            elseif move == "B" then
                play.move(1, 0)
            elseif move == "C" then
                safeloop(function() return play.move(-1, 0) end, 20)
            elseif move == "D" then
                safeloop(function() return play.move(1, 0) end, 20)
            elseif move == "E" then
                play.move(0, -1, true)
            elseif move == "F" then
                safeloop(function() return play.move(0, -1, true) end, 50)
            elseif move == "G" then
                if safeloop(function() return play.move(0, -1, true) end, 50) then
                    -- ?
                end
                if play.piece.done ~= 1000000 then
                    play.piece.done = 0
                    t.board.offset_y = 2
                end
            elseif move == "H" then
                play.rotate(-1)
            elseif move == "I" then
                play.rotate(1)
            elseif move == "J" then
                play.rotate(2)
            elseif move == "K" then
                if blocks.mirror then
                    play.rotate(0, true)
                else
                    print("Mirror mode not on!")
                end
            elseif move == "L" then
                play.save_piece()
            else
                print("Unrecognised move: " .. move)
            end
        end
        if meta == nil and play.replay_speed > 1 then
            -- natural timer
            play.timer(play.replay_speed)
        elseif meta ~= nil and meta > 1 then
            play.timer(meta - 1)
        end
    else
        -- record key-value pair move/time (if not replaying or failing)
        if type(play.replay.s) == "table" and not play.fail then
            play.replay.s[play.time] = play.replay_moves:pop_left()
            play.replay.t = play.time
        end
    end
    
    window:invalidate()
end

function play.add_piece()
    local p = play.piece
    
    t.add_piece(p.type, p.rot, p.x, p.y)
    
    local count = 0
    for y = t.board.height, 1, -1 do
        if t.check_line(y) then
            t.clear_line(y)
            count = count + 1
        end
    end
    
    play.lines = play.lines + count
    play.disp_lines = count
    play.disp_lines_score = lines_score[count]
    if play.disp_lines_score == nil then
        play.disp_lines_score = 0
    end
        
    -- t-spin!
    if play.t_spin > 0 then
        play.disp_lines = "T" .. count
        play.disp_lines_score = lines_score[play.disp_lines]
    end
    
    -- other spins!
    if play.spin > 0 then
        play.disp_lines = blocks.letters[play.spin] .. count
        -- do I give score?
        play.disp_lines_score = lines_score[play.disp_lines]
        if play.disp_lines_score == nil then
            play.disp_lines = "?" .. count
            play.disp_lines_score = lines_score[play.disp_lines]
        end
    end
                
    -- all clear!
    if t.check_line_empty(1) then
        play.disp_lines = "PC" .. count
        if play.disp_lines_score == nil then
            play.disp_lines_score = 0
        end
        play.disp_lines_score = play.disp_lines_score + lines_score[play.disp_lines]
    end
    
    -- time, combo
    if play.disp_lines ~= 0 then
        play.combo = play.combo + 1
        play.disp_lines_time = play.time
        if play.disp_lines_score == nil then
            play.disp_lines_score = 0
        else
            play.disp_lines_score = play.disp_lines_score + 50 * play.combo
        end
    else
        play.combo = -1
    end
    
    play.score = play.score + play.disp_lines_score
    
    if 
      (play.mode == "lines" and play.lines >= play.target_lines) or
      (play.mode == "clear" and t.check_clear_empty()) then
        play.done = true
        play.fail_time = play.time
        play.fail_time_milli = timer.getMilliSecCounter()
    end
    
    if play.mode == "send" then
        local to_send = lines_garbage[play.disp_lines]
        if to_send ~= nil then
            t.send_garbage(to_send)
        end
    end
    
    play.new_piece()
    
end

-- play timer functions

function play.move(dx, dy, from_drop, hard_drop)
    if play.piece.type == 0 then
        play.new_piece()
    end
    if play.piece.done == 0 then
        return
    end
    -- drop
    local p = play.piece
    local blocked = false
    if t.check_piece(p.type, p.rot, p.x + dx, p.y + dy) then
        blocked = true
        if from_drop then
            if p.done == -1 then
                p.done = 10 -- play.gravity * constant?
            elseif p.y > 21 then
                p.done = 1000000
                -- FAIL
                play.init_fail()
            end
        else
            if p.x == 1 then
                t.board.offset_x = -2
            elseif p.x + round(sqrt(#blocks[p.type])) >= t.board.width + 1 then
                t.board.offset_x = 2
            end
        end
    else
        p.x = p.x + dx
        p.y = p.y + dy
        if p.done > -1 then
            if from_drop then
                p.done = -1
            else
                p.done = p.done + 1
            end
        end
        if not from_drop then
            play.t_spin = 0
        end
    end
    
    if from_drop then
        if hard_drop then
            play.score = play.score + 2
        else
            play.score = play.score + 1
        end
    end
    
    if dy == 0 then
        play.find_ghost()
    end
    
    play.piece = p
    
    return blocked
end

function play.rotate(dr, mirror)
    local p = play.piece
    local mirror = mirror or false
    -- get new rotation
    local new_rot = (p.rot + dr + 4) % 4
    if p.rot >= 4 then
        if mirror then
            new_rot = p.rot - 4
        else
            new_rot = (p.rot - dr + 4) % 4 + 4
        end
    else
        if mirror then
            new_rot = p.rot + 4
        end
    end
    
    -- find the key
    local key_1 = p.rot % 4
    local key_2 = new_rot % 4
    local key = key_1 .. " " .. key_2
    
    -- rotation system
    local rs = srs
    if p.type == 7 and blocks.mode == "normal" then
        -- return on O piece (box)
        return
    elseif p.type == 1 then
        rs = srsi
    end
    
    -- rotate!
    for i = 1, 5 do
        local offset = rs[key][i]
        local dx, dy = offset[1], offset[2]
        dy = dy -- ???
        if not t.check_piece(p.type, new_rot, p.x + dx, p.y + dy) then
            p.x = p.x + dx
            p.y = p.y + dy
            p.rot = new_rot
            break
        end
    end
    
    local blocked = false
    play.t_spin = 0
    play.spin = 0
    if p.rot ~= new_rot then
        -- cannot rotate!!!
        blocked = true
    else
        -- can rotate
        if p.done > -1 then
            p.done = p.done + 1
        end
        -- t-spin detection
        if p.type == 6 and blocks.mode == "normal" then
            local c = 0 -- block counter
            if t.check(p.x, p.y)         then c = c + 1 end
            if t.check(p.x + 2, p.y)     then c = c + 1 end
            if t.check(p.x, p.y - 2)     then c = c + 1 end
            if t.check(p.x + 2, p.y - 2) then c = c + 1 end
            if c >= 3 then
                play.t_spin = c - 2
            end
        else
            -- other spin detection
            if t.check_piece_immobile(p.type, p.rot, p.x, p.y) then
                play.spin = p.type
            end
        end
    end
    
    play.find_ghost()
    
    play.piece = p
    
    return blocked
end

function play.charIn(char)
    if play.paused then
        if char == play.settings.pause or char == play.settings.pause_2 then
            play.init_pause()
        end
    else
        if play.replaying then
            if char == play.settings.move_left or char == play.settings.move_left_2 then
                if play.replay_speed > 1 then
                    play.replay_speed = play.replay_speed - 1
                end
            elseif char == play.settings.move_right or char == play.settings.move_right_2 then
                if play.replay_speed < 5 then
                    play.replay_speed = play.replay_speed + 1
                end
            elseif char == play.settings.quit or char == play.settings.quit_2 then
                play.init_fail()
            end
        else -- not replaying
            local move = ""
            if char == play.settings.move_left or char == play.settings.move_left_2 then
                if not play.move(-1, 0) then
                    move = "A"
                end
            elseif char == play.settings.move_right or char == play.settings.move_right_2 then
                if not play.move(1, 0) then
                    move = "B"
                end
            elseif char == play.settings.move_left_all or char == play.settings.move_left_all_2 then
                -- while not play.move(1, 0) do end
                if safeloop(function() return play.move(-1, 0) end, 20) then
                    move = "C"
                end
            elseif char == play.settings.move_right_all or char == play.settings.move_right_all_2 then
                if safeloop(function() return play.move(1, 0) end, 20) then
                    move = "D"
                end
            elseif char == play.settings.soft_drop or char == play.settings.soft_drop_2 then
                if not play.move(0, -1, true) then
                    move = "E"
                end
            elseif char == play.settings.soft_drop_all or char == play.settings.soft_drop_all_2 then
                if safeloop(function() return play.move(0, -1, true) end, 50) then
                    move = "F"
                end
            elseif char == play.settings.hard_drop or char == play.settings.hard_drop_2 then
                if safeloop(function() return play.move(0, -1, true) end, 50) then
                    move = "G"
                end
                if play.piece.done ~= 1000000 then
                    play.piece.done = 0
                    t.board.offset_y = 2
                end
            elseif char == play.settings.rotate_left or char == play.settings.rotate_left_2 then
                if not play.rotate(-1) then
                    move = "H"
                end
            elseif char == play.settings.rotate_right or char == play.settings.rotate_right_2 then
                if not play.rotate(1) then
                    move = "I"
                end
            elseif char == play.settings.rotate_180 or char == play.settings.rotate_180_2 then
                if not play.rotate(2) then
                    move = "J"
                end
            elseif char == play.settings.rotate_mirror or char == play.settings.rotate_mirror_2 then
                if blocks.mirror then
                    if not play.rotate(0, true) then
                        move = "K"
                    end
                end
            elseif char == play.settings.save_piece or char == play.settings.save_piece_2 then
                if not play.save_piece() then
                    move = "L"
                end
            elseif char == play.settings.pause or char == play.settings.pause_2 then
                play.init_pause()
            elseif char == play.settings.restart or char == play.settings.restart_2 then
                play.restart()
            elseif char == play.settings.quit or char == play.settings.quit_2 then
                play.init_fail()
            end
            -- log moves (not replaying)
            if move ~= "" then
                play.replay_moves:push_right(move)
            end
        end
    end
end

function play.get_info()
    local i = {}
    i.info = true
    --i.time = play.fail_time / 20
    i.time = (play.fail_time_milli - play.milliseconds) / 1000
    i.lines = play.lines
    i.score = play.score
    i.mode = play.mode
    return i
end

function play_end.start(info)
    mode = "play_end"
    play_end.time = 0
    play_end.info = deep_copy(info)
    if play.replaying then
        -- don't save the replay!
        play_end.replaying = true
    else
        play.replay.r = info.time * 1000
        play_end.replay = play.replay_encode(play.replay)
        replays[1] = deep_copy(play_end.replay)
    end
end

function play_end.paint(gc)
    draw_screen(gc, "black")
    
    local i = play_end.info
            
    set_font(gc, 16)
    set_color_white(gc, block_colors[floor((play_end.time % 140) / 20) + 1], 0.4)
    draw_string_plop(gc, capitalise(i.mode), window_width / 2, 16)
        
    set_font(gc, 10)
    draw_string_plop_left(gc, "Score", 10, 60 + 3, "white")
    
    set_font(gc, 11)
    draw_string_plop(gc, tostring(i.score), window_width / 2, 60, "white")
    
    set_font(gc, 10)
    draw_string_plop_left(gc, "Lines", 10, 90 + 3, "white")
    
    set_font(gc, 11)
    draw_string_plop(gc, tostring(i.lines), window_width / 2, 90, "white")
        
    set_font(gc, 10)
    draw_string_plop_left(gc, "Time", 10, 120 + 3, "white")
    
    set_font(gc, 11)
    local minutes = tostring(floor(i.time / 60))
    local seconds = tostring(floor(i.time % 60))
    local milliseconds = tostring(floor((i.time % 1) * 1000))
    while #seconds < 2 do
        seconds = "0" .. seconds
    end
    while #milliseconds < 3 do
        milliseconds = "0" .. milliseconds
    end
    draw_string_plop(gc, tostring(minutes) .. ":" .. tostring(seconds) .. "." .. tostring(milliseconds), window_width / 2, 120, "white")
    
    set_font(gc, 10)
    draw_string_plop(gc, "press enter or esc", window_width / 2, 185, "white")
end

function play_end.timer()
    play_end.time = play_end.time + 1
end

function play_end.charIn(char)
    local dx, dy = dirnum_to_xy_extended(char_to_dirnum(char))
    if char == "esc" or char == "enter" then
        if play_end.replaying then
            main_menu.start()
        else
            menu.start()
        end
    end
end

function settings.start()
    mode = "settings"
    
    settings.time = 0
    settings.tab = 3
    settings.target_tab = 1
    settings.tab_scroll = 0
    settings.target_tab_scroll = 0
    settings.sx = 1
    settings.sy = 1
    settings.sz = 0
    settings.tx = 1
    settings.ty = 1
    settings.height = 0
    settings.login_show = false
    settings.create_show = false
    settings.replay_show = false
    settings.replay_sx = 1
    settings.replay_tx = 1
    settings.replay_delete = false
    settings.username = ""
    settings.password = ""
    settings.number = #settings.draw

end

function settings.paint(gc)
    draw_screen(gc, "black")
    
    local tab_w = window_width / 3
    local tab_show = (settings.tab - 0.9) % 3 + 0.9
    local target_tab_show = settings.target_tab
    
    local tab_oy = 30 - settings.tab_scroll
    local tab_left = floor(settings.tab)
    local tab_right = ceil(settings.tab)
    local tab_left_ox = -window_width * (settings.tab - tab_left)
    local tab_right_ox = window_width * (tab_right - settings.tab)
    if tab_left ~= tab_right then
        settings.draw[tab_left](gc, tab_left_ox, tab_oy)
        settings.draw[tab_right](gc, tab_right_ox, tab_oy)
    else
        settings.draw[tab_left](gc, 0, tab_oy)
    end
            
    fill_rect(gc, 0, 0, window_width, 25, "black")
    fill_rect(gc, (tab_show * tab_w) - tab_w, 0, tab_w, 25, "dimgrey")
    
    set_font(gc, 10)
    if target_tab_show > 1 then
        draw_string(gc, "+", (tab_show * tab_w) - tab_w + 5, 10, "white", "centre")
    end
    if target_tab_show < 6 then
        draw_string(gc, "-", (tab_show * tab_w) - 5, 10, "white", "centre")
    end
    draw_polyline(gc, { 0, 25, window_width, 25 }, "white")
    
    set_font(gc, 11)
    if settings.target_tab <= 3 then
        draw_string_plop_both(gc, "Controls", tab_w / 2, 10, "white")
        draw_string_plop_both(gc, "Display", 3 * tab_w / 2, 10, "white")
        draw_string_plop_both(gc, "Account", 5 * tab_w / 2, 10, "white")
    else
        draw_string_plop_both(gc, "Version", tab_w / 2, 10, "white")
        draw_string_plop_both(gc, "About", 3 * tab_w / 2, 10, "white")
        draw_string_plop_both(gc, "??????????", 5 * tab_w / 2, 10, "white")
    end
    
    if settings.login_show then
        settings.draw.login(gc, 0, 0)
    end
    
    if settings.create_show then
        settings.draw.create(gc, 0, 0)
    end
    
end

settings.draw = {}

settings.controls = {
    "move_left=Move Left",
    "move_right=Move Right",
    "hard_drop=Hard Drop",
    "soft_drop=Soft Drop",
    "rotate_left=Rotate Left",
    "rotate_right=Rotate Right",
    "rotate_180=Rotate 180",
    "move_left_all=Hard Left",
    "move_right_all=Hard Right",
    "soft_drop_all=Hard Soft Drop",
    "save_piece=Hold",
    "rotate_mirror=Mirror",
    "pause=Pause",
    "restart=Restart",
    "quit=Quit",
}

settings.about_text = {
    "Test",
    "This is a very long sentence to test how this textbox behaves. Ok, it works.",
    "Both \\n test and &nbsp; test fails. Some short words. a-long-word-that-goes-to-the-next-line."
}

settings.draw[1] = function(gc, ox, oy)
    -- draw_string_plop_both(gc, "Controls", window_width / 2 + ox, window_height / 2 + oy, "white")
    
    for i, v in pairs(settings.controls) do
        local found = v:find("=")
        local k = v:sub(1, found - 1)
        local v = v:sub(found + 1, #v)
        local c = play.settings[k]
        local c2 = play.settings[k .. "_2"]
        
        if c == " " then c = "space" end
        if c2 == " " then c2 = "space" end
        
        set_font(gc, 10)
        draw_string_plop_left(gc, v, 15 + ox, i * 30 + oy, "white")
        
        draw_rect(gc, 120 + ox, i * 30 - 10 + oy, 60, 20, "white")
        draw_string_plop_both(gc, c, 150 + ox, i * 30 + oy, "white")
        
        draw_rect(gc, 200 + ox, i * 30 - 10 + oy, 60, 20, "white")
        draw_string_plop_both(gc, c2, 230 + ox, i * 30 + oy, "white")
    end
    
    if settings.sz == 1 then
        set_color_mix(gc, "orange", "red", bounce(settings.time, 10))
    else
        set_color(gc, "orange")
    end
    if settings.sx < 2.1 then
        draw_rect(gc, 40 + ox + 2 * round(settings.sx * 40), round(settings.sy * 15) * 2 - 10 + oy, 60, 20)
    end
    
    local y = (#settings.controls + 1) * 30
    set_font(gc, 10)
    draw_string(gc, "About", window_width / 2 + ox, y + oy, "white", "centre")
end

settings.draw[2] = function(gc, ox, oy)
    
    if settings.replay_show then
        
        -- draw number box(es)
        set_font(gc, 11)
        local x = settings.replay_sx + window_width / 2
        local y = 20
        local size = 30
        local c = "white"
        for i = 1, #replays do
            c = "white"
            if settings.replay_tx == i then
                c = set_color_mix(gc, "orange", "red", bounce(settings.time, 10))
            elseif replays[i] ~= nil then
                c = "orange"
            end
            draw_rect(gc, x + ox - size / 2, y + oy - size / 2, size, size, c)
            draw_string(gc, i - 1, x + ox + 1, y + oy, "white", "centre")
            x = x + 30
        end
        draw_polyline(gc, { 0 + ox, 50 + oy, window_width + ox, 50 + oy }, "darkgrey")
        local r = replays[settings.replay_tx]
        local time = #r.s
        local bytes = #r.s + #r.p
        set_font(gc, 11)
        draw_string(gc, "Mode: " .. r.m, window_width / 2, 70 + oy, "white", "centre")
        draw_string(gc, "Frames: " .. tostring(time), window_width / 2, 100 + oy, "white", "centre")
        set_font(gc, 10)
        draw_string(gc, tostring(bytes) .. " bytes", window_width / 2, 160 + oy, "white", "centre")
        
    -- end of replay_show
    else
        
        local c = "white"
        if settings.ty == 1 then
            c = set_color_mix(gc, "orange", "red", bounce(settings.time, 10))
        end
        set_font(gc, 11)
        draw_rect(gc, 110 + ox, 10 + oy, window_width - 220, 25, c)
        c = block_colors[floor(settings.time / 10) % 7 + 1]
        draw_string(gc, "Replay", window_width / 2 + ox, 22.5 + oy, c, "centre")
    
        local g = play.settings.gravity
        if settings.ty == 2 then
            g = settings.tx
        end
        local g_str = g
        if g == 17 then
            g_str = 20
        end
        if g == 20 then
            g_str = "INF"
        end
        
        draw_polyline(gc, { 0 + ox, 50 + oy, window_width + ox, 50 + oy }, "darkgrey")
        
        set_font(gc, 10)
        local y = 75 + oy
        draw_string_plop_left(gc, "Gravity", 10 + ox, y, "white")
        fill_circle(gc, 2, 75 + ox, y, "dimgrey")
        fill_rect(gc, 75 + ox, y - 2, 200, 4, "dimgrey")
        fill_circle(gc, 2, 275 + ox, y, "dimgrey")
        fill_circle(gc, 6, 75 + ox + 10 * g, y, "white")
        draw_string_plop_left(gc, g_str, 290 + ox, y, "white")
        
        local t = play.settings.ghost * 20
        if settings.ty == 3 then
            t = settings.tx
        end
        y = y + 40
        draw_string_plop_left(gc, "Shadow", 10 + ox, y, "white")
        fill_circle(gc, 2, 75 + ox, y, "dimgrey")
        fill_rect(gc, 75 + ox, y - 2, 200, 4, "dimgrey")
        fill_circle(gc, 2, 275 + ox, y, "dimgrey")
        fill_circle(gc, 6, 75 + ox + 10 * t, y, "white")
        draw_string_plop_left(gc, tostring(t * 5) .. "%", 290 + ox, y, "white")
        
        if settings.ty >= 2 and settings.ty <= 3 then
            fill_circle(gc, 6, 75 + ox + round(settings.sx * 10), 2 * round(settings.sy * 20) - 5 + oy, "orange")
        end
    -- end of not replay_show
    end
    
end

settings.draw[3] = function(gc, ox, oy)
    set_font(gc, 11)
    draw_string_plop_both(gc, "this feature is not coming soon", window_width / 2 + ox, window_height - (settings.time * 4) % (window_height - oy + 10), "white")
end

settings.draw[4] = function(gc, ox, oy)
    local tx = round(settings.tx)
    for i = 1, #version_list do
        local v = version_list[i]
        if abs(i - settings.sx) < 0.8 then
            local height = draw_textbox(gc, 20 + window_width * (i - settings.sx) + ox, 45 - settings.sy + oy, window_width - 40, window_height * 100, v, "white", 10, "left")
            if tx == i then
                settings.height = height
            end
        end
    end
    fill_rect(gc, ox, oy - 5, window_width, 35, "black")
    set_font(gc, 11)
    if version_list[tx] ~= nil then
        set_font(gc, 11)
        draw_string(gc, "v" .. version_list[tx].key, window_width / 2 + ox, 15 + oy, "white", "centre")
    end
end
        
settings.draw[5] = function(gc, ox, oy)
    set_font(gc, 11)
    draw_string(gc, "About this game...", window_width / 2 + ox, 15 + oy, "white", "centre")
    -- (gc, x, y, w, h, text, color, font_size, alignment)
    draw_textbox(gc, 20 + ox, 50 + oy, window_width - 40, window_height, settings.about_text, "white", 10, "centre")
end
        
settings.draw[6] = function(gc, ox, oy)
    set_font(gc, 11)
    draw_string(gc, "this feature is not not not coming soon", window_width / 2 + ox, window_height - (settings.time * 4) % (window_height - oy + 10), "white", "centre")
end

settings.draw.login = function(gc, ox, oy)
    set_font(gc, 11)
    fill_rect(gc, 20, 20, window_width - 40, window_height - 40, "dimgrey")
    settings.draw.userpass(gc, ox, oy)
end
    
settings.draw.create = function(gc, ox, oy)
    set_font(gc, 11)
    fill_rect(gc, 20, 20, window_width - 40, window_height - 40, "dimgrey")
    settings.draw.userpass(gc, ox, oy)
end
    
settings.draw.userpass = function(gc, ox, oy)
    
end

function settings.timer()
    settings.time = settings.time + 1
    
    settings.tab = smooth(settings.tab, settings.target_tab, 0.7)
    settings.tab_scroll = smooth(settings.tab_scroll, settings.target_tab_scroll, 1)
    settings.sx = smooth(settings.sx, settings.tx, 0.7)
    settings.sy = smooth(settings.sy, settings.ty, 0.7)
    
    if settings.replay_show then
        settings.replay_sx = smooth(settings.replay_sx, settings.replay_tx, 0.7)
    end
    
    window:invalidate()
end

function settings.charIn(char)
    if settings.target_tab == 1 and settings.sz == 1 then
        settings.sz = 0
        local key = settings.controls[settings.ty]
        key = key:sub(1, key:find("=") - 1)
        if settings.tx == 2 then
            key = key .. "_2"
        end
        if char == "del" then
            play.settings[key] = ""
        else
            play.settings[key] = char
        end
        return
    end

    local dt = 0
    local dx = 0
    local dy = 0
    local dz = false
    local str = ""
    
    if char == play.settings.quit or char == play.settings.quit_2 then
        if settings.login_show then
            settings.login_show = false
            return        
        elseif settings.create_show then
            settings.create_show = false
            return
        elseif settings.replay_show then
            settings.replay_show = false
            return
        elseif settings.target_tab > 3 then
            settings.target_tab = settings.target_tab - 3
            return
        else
            main_menu.start()
        end
    end
    
    if char == "left" or char == "4" then
        dx = -1
    elseif char == "right" or char == "6" then
        dx = 1
    elseif char == "up" or char == "8" then
        dy = -1
    elseif char == "down" or char == "2" then
        dy = 1
    elseif char == "+" then
        dt = -1
    elseif char == "-" then
        dt = 1
    elseif char == "enter" then
        dz = true
    else
        str = char
    end
    
    if dx ~= 0 then
        settings.tx = settings.tx + dx
    elseif dy ~= 0 then
        if settings.target_tab ~= 4 then
            settings.ty = settings.ty + dy
        end
    elseif dz then
        -- handle enter individually
    elseif dt ~= 0 then
        settings.target_tab = (settings.target_tab + dt - 1 + settings.number) % settings.number + 1
        settings.replay_show = false -- if not false, funny behaviour
        
        -- tab init
        if settings.target_tab == 1 then
            settings.target_tab_scroll = 0
            settings.tx = 1
            settings.ty = 1
        elseif settings.target_tab == 2 then
            settings.target_tab_scroll = 0
            settings.ty = 1
            settings.tx = play.settings.gravity
        elseif settings.target_tab == 3 then
            settings.target_tab_scroll = 0
            settings.tx = 1
            settings.ty = 1
        elseif settings.target_tab == 4 then
            settings.target_tab_scroll = 0
            settings.tx = #version_list
            settings.ty = 1
        elseif settings.target_tab == 5 then
            settings.target_tab_scroll = 0
            settings.tx = 1
            settings.ty = 1
        end
    end
    
    if settings.login_show or settings.create_show then
        if char == "backspace" then
            settings.username = string.sub(settings.login_username, 1, -2)
        elseif str ~= "" then
            settings.username = settings.login_username .. str
        end
        return -- skip tab char section
    end
    
    -- tab char
    if settings.target_tab == 1 then
        if settings.tx <= 0 then
            settings.tx = 1
        elseif settings.ty <= 0 then
            settings.ty = 1
        elseif settings.tx >= 3 then
            settings.tx = 2
        elseif settings.ty >= #settings.controls + 1 then
            settings.ty = #settings.controls + 1
            settings.tx = 1.111 -- wow
        else
            settings.tx = floor(settings.tx)
        end
        if settings.ty * 30 - settings.target_tab_scroll > 150 then
            settings.target_tab_scroll = settings.target_tab_scroll + 30
        elseif settings.ty * 30 - settings.target_tab_scroll < 30 then
            settings.target_tab_scroll = settings.target_tab_scroll - 30
        end
        if dz then
            if settings.ty == #settings.controls + 1 then
                settings.target_tab = settings.target_tab + 3
            else
                settings.sz = 1 - settings.sz
            end
        end
    elseif settings.target_tab == 2 then
        if settings.ty == 0 then
            settings.ty = 1
        elseif settings.ty == 1 then
            if settings.replay_show then
                -- todo
                settings.replay_tx = settings.replay_tx + dx
                if settings.replay_tx <= 0 then
                    settings.replay_tx = 1
                elseif settings.replay_tx > #replays then
                    settings.replay_tx = #replays
                end
                if dz then
                    play.start_replay(replays[settings.replay_tx])
                end
            else
                if dz then
                    settings.replay_show = true
                end
            end
        elseif settings.ty == 2 then
            if dy ~= 0 then
                settings.tx = play.settings.gravity
            end
            if dx ~= 0 then
                if settings.tx <= 0 then
                    settings.tx = 1
                elseif settings.tx == 16 then
                    settings.tx = settings.tx + dx
                elseif settings.tx == 18 then
                    settings.tx = 20
                elseif settings.tx == 19 then
                    settings.tx = 17
                elseif settings.tx >= 21 then
                    settings.tx = 20
                end
                play.settings.gravity = settings.tx
            end
        elseif settings.ty == 3 then
            if dy ~= 0 then
                settings.tx = play.settings.ghost * 20
            end
            if dx ~= 0 then
                if settings.tx < 0 then
                    settings.tx = 0
                elseif settings.tx >= 20 then
                    settings.tx = 19
                end
                play.settings.ghost = settings.tx / 20
            end
        elseif settings.ty >= 4 then
            settings.ty = 3
        end
        
    elseif settings.target_tab == 3 then
        
        -- account
        if dz then
            settings.login_show = true
        end
                
    elseif settings.target_tab == 4 then
        
        -- versions
        if settings.tx <= 1 then
            settings.tx = 1
        elseif settings.tx >= #version_list then
            settings.tx = #version_list
        end
        local end_y = settings.height - window_width + 50
        if dy == 1 and settings.ty < end_y then
            settings.ty = settings.ty + 30
        elseif dy == -1 and settings.ty > 1 then
            settings.ty = settings.ty - 30
        end

    elseif settings.target_tab == 5 then
        -- about, do nothing
    end
end

function lb.first_init()

end

function lb.start(tab)
    mode = "lb"
    lb.time = 0
    lb.tab = 0
end

function lb.paint(gc)
    draw_screen(gc, "black")
end

function lb.timer()
    lb.time = lb.time + 1
end

function lb.charIn(char)
    
    if char == "esc" then
        main_menu.start()
    end
    
end


timer.start(0.05)

local number_of_colors = 0
for c in pairs(color) do
    number_of_colors = number_of_colors + 1
end
print("[TEST] Total colours: " .. number_of_colors)

print("[TEST] Retrieving data...")
v.recall()

print("[TEST] Starting menu...")
main_menu.start()

print("�---------- Script initialized! ----------�\n") -- wow, a �
