local somatouranos = require("astrodiagramma.somatouranos")
local units = require("astrodiagramma.units")
local ouranos = {}
ouranos.__index = ouranos

function ouranos:new()
    return setmetatable({
        somatouranoi = {},
        latitude = nil,
        longitude = nil,
        zenith = {},
        radius = 45, -- degrees
    }, ouranos)
end

function ouranos:add_soma(soma)
    if(self.somatouranoi[soma.name] == nil) then
        table.insert(self.somatouranoi, soma)
    end
end

function ouranos:set_zenith(ra, decl)
    if ra == nil or decl == nil then
        ra, decl = units.set_zenith_lat_lon(self.latitude, self.longitude)
    end

    self.zenith.ra = ra
    self.zenith.decl = decl
end

function ouranos:set_reference_coordinates(lat, long)
    self.latitude = lat
    self.longitude = long

    self:set_zenith()
end

function ouranos:auto_set_reference_coordinates()
    local http = require("socket.http")
    local ltn12 = require("ltn12")

    local url = "http://ip-api.com/json/"
    local response_body = {}

    local res, code, response_headers, status = http.request{
        url = url,
        sink = ltn12.sink.table(response_body)
    }

    if code == 200 then
        local data = table.concat(response_body)

        self.latitude = data:match('"lat"%s*:%s*([%-%.%d]+)')
        self.longitude = data:match('"lon"%s*:%s*([%-%.%d]+)')

        print("Set coordinates:\nlatitude: " .. tostring(self.latitude) .. "\nlongitude: " .. tostring(self.longitude) .. "\nReset if incorrect.")
    else
        print("Failed to get location. HTTP code: " .. tostring(code) .. "\nTry manually entering coordinates.")
    end
end

function ouranos:scan_within_radius()

end

return ouranos