local user_state = {}
user_state.__index = user_state

function user_state:new(state, name, path_to_db, fovRadius)
    if not state or state.exists == false then
        return setmetatable({
            exists = false,
            userName = name,
            userCoordinates = {
                latitude = 0.0,
                longitude = 0.0
            },
        database = (not path_to_db) and "database/gaia.db" or path_to_db,
        fovRadius = (not fovRadius) and 45 or fovRadius
        }, user_state)
    end

    return setmetatable({
        exists = true,
        userName = state.name,
        userCoordinates = {
            latitude = state.userCoordinates.latitude,
            longitude = state.userCoordinates.longitude
        },
        database = state.database,
        fovRadius = state.fovRadius,
    }, user_state)
end

function user_state:state()
    return self.__index
end

return user_state