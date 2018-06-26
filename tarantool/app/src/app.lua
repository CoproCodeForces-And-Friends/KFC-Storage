local config = require('config.default')
local server = require('http').init(config)

server:start()
