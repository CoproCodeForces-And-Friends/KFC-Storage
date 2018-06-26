
local math = require('math')
local string = require('string')

local utils = {}


function utils.now()
    return math.floor(fiber.time())
end

function utils.format_update(tuple)
    local fields = {}
    for number, value in pairs(tuple) do
        table.insert(fields, {'=', number, value})
    end
    return fields
end

function utils.string(str)
    return type(str) == 'string'
end

function utils.not_empty_string(str)
    return utils.string(str) and str ~= ''
end

function utils.parse_url_by_pattern(url, pattern)
    return string.match(url,pattern)
end

return utils