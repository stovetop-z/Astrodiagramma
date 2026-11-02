local constants = require("astrodiagramma.constants")
local units = {}

function units.normalize_360(W)
    W = W % 360
    if W < 0 then W = W + 360 end
    return W
end

function units.normalize_hour(x)
    return x % 24
end

function units.hours_to_deg(x)
    return x * 15
end

function units.subhour_to_deg(x, grad)
    return (x / (60^grad)) * 15
end

function units.degree_to_hours(x)
    return x / 15
end

function units.hms_to_degrees(x)
    if type(x) == "string" then
        local degrees = 0.0
        local index = 0
        for val in string.gmatch(x, "(%d+)") do
            print(val)
            if index == 0 then
                degrees = units.hours_to_deg(val)
            else
                degrees = degrees + units.subhour_to_deg(val, index)
            end

            index = index + 1
        end

        return degrees
    end

    if type(x) == "table" then
        return units.hour_to_deg(x[1]) + units.subhour_to_deg(x[2], 1) + units.subhour_to_deg(x[3], 2)
    end

    error("Invalid type. Exepected string or table, got: " .. type(x))
end

function units.dms_to_degrees(x)
    if type(x) == "string" then
        local degrees = 0.0
        local multiplier = (string.sub(x, 1, 1) == '-') and (-1.0) or 1.0
        local index = 0
        for val in string.gmatch(x, "(%d+)") do
            if index == 0 then
                degrees = tonumber(val) * multiplier
            else
                degrees = degrees + units.subhour_to_deg(val, index) * multiplier
            end

            index = index + 1
        end

        print(degrees)
        return degrees
    end

    if type(x) == "table" then
        local multiplier = (x[1] < 0) and -1.0 or 1.0
        return x[1] + units.subhour_to_deg(x[2], 1) * multiplier + units.subhour_to_deg(x[3], 2) * multiplier
    end

    error("Invalid type. Exepected string or table, got: " .. type(x))
end

function units.calculate_gmst()
    local d = (units.utc() - constants.JD)
    local T = d / 36525 
    
    local gmst = 280.46061837 + 360.98564736629 * d + 0.000387933 * T * T - T * T * T / 38710000
    return gmst
end

function units.utc()
    return os.time()
end

function units.calculate_lst(lon)
    return units.normalize_hour(units.calculate_gmst() + units.degree_to_hours(lon))
end

function units.calculate_ra(lon)
    return units.hours_to_deg(units.calculate_lst(lon))
end

function units.set_zenith_lat_lon(lat, lon)
    local ra = units.calculate_ra(lon)
    local decl = lat
    return ra, decl
end

return units
