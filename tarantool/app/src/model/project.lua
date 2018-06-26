local utils = require('utils.utils')
local uuid = require('uuid')
local log = require('log')

local project_provider = {}

function create_project_space(project_model)
    log.info('Info %s', 'project environment creation started')

    local space = box.schema.space.create(project_model.SPACE_NAME, {
        if_not_exists = true
    })

    space:create_index(project_model.PRIMARY_INDEX, {
        type = 'hash',
        parts = { project_model.ID, 'string' },
        if_not_exists = true
    })
    space:create_index(project_model.TRACKER_INDEX, {
        type = 'tree',
        unique = false,
        parts = { project_model.EXTERNAL_ID, 'string', project_model.TRACKER, 'string' },
        if_not_exists = true
    })
    log.info('Info %s', 'project environment created')
end


function project_provider:new(config)
    local projectObj = {}
    log.info('Info %s', 'project_provider creating started')
    projectObj.SPACE_NAME = config.spaces.project.name

    projectObj.PRIMARY_INDEX = 'primary'
    projectObj.TRACKER_INDEX = 'tracker_index'

    model.ID = 1
    model.EXTERNAL_ID = 2
    model.NAME = 3
    model.DESCRIPTION = 4
    model.ORGANIZATION_ID = 5
    model.CREATE_DATE = 6
    model.URL = 7
    model.TRACKER = 8

    box.once('project bootstrap', create_project_space, projectObj)

    self.__index = self
    log.info('Info %s', 'project_provider created')
    return setmetatable(projectObj, self)
end

function project_provider:get_space()
    return box.space[self.SPACE_NAME]
end

function project_provider:get_by_id(id)
    return self:get_space():get(id)
end


function project_provider:get_by_tracker(external_id, tracker)
    return self:get_space().index[self.TRACKER_INDEX]:select({ external_id, tracker })[1]
end


function project_provider:delete_by_tracker(external_id, tracker)
    if utils.not_empty_string(external_id) and utils.not_empty_string(tracker) then
        return self:get_space().index[self.TRACKER_INDEX]:delete({ external_id, tracker })
    end
end


function project_provider:update_by_tracker(project_tuple)
    local external_id = project_tuple[self.EXTERNAL_ID]
    local tracker = project_tuple[self.TRACKER]

    local fields = utils.format_update(project_tuple)

    return self:get_space().index[self.TRACKER_INDEX]:update({ external_id, tracker }, fields)
end


function project_provider:update(project_tuple)
    local id = project_tuple[self.ID]

    local fields = utils.format_update(project_tuple)

    return self:get_space():update(id, fields)
end


function project_provider:create(project_tuple)

    local ID = uuid.str()
    project_tuple[self.ID] = ID

    return self:get_space():insert(project_tuple)
end


return project_provider