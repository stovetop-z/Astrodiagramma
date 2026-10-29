-- Run the Limekit project using the Python bundled with Limer.
local script = arg[0]
local root = script:match("^(.*)/[^/]+$") or "."
if root == "" then root = "/" end

local function quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local python = root .. "/Limer/Contents/Resources/python/bin/python"
local file = io.open(python, "r")
if not file then
    io.stderr:write("Limer's bundled Python was not found at " .. python .. "\n")
    os.exit(1)
end
file:close()

local ok, _, code = os.execute("cd " .. quote(root) .. " && "
    .. quote("./Limer/Contents/Resources/python/bin/python") .. " -m limekit .")
if not ok then os.exit(code or 1) end
