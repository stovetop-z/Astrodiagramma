local sqlite3 = require("lsqlite3")
local gaiadb = {}
gaiadb.__index = gaiadb

function gaiadb:new(path)
    return setmetatable({
        path = path,
        is_open = false,
        db = nil,
    }, gaiadb)
end

function gaiadb:open(diff_path)
    if self.is_open == true then
        print("Database already connected at " .. self.path)
    end
    if diff_path ~= nil then
        self.path = diff_path
    end

    self.db = assert(sqlite3.open(self.path))
    self.is_open = true
    print("Connected to database at " .. self.path)
end

function gaiadb:close()
    self.is_open = false
    self.db:close()
end

function gaiadb:query(q, values)
    local sq = assert(self.db:prepare(q))
end

return gaiadb