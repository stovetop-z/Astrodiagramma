local json = require("dkjson")
local cio = {}

function cio.table_to_string(t, name)
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

function cio.read_file(path)
    local file, err = io.open(path, "r")
    if not file then return nil, "Could not open file: " .. path end
    local content = file:read("*a")
    file:close()
    return content
end

function cio.write_file(path, content)
    local file, err = io.open(path, "w")
    if not file then 
        return false, "Failed to open file for writing: " .. tostring(err) 
    end
    
    file:write(content)
    file:close()
    return true
end

function cio.load_json_as_table(path)
    local json_content, err = cio.read_file(path)
    if not json_content then
        print("Failed to load json_content " .. tostring(err))
        return {}, false
    end

    local json_table, err = json.decode(json_content, 1, nil)
    if not json_table then
        print("Failed to load json file " .. tostring(err))
        return {}, false
    end

    return json_table, true
end

function cio.save_table_to_json(config_json, path)
    local json_str = json.encode(config_json, {indent = true})
    return cio.write_file(path, json_str)
end

return cio