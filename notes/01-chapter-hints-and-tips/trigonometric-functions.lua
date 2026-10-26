local math = require("math")
-- Large angles appear frequently in astronomical calulations.
-- e.g. u longitude angle of sun on 1992 Oct 13 is -2318.19280 degrees
-- NOTE: Lua trig functions take radians as input

local u_long_sun = math.rad(-2318.19280)
print(math.sin(u_long_sun)) -- output: 0.29798241277760151

-- It is therefore apt to reduce the angles to the interval 0-360

function reduceAngle(W)
    return W % 360
end

print(reduceAngle(u_long_sun))

-- Do a test of your system to ensure your outputs are accurate for larger angles.
local large_w = math.rad(36000030)
print(math.sin(large_w)) -- output: 0.5 (0.4999999...)

-- SUBSECTION: Right Ascensions - alpha
-- Right ascensions are calculated in hours, minutes, and seconds. 
-- 1 hour = 15 degrees
function hourToDegrees(x)
    return x * 15
end

function subHourToDegrees(x, grad)
    return (x / (60^grad)) * 15
end

function rightAscensionToDegrees(x) -- Assuming a string value of: hour:minute:second
    local degrees = 0.0
    local index = 0
    for val in string.gmatch(x, "(%d+)") do
        if index == 0 then
            degrees = hourToDegrees(val)
        else
            degrees = degrees + subHourToDegrees(val, index)
        end

        index = index + 1
    end

    return degrees
end

local alpha = rightAscensionToDegrees("9:14:55.8")
print(alpha) -- output: 138.73
print(math.tan(math.rad(alpha))) -- output: -0.8776

-- SUBSECTION: The correct quandrant
-- arctan and arcsin give angle values between -90 deg and +90 deg
-- ALL DECLINATIONS are within -90 and +90 def
-- arccos gives angle values between 0 and +180 deg
-- ANGULAR SEPARATION is within 0 and +180 deg
-- Ambiguity arises with atan(A/B) vs atan(A, B). atan(A/B) is correct for B >= 0, otherwise, use atan(A, B)

-- SUBSECTION: Input of negative angles
-- Angles from DEG:MIN:SEC 
function degreeMinSecToDegrees(x) -- e.g. x = 21:44:7
    local degrees = 0.0
    local multiplier = (string.sub(x, 1, 1) == '-') and (-1.0) or 1.0
    local index = 0
    for val in string.gmatch(x, "(%d+)") do
        if index == 0 then
            degrees = tonumber(val) * multiplier
        else
            degrees = degrees + subHourToDegrees(val, index) * multiplier
        end

        index = index + 1
    end

    return degrees
end

print(degreeMinSecToDegrees("-21:44:7")) -- output: -32.03

-- SUBSECTION: Polynomials
-- Consider using Horner's method