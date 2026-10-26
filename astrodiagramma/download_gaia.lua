local magnitude = tonumber(arg[1])
if not magnitude or magnitude <= 0 then
    io.stderr:write("Usage: lua astrodiagramma/download_gaia.lua <max_g_magnitude> [output.csv]\n")
    os.exit(2)
end

local output = arg[2] or ("gaia_dr3_gmag_" .. tostring(magnitude):gsub("%.", "_") .. ".csv")
local endpoint = "https://gea.esac.esa.int/tap-server/tap/async"

local function shell_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function run(command)
    local handle = io.popen(command .. " 2>&1")
    if not handle then error("Could not start curl") end
    local result = handle:read("*a")
    local ok, _, code = handle:close()
    if not ok then error("Command failed (" .. tostring(code) .. "): " .. result) end
    return result
end

local query = "SELECT source_id, ra, dec, phot_g_mean_mag FROM gaiadr3.gaia_source WHERE phot_g_mean_mag <= " .. tostring(magnitude)
local submit = table.concat({
    "curl -sS -D - -o /dev/null -X POST",
    "--data-urlencode 'REQUEST=doQuery'",
    "--data-urlencode 'LANG=ADQL'",
    "--data-urlencode 'FORMAT=csv'",
    "--data-urlencode 'PHASE=RUN'",
    "--data-urlencode " .. shell_quote("QUERY=" .. query),
    shell_quote(endpoint),
}, " ")

local response = run(submit)
local job_url = response:match("[Ll]ocation:%s*(https?://[^\r\n]+)")
if not job_url then error("Gaia did not return a job URL:\n" .. response) end
job_url = job_url:gsub("%s+$", "")
print("Submitted Gaia query: " .. job_url)

while true do
    local status = run("curl -sS " .. shell_quote(job_url))
    local phase = status:match("<uws:phase>(.-)</uws:phase>")
    if phase == "COMPLETED" then break end
    if phase == "ERROR" or phase == "ABORTED" then
        error("Gaia job finished with phase " .. phase .. ":\n" .. status)
    end
    if not phase then error("Could not read job phase:\n" .. status) end
    print("Gaia job phase: " .. phase)
    os.execute("sleep 2")
end

local results_url = job_url .. "/results/result"
run("curl -fLsS " .. shell_quote(results_url) .. " -o " .. shell_quote(output))
print("Saved Gaia CSV to " .. output)
