-- Import the Gaia CSV produced by download_gaia.lua into SQLite.
-- Usage: lua astrodiagramma/csv_to_sqlite.lua [input.csv] [output.db]
-- Requires the sqlite3 command-line program.

local input = arg[1] or "gaia_dr3_bright_sources.csv"
local database = arg[2] or input:gsub("%.csv$", "") .. ".db"
if input:find("%s") then
    error("Use an input CSV path without spaces; SQLite's .import command does not accept quoted paths.")
end

local function shell_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function run(command)
    local ok, _, code = os.execute(command)
    if not ok then
        error("Command failed (" .. tostring(code) .. "): " .. command)
    end
end

local create_table = [[CREATE TABLE IF NOT EXISTS gaia_sources (
    source_id INTEGER PRIMARY KEY,
    ra REAL NOT NULL,
    dec REAL NOT NULL,
    phot_g_mean_mag REAL NOT NULL
);]]
local create_import_table = [[CREATE TABLE IF NOT EXISTS gaia_csv_import (
    source_id TEXT,
    ra TEXT,
    dec TEXT,
    phot_g_mean_mag TEXT
);]]

-- The command-line importer handles CSV quoting and commas correctly.
run("sqlite3 " .. shell_quote(database) .. " " .. shell_quote(create_table))
run("sqlite3 " .. shell_quote(database) .. " " .. shell_quote(create_import_table))
local script_path = os.tmpname()
local script = assert(io.open(script_path, "w"))
script:write(".mode csv\n.import " .. input .. " gaia_csv_import\n")
script:write([[BEGIN;
DELETE FROM gaia_sources;
INSERT INTO gaia_sources (source_id, ra, dec, phot_g_mean_mag)
SELECT CAST(source_id AS INTEGER), CAST(ra AS REAL), CAST(dec AS REAL), CAST(phot_g_mean_mag AS REAL)
FROM gaia_csv_import WHERE source_id != 'source_id';
DELETE FROM gaia_csv_import;
CREATE INDEX IF NOT EXISTS idx_gaia_sources_magnitude ON gaia_sources(phot_g_mean_mag);
COMMIT;
]])
script:close()
local ok, err = pcall(run, "sqlite3 " .. shell_quote(database) .. " < " .. shell_quote(script_path))
os.remove(script_path)
if not ok then error(err) end

print("Imported " .. input .. " into " .. database .. " (table: gaia_sources)")
