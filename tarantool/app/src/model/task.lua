local utils = require('utils.utils')
local uuid = require('uuid')
local log = require('log')

local task_provider = {}

function create_task_space(task_model)
    log.info('Info %s', 'task environment creation started')

    local space = box.schema.space.create(task_model.SPACE_NAME, {
        if_not_exists = true
    })

    space:create_index(task_model.PRIMARY_INDEX, {
        type = 'hash',
        parts = { task_model.ID, 'string' },
        if_not_exists = true
    })
    space:create_index(task_model.TRACKER_INDEX, {
        type = 'tree',
        unique = false,
        parts = { task_model.EXTERNAL_ID, 'string', task_model.TRACKER, 'string' },
        if_not_exists = true
    })
    log.info('Info %s', 'task environment created')
end

function task_provider:new(config)
    local taskObj = {}
    log.info('Info %s', 'task_provider creating started')
    taskObj.SPACE_NAME = config.spaces.task.name

    taskObj.PRIMARY_INDEX = 'primary'
    taskObj.TRACKER_INDEX = 'tracker_index'

    taskObj.ID = 1
    taskObj.EXTERNAL_ID = 2
    taskObj.TRACKER = 3
    taskObj.NAME = 4
    taskObj.DESCRIPTION = 5
    taskObj.CREATION_DATE = 6
    taskObj.CHANGE_DATE = 7
    taskObj.STATUS = 8
    taskObj.CREATOR_ID = 9
    taskObj.HANDLER_ID = 10
    taskObj.DUE = 11
    taskObj.URL = 12
    taskObj.LABELS = 13
    taskObj.PROJECT_ID = 14
    taskObj.RELATED_TASKS = 15
    taskObj.ACTIVITY = 16

    box.once('task bootstrap', create_task_space, taskObj)

    self.__index = self
    log.info('Info %s', 'task_provider created')
    return setmetatable(taskObj, self)
end

function task_provider:get_space()
    return box.space[self.SPACE_NAME]
end

function task_provider:get_by_id(id)
    return self:get_space():get(id)
end


function task_provider:get_by_tracker(external_id, tracker)
    return self:get_space().index[self.TRACKER_INDEX]:select({ external_id, tracker })[1]
end


function task_provider:delete_by_tracker(external_id, tracker)
    if utils.not_empty_string(external_id) and utils.not_empty_string(tracker) then
        return self:get_space().index[self.TRACKER_INDEX]:delete({ external_id, tracker })
    end
end


function task_provider:update_by_tracker(task_tuple)
    local external_id = task_tuple[self.EXTERNAL_ID]
    local tracker = task_tuple[self.TRACKER]

    local fields = utils.format_update(task_tuple)

    return self:get_space().index[self.TRACKER_INDEX]:update({ external_id, tracker }, fields)
end


function task_provider:update(task_tuple)
    local id = task_tuple[self.ID]

    local fields = utils.format_update(task_tuple)

    return self:get_space():update(id, fields)
end


function task_provider:create(task_tuple)

    local ID = uuid.str()
    task_tuple[self.ID] = ID

    return self:get_space():insert(task_tuple)
end


return task_provider