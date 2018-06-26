local utils = require('utils.utils')
local uuid = require('uuid')
local log = require('log')

local org_provider = {}

function create_org_space(org_model)
    log.info('Info %s', 'org environment creation started')

    local space = box.schema.space.create(org_model.SPACE_NAME, {
        if_not_exists = true
    })

    space:create_index(org_model.PRIMARY_INDEX, {
        type = 'hash',
        parts = { org_model.ID, 'string' },
        if_not_exists = true
    })
    space:create_index(org_model.TRACKER_INDEX, {
        type = 'tree',
        unique = false,
        parts = { org_model.EXTERNAL_ID, 'string', org_model.TRACKER, 'string' },
        if_not_exists = true
    })
    log.info('Info %s', 'org environment created')
end


function org_provider:new(config)
    local orgObj = {}
    log.info('Info %s', 'org_provider creating started')
    orgObj.SPACE_NAME = config.spaces.organization.name

    orgObj.PRIMARY_INDEX = 'primary'
    orgObj.TRACKER_INDEX = 'tracker_index'

    orgObj.ID = 1
    orgObj.EXTERNAL_ID = 2
    orgObj.TRACKER = 3
    orgObj.NAME = 4
    orgObj.DESCRIPTION = 5
    orgObj.URL = 6

    box.once('org bootstrap', create_org_space, orgObj)

    self.__index = self
    log.info('Info %s', 'org_provider created')
    return setmetatable(orgObj, self)
end

function org_provider:get_space()
    return box.space[self.SPACE_NAME]
end

function org_provider:get_by_id(id)
    return self:get_space():get(id)
end


function org_provider:get_by_tracker(external_id, tracker)
    return self:get_space().index[self.TRACKER_INDEX]:select({ external_id, tracker })[1]
end


function org_provider:delete_by_tracker(external_id, tracker)
    if utils.not_empty_string(external_id) and utils.not_empty_string(tracker) then
        return self:get_space().index[self.TRACKER_INDEX]:delete({ external_id, tracker })
    end
end


function org_provider:update_by_tracker(org_tuple)
    local external_id = org_tuple[self.EXTERNAL_ID]
    local tracker = org_tuple[self.TRACKER]

    local fields = utils.format_update(org_tuple)

    return self:get_space().index[self.TRACKER_INDEX]:update({ external_id, tracker }, fields)
end


function org_provider:update(org_tuple)
    local id = org_tuple[self.ID]

    local fields = utils.format_update(org_tuple)

    return self:get_space():update(id, fields)
end


function org_provider:create(org_tuple)

    local ID = uuid.str()
    org_tuple[self.ID] = ID

    return self:get_space():insert(org_tuple)
end


return org_provider