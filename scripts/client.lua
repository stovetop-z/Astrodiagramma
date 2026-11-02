local socket = require("socket")

-- 1. Generate stars
local stars = {}
for i = 1, 5000 do
    table.insert(stars, {
        x = math.random(0, 799), 
        y = math.random(0, 799), 
        brightness = math.random()
    })
end

local tcp = assert(socket.tcp())
assert(tcp:connect("127.0.0.1", 8080))

-- 2. Pack the data
-- Format: "<" (Little-Endian)
-- "I4" = 4-byte unsigned int
-- "I2" = 2-byte unsigned int, "f" = 4-byte float
local parts = {}

-- Send the HEADER first: The total number of stars
table.insert(parts, string.pack("<I4", #stars)) 

-- Send the PAYLOAD: Pack each star individually
for i = 1, #stars do
    table.insert(parts, string.pack("<I2I2f", stars[i].x, stars[i].y, stars[i].brightness))
end

-- table.concat is vastly faster than concatenating strings in a loop
local payload = table.concat(parts)

assert(tcp:send(payload))
print("Sent " .. #stars .. " stars (" .. #payload .. " bytes) in binary")

tcp:close()