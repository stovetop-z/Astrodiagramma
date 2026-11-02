local ouranos = require("astrodiagramma.ouranos")
local gaiadb = require("astrodiagramma.gaiadb")
local cio = require("astrodiagramma.cio")
local user_state = require("astrodiagramma.user_state")

local app = {}
app.__index = app

function app:new(user_state_path, config_path, db_path)
    return setmetatable({
        user = user_state:new(cio.load_json_as_table(user_state_path), nil, user_state_path),
        config = cio.load_json_as_table(config_path),
        fov = ouranos:new(),
        db = gaiadb:new(db_path)
    }, app)
end

--- SET API calls
function app:set_userName(name)
    self.user.userName = name
end

function app:set_fovRadius(fovRadius)
    self.user.fovRadius = fovRadius
end

function app:autoset_user_info()
    self.fov:auto_set_reference_coordinates()
end

function app:set_sky()
    if not self.fovRadius then
        print("Field of reference must be set")
        return nil
    end

    self.fov:scan_within_radius()
end

-- UPDATE API calls
function app:update_sky(time) -- expecting string: "MM:DD:YYYY HH:MIN:SS"

end

-- GET API calls
function app:get_sky()
    
end

return app