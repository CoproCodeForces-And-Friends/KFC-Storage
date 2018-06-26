local utils = require('utils.utils')
local uuid = require('uuid')
local log = require('log')

local user_provider = {}


function create_user_space(user_model)
    log.info('Info %s', 'user environment creation started')

    local space = box.schema.space.create(user_model.SPACE_NAME, {
        if_not_exists = true
    })

    space:create_index(user_model.PRIMARY_INDEX, {
        type = 'hash',
        parts = { user_model.ID, 'string' },
        if_not_exists = true
    })
    space:create_index(user_model.TRACKER_INDEX, {
        type = 'tree',
        unique = false,
        parts = { user_model.EXTERNAL_ID, 'string', user_model.TRACKER, 'string' },
        if_not_exists = true
    })
    log.info('Info %s', 'user environment created')
end

-----
-- user (internal_id, id, name, nickname, email)
-----
function user_provider:new(config)
    local userObj = {}
    log.info('Info %s', 'user_provider creating started')
    userObj.SPACE_NAME = config.spaces.user.name

    userObj.PRIMARY_INDEX = 'primary'
    userObj.TRACKER_INDEX = 'tracker_index'

    userObj.ID = 1
    userObj.EXTERNAL_ID = 2
    userObj.TRACKER = 3
    userObj.NAME = 4
    userObj.NICKNAME = 5
    userObj.EMAIL = 6
    userObj.ORGANIZATION_ID = 7
    userObj.CREATION_DATE = 8
    userObj.URL = 9
    userObj.IS_ACTIVE = 10

    box.once('user bootstrap', create_user_space, userObj)

    self.__index = self
    log.info('Info %s', 'user_provider created')
    return setmetatable(userObj, self)
end

function user_provider:get_space()
    return box.space[self.SPACE_NAME]
end

function user_provider:get_by_id(id)
    return self:get_space():get(id)
end


function user_provider:get_by_tracker(external_id, tracker)
    return self:get_space().index[self.TRACKER_INDEX]:select({ external_id, tracker })[1]
end


function user_provider:delete_by_tracker(external_id, tracker)
    if utils.not_empty_string(external_id) and utils.not_empty_string(tracker) then
        return self:get_space().index[self.TRACKER_INDEX]:delete({ external_id, tracker })
    end
end


function user_provider:update_by_tracker(user_tuple)
    local external_id = user_tuple[self.EXTERNAL_ID]
    local tracker = user_tuple[self.TRACKER]

    local fields = utils.format_update(user_tuple)

    return self:get_space().index[self.TRACKER_INDEX]:update({ external_id, tracker }, fields)
end


function user_provider:update(user_tuple)
    local id = user_tuple[self.ID]

    local fields = utils.format_update(user_tuple)

    return self:get_space():update(id, fields)
end


function user_provider:create(user_tuple)

    local ID = uuid.str()
    user_tuple[self.ID] = ID

    return self:get_space():insert(user_tuple)
end


return user_provider