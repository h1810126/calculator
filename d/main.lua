print("|||||||||||||||||||| TD ||||||||||||||||||||")

local TD = {
    version="2.5", -- wow
}

-- @TD

local window = platform.window
local window_width = window:width()
local window_height = window:height()

------------------------------------------------------------------------------------------- basic math functions ------------------------------------------------------------------------------------------- why so long

-- @math

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

random.randreal = random.rand

random.random_angle = function()
    return random.rand(0, 2 * pi)
end

local vector = {}

-- memory intensive??? don't use
vector.new = function(x, y)
    return {
        x,
        y,
        x = x,
        y = y,
    }
end

vector.new_polar = function(angle, magnitude)
    local magnitude = magnitude or 1
    return vector.multiply(vector.new(cos(angle), sin(angle)), magnitude)
end

vector.x = function(v)
    return v[1]
end

vector.y = function(v)
    return v[2]
end

vector.xy = function(v)
    return v[1], v[2]
end

-- don't use, not using v.x or v.y anymore (use v[1] and v[2])
vector.convert = function(t)
    return vector.new(vector.x(t), vector.y(t))
end

vector.length2 = function(v)
    return v[1] ^ 2 + v[2] ^ 2
end

vector.len2 = vector.length2

vector.length = function(v)
    return sqrt(vector.length2(v))
end

vector.len = vector.length
vector.mag = vector.length

vector.distance2 = function(v1, v2)
    return vector.length2(vector.subtract(v1, v2))
end

vector.dist2 = vector.distance2

vector.distance = function(v1, v2)
    return sqrt(vector.distance2(v1, v2))
end

vector.dist = vector.distance

vector.direction = function(v)
    return math.atan2(v[2], v[1])
end

vector.dir = vector.direction

-- direction of v1 *from* v2
vector.dir_from = function(v1, v2)
    return vector.direction(vector.subtract(v2, v1))
end

-- direction from v1 *to* v2
vector.dir_to = function(v1, v2)
    return vector.direction(vector.subtract(v1, v2))
end

vector.unit = function(v)
    local len = vector.length(v)
    return {
        v[1] / len,
        v[2] / len,
    }
end

vector.add = function(v1, v2)
    return {
        v1[1] + v2[1],
        v1[2] + v2[2],
    }
end

vector.negate = function(v)
    return {
        -v[1],
        -v[2]
    }
end

vector.subtract = function(v1, v2)
    return vector.add(v1, vector.negate(v2))
end

vector.multiply = function(v, k)
    return {
        v[1] * k,
        v[2] * k,
    }
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
    local suffix = suffixes[i]
    
    if suffix == nil then
        suffix = "e" .. (i*3 - 3)
    end
    
    return round_dp(n / (1000 ^ (i - 1)), dp) .. suffix
    
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
    
-- @table

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

-- iterate through table in sorted order (for towers)
local function tower_sorted_pairs(t, order, tower)
    -- collect the keys
    local keys = { }
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order == nil then
        table.sort(keys)
    else
        table.sort(keys, function(a,b) return order(tower, t, a, b) end)
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

local function tower_sorted_keys(t, order, tower)
    -- collect the keys
    local keys = { }
    for k in pairs(t) do keys[#keys+1] = k end
    
    table.sort(keys, function(a,b) return order(tower, t, a, b) end)
    
    return keys
end


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
      for i=self.head+1,self.tail do
        r[i-self.head] = self[i]
      end
      return r
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
    }
    
    local new = function()
      local r = {head = 0, tail = 0}
      return setmetatable(r, {__index = methods})
    end
    
    return {
      new = new,
    }
end

local queue = make_deque()

-- deque test
local test_q = queue.new()
test_q:push_left("i a")
test_q:push_left("ow")
test_q:push_left("m a c")
-- should return "i am a cow"
if (test_q:pop_right() .. test_q:pop_left() .. test_q:pop_right()) == "i am a cow" then
    print("[TEST 1] Queues working!")
end


------------------------------------------------------------------------------------------- the images -------------------------------------------------------------------------------------------

-- @image names

TD.image_names = {
    -- tiles
    
    -- general
    "color_scale"
}

-- @images

TD.images = {}

local function load_images()
    for key, name in pairs(TD.image_names) do
        TD.images[name] = image.new(_R.IMG[name])
    end
end

if pcall(load_images) then
    print("[TEST 2] Images working!")
else
    error("[TEST 2] Images failed!")
end

------------------------------------------------------------------------------------------- the tiles -------------------------------------------------------------------------------------------

-- @tiles

TD.tiles = { }

TD.tiles["  "] = {
    type="blank",
    name="blank",
    image="blank",
    walk=false,
    platform=false,
}

TD.tiles["@@"] = {
    type="spawn",
    name="spawn",
    image="spawn",
    walk=true,
    platform=false,
}

TD.tiles["$$"] = {
    type="base",
    name="base",
    image="base",
    walk=true,
    platform=false,
}

TD.tiles["##"] = {
    type="road",
    name="road",
    image="road",
    walk=true,
    platform=false,
}

TD.tiles["01"] = {
    type="platform",
    name="platform normal",
    image="platform",
    walk=false,
    platform=true,
}

------------------------------------------------------------------------------------------- the levels -------------------------------------------------------------------------------------------

TD.stages = { }

TD.stages.order = {
    "R2", "R1", "0", "1", "2", "3",
}

TD.stages.starting_stage = 3

TD.stages["R1"] = {
    name = "Random #1",
    location = { -200, 200 },
    shape = { -1, -1, 1, -1, 0.7, -0.4, 0.7, 0.4, 1, 1, -1, 1, -0.7, 0.4, -0.7, -0.4, },
    color = { 0.9, 0.7, 0.6 },
    background_color = { 0.1, 0.15, 0.25 },
    rotation_speed = 1,
}

TD.stages["R2"] = {
    name = "Random #2",
    location = { -450, 100 },
    shape = { -1, -1, 1, -1, 0.7, -0.4, 0.7, 0.4, 1, 1, -1, 1, -0.7, 0.4, -0.7, -0.4, },
    color = { 0.9, 0.7, 0.6 },
    background_color = { 0.1, 0.15, 0.25 },
    rotation_speed = -1,
}

TD.stages["0"] = {
    name = "Tutorial",
    location = { 0, 0 },
    shape = { 1, 1, -1, 1, -1, -1, 1, -1 },
    color = { 0.2, 0.2, 0.35 },
    background_color = { 0.7, 0.7, 0.7 },
    rotation_speed = 1,
}

TD.stages["1"] = {
    name = "The Start",
    location = { 300, -10 },
    shape = { 1, 1, 0, 0.8, -1, 1, -0.8, 0, -1, -1, 0, -0.8, 1, -1, 0.8, 0 },
    color = { 0.4, 0.7, 0.4 },
    background_color = { 0.2, 0.2, 0.2 },
    rotation_speed = -2,
}
        
TD.stages["2"] = {
    name = "A Brown Rock",
    location = { 700, 50 },
    shape = { 0.55, -0.62, 0.97, -0.44, 0.89, -0.08, 1.03, 0.35, 0.64, 0.68, 0, 0.85, -0.61, 0.62, -0.93, 0.02, -0.72, -0.73, -0.15, -0.78, 0.2, -0.9, },
    color = { 0.4, 0.32, 0.08 },
    background_color = { 1, 0.61, 0.44 },
    rotation_speed = 2.5,
}
    
TD.stages["3"] = {
    name = "Dart?",
    location = { 1100, -80 },
    shape = { 0, 1, 1, -0.7, 0, -0.5, -1, -0.7 },
    color = { 0.7, 0.7, 0.5 },
    background_color = { 0.1, 0.2, 0.56 },
    rotation_speed = -2,
}



------------------------------------------------------------------------------------------- the maps -------------------------------------------------------------------------------------------

-- @maps

TD.maps = { }

TD.maps["R1"] = {
    map={
        "@@01              01",
        "####01          01  ",
        "01####01      01    ",
        "  01####01  01      ",
        "    01####01        ",
        "      01####01      ",
        "      0101####01    ",
        "    01    01####01  ",
        "  01        01####01",
        "01            01##$$",
    },

    path = {
        {1,1}, {1,2}, {2,2}, {2,3}, {3,3}, {3,4}, {4,4}, {4,5}, {5,5}, {5,6}, {6,6}, {6,7}, {7,7}, {7,8}, {8,8}, {8,9}, {9,9}, {9,10}, {10,10},
    },
    
    enemies = {
        "normal", "slow", "fast",
    },
    
    waves = {
        { t="fast", h=1.5,  d=10,  n=10 }, -- wave 1
        { t="normal", h=1.7,  d=9,   n=10 }, -- wave 2
        { t="slow", h=1.9,  d=8,   n=10 }, -- wave 3
    },
    
    wave_multiplier = 1.25,
}

TD.maps["R2"] = {
    map={
        "    010101010101    ",
        "                    ",
        "                    ",
        "    @@        $$    ",
        "    ##01    01##    ",
        "    ##  0101  ##    ",
        "    ##01    01##    ",
        "    ############    ",
        "                    ",
        "                    ",
        "    010101010101    ",
    },

    path = {
        {3,4}, {3,8}, {8,8}, {8,4},
    },
    
    enemies = {
        "normal", "fast",
    },
    
    waves = {
        { t="normal", h=1,    d=20,  n=20 }, -- wave 1
        { t="normal", h=1.1,  d=18,  n=20 }, -- wave 2
        { t="fast",    h=1.2,  d=16,  n=20 }, -- wave 3
    },
    
    wave_multiplier = 1.25,
}

TD.maps["0"] = {
    map={
        "  01  01  01  01    ",
        "@@################$$",
        "    01  01  01  01  ",
        "                    ",
    },

    path = {
        {1,2}, {10,2},
    },
    
    enemies = {
        "normal",
    },
    
    waves = {
        { t="normal", h=1,  d=3,   n=6 }, -- wave 1
        { t="normal", h=1,  d=3,   n=8 },
        { t="normal", h=1,  d=4,   n=7 },
        { t="normal", h=1,  d=3,   n=15 },
        { t="normal", h=1,  d=4,   n=12 },
        { t="normal", h=1,  d=5,   n=10 },
        { t="normal", h=1,  d=5,   n=11 },
        { t="normal", h=1,  d=5,   n=12 },
        { t="normal", h=2,  d=2,   n=8  },
        { t="normal", h=2,  d=3,   n=5  }, -- wave 10
    },
    
    wave_multiplier = 2,
}

TD.maps["1"] = {
    map = {
        "          01          ",
        "01##################01",
        "    ##0101  0101##    ",
        "    ##01      01##    ",
        "    @@          ####$$",
        "    01            01  ",
    },

    path = {
        {3,5}, {3,2}, {9,2}, {9,5}, {11,5},
    },
    
    enemies = {
        "normal",
    },
    
    -- cycle 20
    waves = {
        { t="normal", h=1,  d=5,   n=10 }, -- wave 1 difficulty 1
        { t="normal", h=1,  d=5,   n=10 }, -- copy
        { t="normal", h=1,  d=6,   n=8 },
        { t="normal", h=1,  d=7.5, n=6 },
        { t="normal", h=1,  d=30,  n=5 }, -- wave 5 mini boss
        { t="normal", h=2,  d=4,   n=5 },
        { t="normal", h=1,  d=7,   n=13 },
        { t="normal", h=6,  d=5,   n=1 }, -- wave 8 mini boss
        { t="normal", h=1,  d=5,   n=20 }, -- wave 9 free money
        { t="normal", h=3,  d=4,   n=5 }, -- wave 10 the end
        { t="normal", h=2,  d=5,   n=10 }, -- wave 11 difficulty 2
        { t="normal", h=2,  d=5,   n=10 }, -- copy
        { t="normal", h=3,  d=4.5, n=6 },
        { t="normal", h=2,  d=6,   n=16 },
        { t="normal", h=2,  d=30,  n=6 }, -- wave 15 mini boss
        { t="normal", h=7,  d=15,  n=2 },
        { t="normal", h=3,  d=5,   n=11 },
        { t="normal", h=12, d=5,   n=1 }, -- wave 18 mini boss
        { t="normal", h=2,  d=6,   n=20 }, -- wave 19 free money
        { t="normal", h=5,  d=3.5, n=10 }, -- wave 20 the end
    },
    
    wave_multiplier = 4,
}

TD.maps["2"] = {
    map = {
        "                      ",
        "  @@01$$############  ",
        "  ##01  0101##  01##  ",
        "  ########  ##    ##  ",
        "  ##01      01    ##  ",
        "  ##0101  01  01  ##  ",
        "  ##################  ",
        "                      ",
    },

    path = {
        {2,2}, {2,7}, {10,7}, {10,2}, {4,2},
    },
    
    enemies = {
        "normal", "slow"
    },
    
    -- cycle 10 (20?)
    waves = {
        { t="normal", h=1.05, d=5,   n=10 }, -- wave 1 difficulty 1
        { t="slow",    h=1.1,  d=5,   n=8 },
        { t="normal", h=1.2,  d=6,   n=8 },
        { t="slow",    h=1.3,  d=7,   n=6 },
        { t="normal", h=1.4,  d=10,  n=5 }, -- wave 5 mini boss
        { t="normal", h=2.5,  d=4,   n=5 },
        { t="slow",    h=1.25, d=6.5, n=15 }, -- free money!
        { t="slow",    h=7.5,  d=5,   n=1 }, -- wave 8 mini boss
        { t="normal", h=1.35, d=5,   n=20 }, -- more free money!
        { t="slow",    h=2.35, d=5,   n=8 }, -- wave 10 the end
        --[[
        { t="slow",    h=2,  d=5,   n=8 }, -- wave 11 difficulty 2
        { t="normal", h=2,  d=5,   n=10 }, -- copy
        { t="normal", h=3,  d=4.5, n=6 },
        { t="normal", h=2,  d=6,   n=16 },
        { t="normal", h=2,  d=30,  n=6 }, -- wave 15 mini boss
        { t="normal", h=7,  d=15,  n=2 },
        { t="normal", h=3,  d=5,   n=11 },
        { t="normal", h=12, d=5,   n=1 }, -- wave 18 mini boss
        { t="normal", h=2,  d=6,   n=20 }, -- wave 19 free money
        { t="normal", h=5,  d=3.5, n=10 }, -- wave 20 the end
        --]]
    },
    
    wave_multiplier = 2,
}

TD.maps["3"] = {
    map = {
        "01                01  ",
        "    01      01        ",
        "  $$################  ",
        "  01  010101  0101##01",
        "  ##################  ",
        "01##0101  010101  01  ",
        "  ################@@  ",
        "        01      01    ",
        "  01                01",
    },

    path = {
        {10,7}, {2,7}, {2,5}, {10,5}, {10,3}, {2,3},
    },
    
    enemies = {
        "normal", "slow", "fast",
    },
    
    -- cycle 10
    waves = {
        { t="normal", h=1.05, d=5,   n=15 }, -- wave 1 difficulty 1
        { t="slow",    h=1.1,  d=6,   n=10 },
        { t="normal", h=1.2,  d=6,   n=10 },
        { t="fast",    h=1.3,  d=7,   n=7 },
        { t="slow",    h=1,    d=60,  n=10 }, -- wave 5 mini boss
        { t="fast",    h=2.4,  d=4,   n=8 },
        { t="normal", h=1.8,  d=5,   n=15 },
        { t="slow",    h=8,    d=10,  n=1 }, -- wave 8 mini boss
        { t="fast",    h=1.25, d=5,   n=30 }, -- free money!
        { t="fast",    h=2.3,  d=5,   n=10 }, -- wave 10 the end
    },
    
    wave_multiplier = 2,
}


------------------------------------------------------------------------------------------- colours -------------------------------------------------------------------------------------------

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

color.platform_gray = {0.5, 0.5, 0.5}
color.road_gray = {0.66, 0.66, 0.66}

-- don't use grey?
color.platform_grey = {0.5, 0.5, 0.5}
color.road_grey = {0.66, 0.66, 0.66}

-- ui
color.ui_button_blue = {0, 0.47, 0.76}
color.ui_button_gray = {0.33, 0.33, 0.38}
color.ui_button_grey = {0.33, 0.33, 0.38}
color.ui_button_red = {0.92, 0.25, 0.20}
color.ui_button_green = {0.26, 0.84, 0.42}
color.ui_button_yellow = {0.99, 0.73, 0.01}
color.ui_button_orange = {0.99, 0.62, 0}
color.ui_button_purple = {0.82, 0.47, 1}
color.ui_coin_yellow = {0.96, 0.75, 0.27}
color.ui_health_red = {0.95, 0.26, 0.21}
color.ui_background_green = {0.63, 1.00, 0.52}
color.ui_background_purple = {0.94, 0.81, 1.00}
color.ui_background_orange = {1, 0.82, 0.53}
color.ui_background_yellow = {0.97, 1, 0.56}
color.ui_background_red = {1, 0.82, 0.87}

-- ui
color.stat_bullet_damage = {1, 0.32, 0.05}
color.stat_tower_damage = {1, 0.32, 0.05}
color.stat_attack_speed = {1, 0.92, 0.05}
color.stat_range = {0.15, 1, 0.24}
color.stat_bullet_number = {0.30, 0.33, 0.89}
color.stat_bullet_speed = {0.99, 0.64, 0.03}
color.stat_big_chance = {0.36, 0.74, 0}
color.stat_big_multiplier = {0.89, 0.30, 0.87}
color.stat_freeze_amount = {0, 0.96, 0.99}
color.stat_freeze_time = {0.42, 0.45, 1}
color.stat_coins_round = {0.96, 0.75, 0.27}
color.stat_coins_multiplier = {0.89, 0.89, 0}
color.stat_explosion_range = {0.81, 0, 0.28}
color.stat_water_range = {0.37, 1, 0.85}
color.stat_water_duration = {0.37, 0.4, 1}

color.play_selections = {
    blank = {0.7, 0.7, 0.7},
    platform = {1, 0.6, 0.1},
    road = {1, 0.3, 0},
    spawn = {0.4, 0.3, 0.8},
    base = {0.6, 0.8, 0.2},
}

for k, v in pairs(color.play_selections) do
    color["select_" .. k] = v
end

for k, v in pairs(TD.stages) do
    if k == "order" or k == "starting_stage" then
        
    else
        color["stage_shape_" .. k] = v.color
        color["stage_background_" .. k] = v.background_color
    end
end

------------------------------------------------------------------------------------------- globals -------------------------------------------------------------------------------------------

-- screen mode
local mode = "menu"

------------------------------------------------------------------------------------------- gc functions -------------------------------------------------------------------------------------------

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
        return color[c]
        
    elseif type(c) == "table" then
        return c
    end
    
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
    print("[TEST 3] RGB-HSL conversion accurate!")
else
    print("[TEST 3] RGB-HSL conversion failed!")
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
    set_color_mix(gc, color_string, {1, 1, 1}, amount)
end

local function draw_image(gc, image_string, x, y, w, h)
    if w == nil and h == nil then
        gc:drawImage(TD.images[image_string], x, y)
    else
        gc:drawImage(image.copy(TD.images[image_string], w, h), x, y)
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
            
    local w = ceil(w)
    local h = ceil(h)
    
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
    
    -- maximise size of rectangle
    local x = floor(x)
    local y = floor(y)
    local w = ceil(w)
    local h = ceil(h)
    
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

local function draw_string(gc, string, x, y, color)
    -- optimisation checks
    if x > window_width or y > window_height or string == nil then
        return
    end
    
    if type(string) == "number" then
        string = number_to_string(string)
    end
    
    set_color(gc, color)
    
    gc:drawString(string, x, y)
    
    _context.draw.string = _context.draw.string + 1
end

local function draw_string_plop(gc, string, x, y, color)
    -- optimisation checks
    if x > window_width or y > window_height or string == nil then
        return
    end
    
    if type(string) == "number" then
        string = number_to_string(string)
    end
    
    set_color(gc, color)
    
    draw_string(gc, string, x - gc:getStringWidth(string) / 2, y)
    
    _context.draw.string = _context.draw.string + 1
end

local function draw_string_plop_both(gc, string, x, y, color)
    -- optimisation checks
    if x > window_width or y > window_height then
        return
    end
    
    if type(string) == "number" then
        string = number_to_string(string)
    end
    
    set_color(gc, color)
    
    draw_string(gc, string, x - gc:getStringWidth(string) / 2, y - gc:getStringHeight(string) / 2)
    
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

local function draw_textbox(gc, x, y, w, h, text, font, color)

    set_color(gc, color)
    set_font(gc, font)
    
    local max_width = w
    
    for key, text in pairs(text) do
        
        if gc:getStringWidth(text) < max_width then
            -- draw the string safely!
            gc:drawString(text, x, y)
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
                gc:drawString(table.concat(text_done, " "), x, y)
                y = y + font * 2
            end
            gc:drawString(table.concat(text_left, " "), x, y)
            y = y + font * 2
        end
    end
    
end

------------------------------------------------------------------------------------------- key to direction functions -------------------------------------------------------------------------------------------
    
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

-- the ACTUAL start of the code @start

------------------------------------------------------------------------------------------- globals -------------------------------------------------------------------------------------------

-- @globals

local menu = {}

local play = {}

local stages = {}

local box = {}

local things = {}

local thing = {}

local raw_accounts = {}

local account = {}

local acc = {}

local profile = {}

local achievements = {}

------------------------------------------------------------------------------------------- the menu code -------------------------------------------------------------------------------------------

menu = {
    camera_y = 0,
    target_y = 0,
    
    pointer_x = 0,
    target_x = 0,
    
    selected = 1,
    
    bounce_time = 0,
    bounce_difference = 0,
}

menu.options = {
    "Play Level", "Inventory", "Upgrades", "Shop", "Account", "Settings",
}

menu.option_widths = {
    -- to be filled in when gc is ready
}

menu.option_colors = {
    "orange", "box_background_2", "yellow", "green", "crimson", "mediumpurple",
}

function menu.start()

    -- clear option widths in case
    menu.option_widths = { }
    
    menu.camera_y = -100
    menu.center_on_selected()
    
    menu.bounce_time = 9

    mode = "menu"
    
    if var.recall("save") == "" then
        menu.options[1] = "Play Level"
    else
        menu.options[1] = "Continue Level"
    end
    
end

function menu.paint(gc)
    menu.draw.background(gc)
    menu.draw.options(gc)
    menu.draw.middleground(gc)
    menu.draw.title(gc)
    menu.draw.foreground(gc)
end

menu.draw = {}

function menu.draw.background(gc)
    draw_screen(gc, "skyblue")
end

function menu.draw.middleground(gc)
    fill_rect(gc, 0, 0, window_width, 60, "mediumspringgreen")
    
    set_font(gc, 12)
    local width = gc:getStringWidth(menu.options[menu.selected])
    
    local color = menu.option_colors[menu.selected]
    
    local bounce = 5 * sin(menu.time / 5)
    
    if menu.bounce_time > 0 then
    
        local bounce_angle = deg_to_rad((17 - menu.bounce_time) / 16 * 180)
        
        bounce = bounce + 30 * sin(bounce_angle) + menu.bounce_difference * menu.bounce_time / 16
        
    end
    
    local x = (window_width - width) / 2 - 15 - bounce
    local y = window_height / 2
    fill_polyline(gc, { x, y, x - 13, y - 5, x - 13, y + 5 }, color, "darkgrey")
    
    local x = (window_width + width) / 2 + 15 + bounce
    local y = window_height / 2
    fill_polyline(gc, { x, y, x + 13, y - 5, x + 13, y + 5 }, color, "darkgrey")
end
    
function menu.draw.title(gc)
    set_font(gc, 15)
    draw_string_middle(gc, "TD", 20, "black")
end

function menu.draw.options(gc)
    set_font(gc, 12)
    for i=1, #menu.options do
    
        local str = menu.options[i]
        
        if i == menu.selected then
            set_font(gc, 12)
        else
            set_font(gc, 10)
        end
        
        draw_string_middle(gc, str, 60 + i * 35 - menu.camera_y, "black")
    end
    
    if #menu.option_widths == 0 then
        for i=1, #menu.options do
            menu.option_widths[i] = gc:getStringWidth(menu.options[i])
        end
    end
end

function menu.draw.foreground(gc)
    draw_border(gc, 10, "slateblue")
end

menu.time = 0

function menu.timer()

    menu.time = menu.time + 1
    
    if menu.bounce_time > 0 then
        menu.bounce_time = menu.bounce_time - 1
    end
    
    menu.camera_y = smooth(menu.camera_y, menu.target_y, 2)
    
    window:invalidate()
    
end

function menu.center_on_selected()
    menu.target_y = menu.selected * 35 - 35
end

function menu.start_bounce(a, b)    
    menu.bounce_time = 16
    menu.bounce_difference = (menu.option_widths[a] - menu.option_widths[b]) / 2
end

function menu.charIn(char)
    
    -- todo: remove
    if char == "enter" then
        if menu.selected == 1 then
            stages.start()
        elseif menu.selected == 2 then
            box.start()
        elseif menu.selected == 5 then
            acc.start()
        end
        
    elseif char == "down" or char == "2" then
        if menu.selected < #menu.options then
            menu.start_bounce(menu.selected, menu.selected + 1)
            menu.selected = menu.selected + 1
        else
            menu.start_bounce(menu.selected, 1)
            menu.selected = 1
        end
        menu.center_on_selected()
        
    elseif char == "up" or char == "8" then
        if menu.selected > 1 then
            menu.start_bounce(menu.selected, menu.selected - 1)
            menu.selected = menu.selected - 1
        else
            menu.start_bounce(menu.selected, #menu.options)
            menu.selected = #menu.options
        end
        menu.center_on_selected()
        
    --[[
    elseif ("1234567890"):find(char) then
        local number = tonumber(char)
        
        if number == 0 then
            number = 10
        end
        
        if number <= #menu.options then
            menu.start_bounce(menu.selected, number)
            menu.selected = number
            menu.center_on_selected()
        end
    --]]
    
    end
    
end


------------------------------------------------------------------------------------------- the play model -------------------------------------------------------------------------------------------

play = {

    -- in pixel coordinates
    camera_x = 0,
    camera_y = 0,
    target_x = 0,
    target_y = 0,

    -- in tile coordinates
    selected_x = 0,
    selected_y = 0,

}

play.tile_size = 32
play.target_tile_size = play.tile_size

-- the drawing stuff
play.draw = {}

-- current map
play.map = {}

-- current path that enemies take
play.path = {}

-- list of enemies
play.enemies = {}

play.enemies_length = 0

-- taken from the map info
play.enemy_types = {}

-- taken from the map info
play.waves = {}

-- the wave multiplier, taken from map info too
play.wave_multiplier = 1

--  the enemy queue
play.enemy_queue = queue.new()

-- pop-ups
play.pop = {}

-- list of towers, works the same as play.enemies
play.towers = {}

play.towers_length = 0

-- stats

play.stats = {
    starting_coins = 150,
    starting_health = 10,
}


-- model: how an enemy works

local enemy = {}

-- enemy type stats
enemy.types = {
    normal = {
        health = 100,
        speed = 5,
        coins = 5,
    },
    slow = {
        health = 175,
        speed = 3,
        coins = 6,
    },
    fast = {
        health = 70,
        speed = 8.5,
        coins = 5,
    },
}

enemy.level_exp = {
    health = 1,
    speed = 0,
    -- a bit better than sqrt
    coins = 0.65,
}

enemy.difficulty = {
    normal = 1,
}

enemy.default_enemy = {
    enemy_type = "normal",
    enemy_level = 1,

    time = 0, -- simple time (in ticks)
    dist = 0, -- increment this by enemy.speed
    lap = 1,
    lap_dist = 0,
    position = {0, 0}, -- this position is calculated
    position_offset = 0,
    direction = {1, 0},
    direction_angle = 0,
    
    freeze_amount = 1,
    freeze_time = 0,
    max_freeze_time = 0,
    
    new = true,
    dead = false,

    -- stats
    stats = {},

    health = 0,
    speed = 1,

}

enemy.draw = {}

--- enemy
color.low_health_red = { 0.67, 0, 0 }
color.high_health_green = { 0.43, 1, 0.15 }

color.enemy_normal = { 0, 0.5, 0 }
color.enemy_slow = { 0.71, 0.37, 0.18 }
color.enemy_fast = { 0.85, 1, 0.17 }

function enemy.draw.health_bar(gc, size, x, y, e, order)
    local health_ratio = max(0, e.health / e.max_health)
    set_color_mix_real(gc, "low_health_red", "high_health_green", health_ratio)
    fill_rect(gc, x - size * 0.1, y - size * (0.16 + order * 0.03), size * 0.2 * health_ratio, size * 0.02)
    return true
end

function enemy.draw.freeze_bar(gc, size, x, y, e, order)
    if e.freeze_time > 0 and e.max_freeze_time > 0 then
        local freeze_ratio = max(0, e.freeze_time / e.max_freeze_time)
        set_color_white(gc, "t_fridge_top", 0.5 * (1 - freeze_ratio))
        fill_rect(gc, x - size * 0.1, y - size * (0.16 + order * 0.03), size * 0.2 * freeze_ratio, size * 0.02)
        return true
    else
        return false
    end
end

function enemy.draw.bars(gc, size, x, y, e)
    local bars = {
        "health_bar", "freeze_bar",
    }
    
    local order = 1
    for i=1, #bars do
        local bar = bars[i]
        local drawn = enemy.draw[bar](gc, size, x, y, e, order)
        if drawn then
            order = order + 1
        end
    end
end

function enemy.draw.normal(gc, size, x, y, e)
    if e ~= nil then
        enemy.draw.bars(gc, size, x, y, e)
    end
    fill_circle(gc, size / 10, x, y, "enemy_normal")
end
    
function enemy.draw.slow(gc, size, x, y, e)
    if e ~= nil then
        enemy.draw.bars(gc, size, x, y, e)
    end
    fill_circle(gc, size / 10, x, y, "enemy_slow")
    -- fill_rect(gc, x - size / 10, y - size / 10, size / 5, size / 5, "enemy_slow")
end

function enemy.draw.fast(gc, size, x, y, e)
    local direction
    if e ~= nil then
        direction = e.direction_angle
        enemy.draw.bars(gc, size, x, y, e)
    else
        direction = -90
    end
    
    fill_circle(gc, size / 10, x, y, "enemy_fast")
    -- fill_polygon(gc, 3, size / 8, x, y, direction, "enemy_fast")
end


enemy.current_id = 1


function enemy.new(enemy_type, enemy_level)
    -- default enemy type = normal
    local enemy_type = enemy_type or "normal"
    local enemy_level = enemy_level or 1

    -- t is the table from the enemy type stats
    -- (a reference to it, do NOT modify!)
    local t = enemy.types[enemy_type]

    -- the new enemy (taken from the default one)
    local new_enemy = deep_copy(enemy.default_enemy)
    
    new_enemy.enemy_type = enemy_type
    new_enemy.enemy_level = enemy_level

    -- load the new enemy with stats from t
    for key, value in pairs(t) do
        new_enemy[key] = value * enemy_level ^ enemy.level_exp[key]
        if key == "speed" then
            new_enemy.speed = new_enemy.speed * enemy.speed_multiplier(enemy_type, enemy_level)
        elseif key == "coins" then
            new_enemy.coins = random_round(new_enemy.coins)
        end
    end

    -- remember the original stats
    new_enemy.stats = fast_copy(t)

    -- just a feature
    new_enemy.max_health = new_enemy.health
    
    -- just another feature, used for first/last targeting
    new_enemy.spawn_time = play.time
    
    -- another feature for wave number calculations
    new_enemy.spawn_wave = play.wave_number - 1
    
    -- offset tile thingy
    new_enemy.position_offset = random.rand(0.15, 0.85)
    
    new_enemy.id = enemy.current_id
    enemy.current_id = enemy.current_id + 1
    
    new_enemy.new = true
    
    return new_enemy
end

function enemy.speed_multiplier(enemy_type, enemy_level)
    return 1
end

function enemy.print_enemy(e)
    -- todo make it better?
    print(table.to_string(e))
end

function enemy.freeze(e, freeze_amount, freeze_time)
    if e.freeze_amount < freeze_amount then
        e.freeze_amount = freeze_amount
    end
    if e.freeze_time < freeze_time then
        e.freeze_time = random_round(freeze_time)
        e.max_freeze_time = e.freeze_time
    end
end

function enemy.move(e)
    assert(e ~= nil)
    if e.dead then
        return false
    end
    
    -- health check
    if e.health <= 0 then
        play.kill_enemy(e)
        return false
    end
    
    e.new = false
    
    e.time = e.time + 1
    
    local distance_moved = e.speed * 0.01
    
    if e.freeze_time > 0 then
        distance_moved = distance_moved / e.freeze_amount
        e.freeze_time = e.freeze_time - 1
        if e.freeze_time == 0 then
            e.freeze_amount = 1
        end
    end
    
    e.dist = e.dist + distance_moved
    e.lap_dist = e.lap_dist + distance_moved
    
    enemy.update_position(e)
    
    return true
end

function enemy.update_position(e)

    local path = play.path
    
    local start_pos, end_pos
    local sx, sy
    local ex, ey
    local cx, cy, length
    local dx, dy
        
    local end_loop = false
    
    while not end_loop do
        start_pos = path[e.lap]
        end_pos = path[e.lap + 1]
        assert(end_pos ~= nil)
                
        sx = start_pos[1]
        sy = start_pos[2]
        
        ex = end_pos[1]
        ey = end_pos[2]
    
        if sx == ex then
            cx = 0
            dx = 0
            cy = ey - sy
            dy = cy / abs(cy)
            
            length = cy
            
        elseif sy == ey then
            cx = ex - sx
            dx = cx / abs(cx)
            cy = 0
            dy = 0
            
            length = cx
            
        else
            error("diagonal path?")
        end
        
        e.direction = {dx, dy}
        e.direction_angle = vector.direction(e.direction)
        
        -- if the enemy exceeded the lap distance
        if e.lap_dist > abs(length) then
            e.lap_dist = e.lap_dist - abs(length)
            e.lap = e.lap + 1
            
            -- if reached the end of the path
            if e.lap == #path then
                -- set position to the end of the path
                e.position = {ex, ey}
                -- and mark the enemy as reached
                e.dead = true
                -- call the appropriate play function
                play.enemy_reached(e)
                return e
            end
        else
            end_loop = true
        end
        
    end

    local x = sx + e.lap_dist * dx + e.position_offset
    local y = sy + e.lap_dist * dy + e.position_offset

    e.position = {x, y}
    
    return e
end


-- the wave generator, unused @generator

local wave_generator = {}

function wave_generator.map_to_number(map)
    
    local num = 0
    local mult = 1
    for y=1, #map do
        local row = map[y]
        for c in row:gmatch(".") do
            num = num + mult * string.byte(c)
            mult = mult + 1
        end
        -- for the purpose of differentiating maps, explanation too long to fit in the margin
        mult = mult + 1
    end
    
    return num
    
end

-- enemy_type: the enemy type (string)
-- difficulty: the decided difficulty for the particular spawn point and wave number in hps (health per second)
-- density: the number of enemies per second coming out of the spawn point
function wave_generator.adjust_stats(enemy_type, difficulty, density)
    -- the actual difficulty the enemies must be in terms of hps
    local real_difficulty = difficulty / enemy.difficulty[enemy_type]
    -- the unit of health that enemy type has to decide on the adjustment on the density
    local health_unit = enemy.types[enemy_type].health
    -- todo
end

-- model: how a bullet works

-- @bullet

-- @draw bullet

play.draw.bullet = {}

function play.draw.bullet.eraser(gc, b)
    local pos = b.position
    local x, y = play.tile_to_pixel(pos[1], pos[2])
    local size = play.tile_size / 15
        
    if b.big then
        size = size * 2
    end
    
    -- todo rotation
    fill_rect(gc, x, y, size, size, "white")
end

function play.draw.bullet.pencil(gc, b)
    local pos = b.position
    local x, y = play.tile_to_pixel(pos[1], pos[2])
    local size = play.tile_size / 15
    
    if b.big then
        size = size * 2
    end
    
    fill_rect(gc, x, y, size, size, "red")
end
    
function play.draw.bullet.air(gc, b)
    local pos = b.position
    local x, y = play.tile_to_pixel(pos[1], pos[2])
    local size = play.tile_size / 15
    
    fill_rect(gc, x, y, size, size, "t_air_orbit")
end

function play.draw.bullet.fridge(gc, b)
    local pos = b.position
    local x, y = play.tile_to_pixel(pos[1], pos[2])
    local size = play.tile_size / 15
    
    fill_rect(gc, x, y, size, size, "t_fridge_top")
end
    
function play.draw.bullet.pen(gc, b)
    local pos = b.position
    local x, y = play.tile_to_pixel(pos[1], pos[2])
    local size = play.tile_size / 15
    
    local color = b.pen_color
    
    if b.big then
        size = size * 1.4
        color = "t_pen_top_orange"
    end
    
    fill_rect(gc, x, y, size, size, color)
end
    
function play.draw.bullet.coin_pile(gc, b)
    local pos = b.position
    local x, y = play.tile_to_pixel(pos[1], pos[2])
    local size = play.tile_size
    
    set_color_mix(gc, "t_coin_pile_centre", "t_coin_pile_base_border", 0.4)
    fill_circle(gc, size * 0.1, x, y)
end

function play.draw.bullet.pillow(gc, b)
    local pos = b.position
    local x, y = play.tile_to_pixel(pos[1], pos[2])
    local size = play.tile_size * 0.5
    
    local pillow_color = { hsl_to_rgb(b.pillow_hue, 1, 0.9) }
    local pillow_shape = rectangle_to_shape(-0.5, -0.5, 1, 1)
    local turn_speed = 0.06
    local rotation = (b.spawn_time + play.all_time) * turn_speed

    fill_shape(gc, pillow_shape, size, x, y, rotation, pillow_color)
    
end

function play.draw.bullet.pillow_residue(gc, b)
    local pos = b.position
    local x, y = play.tile_to_pixel(pos[1], pos[2])
    local size = play.tile_size * b.tower.explosion_range
    local pillow_color = { hsl_to_rgb(b.pillow_hue, 1, 0.9) }
    
    set_color_mix(gc, pillow_color, "road_grey", 1 - b.residue_time / b.residue_length)
    draw_circle(gc, size, x, y)
end

function play.draw.bullet.water(gc, b)
    local pos = b.position
    local x, y = play.tile_to_pixel(pos[1], pos[2])
    local size = play.tile_size
    
    fill_circle(gc, size * 0.1, x, y, "t_water_centre")
end

function play.draw.bullet.water_residue(gc, b)
    local pos = b.position
    local x, y = play.tile_to_pixel(pos[1], pos[2])
    local size = play.tile_size * b.tower.water_range
    
    set_color_mix(gc, "t_water_centre", "road_grey", (1 - b.residue_time / b.residue_length) ^ 10)
    fill_circle(gc, size, x, y)
end

-- @make bullet

local function make_bullet_class()
    
    local b = {}
    
    function b.init(self, t, args)
    
        local args = args or {}
            
        -- stats
        self.damage = t.bullet_damage
        if args.speed == nil then
            self.speed = t.bullet_speed
        else
            self.speed = args.speed
        end
    
        ------------------- init
        -- tower
        self.tower = t
        -- tower type
        self.tower_type = t.tower_type
        -- target
        if args.no_target then
            self.target = nil
            self.rotation = args.rotation
            self.targeting = args.targeting
            
            if args.range == nil then
                self.range = t.range
            else
                self.range = args.range
            end
            
            if args.time_left == nil then
                self.time_left = floor(self.range / self.speed)
            else
                self.time_left = args.time_left
            end
            
        else
            self.target = t.target
            self.rotation = 0
            self.targeting = true
            self.range = -1
            self.time_left = -1
        end
        -- pos
        self.position = { t.position[1], t.position[2] }
        -------------------
        
        -- look
        self.big = false
        
        if args.no_target then
            self.hitbox = t.bullet_size
        else
            self.hitbox = self.speed
        end
        
        self.explosion_range = t.explosion_range
        
        -- freeze
        self.freeze_amount = t.freeze_amount
        self.freeze_time = t.freeze_time
        
        self.residue_length = 0
        self.residue_time = -1
        
        -- bullet id
        bullet.current_id = bullet.current_id + 1
        self.id = bullet.current_id
        
        self.spawn_time = play.time
        
        -- special cases
        
        if self.tower_type == "pen" then
            self.pen_color = play.draw.tower.get_pen_color(t)
        end
        if self.tower_type == "pillow" then
            self.pillow_hue = t.pillow_hue
            self.residue_length = 5
        end
        if self.tower_type == "water" then
            self.pillow_hue = t.pillow_hue
            self.residue_length = t.water_duration
        end
        
    end
    
    function b.move(self)
    
        if self.residue_time < 0 then
    
            if self.target ~= nil then
                local e = self.target
                -- direction of enemy (e) *from* bullet (self)
                local dir = vector.dir_from(e.position, self.position)
                -- visually rotate
                self.rotation = dir
                -- distance vector
                local dist = vector.subtract(e.position, self.position)
                -- unit velocity vector
                local v = vector.unit(dist)
                -- magnitude of velocity vector = speed
                v = vector.multiply(v, self.speed)
                
                -- move to the enemy
                self.position = vector.add(self.position, v)
                        
                -- if can hit, then hit
                if vector.length2(dist) < sqr(self.hitbox) then
                    self:hit(e)
                            
                    if self.explosion_range > 0 then
                        -- check for enemies
                        for i, e1 in pairs(play.enemies) do
                            local dist = vector.subtract(e1.position, self.position)
                            if e1 ~= e and vector.length2(dist) < sqr(self.explosion_range) then
                                self:hit(e1)
                            end
                        end
                    end
                end
                
            else
                local v = vector.new_polar(self.rotation, self.speed)
                -- move straight
                self.position = vector.add(self.position, v)
                
                -- remove if out of range
                if self.time_left ~= -1 then
                    self.time_left = self.time_left - 1
                    if self.time_left <= 0 then
                        self:despawn()
                    end
                end
                
                if self.tower_type == "coin_pile" then
                    self.speed = self.speed * 0.85
                end
                
                if self.targeting then
                    local e = nil
                
                    -- check for enemies
                    for i, e1 in pairs(play.enemies) do
                        local dist = vector.subtract(e1.position, self.position)
                        if vector.length2(dist) <= sqr(self.hitbox) then
                            self:hit(e1)
                            e = e1
                            break
                        end
                    end
                    
                    -- explode! boom!
                    if e ~= nil and self.explosion_range > 0 then
                        -- check for enemies
                        for i, e1 in pairs(play.enemies) do
                            local dist = vector.subtract(e1.position, self.position)
                            if e ~= e1 and vector.length2(dist) < sqr(self.explosion_range) then
                                self:hit(e1)
                            end
                        end
                    end
                    
                end
            end
            
        else
        
            self.residue_time = self.residue_time - 1
            if self.residue_time <= 0 then
                self:despawn()
            end
            
            -- special cases: residue movement or damage (water)?
            
            if self.tower_type == "water" then
                local range = self.tower.water_range
                local damage = self.damage / 5
                -- check for enemies
                for i, e in pairs(play.enemies) do
                    local dist = vector.subtract(e.position, self.position)
                    if vector.length2(dist) < sqr(range) then
                        e.health = e.health - damage
                        self.tower:record_damage(damage, e)
                    end
                end
            end
            
        end
        
    end
    
    function b.hit(self, e)
    
        if self.tower_type ~= "water" and self.tower_type ~= "fridge" then
            e.health = e.health - self.damage
            self.tower:record_damage(self.damage, e)
        end
        
        if self.residue_length > 0 then
            self.position = { e.position[1], e.position[2] }
            self.residue_time = self.residue_length
        else
            self:despawn()
        end
        
        if self.freeze_amount > 0 and self.freeze_time > 0 then
            enemy.freeze(e, self.freeze_amount, self.freeze_time)
        end
    end
    
    function b.make_big(self, mult)
        self.damage = self.damage * mult
        self.big = true
        
        if self.tower_type == "pencil" then
            self.speed = self.speed / 2
            self.hitbox = self.speed
        end
    end
    
    function b.draw(self, gc)
        -- call function to draw the tower!
        if self.residue_time < 0 then
            play.draw.bullet[self.tower_type](gc, self)
        else
            play.draw.bullet[self.tower_type .. "_residue"](gc, self)
        end
    end
    
    function b.despawn(self)
        local remove_id = self.id
        local t = self.tower
        for i, v in pairs(t.bullets) do
            if v.id == remove_id then
                t.bullets[i] = nil
            end
        end
    end
    
    local bullet = {}
    
    bullet.current_id = 1

    function bullet.new(tower, args)
        local new_bullet = {}
        new_bullet = setmetatable(new_bullet, {__index = b})
        new_bullet:init(tower, args)
        return new_bullet
    end
    
    return bullet
end

-- GLOBAL, has to be
bullet = make_bullet_class()


-- model: how a tower works

-- @tower

TD.tower_names = {
    "eraser", "pencil", "air", "fridge", "pen", "coin_pile", "pillow", "water",
}

TD.tower_desc = {
    eraser = {
        "Erases erasable stuff.",
    },
    pencil = {
        "Shoots some pencil lead.",
    },
    air = {
        "Hits all things around it.",
    },
    fridge = {
        "Throws nice cold ice.",
    },
    pen = {
        "Shoots blue, red and green ink.",
    },
    coin_pile = {
        "Gives some coins. Yay!",
    },
    pillow = {
        "Pillows explode. Boom!",
    },
    water = {
        "Splashes some water which lasts for some time.",
    },
}

-- @draw tower

play.draw.tower = {}

color.t_eraser_base = {0.90, 0.45, 0.28}
color.t_eraser_base_border = {0.70, 0.34, 0.21}
color.t_eraser_top_1 = {1, 0.84, 0.74}
color.t_eraser_top_2 = {0.94, 0.90, 0.86}

function play.draw.tower.eraser(gc, x, y, size, direction, time, self)
    fill_rect_size(gc, x, y, size, size, 0.9, "t_eraser_base", "t_eraser_base_border")
    -- fill_rect(gc, x + size * 0.25, y + size * 0.35, size * 0.5, size * 0.3, "t_eraser_top_1", "dimgrey")
    -- fill_rect(gc, x + size * 0.6, y + size * 0.35, size * 0.15, size * 0.3, "t_eraser_top_2", "dimgrey")
    
    local eraser_shape = { -0.25, -0.15, 0.25, -0.15, 0.25, 0.15, -0.25, 0.15 }
    set_color_mix(gc, "t_eraser_top_1", {0.70, 0.34, 0.21}, 0.03 * abs(10 - time % 20))
    fill_shape(gc, eraser_shape, size * 0.9, x + size * 0.5, y + size * 0.5, direction, nil, "dimgrey")
    
    local eraser_front_shape = { 0.10, -0.15, 0.25, -0.15, 0.25, 0.15, 0.10, 0.15 }
    fill_shape(gc, eraser_front_shape, size * 0.9, x + size * 0.5, y + size * 0.5, direction, "t_eraser_top_2", "dimgrey")
end
    
function play.draw.tower.eraser_(gc, x, y, size, self)

end

color.t_pencil_base = {0.95, 0.50, 0.55}
color.t_pencil_base_border = {0.70, 0.34, 0.21}
color.t_pencil_top_1 = {1, 0, 0}
color.t_pencil_top_2 = {0, 0, 0}

function play.draw.tower.pencil(gc, x, y, size, direction, time, self)
    local self = self or { attack_wait = time % 20 * 3 }

    fill_rect_size(gc, x, y, size, size, 0.9, "t_pencil_base", "t_pencil_base_border")
    
    local pencil_shape = { -0.7, 0.15, -0.7, -0.15, 0.65, -0.15, 0.80, 0.00, 0.65, 0.15 }
    fill_shape(gc, pencil_shape, size * 0.5, x + size * 0.5, y + size * 0.5, direction, "t_pencil_top_1")
    
    local pencil_front_shape = { 0.65, -0.15, 0.80, 0.00, 0.65, 0.15 }
    fill_shape(gc, pencil_front_shape, size * 0.5, x + size * 0.5, y + size * 0.5, direction, "t_pencil_top_2")
    
    local position = min(1, self.attack_wait / 60)
    -- rectangle_to_shape(-0.4 + 0.03 * max(0, abs(25 - time % 50) - 5), -0.08, 0.1, 0.15)
    local pencil_slider_shape = rectangle_to_shape(-0.4 + 0.03 * position * 20, -0.08, 0.1, 0.15)
    fill_shape(gc, pencil_slider_shape, size, x + size * 0.5, y + size * 0.5, direction, "dimgrey")
end

function play.draw.tower.pencil_(gc, x, y, size, self)

end

color.t_air_base = {0.80, 0.99, 1.00}
color.t_air_base_border = {0.60, 0.69, 0.80}
color.t_air_centre = {0.55, 0.78, 1.00}
color.t_air_orbit = {0.45, 0.66, 0.99}

function play.draw.tower.air(gc, x, y, size, direction, time, self)
    fill_rect_size(gc, x, y, size, size, 0.9, "t_air_base", "t_air_base_border")
    fill_circle(gc, size * 0.35, x + size * 0.5, y + size * 0.5, "t_air_centre")
    
    local orbit_radius = 0.21
    local orbit_speed = 6
    local orbit_things = 2
    for i=1, orbit_things do
        local angle = time / orbit_speed + (i - 1) * (pi * 2) / orbit_things
        fill_circle(gc, size * 0.1, x + size * (0.5 + sin(angle) * orbit_radius), y + size * (0.5 - cos(angle) * orbit_radius), "t_air_orbit", "dimgrey")
    end
    
end

function play.draw.tower.air_(gc, x, y, size, self)
    
    --[[
    local x = x + size / 2
    local y = y + size / 2
    
    if self.targets ~= nil then
        for i, e in pairs(self.targets) do
            local ex, ey = play.tile_to_pixel(e.position[1], e.position[2])
            local dir = vector.unit(vector.subtract( {ex, ey}, {x, y} ))
            local dx, dy = vector.xy(vector.multiply(dir, size * 0.35))
            draw_polyline(gc, {x + dx, y + dy, ex, ey}, "t_air_centre")
        end
    end
    --]]
    
    if self.targets ~= nil and #self.targets > 0 and self.shoot_draw < 2 then
        draw_circle(gc, self.range * size, x + size / 2, y + size / 2, "t_air_centre")
    end
    
end

color.t_fridge_base = {0.7, 1, 1}
color.t_fridge_base_border = {0.60, 0.69, 0.80}
color.t_fridge_top = {0, 0.40, 0.99}

function play.draw.tower.fridge(gc, x, y, size, direction, time, self)
    fill_rect_size(gc, x, y, size, size, 0.9, "t_fridge_base", "t_fridge_base_border")
    
    local fridge_top_shape = rectangle_to_shape(-0.5, -0.5, 1, 1)
    local turn_speed = 0.07
    fill_shape(gc, fridge_top_shape, size * 0.5, x + size * 0.5, y + size * 0.5, time * turn_speed, "t_fridge_top")
    
    local fridge_shoot_shape = rectangle_to_shape(0, -0.15, 1, 0.3)
    fill_shape(gc, fridge_shoot_shape, size * 0.5, x + size * 0.5, y + size * 0.5, direction, "t_fridge_top")
    
    -- fill_rect_size(gc, x, y, size, size, 0.5, "t_fridge_top")
    -- fill_circle(gc, size * 0.35, x + size * 0.5, y + size * 0.5, "t_fridge_top")
end

function play.draw.tower.fridge_(gc, x, y, size, self)
    
end

color.t_pen_base = {0.75, 0.7, 1}
color.t_pen_base_border = {0.6, 0.55, 0.89}
color.t_pen_top = {0.30, 0.22, 0.97}
color.t_pen_top_blue = {0.20, 0.12, 0.89}
color.t_pen_top_red = {0.97, 0.22, 0.30}
color.t_pen_top_green = {0.30, 0.81, 0.32}
color.t_pen_top_orange = {1, 0.82, 0}

function play.draw.tower.get_pen_color(self)
    local time = 0
    if type(self) == "number" then
        time = self
    else
        time = self.spawn_time + play.all_time
    end
    
    local colors = { "t_pen_top_blue", "t_pen_top_red", "t_pen_top_green", }
    return colors[(floor(time / 9) % 3) + 1]
end

function play.draw.tower.pen(gc, x, y, size, direction, time, self)
    fill_rect_size(gc, x, y, size, size, 0.9, "t_pen_base", "t_pen_base_border")
    
    local pen_shape = { -0.5, 0.15, -0.5, 0.12, -0.7, 0.12, -0.7, -0.12, -0.5, -0.12, -0.5, -0.15, 0.65, -0.15, 0.80, 0.00, 0.65, 0.15 }
    fill_shape(gc, pen_shape, size * 0.5, x + size * 0.5, y + size * 0.5, direction, "t_pen_top")
    
    local pen_click_shape = { -0.5, 0.15, -0.5, 0.12, -0.7, 0.12, -0.7, -0.12, -0.5, -0.12, -0.5, -0.15, -0.35, -0.15, -0.35, 0.15 }
    
    set_color(gc, play.draw.tower.get_pen_color(time))
    fill_shape(gc, pen_click_shape, size * 0.5, x + size * 0.5, y + size * 0.5, direction)
end

function play.draw.tower.pen_(gc, x, y, size, self)
    
end

color.t_coin_pile_base = color.ui_coin_yellow
color.t_coin_pile_base_border = {0.79, 0.38, 0}
color.t_coin_pile_centre = {0.9, 0.9, 0.2}

function play.draw.tower.coin_pile(gc, x, y, size, direction, time, self)
    fill_rect_size(gc, x, y, size, size, 0.9, "t_coin_pile_base", "t_coin_pile_base_border")
    
    fill_circle(gc, size * 0.45 * 0.6, x + size * 0.5, y + size * 0.5, "t_coin_pile_centre")
end

function play.draw.tower.coin_pile_(gc, x, y, size, self)
    
end

color.t_pillow_base = {0.75, 0.31, 0.67}
color.t_pillow_base_border = {0.39, 0.16, 0.35}

function play.draw.tower.pillow(gc, x, y, size, direction, time, self)
    fill_rect_size(gc, x, y, size, size, 0.9, "t_pillow_base", "t_pillow_base_border")
    
    local pillow_shape = rectangle_to_shape(-0.5, -0.5, 1, 1)
    local turn_speed = 0.06
    
    if self == nil then
    
        local pillow_color = { hsl_to_rgb(0.5, 1, 0.94) }
        local pillow_size = 1 / 60 * (time % 60 + 1)
        fill_shape(gc, pillow_shape, size * 0.5 * pillow_size, x + size * 0.5, y + size * 0.5, time * turn_speed, pillow_color)
    
    else
        
        local pillow_color = { hsl_to_rgb(self.pillow_hue, 1, 0.9) }
        local pillow_size = min(1, self.attack_wait / 60)
        fill_shape(gc, pillow_shape, size * 0.5 * pillow_size, x + size * 0.5, y + size * 0.5, time * turn_speed, pillow_color)
    
    end
end

function play.draw.tower.pillow_(gc, x, y, size, self)
    
end

color.t_water_base = {0.58, 0.59, 1}
color.t_water_base_border = {0.38, 0.39, 0.7}
color.t_water_centre = {0.26, 0.35, 1}
color.t_water_centre_2 = {0.41, 1, 0.26}

function play.draw.tower.water(gc, x, y, size, direction, time, self)
    fill_rect_size(gc, x, y, size, size, 0.9, "t_water_base", "t_water_base_border")
    
    local value
    if self == nil then
        value = 1 / 12 * (time % 12 + 1)
    else
        value = bound(0, 1, self.attack_wait / 60)
    end
    
    fill_circle(gc, size * 0.5 * 0.6, x + size * 0.5, y + size * 0.5, "t_water_centre")
    set_color_white(gc, "t_water_centre", 1 - value)
    fill_circle(gc, size * 0.5 * 0.6 * value, x + size * 0.5, y + size * 0.5)
    local water_shoot_shape = rectangle_to_shape(0.4, -0.15, 0.6, 0.3)
    fill_shape(gc, water_shoot_shape, size * 0.5, x + size * 0.5, y + size * 0.5, direction, "t_water_centre")
end

function play.draw.tower.water_(gc, x, y, size, self)
    
end

-- @make tower

local function make_tower_class()

    local t = {}
    
    function t.init(self, tower_type, args)
    
        local args = args or {}
    
        local tower_type = tower_type or "none"
        self.tower_type = tower_type
                
        -- tower stats
        self.stats = tower.new_stats()
        
        -- statistics
        self.total_damage = 0
        self.total_kills = 0
        self.coins_gained = 0
        
        self.total_price = tower.stats[tower_type].price
        
        self.level = 1
        
        self:set_position(play.selected_x, play.selected_y)
        
        -- bullets
        self.bullets = {}
        self.bullets_length = 0
        self.bullet_current_id = 1
        
        -- shooting
        self.attack_wait = 0
        self.shooting = 1
        self.shoot_draw = 1
        
        self:reload_stats()
        
        -- the enemy target
        self.target = nil
        self.target_direction = 0
        self.targeting = "first"
        
        -- tower id
        self.id = tower.current_id
        tower.current_id = tower.current_id + 1
        
        -- tower spawn time
        self.spawn_time = play.time
        
        -- special cases
        if self.tower_type == "pillow" then
            self.pillow_hue = random.rand(0, 1)
        end
        
    end
    
    function t.set_position(self, x, y)
        self.tile_x = x
        self.tile_y = y
        
        -- top left, unused?
        self.top_left_position = { self.tile_x, self.tile_y }
        -- centre
        self.position = { self.tile_x + 0.5, self.tile_y + 0.5}
    end
    
    function t.reload_stats(self)
        self.attack_speed = self:stat("attack_speed")
        self.range = self:stat("range")
        self.bullet_damage = self:stat("bullet_damage")
        self.bullet_speed = self:stat("bullet_speed")
        self.bullet_number = self:stat("bullet_number")
        self.tower_damage = self:stat("tower_damage")
        self.big_chance = self:stat("big_chance")
        self.big_multiplier = self:stat("big_multiplier")
        self.freeze_amount = self:stat("freeze_amount")
        self.freeze_time = self:stat("freeze_time")
        self.coins_round = self:stat("coins_round")
        self.coins_multiplier = self:stat("coins_multiplier")
        self.explosion_range = self:stat("explosion_range")
        self.water_range = self:stat("water_range")
        self.water_duration = self:stat("water_duration")
        
        
        self:reload_upgrade_stats()
    end
    
    function t.draw(self, gc, detail)
        
        local x, y = play.tile_to_pixel(self.tile_x, self.tile_y)
        local size = play.tile_size
        
        -- update the tower direction
        if self.target ~= nil then
            self.target_direction = vector.dir_from(self.position, self.target.position)
        end
                    
        if self:can_upgrade() then
            if play.all_time % 20 >= 10 then
                local time = ((play.all_time % 10) / 10)
                set_color_white(gc, "ui_button_blue", 0.5 * time)
                draw_rect_size(gc, x, y, size, size, 1 + 0.4 * time)
            end
        end
           
        if detail then
            set_global_black(gc, 0.45)
        end
        
        -- call function to draw the tower!
        play.draw.tower[self.tower_type](gc, x, y, size, self.target_direction, play.all_time + self.spawn_time, self)
                
        if detail then
            reset_global_mix(gc)
            
            set_font(gc, bound(6, 255, size * 0.35))
            draw_string_plop_both(gc, self.level, x + size * 0.5, y + size * 0.5, "white")
            
        end
        
        -- draw _
        play.draw.tower[self.tower_type .. "_"](gc, x, y, size, self)
        
        -- see below
        self:draw_bullets(gc)
        
        self.shoot_draw = self.shoot_draw + 1
        
    end
    
    function t.draw_bullets(self, gc)
        for i, b in pairs(self.bullets) do
            b:draw(gc)
        end
        
        -- draw the target, outline red circle
        -- TEST todo REMOVE
        --[[
        if self.target ~= nil then
            local pos = self.target.position
            local x, y = play.tile_to_pixel(pos[1], pos[2])
            draw_circle(gc, play.tile_size / 10, x, y, "red")
        end
        ]]
    end
    
    function t.distance_to_enemy(self, e)
        return vector.distance(e.position, self.position)
    end
    
    function t.check_enemy(self, e)
        if e.dead then
            return false
        else
            return vector.distance2(e.position, self.position) <= sqr(self.range)
        end
    end
    
    function t.get_target(self)
        -- the list of possible enemies (unused (for now))
        local possible = {}
        
        local enemies = play.enemies
                
        -- the targeting function
        local f = self.target_functions[self.targeting]
        
        if self.tower_type == "fridge" then
            f = self.target_functions.fridge
        end
        
        -- the targeted enemy
        local targeted = nil
        for i, e in tower_sorted_pairs(enemies, f, self) do
            if self:check_enemy(e) then
                -- new method
                targeted = e
                break
                
                -- old method (without sorted_pairs)
                --[[
                possible[#possible + 1] = e
                -- if spawn time is even earlier than the earliest time
                if e.spawn_time < earliest_time then
                    targeted = e
                    earliest_time = e.spawn_time
                end
                ]]
            end
        end
        return targeted
    end
    
    function t.check_target(self)
        -- if target does not exist, or target is dead, or target goes out of detection
        if self.target == nil or not self:check_enemy(self.target) then
            self.target = self:get_target()
        end
    end
    
    -- SLOW! don't know why
    function t.shoot(self)
        -- todo attack speed things here
        if self.attack_wait <= 60 then
            self.attack_wait = self.attack_wait + self.attack_speed
        end
                
        self.shooting = self.shooting + 1
        
        local done = false
        while self.attack_wait >= 60 and not done do
            self.shooting = 0
            self.shoot_draw = 0
            if self.bullet_damage ~= 0 then
                done = not self:spawn_bullet()
            end
            if self.tower_damage ~= 0 then
                done = not self:hit_in_range()
            end
        end
    end
            
    function t.hit_in_range(self)
        self.targets = {}
        for i, e in pairs(play.enemies) do
            if self:check_enemy(e) then
                e.health = e.health - self.tower_damage
                self:record_damage(self.tower_damage, e)
                table.insert(self.targets, e)
            end
        end
        if #self.targets > 0 then
            self.attack_wait = self.attack_wait - 60
            return true
        else
            return false
        end
    end
    
    -- damage has been done, record the stats down
    function t.record_damage(self, damage, e)
        self.total_damage = self.total_damage + damage
        if e.health < 0 then
            self.total_kills = self.total_kills + 1
            self.coins_gained = self.coins_gained + e.coins
        end
    end
    
    function t.spawn_bullet_base(self, args)
        -- time eater suspect #2
        local b = bullet.new(self, args)
        
        if self.big_chance > 0 and random.random() < self.big_chance then
            -- big bullet
            b:make_big(self.big_multiplier)
        end
        
        -- time eater suspect #3
        self.bullets_length = self.bullets_length + 1
        self.bullets[self.bullets_length] = b
    end
    
    function t.spawn_bullet(self, args)
        -- time eater suspect #1
        if self.target == nil or not self:check_enemy(self.target) or self.tower_type == "fridge" then
            self.target = self:get_target()
        end
    
        if self.target == nil then
            return false
        end
        
        self:spawn_bullet_base(args)
        
        self.attack_wait = self.attack_wait - 60
                    
        -- special cases: after shoot
        if self.tower_type == "pillow" then
            self.pillow_hue = random.rand(0, 1)
        end
        
        return true
    end
    
    function t.move_bullets(self, gc)
        for i, b in pairs(self.bullets) do
            b:move(gc)
        end
    end
    
    function t.after_round(self)
        if self.coins_round > 0 then
            play.add_coins(self.coins_round, self)
        end
        if self.tower_type == "coin_pile" then
            for i=1, 6 do
                self:spawn_bullet_base({
                    no_target = true,
                    rotation = random.random_angle(),
                    targeting = false,
                    range = 1,
                    speed = random.rand(0.11, 0.18),
                    time_left = random.randint(17, 24),
                })
            end
        end
    end
    
    -- @tower targeting functions
    t.target_functions = {}
    
    function t.target_functions.first(self, t, a, b)
        return a < b
    end
    
    function t.target_functions.last(self, t, a, b)
        return a > b
    end
                    
    function t.target_functions.strong(self, t, a, b)
        return t[a].max_health > t[b].max_health
    end
            
    function t.target_functions.weak(self, t, a, b)
        return t[a].max_health < t[b].max_health
    end
                    
    function t.target_functions.fast(self, t, a, b)
        return t[a].speed > t[b].speed
    end
    
    function t.target_functions.slow(self, t, a, b)
        return t[a].speed < t[b].speed
    end
    
    function t.target_functions.random(self, t, a, b)
        return t[a].position_offset < t[b].position_offset
    end
            
    function t.target_functions.fridge(self, t, a, b)
        if t[a].freeze_time == t[b].freeze_time then
            return self.target_functions[self.targeting](self, t, a, b)
        else
            return t[a].freeze_time < t[b].freeze_time
        end
    end
    
    -- @tower upgrade
    function t.upgrade(self, args)
        for k, v in pairs(self.upgrade_stat_mult) do
            self.stats[k] = self.stats[k] * self.upgrade_stat_mult[k]
        end
        self.total_price = self.total_price * self.upgrade_stats.price
        self.level = self.level + 1
        self:reload_stats()
    end
    
    function t.reload_upgrade_stats(self)
    
        local all = tower.upgrade_stats[self.tower_type]
        local index = ((self.level - 1) % #all) + 1
        self.upgrade_stats = all[index]
        
        self.upgrade_stat_mult = tower.new_stats()
        
        local damage_mult = 1
        for k, v in pairs(self.upgrade_stats) do
            if k ~= "price" then
                local v = v or error("WHAT?")
                local value = self:stat(k) * v
                local max_value = tower.stat_max[k]
                if value > max_value and max_value ~= -1 then
                    damage_mult = damage_mult * value / tower.stat_max[k]
                    v = tower.stat_max[k] / self:stat(k)
                end
                self.upgrade_stat_mult[k] = v
            end
        end
        
        if damage_mult > 1 then
            local damage_stat = "bullet_damage"
            local damage_power = 1
            if tower_type == "air" then
                damage_stat = "tower_damage"
                damage_power = 1
            elseif tower_type == "fridge" then
                damage_stat = "freeze_amount"
                damage_power = 0.5
            elseif tower_type == "coin_pile" then
                damage_stat = "coins_round"
                damage_power = 1
            end
            self.upgrade_stat_mult[damage_stat] = self.upgrade_stat_mult[damage_stat] * (damage_mult ^ damage_power)
        end
        
    end
    
    -- to use: t:stat("bullet_damage")
    function t.stat(self, stat_type)
        local num =
              tower.stats[self.tower_type][stat_type]
            * tower.stats.all[stat_type]
            * self.stats[stat_type]
        return num
    end
            
    -- to use: t:upgrade_stat("bullet_damage")
    function t.upgrade_stat(self, stat_type)
        local num = self:stat(stat_type)
        local mult = self.upgrade_stat_mult[stat_type]
        if mult ~= nil then
            num = num * mult
        end        
        return num
    end
    
    function t.upgrade_price(self)
        local mult = self.upgrade_stats.price
        if mult == nil then
            error("Upgrades must have a price!")
        end
        local price = self.total_price * (mult - 1)
        return price
    end
    
    function t.can_upgrade(self)
        return play.coins >= self:upgrade_price()
    end
    
    -- to use: t:table()
    function t.table(self)
        local table = {
            -- main
            self.tower_type, self.level,
            -- position
            self.tile_x, self.tile_y,
            -- stats
            self.total_damage, self.total_kills, self.coins_gained,
            -- settings
            self.targeting,
            -- abilities todo
        }
        return table
    end
    
    local tower = { }
    
    tower.current_id = 1
    
    function tower.new_stats()
        return {
            attack_speed = 1,
            bullet_damage = 1,
            bullet_number = 1,
            bullet_speed = 1,
            range = 1,
            tower_damage = 1,
            big_chance = 1,
            big_multiplier = 1,
            freeze_amount = 1,
            freeze_time = 1,
            coins_round = 1,
            coins_multiplier = 1,
            explosion_range = 1,
            water_range = 1,
            water_duration = 1,
        }
    end
    
    tower.stat_max = {
        attack_speed = -1,
        bullet_damage = -1,
        bullet_number = -1,
        bullet_speed = 0.75,
        range = 10,
        tower_damage = -1,
        big_chance = 1,
        big_multiplier = -1,
        freeze_amount = -1,
        freeze_time = 250,
        coins_round = -1,
        coins_multiplier = -1,
        explosion_range = -1,
        water_range = 0.5,
        water_duration = 100,
    }
    
    tower.stats = {
        -- global *multipliers*
        all = {
            price = 1,
            sell_multiplier = 1,
            attack_speed = 1,
            bullet_damage = 1,
            bullet_number = 1,
            bullet_speed = 1,
            range = 1,
            tower_damage = 1,
            big_chance = 1,
            big_multiplier = 1,
            freeze_amount = 1,
            freeze_time = 1,
            coins_round = 1,
            coins_multiplier = 1,
            explosion_range = 1,
            water_range = 1,
            water_duration = 1,
        },
        -- @tower stats
        eraser = {
            price = 100,
            sell_multiplier = 0.78,
            attack_speed = 10,
            bullet_damage = 50,
            bullet_number = 1,
            bullet_speed = 0.11,
            range = 2,
            tower_damage = 0,
            big_chance = 0,
            big_multiplier = 0,
            freeze_amount = 0,
            freeze_time = 0,
            coins_round = 0,
            coins_multiplier = 0,
            explosion_range = 0,
            water_range = 0,
            water_duration = 0,
        },
        pencil = {
            price = 180,
            sell_multiplier = 0.72,
            attack_speed = 3,
            bullet_damage = 150,
            bullet_number = 1,
            bullet_speed = 0.3,
            range = 3.2,
            tower_damage = 0,
            big_chance = 0.2,
            big_multiplier = 2,
            freeze_amount = 0,
            freeze_time = 0,
            coins_round = 0,
            coins_multiplier = 0,
            explosion_range = 0,
            water_range = 0,
            water_duration = 0,
        },
        air = {
            price = 150,
            sell_multiplier = 0.75,
            attack_speed = 6,
            bullet_damage = 0,
            bullet_number = 0,
            bullet_speed = 0,
            range = 1.5,
            tower_damage = 30,
            big_chance = 0,
            big_multiplier = 0,
            freeze_amount = 0,
            freeze_time = 0,
            coins_round = 0,
            coins_multiplier = 0,
            explosion_range = 0,
            water_range = 0,
            water_duration = 0,
        },
        fridge = {
            price = 210,
            sell_multiplier = 0.5,
            attack_speed = 5.5,
            bullet_damage = 0.000000001,
            bullet_number = 1,
            bullet_speed = 0.125,
            range = 2.15,
            tower_damage = 0,
            big_chance = 0,
            big_multiplier = 0,
            freeze_amount = 1.3,
            freeze_time = 30,
            coins_round = 0,
            coins_multiplier = 0,
            explosion_range = 0,
            water_range = 0,
            water_duration = 0,
        },
        pen = {
            price = 240,
            sell_multiplier = 0.65,
            attack_speed = 9,
            bullet_damage = 100,
            bullet_number = 1,
            bullet_speed = 0.2,
            range = 2.35,
            tower_damage = 0,
            big_chance = 0.1,
            big_multiplier = 2.5,
            freeze_amount = 0,
            freeze_time = 0,
            coins_round = 0,
            coins_multiplier = 0,
            explosion_range = 0,
            water_range = 0,
            water_duration = 0,
        },
        coin_pile = {
            price = 200,
            sell_multiplier = 0.005,
            attack_speed = 0,
            bullet_damage = 0,
            bullet_number = 0,
            bullet_speed = 0,
            range = 0,
            tower_damage = 0,
            big_chance = 0,
            big_multiplier = 0,
            freeze_amount = 0,
            freeze_time = 0,
            coins_round = 20,
            coins_multiplier = 0,
            explosion_range = 0,
            water_range = 0,
            water_duration = 0,
        },
        pillow = {
            price = 120,
            sell_multiplier = 0.69,
            attack_speed = 1,
            bullet_damage = 555,
            bullet_number = 1,
            bullet_speed = 0.09,
            range = 1.8,
            tower_damage = 0,
            big_chance = 0,
            big_multiplier = 0,
            freeze_amount = 0,
            freeze_time = 0,
            coins_round = 20,
            coins_multiplier = 0,
            explosion_range = 0.25,
            water_range = 0,
            water_duration = 0,
        },
        water = {
            price = 150,
            sell_multiplier = 0.7,
            attack_speed = 5,
            bullet_damage = 70,
            bullet_number = 1,
            bullet_speed = 0.25,
            range = 2.2,
            tower_damage = 0,
            big_chance = 0,
            big_multiplier = 0,
            freeze_amount = 0,
            freeze_time = 0,
            coins_round = 0,
            coins_multiplier = 0,
            explosion_range = 0,
            water_range = 0.25,
            water_duration = 10,
        },
    }
    
    tower.upgrade_stats = {
        eraser = {
            {
                price = 1.4,
                attack_speed = 1.16,
                bullet_speed = 1.15,
            },
            {
                price = 1.3,
                bullet_damage = 1.23,
                range = 1.04,
            },
            {
                price = 1.4,
                attack_speed = 1.05,
                bullet_damage = 1.3,
            },
            {
                price = 1.3,
                bullet_damage = 1.175,
                bullet_speed = 1.04,
                range = 1.03,
            },
        },
        pencil = {
            {
                price = 1.4,
                attack_speed = 1.07,
                bullet_damage = 1.23,
            },
            {
                price = 1.3,
                attack_speed = 1.05,
                bullet_damage = 1.07,
                bullet_speed = 1.07,
                range = 1.05,
            },
            {
                price = 1.4,
                attack_speed = 1.05,
                bullet_damage = 1.22,
                bullet_speed = 1.05,
            },
        },
        air = {
            {
                price = 1.4,
                attack_speed = 1.11,
                tower_damage = 1.21,
            },
            {
                price = 1.4,
                range = 1.045,
                tower_damage = 1.23,
            },
            {
                price = 1.4,
                range = 1.04,
                attack_speed = 1.11,
                tower_damage = 1.14,
            },
        },
        fridge = {
            {
                price = 1.4,
                attack_speed = 1.07,
                bullet_speed = 1.06,
                freeze_time = 1.15,
            },
            {
                price = 1.4,
                freeze_amount = 1.05,
                bullet_speed = 1.06,
                range = 1.08,
            },
            {
                price = 1.5,
                attack_speed = 1.09,
                freeze_amount = 1.065,
                freeze_time = 1.09,
            },
        },
        pen = {
            {
                price = 1.4,
                bullet_damage = 1.2,
                attack_speed = 1.04,
                bullet_speed = 1.09,
            },
            {
                price = 1.4,
                bullet_damage = 1.2,
                attack_speed = 1.06,
                range = 1.04,
            },
            {
                price = 1.4,
                bullet_damage = 1.19,
                attack_speed = 1.05,
                range = 1.03,
                bullet_speed = 1.055,
            },
        },
        coin_pile = {
            {
                price = 1.3,
                coins_round = 1.265,
            },
            {
                price = 1.35,
                coins_round = 1.3,
            },
            {
                price = 1.4,
                coins_round = 1.36,
            },
            {
                price = 1.35,
                coins_round = 1.3,
            },
        },
        pillow = {
            {
                price = 1.3,
                bullet_damage = 1.08,
                attack_speed = 1.08,
                bullet_speed = 1.1,
            },
            {
                price = 1.35,
                bullet_damage = 1.16,
                attack_speed = 1.05,
                range = 1.04,
            },
            {
                price = 1.4,
                bullet_damage = 1.15,
                attack_speed = 1.08,
                bullet_speed = 1.1,
            },
            {
                price = 1.35,
                bullet_damage = 1.26,
                range = 1.045,
            },
        },
        water = {
            {
                price = 1.3,
                bullet_damage = 1.08,
                attack_speed = 1.08,
                water_duration = 1.1,
            },
            {
                price = 1.35,
                bullet_damage = 1.16,
                water_range = 1.025,
                range = 1.04,
            },
            {
                price = 1.4,
                bullet_damage = 1.15,
                attack_speed = 1.04,
                water_range = 1.015,
                water_duration = 1.1,
            },
            {
                price = 1.35,
                bullet_damage = 1.26,
                water_range = 1.005,
                range = 1.045,
            },
        },
    }
    
    tower.stats_order = {
        eraser = {
            "bullet_damage", "attack_speed", "range", "bullet_speed",
        },
        pencil = {
            "bullet_damage", "attack_speed", "range", "bullet_speed", "big_chance | big_multiplier",
        },
        air = {
            "tower_damage", "attack_speed", "range",
        },
        fridge = {
            "attack_speed", "range", "bullet_speed", "freeze_amount", "freeze_time",
        },
        pen = {
            "bullet_damage", "attack_speed", "range", "bullet_speed", "big_chance | big_multiplier",
        },
        coin_pile = {
            "coins_round",
        },
        pillow = {
            "bullet_damage", "attack_speed", "range", "bullet_speed", "explosion_range",
        },
        water = {
            "bullet_damage", "attack_speed", "range", "water_range", "water_duration",
        },
        spray = {
            "bullet_damage", "attack_speed", "range", "bullet_number", "bullet_speed",
        },
    }
    
    tower.draw_stat = {}
    
    function tower.draw_stat.bullet_damage(gc, x, y, size)
    
        --[[
        local x = x + size / 2
        local y = y + size / 2
        
        local blade_1 = { 1, -1, 0.8, -0.95, 0, -0.2, 0.1, -0.1 }
        local blade_2 = { 1, -1, 0.95, -0.8, 0.2, 0, 0.1, -0.1 }
        
        fill_shape(gc, blade_1, size, x, y, 0, "gray")
        fill_shape(gc, blade_2, size, x, y, 0, "darkgray")
        --]]
        
        fill_rect(gc, x, y, size, size, "stat_bullet_damage")
        
    end
    
    function tower.draw_stat.tower_damage(gc, x, y, size)
    
        fill_rect(gc, x, y, size, size, "stat_tower_damage")
        
    end
    
    function tower.draw_stat.attack_speed(gc, x, y, size)
    
        fill_rect(gc, x, y, size, size, "ui_button_yellow")
        
    end
    
    function tower.draw_stat.range(gc, x, y, size)
    
        fill_rect(gc, x, y, size, size, "stat_range")
        
    end
        
    function tower.draw_stat.bullet_speed(gc, x, y, size)
    
        fill_rect(gc, x, y, size, size, "stat_bullet_speed")
        
    end
            
    function tower.draw_stat.bullet_number(gc, x, y, size)
        
        fill_rect(gc, x, y, size, size, "stat_bullet_number")
        
    end
                    
    function tower.draw_stat.big_chance(gc, x, y, size)
        
        fill_rect(gc, x, y, size, size, "stat_big_chance")
        
    end
                    
    function tower.draw_stat.big_multiplier(gc, x, y, size)
        
        fill_rect(gc, x, y, size, size, "stat_big_multiplier")
        
    end
                            
    function tower.draw_stat.freeze_amount(gc, x, y, size)
        
        fill_rect(gc, x, y, size, size, "stat_freeze_amount")
        
    end
                                    
    function tower.draw_stat.freeze_time(gc, x, y, size)
        
        fill_rect(gc, x, y, size, size, "stat_freeze_time")
        
    end
                                            
    function tower.draw_stat.coins_round(gc, x, y, size)
        
        fill_rect(gc, x, y, size, size, "stat_coins_round")
        
    end
                                            
    function tower.draw_stat.coins_multiplier(gc, x, y, size)
        
        fill_rect(gc, x, y, size, size, "stat_coins_multiplier")
        
    end
                                                    
    function tower.draw_stat.explosion_range(gc, x, y, size)
        
        fill_rect(gc, x, y, size, size, "stat_explosion_range")
        
    end
                                                            
    function tower.draw_stat.water_range(gc, x, y, size)
        
        fill_rect(gc, x, y, size, size, "stat_water_range")
        
    end
                                                            
    function tower.draw_stat.water_duration(gc, x, y, size)
        
        fill_rect(gc, x, y, size, size, "stat_water_duration")
        
    end

    function tower.new(tower_type, args)
        local new_tower = {}
        new_tower = setmetatable(new_tower, {__index = t})
        new_tower:init(tower_type, args)
        return new_tower
    end
    
    function tower.new_table(table)
        
        local tower_type, level = table[1], table[2]
        
        local t = play.spawn_tower(tower_type)
        
        for i=1, level - 1 do
            t:upgrade()
        end
        
        t:set_position(table[3], table[4])
        
        t.total_damage = table[5]
        t.total_kills = table[6]
        t.coins_gained = table[7]
        
        t.targeting = table[8]
        
    end
    
    function tower.combine(t1, t2)
        -- ???
    end
    
    -- not unused
    function tower.base_stat(tower_type, stat_type)
        return tower.stats[tower_type][stat_type] * tower.stats.all[stat_type]
    end
    
    tower.target_types = {
        "first", "last", "strong", "weak", "fast", "slow", "random",
    }
    
    return tower
    
end

-- GLOBAL, has to be
tower = make_tower_class()


-- model: how the tile-based system works

-- uses play.camera_x and y
function play.tile_to_pixel(tile_x, tile_y)
    local pixel_x = tile_x * play.tile_size - play.camera_x
    local pixel_y = tile_y * play.tile_size - play.camera_y
    return pixel_x, pixel_y
end

function play.tile_to_camera(tile_x, tile_y)
    local camera_x = (tile_x + 0.5) * play.tile_size - window_width / 2
    local camera_y = (tile_y + 0.5) * play.tile_size - window_height / 2
    return camera_x, camera_y
end

-- other play model-related functions

function play.center_at_selected()
    play.target_x, play.target_y = play.tile_to_camera(play.selected_x, play.selected_y)
end

function play.get_tile(x, y)
    if x < 1 or y < 1 or y > #play.map or x > #play.map[y] then
        return TD.tiles["  "]
    end
    return TD.tiles[play.map[y][x]]
end

function play.add_score(value)
    play.score = play.score + value
end

function play.load_string(str)
    
    local t = deserialize(str)
    
    print(table.to_string(t))
    
    play.main_level = t[1]
    play.coins = t[2]
    play.health = t[3]
    play.wave_number = t[4]
    play.saved_until = play.wave_number
    play.round_until = play.wave_number
    play.score = t[5]
    
    play.towers = { }
    play.towers_length = 0
    
    for i, table in pairs( t[6] ) do
        play.towers_length = play.towers_length + 1
        play.towers[play.towers_length] = tower.new_table(table)
    end
    
    play.things_gained = deserialize(t[7])
    
    return t
    
end

function play.save_string()

    local table = {
        play.main_level,
        play.coins,
        play.health,
        play.wave_number,
        play.score,
    }
    
    local towers = {}
    for i, t in pairs(play.towers) do
        towers[#towers + 1] = t:table()
    end
    
    table[6] = towers
    
    table[7] = serialize(play.things_gained)
    
    return serialize_numbers(table)
    
end

function play.store_save()

    local wave_number = play.get_wave_number()

    -- important - check if there is NO enemies (if not they will be gone after load)
    if play.saved_until < wave_number and play.wave_number > 1 and play.enemy_empty and not play.game_ended then
        
        play.saved_until = wave_number
    
        play.saved_animation = 30
        
        local str = play.save_string()
        var.store("save", str)
        -- clipboard.addText(str)
        
    end
    
    -- do after round
    if play.round_until < wave_number and play.wave_number > 1 and not play.game_ended then
        play.round_until = wave_number
        play.after_round()
    end
    
end

function play.after_round()
    play.score = play.score + play.wave_number * 100
    
    play.add_thing("money", play.wave_number * 30, play.base_position)
    
    for i, t in pairs(play.towers) do
        t:after_round()
    end
end

function play.load_save_from(name)
    play.load_string(var.recall(name))
end


------------------------------------------------------------------------------------------- the play view and controller -------------------------------------------------------------------------------------------

function play.start(level, loaded)
    play.init(level, loaded)
    mode = "play"
end

function play.init(level, loaded)
    local main = TD.maps[level]
    
    play.main_level = level
    
    play.escape = false
    
    play.saved_until = 1
    play.round_until = 1
    
    play.score = 0
        
    play.game_ended = false
    
    play.things_gained = {}
    for i, key in ipairs(box.normal_thing_order) do
        play.things_gained[key] = 0
    end
    
    play.things_queue = queue.new()
    
    -- remove all pop-ups
    
    play.pop.is_active = false
    
    play.end_screen.is_active = false
    
    play.detail = false
    
    -- load map
    
    local map = main.map
    
    play.map = {}
    
    local spawn_x = 1
    local spawn_y = 1
    local base_x = 1
    local base_y = 1
    
    for y=1, #map do
        local row = map[y]
        play.map[y] = {}
        for x=1, #row / 2 do
            local tile = row:sub(x*2 - 1, x*2)
            play.map[y][x] = tile
            if TD.tiles[tile].name:find("spawn") then
                spawn_x = x
                spawn_y = y
            end
            if TD.tiles[tile].name:find("base") then
                base_x = x
                base_y = y
            end
        end
    end
    
    play.selected_x = spawn_x
    play.selected_y = spawn_y
    
    play.spawn_position = { spawn_x, spawn_y }
    play.base_position = { base_x, base_y }
    
    play.center_at_selected()
    play.target_tile_size = 32
    
    -- load path
    
    play.path = fast_copy(main.path)
    
    -- load enemies
        
    play.enemies = { }
    
    play.enemies_length = 0
    
    play.enemy_types = fast_copy(main.enemies)
    
    play.enemy_queue = queue.new()
    
    play.enemy_empty = true
    
    play.lowest_enemy_wave = 0
    
    play.spawn_mode = "normal"
    
    play.saved_animation = 0
    
    -- load waves
    
    local waves = main.waves
    
    play.waves = {}
    
    for n=1, #waves do
        local wave = waves[n]
        local w = {}
        w.enemy_type = wave.t
        w.level = wave.h
        w.density = wave.d
        w.number = wave.n
        play.waves[n] = w
    end
    
    play.wave_number = 1
    
    play.wave_multiplier = main.wave_multiplier
    
    -- load towers
    
    play.towers = {}
    
    play.towers_length = 0
    
    play.tower_numbers = {}
    
    -- load coins and health
    
    play.coins = play.stats.starting_coins
    play.coins_display = play.coins
    play.health = play.stats.starting_health
    
    play.total_coins_gained = 0
    
    -- load time system
    
    play.all_time = 0
    play.time = 0
    play.tick_speed = 1
    
    -- todo anything else to load?
    
    -- yes! load from save if possible
    
    if var.recall("save") ~= "" then
        if loaded then
            play.load_save_from("save")
        else
            var.store("save", "")
        end
    end
    
end

function play.paint(gc)
    play.draw.background(gc)
    if play.pop.is_active then
        play.draw.pop(gc)
    elseif play.end_screen.is_active then
        play.end_screen.paint(gc)
    else
        play.draw.map(gc)
        play.draw.towers(gc)
        play.draw.enemies(gc)
        play.draw.selected(gc)
        play.draw.ui(gc)
        play.draw.things(gc)
    end
    play.draw.foreground(gc)
end

function play.draw.background(gc)
    draw_screen(gc, "lightgrey")
end

function play.draw.foreground(gc)
    draw_border(gc, 10, "slategrey")
end

function play.draw.map(gc)
    local map = play.map
    
    for y=1, #map do
        local row = map[y]
        for x=1, #row do
            local tile = row[x]
            play.draw.tile(gc, tile, x, y)
        end
    end
end

function play.draw.selected(gc)
    local x = play.selected_x
    local y = play.selected_y
    local size = play.tile_size
    local tile_type = play.get_tile(x, y).type
    
    local xx, yy = play.tile_to_pixel(x, y)
    
    draw_rect(gc, xx - 1, yy - 1, size + 1, size + 1, "select_" .. tile_type)
    draw_rect(gc, xx, yy, size - 1, size - 1)
    
    local t = play.get_tower(x, y)
    if t ~= nil and t.range > 0 then
        draw_circle(gc, t.range * size, xx + 0.5 * size, yy + 0.5 * size, "teal")
    end
    
    if tile_type ~= "blank" then
        set_color_black(gc, "select_" .. tile_type, 0.5)
        set_font(gc, 11)
        draw_string_middle(gc, tile_type, window_height - 32)
    end
end

function play.draw.tile(gc, tile, x, y)
    local xx, yy = play.tile_to_pixel(x, y)
    
    local size = play.tile_size
    
    local cx = xx + size / 2
    local cy = yy + size / 2
    
    local tile_symbol = tile
    local tile = TD.tiles[tile]
    if tile == nil then error("invalid tile: " .. tile_symbol) end
    
    local tile_name = tile.name
    -- draw_image(TD.tiles[tile].image, xx, yy)
    
    if tile.walk then
        fill_rect(gc, xx, yy, size, size, "road_gray")
    end
    
    if tile_name == "road" then
        -- fill_rect(gc, xx, yy, size, size, "road_gray")
    elseif tile_name:find("platform") then
        fill_rect_size(gc, xx, yy, size, size, 0.8, "platform_gray")
    elseif tile_name:find("spawn") then
        fill_rect_size(gc, xx, yy, size, size, 0.7, "purple")
        
        if play.spawn_mode ~= "normal" then
            if play.spawn_mode == "auto" then
                set_color(gc, "ui_background_purple")
            elseif play.spawn_mode == "instant" then
                set_color(gc, "ui_button_red")
            end
            fill_rect_size(gc, xx + size * 0.5, yy + size * 0.5, size * 0.5, size * 0.5, 0.6)
        end
        
    elseif tile_name:find("base") then
        fill_polygon(gc, 6, size / 2, cx, cy, 0, "yellow")
    end
end

function play.draw.enemies(gc)
    local enemies = play.enemies
    for i, e in pairs(enemies) do
        play.draw.enemy(gc, e)
    end
end

function play.draw.towers(gc)
    for i, t in pairs(play.towers) do
        if play.detail then
            t:draw(gc, true)
        else
            t:draw(gc)
        end
    end
end

function play.draw.enemy(gc, e)
    if e.new then
        return
    end
    
    local pos = e.position
    local x, y = play.tile_to_pixel(pos[1], pos[2])
    
    -- print(x, y)
    
    -- todo other enemies
    enemy.draw[e.enemy_type](gc, play.tile_size, x, y, e)
end

function play.draw.ui(gc)

    set_font(gc, 11)
    
    fill_circle(gc, 7, 30, 30, "ui_coin_yellow")
    -- set_color_black(gc, "white", 0.7 + 0.3 * (1 - abs(play.coins - play.coins_display) / play.coins))
    draw_string(gc, round(play.coins_display), 42, 19, "black")
    
    local wave_number = play.get_wave_number()
    draw_string(gc, "Wave " .. wave_number, 24, 38, "black")
    
    local tile_type = play.get_tile(play.selected_x, play.selected_y).type
    
    if tile_type == "base" or tile_type == "spawn" then
        
        fill_circle(gc, 7, 100, 30, "ui_health_red")
        draw_string(gc, play.health, 112, 19, "black")
        
    end
    
    draw_rect(gc, 20, 164, 12, 29, "ui_button_blue")
    draw_rect(gc, 19, 163, 14, 31)
    
    if play.tick_speed == 0 then
        set_color_white(gc, "ui_button_red", 0.03 * abs(10 - play.all_time % 20))
        fill_rect(gc, 21, 165, 11, 28)
    else
        set_color_white(gc, "ui_button_green", 0.01 * abs(25 - play.all_time % 50))
        for i=1, play.tick_speed do
            fill_rect(gc, 21, 166 + (3 - i) * 9, 11, 8)
        end
    end
    
    if play.escape then
    
        local x = 45
        local y = 70
        fill_rect(gc, x, y, window_width - x * 2, window_height - y * 2, "ui_background_purple", "dimgrey")
        
        set_font(gc, 11)
        draw_string_middle(gc, "Are you sure you want to exit?", window_height / 2 - 30, "black")
        
        fill_rect(gc, 114, 106, 92, 28, "ui_button_blue")
        draw_string_middle(gc, "Enter", 108, "white")
    
    end
    
    if play.saved_animation > 0 then
    
        play.saved_animation = play.saved_animation - 1
        
        set_font(gc, 11)
        set_color_black(gc, "ui_button_green", 0.4)
        draw_string(gc, "Saved!", 250, 15 - ((22 - play.saved_animation) ^ 2) * 0.6)
        
    end
    
end

function play.draw.things(gc)
    local q = play.things_queue
    if play.tile_size > 36 then
        local stuff = q:contents()
        local size = floor(play.tile_size / 4)
        for i, t in ipairs(stuff) do
            local x, y = play.tile_to_pixel(t.x, t.y)
            local time = play.all_time - t.time
            y = y - time ^ 0.5 * 2
            things[t.key].draw(gc, x - size / 2, y - size / 2, size)
            set_font(gc, 8)
            draw_string(gc, t.number, x + size / 2, y - size / 2, "black")
        end
    end
    while not q:is_empty() and q:peek_right().time + 10 < play.all_time do
        q:pop_right()
    end
end

play.camera_smoothness = 1
play.coin_smoothness = 2.3

function play.timer()

    play.all_time = play.all_time + 1
    
    if play.pop.is_active then
        -- pop-up timer
        play.pop.timer()
    elseif play.end_screen.is_active then
        -- end screen timer
        play.end_screen.timer()
    else
    
        local smoothness = play.camera_smoothness
        
        play.camera_x = smooth(play.camera_x, play.target_x, smoothness)
        play.camera_y = smooth(play.camera_y, play.target_y, smoothness)
        play.tile_size = smooth(play.tile_size, play.target_tile_size, smoothness)
        
        play.coins_display = smooth(play.coins_display, play.coins, play.coin_smoothness)
        
        if play.game_ended then
            play.end_screen.check_timer()
        else
            for i=1, play.tick_speed do
                play.tick()
            end
        end
        
    end
    
    window:invalidate()
end

function play.tick()
    -- increment the time
    play.time = play.time + 1
    
    play.move_enemies()
    
    play.store_save()
    
    play.spawn_enemies()
    
    play.shoot_towers()
    play.move_bullets()
end

function play.move_enemies()
    local empty = true
    local lowest_wave = -1
    for i, e in pairs(play.enemies) do
        local status = enemy.move(e)
        if status then
            empty = false
        end
        if lowest_wave > e.spawn_wave or lowest_wave == -1 then
            lowest_wave = e.spawn_wave
        end
    end
    play.enemy_empty = empty
    play.lowest_enemy_wave = lowest_wave
end

function play.spawn_enemies()

    if play.spawn_mode == "auto" and play.wave_number > 1 then
        if play.enemy_empty and play.enemy_queue:is_empty() then
            play.send_wave()
        end
    elseif play.spawn_mode == "instant" and play.wave_number > 1 then
        if play.enemy_queue:is_empty() then
            play.send_wave()
        end
    end

    if play.enemy_queue:is_empty() then
        return
    end
    
    local end_loop = false
    while not end_loop do
        local thing = play.enemy_queue:peek_right()
        if thing == nil or thing.time > play.time then
            end_loop = true
        else
            local e = enemy.new(thing.enemy_type, thing.enemy_level)
            e.position = fast_copy(play.path[1])
            
            play.spawn_enemy(e)
            play.enemy_queue:pop_right()
        end
    end
    
end

function play.shoot_towers()
    for i, t in pairs(play.towers) do
        t:shoot()
    end
end

function play.move_bullets()
    for i, t in pairs(play.towers) do
        t:move_bullets()
    end
end

function play.spawn_enemy(e)
    play.enemies_length = play.enemies_length + 1
    table.insert(play.enemies, play.enemies_length, e)
    -- enemy.print_enemy(e)
end

function play.despawn_enemy(enemy_to_remove)
    local remove_id = enemy_to_remove.id
    for i, e in pairs(play.enemies) do
        if e.id == remove_id then
            play.enemies[i] = nil
        end
    end
end

function play.kill_enemy(e)

    if e.dead then
        return
    else
        e.dead = true
    end
    
    play.add_coins(e.coins, e)
    
    play.add_thing(e.enemy_type .. "_shape", 1, { e.position[1], e.position[2] - 0.25 } )
    
    play.despawn_enemy(e)
end

function play.enemy_reached(e)
    play.despawn_enemy(e)
    
    -- todo health minus scaling?
    play.health = play.health - 1
    
    -- end game
    if play.health < 1 then
        play.end_game()
    end
    
end

function play.end_game()
    local pos = play.base_position
    play.target_x, play.target_y = play.tile_to_camera(pos[1], pos[2])
    play.tile_resize(10 / play.target_tile_size)
    
    play.tick_speed = 0
    play.game_ended = true
    
    play.end_screen.show_after(20)
    
    var.store("save", "")
end

function play.add_coins(coins, target)
    play.coins = play.coins + coins
    play.total_coins_gained = play.total_coins_gained + coins
    play.add_thing("coin", coins, target.position)
    play.add_score(coins)
end

function play.add_thing(key, num, position)
    play.things_gained[key] = play.things_gained[key] + num
    local t = {
        key = key,
        number = num,
        time = play.all_time,
        x = position[1],
        y = position[2],
    }
    play.things_queue:push_left(t)
    if t.x == nil or t.y == nil then
        error(table.to_string(t))
    end
end

function play.charIn(char)
    
    if play.pop.is_active then
        play.pop.charIn(char)
        return
    elseif play.end_screen.is_active then
        play.end_screen.charIn(char)
        return
    end
    
    if play.escape then
        play.escape = false
        if char == "enter" then
            menu.start()
        else
            return
        end
    end
    
    local size = play.tile_size
    
    -- move x, move y, dx, dy
    local mx, my = dir_to_xy(char)
    local dx, dy = dirnum_to_xy(char)
    
    play.target_x = play.target_x + mx * 32
    play.target_y = play.target_y + my * 32
    
    -- if selection changes
    if (dx ~= 0) or (dy ~= 0) then
    
        play.selected_x = play.selected_x + dx
        play.selected_y = play.selected_y + dy
        play.center_at_selected()
        
    end
    
    if char == "enter" then
        play.char_enter()
        
    elseif char == "−" then
        play.char_alt_enter()
        
    elseif char == " " then
        play.send_wave()
        
    elseif char == "+" and play.target_tile_size < 100 then
        play.tile_resize(1.25)
        
    elseif char == "-" and play.target_tile_size > 8 then
        play.tile_resize(0.8)
        
    elseif char == "=" then
        play.detail = not play.detail
        
    elseif char == "." then
        play.tick_speed = play.tick_speed + 1
        if play.tick_speed > 3 then
            play.tick_speed = 1
        end
    
    elseif char == "0" then
        if play.tick_speed > 0 then
            play.old_tick_speed = play.tick_speed
            play.tick_speed = 0
        else
            play.tick_speed = play.old_tick_speed
        end
        
    elseif char == "*" then
        play.pop.start_spawn(x, y)
        
    elseif char == "/" then
        play.pop.start_base(x, y)
    
    elseif char == "s" then
        play.store_save()
        
    elseif char == "l" then
        play.load_save_from("save")
        
    elseif char == "?" then
        play.end_game()
        
    elseif char == "esc" then
        play.escape = true
        
    elseif char == "sin(" then
        play.coins = play.coins + 1000000
        
    elseif char == "cos(" then
        play.coins = play.coins + 1000000000
            
    elseif char == "tan(" then
        play.coins = play.coins + 1000000000000
    
    end
    
    -- print(char) -- for testing
end

function play.char_enter()
    local x, y = play.selected_x, play.selected_y
    local tile_type = play.get_tile(x, y).type
    
    -- pop-up
    if tile_type == "platform" then
        --[[ todo remove this
        if play.get_tower(x, y) == nil then
            play.spawn_tower("pencil")
        end
        --]]
    elseif tile_type == "spawn" then
        -- todo remove
    end
    
    play.pop.start()
end

function play.char_alt_enter()
    local x, y = play.selected_x, play.selected_y
    local tile_type = play.get_tile(x, y).type
    
    if tile_type == "platform" then
        local t = play.get_tower(x, y)
        
    elseif tile_type == "spawn" then
        
        if play.spawn_mode == "normal" then
            play.spawn_mode = "auto"
        elseif play.spawn_mode == "auto" then
            play.spawn_mode = "instant"
        elseif play.spawn_mode == "instant" then
            play.spawn_mode = "normal"
        end
        
    end
end

function play.spawn_tower(tower_type)
    play.towers_length = play.towers_length + 1
    local t = tower.new(tower_type)
    play.towers[play.towers_length] = t
    play.tower_numbers[tower_type] = (play.tower_numbers[tower_type] or 0) + 1
    return t
end

function play.despawn_tower(tower_to_remove)
    local remove_id = tower_to_remove.id
    for i, t in pairs(play.towers) do
        if t.id == remove_id then
            play.towers[i] = nil
        end
    end
end

function play.get_tower(tile_x, tile_y)
    for i, t in pairs(play.towers) do
        if t.tile_x == tile_x and t.tile_y == tile_y then
            return t
        end
    end
    return nil
end

function play.tile_resize(resize)
    play.target_tile_size = play.target_tile_size * resize
    play.target_x = (play.target_x + window_width / 2) * resize - window_width / 2
    play.target_y = (play.target_y + window_height / 2) * resize - window_height / 2
end

function play.get_wave_number()
    -- if there are no enemies
    if play.enemy_empty or play.lowest_enemy_wave == -1 then
        if play.enemy_queue:is_empty() then
            return play.wave_number
        else
            return play.wave_number - 1
        end
    else
        return play.lowest_enemy_wave
    end
end

function play.get_end_wave_number()
    -- if there are no enemies
    if play.enemy_empty or play.lowest_enemy_wave == -1 then
        if play.enemy_queue:is_empty() then
            return play.wave_number - 1
        else
            return play.wave_number - 2
        end
    else
        return play.lowest_enemy_wave - 1
    end
end


-- not to be confused with play.get_wave_number()
function play.get_wave(wave_number)
    if wave_number < 1 then
        return nil
    end
    
    local length = #play.waves
    local index = (wave_number - 1) % length + 1
    local mult = play.wave_multiplier ^ floor( (wave_number - 1) / length)
    local wave = fast_copy(play.waves[ (wave_number - 1) % #play.waves + 1 ])
    -- floor the level
    wave.level = floor(wave.level * mult)
    return wave
end

function play.send_wave()
    if not play.enemy_queue:is_empty() then
        -- todo remove
        print("enemy queue length nonzero (" .. play.enemy_queue:length() .. ")")
        return
    end
    
    play.enemy_queue = queue.new()
    
    local wave = play.get_wave(play.wave_number)
    
    -- important variables
    local enemy_type = wave.enemy_type
    local enemy_level = wave.level
    -- the real rate it is supposed to be sending at in terms of frames per enemy
    local real_rate = 60 / wave.density
    -- but of course this has to be a nice number because frames are not like time
    local rate = floor(real_rate)
    -- to account for this error there is a chance for the enemies to appear one frame later
    local chance = real_rate - rate
    
    local frame = play.time - rate

    for i=1, wave.number do
        frame = frame + rate
        -- random.seed(frame + random.random())
        if random.random() < chance then
            frame = frame + 1
        end
        play.enemy_queue:push_left( { time = frame, enemy_type = enemy_type, enemy_level = enemy_level } )
    end
    
    play.wave_number = play.wave_number + 1
    
    play.enemy_empty = false
    
    -- testing
    -- print(table.to_string(play.enemy_queue))
end


------------------------------------------------------------------------------------------- tile pop-ups -------------------------------------------------------------------------------------------

play.pop = {
    is_active = false,
    
    tile = "spawn",
    type = "spawn",
}

-- play.pop_vars
play.pv = {}

function play.draw.pop(gc)
    
    local t = play.pop.type
    
    if t == "spawn" then
        play.draw.pop_spawn(gc)
    elseif t == "place" then
        play.draw.pop_place(gc)
    elseif t == "upgrade" then
        play.draw.pop_upgrade(gc)
    elseif t == "base" then
        play.draw.pop_base(gc)
    end
end

function play.draw.pop_spawn(gc)
    -- draw wave background
    fill_rect(gc, 0, 0, 213, window_height, "ui_background_purple")
    set_font(gc, 11)
    draw_string(gc, "Enemy Waves", 67, 16, "black")
    
    -- draw headings
    
    local heading_height = 38
    draw_string_plop(gc, "w", 35, heading_height, "red")
    draw_string_plop(gc, "?", 70, heading_height, "red")
    draw_string_plop(gc, "L", 105, heading_height, "red")
    -- clock
    draw_circle(gc, 7, 140, heading_height + 10, "red")
    draw_polyline(gc, { 140, heading_height + 3, 140, heading_height + 10, 144, heading_height + 14, 140, heading_height + 10 }, "red")
    draw_string_plop(gc, "n", 175, heading_height, "red")
    
    local sel = play.pv.selected
    
    set_font(gc, 11)
    
    local offset = sel - play.wave_number
    if offset > -4 and offset < 3 then
        set_color_black(gc, "ui_background_purple", 0.2)
        fill_rect(gc, 20, 102 - 20 * offset, 178, 20)
    end
            
    set_color_white(gc, "ui_background_purple", 0.4)
    fill_rect(gc, 20, 102, 178, 20)
    
    local i = 1
    for w=sel - 2, sel + 4 do
        local wave = play.get_wave(w)
        
        set_color_black(gc, "select_base", 0.4)
        
        local x = 35
        local y = 60 + (i - 1) * 20
        draw_string_plop(gc, w, x, y)
        
        if wave ~= nil then
            
            x = x + 35
            enemy.draw[wave.enemy_type](gc, 64, x, y + 12)
                                
            set_color_black(gc, "select_spawn", 0.4)
            
            x = x + 35
            draw_string_plop(gc, wave.level, x, y)
          
            x = x + 35
            draw_string_plop(gc, wave.density, x, y)
            
            x = x + 35
            draw_string_plop(gc, wave.number, x, y)
            
        end
                        
        i = i + 1
    end
    
    -- draw spawn point
    
    fill_rect(gc, 241, 0, 40, window_height - 50, "road_gray")
    fill_rect_size(gc, 241, window_height - 90, 40, 40, 0.7, "purple")
    
    draw_rect(gc, 241 - 1, window_height - 90 - 1, 40 + 1, 40 + 1, "select_spawn")
    draw_rect(gc, 241, window_height - 90, 40 - 1, 40 - 1)
    
    local enemies = play.pv.enemies
    local latest
    
    for i=1, #enemies do
        local t = enemies[i]
        local dist = (play.all_time - t.time) * t.speed * 40 * max(1, play.tick_speed)
        if dist >= 0 then
            enemy.draw[t.enemy_type](gc, 40, 241 + t.offset * 40, window_height - 90 - dist)
            latest = t
        end
    end
    
    if latest ~= nil then
    
        fill_circle(gc, 7, 229, window_height - 38, "ui_health_red")
        draw_string(gc, latest.health, 239, window_height - 50, "black")
        fill_circle(gc, 7, 229, window_height - 20, "ui_coin_yellow")
        draw_string(gc, latest.coins, 239, window_height - 32, "black")
        
    end
    
end

function play.draw.pop_place(gc)

    if play.pv.confirm then
    
        play.draw.map(gc)
        play.draw.towers(gc)
        --play.draw.enemies(gc)
        play.draw.selected(gc)
        play.draw.ui(gc)
        
        
        local x, y = play.selected_x, play.selected_y
        local xx, yy = play.tile_to_pixel(x, y)
        local size = play.tile_size
        local t = play.get_tower(x, y)
        
        -- draw range
        if t.range > 0 then
            draw_circle(gc, t.range * size, xx + 0.5 * size, yy + 0.5 * size, "red")
        end
        
        local button_color
        if play.pv.price <= play.coins then
            button_color = "ui_button_green"
        else
            button_color = "ui_button_grey"
        end
        
        if play.pv.back then
            -- draw back button
            set_color_white(gc, "ui_button_red", 0.2 + 0.02 * abs(10 - play.all_time % 20))
            fill_rect(gc, 25, 160, 100, 25, nil, "black")
            draw_string_plop(gc, "Cancel", 75, 160, "black")
            
            -- draw confirm button
            fill_rect(gc, window_width - 125, 160, 100, 25, button_color)
            draw_string_plop(gc, "Confirm", window_width - 75, 160, "black")
        else
            -- draw back button
            fill_rect(gc, 25, 160, 100, 25, "ui_button_red")
            draw_string_plop(gc, "Cancel", 75, 160, "black")
            
            -- draw confirm button
            if button_color == "ui_button_green" then
                set_color_white(gc, button_color, 0.2 + 0.02 * abs(10 - play.all_time % 20))
            else
                set_color_white(gc, button_color, 0.2)
            end
            fill_rect(gc, window_width - 125, 160, 100, 25, nil, "black")
            draw_string_plop(gc, "Confirm", window_width - 75, 160, "black")
        end
    
    else
    
        fill_rect(gc, 0, 0, 178, window_height, "aquamarine")
        draw_string(gc, "Place Tower", 50, 16, "black")
        
        local names = TD.tower_names
        for i=1, #names do
            local name = names[i]
            local x = 16 + 38 * ((i - 1) % 4)
            local y = 45 + 38 * floor((i - 1) / 4)
            play.draw.tower[name](gc, x, y, 32, 0, play.all_time)
            
            -- runs one time
            if play.pv.selected == i then
                -- draw the selected box
                draw_rect(gc, x, y, 31, 31, "select_platform")
                draw_rect(gc, x - 1, y - 1, 33, 33, "select_platform")
                
                -- right bar
                
                -- tower name background
                fill_rect(gc, 178, 0, window_width - 178, 39, "skyblue")
                
                -- tower name
                local tower_name = capitalise(name)
                local width = gc:getStringWidth(tower_name)
                draw_string(gc, tower_name, window_width - (window_width - 178 - width + 10) / 2 - width, 14, "black")
                
                -- separator lines
                draw_polyline(gc, { 178, 0, 178, window_height }, "slateblue")
                draw_polyline(gc, { 178, 39, window_width, 39 }, "slateblue")
                
                -- text description
                draw_textbox(gc, 178 + 10, 42, window_width - 178 - 30, h, TD.tower_desc[name], 10, "black")
                
                -- place tower button
                
                play.pv.price = tower.base_stat(name, "price")
                if play.coins >= play.pv.price then
                    set_color_white(gc, "ui_button_blue", 0.01 * abs(20 - play.all_time % 40))
                else
                    set_color(gc, "ui_button_gray")
                end
                fill_rect(gc, 178 + 10, window_height - 46, window_width - 178 - 30, 26, nil)
                draw_string(gc, "Place", 178 + 20, window_height - 44, "white")
                fill_circle(gc, 6, 178 + 70, window_height - 33, "ui_coin_yellow")
                draw_string(gc, play.pv.price, 178 + 80, window_height - 44, "white")
            end
        end
    end
    
end

function play.draw.pop_upgrade(gc)

    local x, y = play.selected_x, play.selected_y
    local xx, yy = play.tile_to_pixel(x, y)
    local size = play.tile_size
    local t = play.get_tower(x, y)
    
    play.pv.tower = t
    
    fill_rect(gc, 0, 0, 200, window_height, "ui_background_green")
    
    local tower_type = t.tower_type
    local tower_name = capitalise(tower_type)
    local level = t.level
    
    set_font(gc, 12)
    draw_string(gc, tower_name .. " L" .. level, 20, 15, "black")
        
    fill_circle(gc, 6, 130, 26, "ui_coin_yellow")
    draw_string(gc, round(play.coins_display), 140, 15, "dimgrey")
    
    local order = tower.stats_order[tower_type]
    
    local arrow_shape = { -0.5, 0, 0.5, 0, 0.35, 0.15, 0.5, 0, 0.35, -0.15, 0.5, 0 }
    
    -- todo this function
    local draw_stat = function(stat, x, y)
        
        tower.draw_stat[stat](gc, x + 10, y + 2, 20)
        
        local old_stat = t:stat(stat)
        local new_stat = t:upgrade_stat(stat)
        
        if old_stat ~= new_stat and not play.pv.sell_confirm then
            draw_shape(gc, arrow_shape, 20, x + gc:getStringWidth(number_to_string(old_stat)) + 55, y + 11, 0, "dimgrey")
            set_color_black(gc, "stat_" .. stat, 0.4)
            draw_string(gc, new_stat, x + gc:getStringWidth(number_to_string(old_stat)) + 70, y)
        end
        
        set_color_black(gc, "stat_" .. stat, 0.4)
        draw_string(gc, old_stat, x + 40, y)
        
    end
    
    set_font(gc, 11)
    for i=1, #order do
        local stat = order[i]
        
        if stat:find("|") then
        
            local pos = stat:find("|")
            local s1 = stat:sub(1, pos - 2)
            local s2 = stat:sub(pos + 2, #stat)
            
            draw_stat(s1, 10, 20 + 23 * i)
            
            draw_stat(s2, 100, 20 + 23 * i)
            
        else
            
            draw_stat(stat, 10, 20 + 23 * i)
            
        end
    end
    
    -- calculate prices
    play.pv.price = t:upgrade_price()
    
    play.pv.price_same = 0
    for i, t1 in pairs(play.towers) do
        if t1.tower_type == t.tower_type and t1.level == t.level then
            play.pv.price_same = play.pv.price_same + t1:upgrade_price()
        end
    end
    
    play.pv.price_all = 0
    for i, t1 in pairs(play.towers) do
        if t1.tower_type == t.tower_type then
            play.pv.price_all = play.pv.price_all + t1:upgrade_price()
        end
    end
    
    set_font(gc, 10)
    
    if play.pv.sell_confirm then
        
        set_color_white(gc, "ui_button_red", 0.015 * abs(20 - play.all_time % 40))
        
        fill_rect(gc, 15, window_height - 46, 150, 26, nil, "ui_button_red")
        
        play.pv.sell_price = round(t.total_price * tower.stats[t.tower_type].sell_multiplier)
        draw_string(gc, "Sell for", 25, window_height - 44, "white")
        fill_circle(gc, 6, 82, window_height - 33, "ui_coin_yellow")
        draw_string(gc, play.pv.sell_price, 92, window_height - 44, "white")
    
    else
    
        if not play.pv.buy_same then
            
            if play.coins >= play.pv.price then
                set_color_white(gc, "ui_button_blue", 0.01 * abs(20 - play.all_time % 40))
            else
                set_color(gc, "ui_button_gray")
            end
            
            fill_rect(gc, 15, window_height - 46, 150, 26, nil, "ui_button_blue")
            
            if play.coins >= play.pv.price_same then
                set_color_white(gc, "ui_button_purple", 0.015 * abs(20 - play.all_time % 40))
                fill_rect(gc, 150, window_height - 45, 15, 25)
            end
                   
            draw_string(gc, "Upgrade", 25, window_height - 44, "white")
            fill_circle(gc, 6, 85, window_height - 33, "ui_coin_yellow")
            draw_string(gc, round(play.pv.price), 95, window_height - 44, "white")
            
        else
        
            if play.coins >= play.pv.price_same then
                set_color_white(gc, "ui_button_purple", 0.01 * abs(20 - play.all_time % 40))
            else
                set_color(gc, "ui_button_gray")
            end
            
            fill_rect(gc, 15, window_height - 46, 150, 26, nil, "ui_button_purple")
            
            if play.coins >= play.pv.price then
                set_color_white(gc, "ui_button_blue", 0.015 * abs(20 - play.all_time % 40))
                fill_rect(gc, 150, window_height - 45, 15, 25)
            end
            
            draw_string(gc, "Upgrade", 25, window_height - 44, "white")
            fill_circle(gc, 6, 85, window_height - 33, "ui_coin_yellow")
            draw_string(gc, round(play.pv.price_same), 95, window_height - 44, "white")
            
        end
        
    end
    
    local types = tower.target_types
    
    -- just opened
    if play.pv.selected == 0 then
        -- find the correct one to select
        for i=1, #types do
            if types[i] == t.targeting then
                play.pv.selected = i
                break
            end
        end
    end
    
    for i=1, #types do
        if play.pv.selected == i then
            set_color(gc, "black")
            set_font(gc, 12)
        else
            set_color(gc, "dimgrey")
            set_font(gc, 10)
        end
        draw_string_plop(gc, types[i], 244, 20 + 20 * (i - 1))
    end
    
    if play.pv.sell_confirm then
        fill_rect(gc, 244 - 32, window_height - 46, 64, 26, "ui_button_blue")
        set_font(gc, 10)
        draw_string_plop(gc, "Upgrade", 244, window_height - 44, "white")
    
    else
        fill_rect(gc, 244 - 20, window_height - 46, 40, 26, "ui_button_red")
        set_font(gc, 10)
        draw_string_plop(gc, "Sell", 244, window_height - 44, "white")
        
    end
    
    -- orange background?
    fill_rect(gc, 290, 0, 30, window_height, "ui_background_purple")
    
end

function play.draw.pop_base(gc)
    
    -- draw things
    local xi = 1
    local yi = 1
    set_font(gc, 10)
    for i, key in pairs(play.pv.thing_order) do
        local num = play.things_gained[key]
        if num ~= 0 then
            local t = things[key]
            local x = 50 * xi - 30
            local y = 60 * yi - play.pv.camera_y - 30
            local w = 40
            local h = 50
            
            -- thing background
            set_color_white(gc, thing.rarity_colors[t.rarity], 0.2)
            fill_rect(gc, x, y, w, h)
            
            -- the thing itself
            t.draw(gc, x + 4, y + 2, 32)
            
            draw_string_plop(gc, num, x + w * 0.5, y + h * 0.6, "black")
                        
            -- draw selected, if it is
            if i == play.pv.selected then
                set_color_mix(gc, "box_select", "lightgrey", (abs(10 - (play.pv.select_time % 20)) / 10) ^ 2)
                draw_rect(gc, x, y, w, h)
                draw_rect(gc, x - 1, y - 1, w + 2, h + 2)
            end
            
            if xi == 6 then
                xi = 1
                yi = yi + 1
            else
                xi = xi + 1
            end
        end
    end
    
    -- cover up some things that overflowed up into the health bar's position
    fill_rect(gc, 0, 0, window_width, 55, "lightgrey")
    
    -- draw health bar
    set_font(gc, 11)    
    set_color_black(gc, "ui_health_red", 0.3)
    draw_string(gc, "Health", 20, 20)
    
    local xx = 26 + gc:getStringWidth("Health")
    local yy = 21
    local health_ratio = play.pv.health / play.stats.starting_health
    
    draw_rect(gc, xx, yy, 160, 20, "ui_health_red")
    draw_rect(gc, xx - 1, yy - 1, 162, 22, "ui_health_red")
    set_color_white(gc, "ui_health_red", 0.1 + 0.03 * abs(10 - (play.pv.time % 20)))
    fill_rect(gc, xx + 1, yy + 1, 159 * health_ratio, 19)
    set_color_black(gc, "ui_health_red", 0.2)
    draw_string(gc, play.health .. " / " .. play.stats.starting_health, 235, 20)
    
end

function play.pop.start()
    local x = play.selected_x
    local y = play.selected_y
    local tile = play.get_tile(x, y)

    local tile_type = tile.type
        
    play.pop.tile = tile_type
        
    if tile_type == "blank" then
        return
    end
    
    if tile_type == "spawn" then
        play.pop.start_spawn(x, y)
    elseif tile_type == "platform" then
        play.pop.start_platform(x, y)
    elseif tile_type == "base" then
        play.pop.start_base(x, y)
    end
    
    -- todo road popups
    
end

function play.pop.init(x, y)
    -- general pop-up init here
    play.pop.is_active = true
end

function play.pop.stop()
    play.pop.is_active = false
end

function play.pop.start_spawn(x, y)
    play.pop.init(x, y)
    
    play.pop.type = "spawn"
    play.pv.selected = play.get_wave_number()
    --[[
    if play.wave_number > #play.waves then
        play.pv.selected = #play.waves
    end
    --]]
    play.pop.spawn_demo()
end

function play.pop.start_platform(x, y)
    play.pop.init(x, y)
    
    if play.get_tower(x, y) == nil then
        play.pop.start_place(x, y)
    else
        play.pop.start_upgrade(x, y)
    end
end

function play.pop.start_place(x, y)
    play.pop.init(x, y)
    
    play.pop.type = "place"
    play.pv.selected = 1
    play.pv.price = 0
    play.pv.confirm = false
    play.pv.back = false
end

function play.pop.start_upgrade(x, y)
    play.pop.init(x, y)
    
    play.pop.type = "upgrade"
    play.pv.tower = nil
    play.pv.price = 0
    play.pv.price_same = 0
    play.pv.price_all = 0
    play.pv.sell_price = 0
    
    play.pv.buy_same = false
    play.pv.buy_all = false
    play.pv.sell_confirm = false
    
    play.pv.selected = 0
end
    
function play.pop.start_base(x, y)
    play.pop.init(x, y)
    
    play.pop.type = "base"
    
    play.pv.selected = 1
    play.pv.select_time = 10
    
    play.pv.camera_y = 60
    play.pv.target_y = -60
    
    play.pv.thing_order = {}
    local index = 1
    local sort_function = function(t, a, b)
        return things[a].value * t[a]
                         >
               things[b].value * t[b]
    end
    for key, num in sorted_pairs(play.things_gained, sort_function) do
        if num ~= 0 then
            play.pv.thing_order[index] = key
            index = index + 1
        end
    end
    
    play.pv.health = 0
    
    play.pv.time = 0
end

function play.pop.timer()
    
    local t = play.pop.type
    
    if t == "spawn" then
        play.pop.tick_spawn(char)
    elseif t == "place" then
        play.pop.tick_place(char)
    elseif t == "upgrade" then
        play.pop.tick_upgrade(char)
    elseif t == "base" then
        play.pop.tick_base(char)
    end
    
end

function play.pop.tick_spawn(char)
    
end

function play.pop.tick_place(char)
    if play.pv.confirm then
    
        local smoothness = play.camera_smoothness
    
        play.camera_x = smooth(play.camera_x, play.target_x, smoothness)
        play.camera_y = smooth(play.camera_y, play.target_y, smoothness)
        play.tile_size = smooth(play.tile_size, play.target_tile_size, smoothness)
        
        play.coins_display = smooth(play.coins_display, play.coins - play.pv.price, play.coin_smoothness)
        
    else
        play.coins_display = play.coins
    end
end

function play.pop.tick_upgrade(char)
    play.coins_display = smooth(play.coins_display, play.coins, play.coin_smoothness)
end

function play.pop.tick_base(char)
    play.pv.time = play.pv.time + 1
    play.pv.select_time = play.pv.select_time + 1

    play.pv.camera_y = smooth(play.pv.camera_y, play.pv.target_y, 1.25)
    play.pv.health = smooth(play.pv.health, play.health, 2.5)
end


function play.pop.charIn(char)

    local t = play.pop.type
    
    if t == "spawn" then
        play.pop.char_spawn(char)
    elseif t == "place" then
        play.pop.char_place(char)
    elseif t == "upgrade" then
        play.pop.char_upgrade(char)
    elseif t == "base" then
        play.pop.char_base(char)
    end
    
end

function play.pop.char_spawn(char)
    
    if char == "esc" then
        play.pop.stop()
    end

    local dx, dy = dir_to_xy(char_to_dir(char))
    
    local sel = play.pv.selected
    sel = sel + dy
    
    if sel < 1 --[[or sel > #play.waves]] then
        -- do nothing
    elseif dx ~= 0 or dy ~= 0 then
        play.pv.selected = sel
        play.pop.spawn_demo()
    end
    
    if char == "enter" then
        play.send_wave()
        play.pop.stop()
    end
    
end

function play.pop.char_place(char)
    
    if play.pv.confirm then
    
        if char == "enter" then
            if play.pv.back then
                char = "esc"
            elseif play.coins >= play.pv.price then
                play.coins = play.coins - play.pv.price
                play.pop.stop()
            end
        end
        
        if char == "esc" then
            play.despawn_tower(play.get_tower(play.selected_x, play.selected_y))
            play.pv.confirm = false
            play.pv.back = false
        end
        
        if ("46"):find(char) then
            play.pv.back = not play.pv.back
        end
        
        local dx, dy = dir_to_xy(char)
        
        play.target_x = play.target_x + dx * play.tile_size
        play.target_y = play.target_y + dy * play.tile_size
        
        if char == "+" and play.target_tile_size < 100 then
            play.tile_resize(1.25)
            
        elseif char == "-" and play.target_tile_size > 8 then
            play.tile_resize(0.8)
            
        end
    
    else
    
        if char == "esc" then
            play.pop.stop()
        end

        local dx, dy = dirnum_to_xy_extended(char)
        
        local sel = play.pv.selected
        sel = sel + dx + dy * 4
        
        if sel < 1 or sel > #TD.tower_names then
            return
        else
            play.pv.selected = sel
        end
        
        if char == "enter" --[[and play.coins >= play.pv.price]] then
            play.spawn_tower(TD.tower_names[sel])
            play.pv.confirm = true
            -- auto-select back button if cannot buy
            play.pv.back = play.coins < play.pv.price
        end
        
    end
    
end

function play.pop.char_upgrade(char)

    if char == "enter" then
        if play.pv.sell_confirm then
            play.coins = play.coins + play.pv.sell_price
            play.despawn_tower(play.pv.tower)
            play.pop.stop()
            
        elseif play.coins >= play.pv.price then
            if not play.pv.buy_same then
                -- upgrade
                play.coins = play.coins - round(play.pv.price)
                play.pv.tower:upgrade()
            else
                -- upgrade
                play.coins = play.coins - round(play.pv.price_same)
                for i, t in pairs(play.towers) do
                    if t.tower_type == play.pv.tower.tower_type then
                        t:upgrade()
                    end
                end
            end
            
        end
    end
    
    if char == "−" then
        play.pv.buy_same = not play.pv.buy_same
    end
    
    if char == "." then
        play.pv.sell_confirm = not play.pv.sell_confirm
    end
    
    local dir = char_to_dir(char)
    
    local dx = 0
    
    if dir == "down" then
        dx = 1
    elseif dir == "up" then
        dx = -1
    end
    
    if dx ~= 0 then
    
        play.pv.selected = play.pv.selected + dx
        if play.pv.selected == 0 then
            play.pv.selected = #tower.target_types
        elseif play.pv.selected == #tower.target_types + 1 then
            play.pv.selected = 1
        end
        
        play.pv.tower.targeting = tower.target_types[play.pv.selected]
        
    end
    
    if char == "esc" then
        play.pop.stop()
    end
end

function play.pop.char_base(char)

    local dx, dy = dirnum_to_xy_extended(char_to_dirnum(char))
    local dd = dx + dy * 6
    if dd ~= 0 then
        play.pv.selected = bound(1, #play.pv.thing_order, play.pv.selected + dd)
        play.pv.select_time = 10
        play.pv.target_y = floor((play.pv.selected - 7) / 6) * 60
    end
    
    if char == "esc" then
        play.pop.stop()
    end
    
end

-- returns list of enemies
function play.pop.spawn_demo()

    local enemies = {}
    local sel = play.pv.selected
    
    local wave = play.get_wave(sel)
    
    -- important variables
    local enemy_type = wave.enemy_type
    -- the real rate it is supposed to be sending at in terms of frames per enemy
    local real_rate = 60 / wave.density / play.tick_speed
    -- but of course this has to be a nice number because frames are not like time
    local rate = floor(real_rate)
    -- to account for this error there is a chance for the enemies to appear one frame later
    local chance = real_rate - rate
    
    local frame = play.all_time - rate

    for i=1, wave.number do
        frame = frame + rate
        -- random.seed(frame + random.random())
        if random.random() < chance then
            frame = frame + 1
        end
        
        local speed = enemy.types[enemy_type].speed * (wave.level ^ enemy.level_exp["speed"]) * enemy.speed_multiplier(enemy_type, wave.level) * 0.01
        local health = enemy.types[enemy_type].health * (wave.level ^ enemy.level_exp["health"])
        local coins = enemy.types[enemy_type].coins * (wave.level ^ enemy.level_exp["coins"])
        
        local real_coins = floor(coins)
        local remainder_coins = coins - real_coins
        if random.random() < remainder_coins then
            real_coins = real_coins + 1
        end
        
        enemies[i] = { time = frame, enemy_type = enemy_type, offset = random.randreal(0.2, 0.8), speed = speed, health = health, coins = real_coins }
    end
    
    play.pv.demo_start_time = play.all_time
    play.pv.enemies = enemies
    
    return enemies
    
end

-- @end screen

play.end_screen = {
    is_active = false,
    show_time = -1,
    
    selected = 1,
    select_time = 9,
    
    camera_y = 0,
    target_y = 0,
    
    thing_order = {},
}

function play.end_screen.paint(gc)

    draw_screen(gc, "ui_background_purple")
    
    local xi = 1
    local yi = 1
    set_font(gc, 10)
    for i, key in pairs(play.end_screen.thing_order) do
        local num = play.things_gained[key]
        if num ~= 0 then
            local t = things[key]
            local x = 50 * xi - 30
            local y = 60 * yi - play.end_screen.camera_y
            local w = 40
            local h = 50
            
            -- thing background
            set_color_white(gc, thing.rarity_colors[t.rarity], 0.2)
            fill_rect(gc, x, y, w, h)
            
            -- the thing itself
            t.draw(gc, x + 4, y + 2, 32)
            
            draw_string_plop(gc, num, x + w * 0.5, y + h * 0.6, "black")
                        
            -- draw selected, if it is
            if i == play.end_screen.selected then
                set_color_mix(gc, "box_select", "lightgrey", (abs(10 - (play.end_screen.select_time % 20)) / 10) ^ 2)
                draw_rect(gc, x, y, w, h)
                draw_rect(gc, x - 1, y - 1, w + 2, h + 2)
            end
            
            if xi == 6 then
                xi = 1
                yi = yi + 1
            else
                xi = xi + 1
            end
        end
    end
    
    fill_rect(gc, 0, 0, window_width, 85, "ui_background_green")
    
    set_font(gc, 16)
    draw_string_middle(gc, "Stage " .. play.main_level, 11, "black")
    
    set_font(gc, 14)
    draw_string_middle(gc, play.score, 40, "black")
    draw_string_plop(gc, play.get_end_wave_number(), 52, 40, "black")
    draw_string_plop(gc, play.total_coins_gained, 252, 40, "black")
    
    set_font(gc, 11)
    draw_string_middle(gc, "score", 60, "dimgrey")
    draw_string_plop(gc, "wave", 52, 60, "dimgrey")
    draw_string_plop(gc, "coins", 252, 60, "dimgrey")
    
    draw_polyline(gc, {0, 85, window_width, 85}, "grey")
    
end

function play.end_screen.show_after(time)
    if play.end_screen.show_time < 0 then
        play.end_screen.show_time = time
    end
end

function play.end_screen.start()
    play.end_screen.is_active = true
    play.end_screen.show_time = -1
    
    play.end_screen.selected = 1
    play.end_screen.select_time = 10
    
    play.end_screen.camera_y = 60
    play.end_screen.target_y = -60
    
    play.end_screen.thing_order = {}
    local index = 1
    local sort_function = function(t, a, b)
        return things[a].value * t[a]
                         >
               things[b].value * t[b]
    end
    for key, num in sorted_pairs(play.things_gained, sort_function) do
        if num ~= 0 then
            play.end_screen.thing_order[index] = key
            box.add_thing(key, num)
            index = index + 1
        end
    end
end
    
-- just to check whether the end screen is about to be shown
function play.end_screen.check_timer()
    if play.end_screen.show_time > -1 then
        play.end_screen.show_time = play.end_screen.show_time - 1
        if play.end_screen.show_time == 0 then
            play.end_screen.start()
        end
    end
end

function play.end_screen.timer()
    play.end_screen.select_time = play.end_screen.select_time + 1

    play.end_screen.camera_y = smooth(play.end_screen.camera_y, play.end_screen.target_y, 1.25)
end

function play.end_screen.charIn(char)
    
    local dx, dy = dirnum_to_xy_extended(char_to_dirnum(char))
    local dd = dx + dy * 6
    if dd ~= 0 then
        play.end_screen.selected = bound(1, #play.end_screen.thing_order, play.end_screen.selected + dd)
        play.end_screen.select_time = 10
        play.end_screen.target_y = floor((play.end_screen.selected - 7) / 6) * 60
    end
    
    if char == "esc" then
        menu.start()
    elseif char == "enter" then
    
    end
    
end


------------------------------------------------------------------------------------------- STAGES -------------------------------------------------------------------------------------------

stages = {
    
    camera_x = 0,
    camera_y = 0,
    target_x = 0,
    target_y = 0,
    
    size = 50,
    target_size = 50,
    
    old = "0",
    old_num = TD.stages.starting_stage,
    current = "0",
    current_num = TD.stages.starting_stage,
    
    saved = false,
    saved_stage = nil,
    saved_wave = 0,
    
    time = 0,
    move_time = 0,

}

stages.draw = {}

function stages.start()
    mode = "stages"
    
    local str = var.recall("save")
    if str ~= "" then
        local t = deserialize(str)
        local stage = t[1]
        stages.old = stage
        stages.current = stage
        local order = TD.stages.order
        for i=1, #order do
            if order[i] == stage then
                stages.old_num = i
                stages.current_num = i
                break
            end
        end
        stages.centre_at_location()
        
        stages.saved = true
        stages.saved_stage = stage
        stages.saved_wave = t[4]
    else
        stages.camera_x = 0
        stages.camera_y = 0
        stages.centre_at_location()
        
        stages.saved = false
        stages.saved_stage = nil
        stages.saved_wave = 0
    end
    
end

function stages.location_to_pixel(location)

    local x = location[1] - stages.camera_x + window_width / 2
    local y = location[2] - stages.camera_y + window_height / 2
    
    return x, y
    
end

function stages.centre_at_location()

    local location = TD.stages[stages.current].location

    -- local x, y = stages.location_to_pixel(location)
    
    stages.target_x = location[1] -- - window_width / 2
    stages.target_y = location[2] -- - window_height / 2
    
end

function stages.paint(gc)
    stages.draw.background(gc)
    stages.draw.main_shapes(gc)
    stages.draw.other_shapes(gc)
    stages.draw.title(gc)
    stages.draw.foreground(gc)
end

function stages.draw.background(gc)

    set_color_mix(gc, "stage_background_" .. stages.current, "stage_background_" .. stages.old, 1 / 15 * stages.move_time)
    
    draw_screen(gc)
    
end
    
function stages.draw.foreground(gc)
    draw_border(gc, 10, "slategrey")
end

function stages.draw.main_shapes(gc)
    stages.draw.shape(gc, stages.old)
    stages.draw.shape(gc, stages.current)
end

function stages.draw.shape(gc, name)
    
    local t = TD.stages[name]
    
    local x, y = stages.location_to_pixel(t.location)
    local size = stages.size
    local angle = stages.time * t.rotation_speed / 60
    local shape = t.shape
    
    fill_shape(gc, shape, size, x, y, angle, "stage_shape_" .. name)
    
end

function stages.draw.other_shapes(gc)
    -- todo
    stages.draw.things(gc, "")
end

function stages.draw.things(gc, name)

end

function stages.draw.title(gc)
    
    if stages.move_time < 11 then
        set_font(gc, 20)
        draw_string_dump(gc, stages.current, "stage_background_" .. stages.current)
    end
    
    set_font(gc, 11)
    set_color(gc, "stage_shape_" .. stages.current)
    
    local str = TD.stages[stages.current].name
        
    if stages.saved then
        if stages.current == stages.saved_stage then
            str = str .. ": Wave " .. stages.saved_wave
        else
            str = str .. " (lose saved game)"
        end
    end
    
    draw_string_middle(gc, str, window_height - 32)
    
end


stages.camera_smoothness = 1.7
    
function stages.timer()
    
    local smoothness = stages.camera_smoothness
        
    stages.camera_x = smooth(stages.camera_x, stages.target_x, smoothness)
    stages.camera_y = smooth(stages.camera_y, stages.target_y, smoothness)
    
    stages.tick()
    
    window:invalidate()
    
end

function stages.tick()
    -- tick
    
    stages.time = stages.time + 1
    
    if stages.move_time > 0 then
        stages.move_time = stages.move_time - 1
    end
    
end

function stages.charIn(char)

    local dir = char_to_dir(char)
    local order = TD.stages.order
    local c = stages.current_num

    if char == "enter" then
        local can_load = stages.saved and stages.current == stages.saved_stage
        play.start(stages.current, can_load)
    elseif char == "esc" then
        menu.start()
    end
    
    local dx = 0
    if dir == "left" then
        dx = -1
    elseif dir == "right" then
        dx = 1
    end
    
    local test = c + dx
    if dx ~= 0 and test > 0 and test <= #order then
        stages.old_num = c
        stages.old = stages.current
        
        c = c + dx
        stages.current = order[c]
        
        stages.current_num = c
        
        stages.move_time = 15
        
        stages.centre_at_location()
    end
    
end


------------------------------------------------------------------------------------------- the things -------------------------------------------------------------------------------------------

-- the colors the thing uses, if any
color.thing_example_1 = {0, 0, 1}

things.example = {
    name = "Example",           -- display name of the item
    rarity = 7,                 -- rarity of the item, ranges from common to unusual (normally)
    type = 1,                   -- type of the item (currency, shape, etc.)
    sell = 1000,                -- the sell price of the item in money
    value = 10000,              -- the value of the item, usually around ~10 times the sell price
                                -- (below) the function to draw the thing (with x, y at top left corner)
    draw = function(gc, x, y, size)
        fill_rect_size(gc, x, y, size, size, 0.6, "thing_example_1")
    end,
    desc = {                    -- the description of the thing, shown on the sidebar
        "I am an example!!!",
    },
}

things.money = {
    name = "Money",
    rarity = 1,
    type = 1,
    sell = 1,
    value = 10,
    draw = function(gc, x, y, size)
        set_font(gc, size / 2)
        draw_string_plop(gc, "$", x + size / 2, y, "green")
        set_font(gc, 10)
    end,
    desc = {
        "The basic currency, used in the shop.",
    },
}
    
things.coin = {
    name = "Coin",
    rarity = 1,
    type = 1,
    sell = 1,
    value = 10,
    draw = function(gc, x, y, size)
        fill_circle(gc, size * 0.35, x + size * 0.5, y + size * 0.5, "ui_coin_yellow")
    end,
    desc = {
        "A nice coin.",
    },
}

things.normal_shape = {
    name = "Normal",
    rarity = 1,
    type = 2,
    sell = 10,
    value = 110,
    draw = function(gc, x, y, size)
        fill_circle(gc, size * 0.35, x + size * 0.5, y + size * 0.5, "enemy_normal")
    end,
    desc = {
        "A normal thing.",
    },
}

things.slow_shape = {
    name = "Slow",
    rarity = 1,
    type = 2,
    sell = 11,
    value = 120,
    draw = function(gc, x, y, size)
        fill_circle(gc, size * 0.35, x + size * 0.5, y + size * 0.5, "enemy_slow")
    end,
    desc = {
        "A slow thing.",
    },
}

things.fast_shape = {
    name = "Fast",
    rarity = 1,
    type = 2,
    sell = 12,
    value = 130,
    draw = function(gc, x, y, size)
        fill_circle(gc, size * 0.35, x + size * 0.5, y + size * 0.5, "enemy_fast")
    end,
    desc = {
        "A fast thing.",
    },
}

things.dev = {
    name = "What?",
    rarity = 8,
    type = 5,
    sell = 1000000,
    value = 10000000,
    draw = function(gc, x, y, size)
        fill_circle(gc, size * 0.35, x + size * 0.5, y + size * 0.5, "turquoise")
        fill_rect_size(gc, x, y, size, size, 0.2, "cyan")
    end,
    desc = {
        ":O",
    },
}

thing.types = {
    --[[1]] "Currency",
    --[[2]] "Shape",
    --[[3]] "Food",
    --[[4]] "Equipment",
    --[[5]] "Special",
}

thing.rarity_names = {
    "Common", "Uncommon", "Rare", "Super Rare", "Unusual", "Unknown", "???", "Badn't",
}

thing.rarity_colors = {
    { 0.66, 0.66, 0.66 }, -- grey
    { 0.32, 0.53, 0.81 }, -- blue
    { 0.35, 0.86, 0.3 }, -- green
    { 0.71, 0.27, 0.87 }, -- purple
    { 1, 0.73, 0.13 }, -- orange
    { 0.1, 0.1, 0.1 }, -- black
    { 0.95, 0.95, 0.95 }, -- white
    { 0.24, 0.91, 0.97 }, -- cyan
}

------------------------------------------------------------------------------------------- BOX -------------------------------------------------------------------------------------------

box = {
    camera_y = 0,
    target_y = 0,
    selected = 1,
    select_time = 10,
}

box.things = {
    money = 100,
    normal_shape = 0,
    slow_shape = 0,
    fast_shape = 0,
    example = 0,
    dev = 0,
    coin = 0,
}

-- keys of things arranged in the box
box.normal_thing_order = {
    "money", "coin",
    "normal_shape", "slow_shape", "fast_shape",
    "example", "dev",
}

box.thing_split = {}

function box.save_things()
    local t = {}
    for k, v in pairs(box.things) do
        if v ~= 0 then
            t[k] = v
        end
    end
    return t
end

function box.load_things(t)
    for k, v in pairs(t) do
        if v ~= 0 then
            box.things[k] = v
        end
    end
    return true
end

function box.add_thing(key, num)
    box.things[key] = box.things[key] + num
    profile.xp = profile.xp + (things[key].value * num) / 100
end

function box.start()
    mode = "box"
    
    box.time = 0
    box.select_time = 10
    
    box.sort("normal")
end

box.sort_functions = {
    normal = function(t, a, b)
        return a < b
    end,
    normal_d = function(t, a, b)
        return a > b
    end,
    rarity = function(t, a, b)
        return things[t[a]].rarity < things[t[b]].rarity
    end,
    rarity_d = function(t, a, b)
        return things[t[a]].rarity > things[t[b]].rarity
    end,
    value = function(t, a, b)
        return things[t[a]].value < things[t[b]].value
    end,
    value_d = function(t, a, b)
        return things[t[a]].value > things[t[b]].value
    end,
    totalvalue = function(t, a, b)
        return things[t[a]].value * box.things[t[a]] < things[t[b]].value * box.things[t[b]]
    end,
    totalvalue_d = function(t, a, b)
        return things[t[a]].value * box.things[t[a]] > things[t[b]].value * box.things[t[b]]
    end,
}

function box.sort(sort_type)
    local sort_type = sort_type or "normal"
    
    box.thing_order = {}
    local index = 1
    
    for i, k in sorted_pairs(box.normal_thing_order, box.sort_functions[sort_type]) do
        if box.things[k] ~= 0 then
            box.thing_order[index] = k
            index = index + 1
        end
    end
end


box.draw = {}

function box.paint(gc)
    box.draw.background(gc)
    box.draw.sidebar(gc)
    box.draw.things(gc)
    box.draw.foreground(gc)
end

color.box_background_1 = {0.4, 0.2, 0}
color.box_background_2 = {0.69, 0.49, 0}
color.box_background_3 = {1, 0.88, 0.57}
color.box_background_4 = {1, 0.8, 0.29}
color.box_background_5 = {0.97, 1, 0.56}
color.box_background_6 = {0.9, 0.93, 0.5}

function box.draw.background(gc)

    set_color_mix(gc, "box_background_5", "box_background_6", 0.4 + 0.02 * abs(10 - box.time % 20))
    
    draw_screen(gc)
    
end
    
function box.draw.foreground(gc)
    draw_border(gc, 10, "slateblue")
end

function box.grid_rect(x, y)
    return 50 * x + 110, 60 * y + 15 - box.camera_y, 40, 50
end

function box.centre_at_selected()
    box.target_y = floor((box.selected - 1) / 3) * 50
end

color.box_select = {1, 0.33, 0}

function box.draw.things(gc)
    
    local xi = 1
    local yi = 1
    set_font(gc, 10)
    for i, key in ipairs(box.thing_order) do
        local num = box.things[key]
        if num ~= 0 then
            local t = things[key]
            local x, y, w, h = box.grid_rect(xi, yi)
            
            -- thing background
            set_color_white(gc, thing.rarity_colors[t.rarity], 0.2)
            fill_rect(gc, x, y, w, h)
            
            -- the thing itself
            t.draw(gc, x + 4, y + 2, 32)
            
            draw_string_plop(gc, num, x + w * 0.5, y + h * 0.6, "black")
                        
            -- draw selected, if it is
            if i == box.selected then
                local current_background_color = get_color_mix(gc, "box_background_5", "box_background_6", 0.4 + 0.02 * abs(10 - box.time % 20))
                set_color_mix(gc, "box_select", current_background_color, (abs(10 - (box.select_time % 20)) / 10) ^ 2)
                draw_rect(gc, x, y, w, h)
                draw_rect(gc, x - 1, y - 1, w + 2, h + 2)
            end
            
            if xi == 3 then
                xi = 1
                yi = yi + 1
            else
                xi = xi + 1
            end
        end
    end
    
end

function box.draw.sidebar(gc)

    fill_rect(gc, 0, 0, 150, window_height, "ui_background_purple")
    
    draw_polyline(gc, {150, 0, 150, window_height}, "grey")
    
    local thing_key = box.thing_order[box.selected]
    local t = things[thing_key]
    
    set_font(gc, 14)
    draw_string_plop(gc, t.name, 80, 12, "black")
    
    set_font(gc, 11)
    set_color_black(gc, thing.rarity_colors[t.rarity], 0.3)
    draw_string_plop(gc, thing.rarity_names[t.rarity], 80, 37)
    
    draw_polyline(gc, {0, 63, 150, 63}, "grey")
    
    draw_textbox(gc, 18, 67, 124, 100, t.desc, 10, "black")
    
end

function box.timer()
    
    box.time = box.time + 1
    box.select_time = box.select_time + 1
    
    box.camera_y = smooth(box.camera_y, box.target_y, 1.25)
    
    window:invalidate()
    
end

function box.charIn(char)

    local dx, dy = dirnum_to_xy_extended(char_to_dirnum(char))
    local dd = dx + dy * 3
    if dd ~= 0 then
        box.selected = bound(1, #box.thing_order, box.selected + dd)
        box.centre_at_selected()
        box.select_time = 10
    end
    
    if char == "esc" then
        menu.start()
    elseif char == "enter" then
    
    end
    
end



------------------------------------------------------------------------------------------- account -------------------------------------------------------------------------------------------

-- all the accounts: raw data
raw_accounts = {}

-- info about the current account
account = {
    name = "Guest",
    password = 0000,
    number = 0,
    
    count = 0,
}

profile = {}

account.starting_profile = {
    level = 1,
    xp = 0,
    color = 0,
}
    
function account.load_raw()
    -- "global" storage
    raw_accounts = deserialize(var.recall("account"))
end

function account.store_raw()
    var.store("account", serialize(raw_accounts))
end

function account.start()

    account.log_out()
    
    account.count = 0
    
    local num = 1
    
    account.load_raw()
    
    -- loop through the accounts
    for k, v in pairs(raw_accounts) do
        -- count the ac-count
        account.count = account.count + 1
    end
    
    return account.count
    
end

function account.save_string()

    local num = account.number

    if num == 0 then
        return
    end
    
    local t = {}
    t[1] = account.name
    t[2] = account.password
    t[3] = profile
    t[4] = box.save_things()
    t[5] = achievements
    
    raw_accounts[num] = t
    
    account.store_raw()
    
end

function account.load_from(num)

    account.load_raw()
    
    local t = raw_accounts[num]
    
    account.number = num
    account.name = t[1]
    account.password = t[2]
    profile = t[3]
    box.load_things(t[4])
    achievements = t[5]
    
    return true
    
end

function account.create(name, password)
    if account.number == 0 then
        local n = account.count + 1
        account.name = name
        account.password = password
        account.number = n
        account.save_string()
        account.count = n
        account.load_from(n)
        account.log_out()
    end
end

function account.delete(num)
    account.log_out()
    for i=num, #raw_accounts - 1 do
        raw_accounts[i] = deep_copy(raw_accounts[i + 1])
    end
    raw_accounts[#raw_accounts] = nil
    account.store_raw()
    account.count = account.count - 1
end

function account.log_out()
    account.save_string()
    account.number = 0
    
    account.name = "Guest"
    profile = deep_copy(account.starting_profile)
    for k, v in pairs(box.things) do
        if k == "money" then
            box.things[k] = 100
        else
            box.things[k] = 0
        end
    end
    
    -- todo achievements
    
    -- todo research
end

function account.log_in(num)
    account.load_from(num)
end

function account.target_xp(level)
    return round(512 * level * level)
end


------------------------------------------------------------------------------------------- accounts -------------------------------------------------------------------------------------------

acc = {
    camera_y = 0,
    target_y = 0,
    selected = 1,
    name_popup = false,
    profile_show = false,
    color_popup = false,
}

acc.options = {
    "View Profile", "Log Out", "Delete Account"
}

function acc.start()
    mode = "acc"
    
    acc.camera_y = 0
    acc.target_y = 0
    
    acc.profile_show = false
    acc.name_popup = false
    acc.color_popup = false
    acc.temp_name = ""
    acc.popup_cursor = 0
    acc.name_error = 0
    
    acc.selected = 1
    acc.select_time = 10
    
    acc.time = 0
    
    acc.logged_in = account.number > 0
    account.save_string()    
end

function acc.paint(gc)
    acc.draw.background(gc)
    if acc.profile_show then
        acc.draw.title(gc)
        acc.draw.profile(gc)
        acc.draw.color_popup(gc)
    else
        acc.draw.accounts(gc)
        acc.draw.title(gc)
        acc.draw.name_popup(gc)
    end
    acc.draw.foreground(gc)
end

acc.draw = {}

function acc.draw.background(gc)
    if acc.logged_in then
        if acc.profile_show then
            local opposite_color = { hsl_to_rgb((profile.color + 0.5) % 1, 1, 0.5) }
            set_color_white(gc, opposite_color, 0.7)
            draw_screen(gc)
        else
            draw_screen(gc, "ui_background_yellow")
        end
    else
        draw_screen(gc, "ui_background_red")
    end
end

function acc.draw.foreground(gc)
    draw_border(gc, 10, "slateblue")
end
    
function acc.draw.title(gc)
    if acc.profile_show then
        local color = { hsl_to_rgb(profile.color, 1, 0.5) }
        
        set_color_white(gc, color, 0.4)
        fill_rect(gc, 0, 0, window_width, 45)
        
        set_font(gc, 14)
        set_color_black(gc, color, 0.75)
        draw_string_middle(gc, "Profile: " .. account.name, 12)
    else
        fill_rect(gc, 0, 0, window_width, 45, "aquamarine") -- "mediumspringgreen")
    
        set_font(gc, 14)
        if acc.logged_in then
            draw_string_middle(gc, "Account: " .. account.name, 12, "black")
        else
            draw_string_middle(gc, "Accounts", 12, "black")
        end
    end
end

function acc.draw.profile(gc)

    local color = { hsl_to_rgb(profile.color, 1, 0.5) }
    local opposite_color = { hsl_to_rgb((profile.color + 0.5) % 1, 1, 0.5) }
    local old_xp = account.target_xp(profile.level - 1)
    local target_xp = account.target_xp(profile.level)
    local xp_ratio = (profile.xp - old_xp) / (target_xp - old_xp)
    
    local y = 46
    set_font(gc, 12)
    set_color_black(gc, opposite_color, 0.8)
    draw_string_middle(gc, "Level " .. number_to_string(profile.level), y)
    
    y = 70
    set_color_white(gc, color, 0.6)
    fill_rect(gc, 20, y, (window_width - 40) * xp_ratio, 20)
    set_color(gc, color)
    draw_rect(gc, 20, y, window_width - 40, 20)
    draw_rect(gc, 19, y - 1, window_width - 38, 22)
    
    set_font(gc, 10)
    local display_xp = number_to_string(profile.xp - old_xp)
    set_color_black(gc, opposite_color, 0.75)
    draw_string(gc, display_xp, 23, y - 1)
    display_xp = number_to_string(target_xp - old_xp)
    set_color_black(gc, color, 0.65)
    draw_string(gc, display_xp, window_width - 21 - gc:getStringWidth(display_xp), y - 1)
    
end

function acc.draw.color_popup(gc)

    if not acc.color_popup then
        return
    end
    
    local color = { hsl_to_rgb(profile.color, 1, 0.5) }
    
    set_color_white(gc, color, 0.5)
    fill_rect(gc, 25, 60, window_width - 50, window_height - 120)
    set_color_white(gc, color, 0)
    draw_rect(gc, 25, 60, window_width - 50, window_height - 120)
    draw_rect(gc, 24, 59, window_width - 48, window_height - 118)
    
    set_color_black(gc, color, 0.7)
    set_font(gc, 12)
    draw_string_middle(gc, "Select Colour", 65)
    set_font(gc, 11)
    draw_string_middle(gc, "Hue: " .. round(profile.color * 255), 85)
    
    draw_image(gc, "color_scale", 30, 110, window_width - 60, 10)
    fill_circle(gc, 8, 30 + (window_width - 60) * profile.color, 127, color)
    set_color_black(gc, color, 0.4)
    draw_circle(gc, 8, 30 + (window_width - 60) * profile.color, 127)
    
end

function acc.draw.accounts(gc)
    
    if acc.logged_in then
    
        local y = 50
        
        for i=1, #acc.options do
        
            if acc.options[i] == "Delete Account" then
                set_color(gc, "ui_button_red")
            else
                set_color(gc, "grey")
            end
            fill_rect(gc, 15, y, window_width - 30, 25)
            
            if acc.selected == i then
                set_color_mix(gc, "ui_button_yellow", "ui_background_yellow", (abs(10 - (acc.select_time % 20)) / 10) ^ 2)
                draw_rect(gc, 15, y, window_width - 30, 25)
                draw_rect(gc, 14, y - 1, window_width - 28, 27)
            end
            
            set_font(gc, 11)
            draw_string_middle(gc, acc.options[i], y, "black")
            
            y = y + 30
        
        end
    
    else

        local y = 50
        
        for i=1, account.count + 1 do
            
            fill_rect(gc, 15, y, window_width - 30, 25, "grey")
            
            if acc.selected == i then
                set_color_mix(gc, "ui_button_red", "ui_background_red", (abs(10 - (acc.select_time % 20)) / 10) ^ 2)
                draw_rect(gc, 15, y, window_width - 30, 25)
                draw_rect(gc, 14, y - 1, window_width - 28, 27)
            end
            
            set_font(gc, 11)
            if i < account.count + 1 then
                local a = raw_accounts[i]
                local name = a[1]
                local level = a[3].level
                level = "Level " .. number_to_string(level)
                
                draw_string(gc, name, 20, y + 1, "black")
                draw_string(gc, level, window_width - 20 - gc:getStringWidth(level), y + 1, "black")
            else
                draw_string_middle(gc, "Create Account", y + 1, "black")
            end
            
            y = y + 30
            
        end
    
    end
    
end

function acc.draw.name_popup(gc)
    if not acc.name_popup then
        return
    end
    
    if not acc.name_popup_log_in and not acc.name_popup_delete then
    
        fill_rect(gc, 25, 25, window_width - 50, window_height - 50, "ui_background_purple")
        draw_rect(gc, 25, 25, window_width - 50, window_height - 50, "ui_button_purple")
        draw_rect(gc, 24, 24, window_width - 48, window_height - 48, "ui_button_purple")
        
        set_font(gc, 12)
        draw_string_middle(gc, "Enter account name:", 30, "black")
            
        local border_color = get_color_mix(gc, "ui_button_red", "darkgrey", (abs(5 - (acc.name_error % 10)) / 5))
        
        fill_rect(gc, 50, 60, window_width - 100, 20, "white")
        draw_rect(gc, 50, 60, window_width - 100, 20, border_color)
        
        set_font(gc, 11)
        draw_string_middle(gc, acc.temp_name, 60, border_color)
        
        if acc.temp_password ~= nil then
            set_font(gc, 12)
            draw_string_middle(gc, "Enter password:", 90, "black")
            
            fill_rect(gc, 50, 120, window_width - 100, 20, "white")
            draw_rect(gc, 50, 120, window_width - 100, 20, "ui_button_orange")
            
            set_font(gc, 11)
            draw_string_middle(gc, acc.temp_password, 120, "ui_button_orange")
            
            local string_end = window_width / 2 + gc:getStringWidth(acc.temp_password) / 2
            set_color_mix(gc, "ui_button_orange", "white", (abs(10 - (acc.popup_cursor % 20)) / 10) ^ 1.5)
            draw_polyline(gc, { string_end, 123, string_end, 138 })
        else
            local string_end = window_width / 2 + gc:getStringWidth(acc.temp_name) / 2
            set_color_mix(gc, border_color, "white", (abs(10 - (acc.popup_cursor % 20)) / 10) ^ 1.5)
            draw_polyline(gc, { string_end, 63, string_end, 78 })
        end
    
    elseif acc.name_popup_delete then
        
        fill_rect(gc, 25, 55, window_width - 50, window_height - 110, "ui_background_red")
        draw_rect(gc, 25, 55, window_width - 50, window_height - 110, "ui_button_red")
        draw_rect(gc, 24, 54, window_width - 48, window_height - 108, "ui_button_red")
        
        set_font(gc, 12)
        draw_string_middle(gc, "Type 'delete' to delete account", 70, "black")
        
        local border_color = get_color_mix(gc, "ui_button_red", "ui_button_blue", (abs(5 - (acc.name_error % 10)) / 5))
        local background_color = get_color_mix(gc, "ui_button_red", "white", 0.2)
        
        fill_rect(gc, 50, 100, window_width - 100, 20, background_color)
        draw_rect(gc, 50, 100, window_width - 100, 20, border_color)
        
        set_font(gc, 11)
        draw_string_middle(gc, acc.temp_name, 100, border_color)
        
        local string_end = window_width / 2 + gc:getStringWidth(acc.temp_name) / 2
        set_color_mix(gc, border_color, background_color, (abs(10 - (acc.popup_cursor % 20)) / 10) ^ 1.5)
        draw_polyline(gc, { string_end, 103, string_end, 118 })
        
    elseif acc.name_popup_log_in then
    
        fill_rect(gc, 25, 55, window_width - 50, window_height - 110, "ui_background_orange")
        draw_rect(gc, 25, 55, window_width - 50, window_height - 110, "ui_button_orange")
        draw_rect(gc, 24, 54, window_width - 48, window_height - 108, "ui_button_orange")
        
        set_font(gc, 12)
        draw_string_middle(gc, "Enter password:", 70, "black")
        
        local border_color = get_color_mix(gc, "ui_button_red", "ui_button_purple", (abs(5 - (acc.name_error % 10)) / 5))
        
        fill_rect(gc, 50, 100, window_width - 100, 20, "white")
        draw_rect(gc, 50, 100, window_width - 100, 20, border_color)
        
        set_font(gc, 11)
        draw_string_middle(gc, acc.temp_password, 100, border_color)
        
        local string_end = window_width / 2 + gc:getStringWidth(acc.temp_password) / 2
        set_color_mix(gc, border_color, "white", (abs(10 - (acc.popup_cursor % 20)) / 10) ^ 1.5)
        draw_polyline(gc, { string_end, 103, string_end, 118 })
        
    end
    
end

function acc.timer()
    acc.time = acc.time + 1
    acc.select_time = acc.select_time + 1
    if acc.name_popup then
        acc.popup_cursor = acc.popup_cursor + 1
    end
    if acc.name_error > 0 then
        acc.name_error = acc.name_error - 1
    end
    
    window:invalidate()
end

function acc.start_name_popup(logging_in)
    acc.name_popup = true
    if not logging_in then
        acc.temp_name = ""
        acc.temp_password = nil
    else
        acc.temp_name = nil
        acc.temp_password = ""
    end
    acc.popup_cursor = 0
    acc.name_error = 0
    acc.name_popup_log_in = logging_in
    acc.name_popup_delete = false
end

function acc.start_delete_popup()
    acc.name_popup_delete = true
    acc.name_popup_log_in = false
    acc.name_popup = true
    acc.temp_name = ""
    acc.temp_password = nil
    acc.popup_cursor = 0
    acc.name_error = 0
end

function acc.start_name_error()
    acc.name_error = 30
end

function acc.start_color_popup()
    acc.color_popup = true
    acc.color_popup_step = 3
end

function acc.charIn(char)
    if not acc.name_popup and not acc.color_popup then
    
        if char == "esc" then
            if acc.profile_show then
                acc.profile_show = false
            else
                menu.start()
            end
        elseif char == "enter" then
            if acc.logged_in then
                if acc.profile_show then
                    acc.start_color_popup()
                else
                    if acc.selected == 1 then
                        acc.profile_show = true
                    elseif acc.selected == 2 then
                        account.log_out()
                        acc.start()
                    elseif acc.selected == 3 then
                        acc.start_delete_popup()
                    end
                end
            else
                if acc.selected == account.count + 1 then
                    acc.start_name_popup(false)
                else
                    acc.start_name_popup(true)
                    -- account.log_in(acc.selected)
                end
            end
        end
    
        local dx, dy = dir_to_xy(char_to_dir(char))
        
        if dy ~= 0 then
            local max = 0
            if acc.logged_in then
                max = #acc.options
            else
                max = account.count + 1
            end
            acc.selected = bound(1, max, acc.selected + dy)
            acc.select_time = 10
        end
    
    elseif acc.name_popup then
    
        if char == "esc" then
            acc.name_popup = false
        elseif char == "enter" then
            if acc.name_popup_log_in and not acc.name_popup_delete then
                if acc.temp_password == raw_accounts[acc.selected][2] then
                    account.log_in(acc.selected)
                    acc.name_popup = false
                    acc.start()
                else
                    acc.start_name_error()
                end
            elseif acc.name_popup_delete then
                if acc.temp_name == "delete" then
                    account.delete(account.number)
                    acc.start()
                else
                    acc.start_name_error()
                end
            else
                if acc.temp_password == nil then
                    if #acc.temp_name > 0 then
                        local can = true
                        for i, v in ipairs(raw_accounts) do
                            if acc.temp_name == v[1] then
                                can = false
                            end
                        end
                        if can then
                            acc.temp_password = ""
                            acc.name_cursor = 10
                        else -- cannot
                            acc.start_name_error()
                        end
                    else
                        acc.start_name_error()
                    end
                else
                    if #acc.temp_password > 0 then
                        account.create(acc.temp_name, acc.temp_password)
                        acc.name_popup = false
                    end
                end
            end
        elseif #char == 1 then
            if acc.temp_password == nil then
                if #acc.temp_name < 15 then
                    acc.temp_name = acc.temp_name .. char
                end
            else
                if #acc.temp_password < 15 then
                    acc.temp_password = acc.temp_password .. char
                end
            end
            acc.name_cursor = 10
        elseif char == "del" then
            if acc.temp_password == nil then
                acc.temp_name = acc.temp_name:sub(1, #acc.temp_name - 1)
            else
                acc.temp_password = acc.temp_password:sub(1, #acc.temp_password - 1)
            end
            acc.name_cursor = 10
        elseif char == "clear" then
            acc.temp_name = ""
            if acc.temp_password == nil then
                acc.temp_name = acc.temp_name:sub(1, #acc.temp_name - 1)
            else
                acc.temp_password = acc.temp_password:sub(1, #acc.temp_password - 1)
            end
        end
    
    elseif acc.color_popup then
    
        if char == "esc" then
            acc.color_popup = false
        elseif char == "enter" then
            acc.color_popup = false
        end
        
        local dx, dy = dir_to_xy(char_to_dir(char))
        
        if dx ~= 0 then
            profile.color = (profile.color + dx / 255 * acc.color_popup_step + 1) % 1
            -- acc.color_popup_step = acc.color_popup_step + 1
        end
    
    end
end


------------------------------------------------------------------------------------------- default functions -------------------------------------------------------------------------------------------

-- @on

function on.paint(gc)
    _context = deep_copy(default_context)
    
    if mode == "menu" then
        menu.paint(gc)
    elseif mode == "stages" then
        stages.paint(gc)
    elseif mode == "play" then
        play.paint(gc)
    elseif mode == "box" then
        box.paint(gc)
    elseif mode == "acc" then
        acc.paint(gc)
    end
end

function on.timer()
    if mode == "menu" then
        menu.timer()
    elseif mode == "stages" then
        stages.timer()
    elseif mode == "play" then
        play.timer()
    elseif mode == "box" then
        box.timer()
    elseif mode == "acc" then
        acc.timer()
    end
end

function on.charIn(char)
    
    if char == "," then
        timer.stop()
        timer.start(0.05)
    end
    
    if mode == "menu" then
        menu.charIn(char)
    elseif mode == "stages" then
        stages.charIn(char)
    elseif mode == "play" then
        play.charIn(char)
    elseif mode == "box" then
        box.charIn(char)
    elseif mode == "acc" then
        acc.charIn(char)
    end
    
    window:invalidate()
end

-- and charIn stuff

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


------------------------------------------------------------------------------------------- ending -------------------------------------------------------------------------------------------

-- @end

timer.start(0.05)

local number_of_colors = 0
for c in pairs(color) do
    number_of_colors = number_of_colors + 1
end
print("[TEST 4] Total colours: " .. number_of_colors)

print("[TEST 5] Starting menu...")
menu.start()

print("[TEST 6] Starting " .. account.start() .. " account(s)...")

print("|||||||||||||||||||| Script initialized! ||||||||||||||||||||\n")
