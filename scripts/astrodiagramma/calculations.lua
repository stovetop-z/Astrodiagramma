local math = require("math")

local calculations = {}

function calculations.interpolation_of_y(y, differences, n)
    local a = differences.a
    local b = differences.b
    local c = differences.c

    if #differences == 3 then 
        return y + n / 2 * (a + b + n * c)
    end

    local d = differences.d
    local e = differences.e
    local f = differences.f
    local g = differences.g
    local h = differences.h
    local j = differences.j
    local k = differences.k

    return y + (n / 2) * (b + c) + (n * n / 2) * f + ((n * (n * n - 1)) / 12) * (h + j) + ((n * n * (n * n - 1)) / 24) * k
end

function calculations.interpolation_of_ym(y2, a, b, c)
    return y2 - ((a + b) * (a + b)) / (8 * c)
end

function calculations.n(x, x2)
    return x - x2
end

function calculations.nm(differences)
    local a = differences.a
    local b = differences.b
    local c = differences.c

    if #differences == 3 then
        return -1.0 * (a + b) / (2 * c)
    end

    local d = differences.d
    local e = differences.e
    local f = differences.f
    local g = differences.g
    local h = differences.h
    local j = differences.j
    local k = differences.k
end

function calculations.n_zero_linear(y2, a, b, c, nzero) -- solve by first putting nzero = 0
    return (-2.0 * y2) / (a + b + c * nzero)
end

function calculations.n_zero_nonlinear(y2, a, b, c, nzero)
    return -1 * (2.0 * y2 + nzero * (a + b + c * nzero)) / (a + b + 2 * c * nzero)
end

function calculations.get_abc(y)
    local a = y[2] - y[1]
    local b = y[3] - y[2]
    local c = b - a

    return a, b, c
end

function calculations.get_abcdefghjk(y)
    local a = y[2] - y[1]
    local b = y[3] - y[2]
    local c = y[4] - y[3]
    local d = y[5] - y[4]

    local e = b - a
    local f = c - b
    local g = d - c
    local h = f - e
    local j = g - f
    local k = j - h

    return {a, b, c, d, e, f, g, h, j, k}
end

return calculations