local ui = require("limekit.ui")
local fs = require("limekit.fs") -- Reading and writing files, folders, and json
local res = require("limekit.res") -- Project images, scripts, and misc
local chart = require("limekit.chart") -- Line, bar, and area charts

local window = ui.Window{
    title = "Astrodiagramma",
    size = {640, 480},
    location = {0, 0},
}
local layout = ui.VLayout()
layout:addChild(ui.Label("Astrodiagramma"))

window:setLayout(layout)
window:show()