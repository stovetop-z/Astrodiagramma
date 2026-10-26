local units = {}

function units.reduce_deg_angle(W)
    return W % 360
end

function units.hours_to_deg(x)
    return x * 15
end

function units.subhour_to_deg(x, grad)
    return (x / (60^grad)) * 15
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
        local multiplier = (d < 0) and -1.0 or 1.0
        return x[1] + units.subhour_to_deg(x[2], 1) * multiplier + units.subhour_to_deg(x[3], 2) * multiplier
    end

    error("Invalid type. Exepected string or table, got: " .. type(x))
end

return units
