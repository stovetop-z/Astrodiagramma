local math = require("math")
local calculations = {} 

function calculations.subhour_to_deg(x, grad)
    return (x / (60^grad)) * 15
end

function calculations.deg_min_sec_to_deg(x) -- e.g. x = 21:44:7
    local degrees = 0.0
    local multiplier = (string.sub(x, 1, 1) == '-') and (-1.0) or 1.0
    local index = 0
    for val in string.gmatch(x, "(%d+)") do
        if index == 0 then
            degrees = tonumber(val) * multiplier
        else
            degrees = degrees + calculations.subhour_to_deg(val, index) * multiplier
        end

        index = index + 1
    end

    return degrees
end

-- Interpolation: finding new values intermiedate for given values in a table
local xy = {
    x = {x1 = 12, x2 = 16, x3 = 20},
    y = {y1 = 1.3814294, y2 = 1.3812213, y3 = 1.3812453},
}

local ab = {
    a = xy.y.y2 - xy.y.y1, -- first difference
    b = xy.y.y3 - xy.y.y2, -- first difference
}

local diff_2nd = ab.b - ab.a -- second difference

function table_to_string(t, name)
    local result = "Table - " .. name .. ":\n"

    for i, row in pairs(t) do
        result = result .. "row " .. i .. ": ["
        
        local has_elements = false
        for j, col in pairs(row) do
            result = result .. col .. ", "
            has_elements = true
        end
        
        -- Strip the trailing comma and space if elements were added
        if has_elements then
            result = string.sub(result, 1, #result - 2)
        end

        result = result .. "]\n"
    end
    
    result = result .. "------- End of " .. name .. " -------\n"
    return result
end


-- For different scenarios, only 3 points of data is enough for interpolation.
-- If y is dependent on x, then interpolating factor n = x - x2, so if n > 0 then we are looking at a later value x.
-- If y2 is chosen correctly, then -0.5 <= n <= +0.5.
function interpolationOfY(y2, a, b, c, n)
    return y2 + n / 2 * (a + b + n * c)
end

-- If the tabulated function reaches an extremum, then
function interpolationOfYExtremum(y2, a, b, c)
    return y2 - ((a + b) * (a + b)) / (8 * c)
end

-- With corresponding value of x given by
function nExtremum(a, b, c)
    return -1.0 * (a + b) / (2 * c)
end

print(table_to_string(xy, "Distance Sun-Mars"))
print("a = " .. ab.a .. "\nb = " .. ab.b .. "\nc = " .. diff_2nd)
local ym = interpolationOfYExtremum(xy.y.y2, ab.a, ab.b, diff_2nd)
local nm = nExtremum(ab.a, ab.b, diff_2nd)
print("ym = " .. ym)
print("nm = " .. nm)
local x = 4
print("x (tabular interval) days * nm = " .. x * nm .. " days")

-- To find where the interpolating factor corresponds to the 0 of the function:
function nZero(y2, a, b, c, nzero) -- solve by first putting nzero = 0
    return -1 * (-2.0 * y2 + nzero * (a + b + c * nzero)) / (a + b + 2 * c * nzero)
end -- loop through this till nzero reaches its limit (i.e. computational limit)

-- Example
local decl_of_mercury = {
    x = {26, 27, 28},
    y = {"-0:28:13.4", "0:06:46.3", "0:38:23.2"},
}

print("\nExample with the following\n")
print(table_to_string(decl_of_mercury, "Declination of Mercury"))
local x = 1
local a = calculations.deg_min_sec_to_deg(decl_of_mercury.y[2]) - calculations.deg_min_sec_to_deg(decl_of_mercury.y[1])
local b = calculations.deg_min_sec_to_deg(decl_of_mercury.y[3]) - calculations.deg_min_sec_to_deg(decl_of_mercury.y[2])
local c = b - a

local y2 = calculations.deg_min_sec_to_deg(decl_of_mercury.y[2])
local nzero = nZero(y2, a, b, c, 0.0)

print("a = " .. a .. "\nb = " .. b .. "\nc = " .. c .. "\nn0 start = " .. nzero)
for i = 1, 1000, 1 do -- limit to 100 calculations of nzero
    local curr_nzero = nZero(y2, a, b, c, nzero)
    if curr_nzero ~= nzero then
        nzero = curr_nzero
    end
end
print("n0 end = " .. nzero .. "\nDeclination was zero apprx. " .. nzero * 24 .. " hours ago.")