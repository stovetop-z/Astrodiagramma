local io = {}

function io.table_to_string(t, name)
    local result = "Table - " .. name .. ":\n"

    for i, row in pairs(t) do
        result = result .. "row " .. i .. ": ["
        
        local has_elements = false
        for j, col in pairs(row) do
            result = result .. col .. ", "
            has_elements = true
        end
        
        if has_elements then
            result = string.sub(result, 1, #result - 2)
        end

        result = result .. "]\n"
    end
    
    result = result .. "------- End of " .. name .. " -------\n"
    return result
end