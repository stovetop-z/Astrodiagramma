local ouranos = require("astrodiagramma.ouranos")
local gaiadb = require("astrodiagramma.gaiadb")
local cio = require("astrodiagramma.cio")

-- load config file
local user_config_state = cio.load_json_as_table("astrodiagramma/configs/user_state.json")
local config = cio.load_json_as_table("astrodiagramma/configs/configs.json") -- debug

-- load user
local user_state = require("astrodiagramma.user_state")
local user = user_state:new(user_config_state)

-- load world
local fov = ouranos:new()
local db = gaiadb:new("database/gaia.db")

local function landing()
    if user.exists == false then
        user.exists = true
        print("Let's setup your configurations:\n")
        print("fovRadius in degrees from zenith: ")
        user.fovRadius = tonumber(io.read())
        print("Automatically load longitude and latitude? [y/n] ")
        local auto = io.read()
        if auto == "y" or auto == "yes" then
            fov:auto_set_reference_coordinates()
            user.userCoordinates.latitude = fov.latitude
            user.userCoordinates.longitude = fov.longitude
        else 
            print("Enter latitude: ")
            user.userCoordinates.latitude = tonumber(io.read())
            print("Enter longitude: ")
            user.userCoordinates.longitude = tonumber(io.read())
        end

        print("If you have an offline sqlite3 database to connect to, type in path, otherwise press enter: ")
        local db_path = io.read()
        if #db_path > 1 then
            user.database = db_path
        end

        print("Lastly, how would you like to be called: ")
        local name = ""
        while true do
            name = io.read()
            print(name .. " are you sure? [y/n] ")
            local ans = io.read()
            if ans == "yes" or ans == "y" then
                break
            end
            print("Enter name: ")
        end
        user.userName = name
    else 
        print("Welcome, " .. user.userName .. ".")
    end
end

local function main()

    print("Welcome to Astrodiagramma.")
    landing()
    fov:set_zenith()
    while true do
        io.flush()
        io.write("> ")
        local com = io.read()
        if com == "q" then
            break
        end
    end

    if config.debug == false then
        cio.save_table_to_json(user:state())
    end
end

main()