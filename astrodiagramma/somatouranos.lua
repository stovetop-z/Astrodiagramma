local u = require("astrodiagramma.units")
local math = require("math")
local somatouranos = {}
somatouranos.__index = somatouranos

function somatouranos:new(ra, decl, units, name, distance)
    -- expects distance in kpc
    local self = setmetatable({}, somatouranos)
    self.units = "deg"
    self.name = (name == nil) and "Unknown Object" or name
    
    self.distance = distance
    self.ra = {}
    self.decl = {}

    if units == "deg" or units == "degrees" then
        self.ra = ra
        self.decl = decl
    elseif units == "hms" then
        self.ra = u.hms_to_degrees(ra)
        self.decl = u.hms_to_degrees(decl)
    elseif units == "dms" then
        self.ra = u.dms_to_degrees(ra)
        self.decl = u.dms_to_degrees(decl)
    elseif units == "radians" or units == "rad" then
        self.ra = math.deg(ra)
        self.decl = math.deg(decl)
    else
        error("Unsupported units. List of supported units:\n- deg or degrees\n- hms\n- dms\n-rad or radians")
    end

    self._description = self.name .. " at <ra, decl> = <" .. self.ra .. ", " .. self.decl  .. ">" .. ", units = " .. self.units

    print(self._description)
    return self
end

function somatouranos:separation(body)
    return {body.ra - self.ra, body.decl - self.decl}
end

return somatouranos