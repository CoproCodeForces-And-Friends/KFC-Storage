local task_factory = require('model.task')
local user_factory = require('model.task')
local project_factory = require('model.task')
local org_factory = require('model.task')

local db = {}


function db.configure(config)
    local configure = {}
    configure.TASK = "task"
    configure.USER = "user"
    configure.ORGANIZATION = "organization"
    configure.PROJECT = "project"


    configure.task_provider     = task_factory:new(config)
    configure.user_provider     = user_factory:new(config)
    configure.project_provider  = project_factory:new(config)
    configure.org_provider      = org_factory:new(config)

    function configure.make_task_tuple(table)
        local tuple = {
            [configure.task_provider.EXTERNAL_ID]   = tostring(table['id']),
            [configure.task_provider.TRACKER]       = table['tracker'],
            [configure.task_provider.NAME]          = table['name'],
            [configure.task_provider.DESCRIPTION]   = table['description'],
            [configure.task_provider.CREATION_DATE] = table['creationDate'],
            [configure.task_provider.CHANGE_DATE]   = table['changeDate'],
            [configure.task_provider.STATUS]        = table['status'],
            [configure.task_provider.CREATOR_ID]    = table['creatorId'],
            [configure.task_provider.HANDLER_ID]    = table['handlerId'],
            [configure.task_provider.DUE]           = table['due'],
            [configure.task_provider.URL]           = table['url'],
            [configure.task_provider.LABELS]        = table['label'],
            [configure.task_provider.PROJECT_ID]    = table['projectId'],
            [configure.task_provider.RELATED_TASKS] = table['relatedTasks'],
            [configure.task_provider.ACTIVITY]      = table['activity']
        }

        return tuple
    end

    function configure.make_user_tuple(table)
        local tuple = {
            [configure.user_provider.EXTERNAL_ID]       = tostring(table['id']),
            [configure.user_provider.TRACKER]           = table['tracker'],
            [configure.user_provider.NAME]              = table['name'],
            [configure.user_provider.NICKNAME]          = table['nickname'],
            [configure.user_provider.EMAIL]             = table['email'],
            [configure.user_provider.CREATION_DATE]     = table['createDate'],
            [configure.task_provider.ORGANIZATION_ID]   = table['organizationId'],
            [configure.user_provider.IS_ACTIVE]         = table['status'],
            [configure.user_provider.URL]               = table['url']
        }

        return tuple
    end

    function configure.make_project_tuple(table)
        local tuple = {
            [configure.project_provider.EXTERNAL_ID]       = tostring(table['id']),
            [configure.project_provider.TRACKER]           = table['tracker'],
            [configure.project_provider.NAME]              = table['name'],
            [configure.project_provider.DESCRIPTION]       = table['description'],
            [configure.project_provider.CREATION_DATE]     = table['createDate'],
            [configure.project_provider.URL]               = table['url'],
            [configure.project_provider.ORGANIZATION_ID]   = table['organizationId']
        }

        return tuple
    end

    function configure.make_task_tuple(table)
        local tuple = {
            [configure.org_provider.EXTERNAL_ID]   = tostring(table['id']),
            [configure.org_provider.TRACKER]       = table['tracker'],
            [configure.org_provider.NAME]          = table['name'],
            [configure.org_provider.DESCRIPTION]   = table['description'],
            [configure.org_provider.URL]           = table['url']
        }

        return tuple
    end

    function configure.add_entity(entity, data)
        if entity == configure.TASK then
            local tuple = configure.make_task_tuple(data)
            configure.task_provider:create(tuple)

        elseif entity == configure.USER then
            local tuple = configure.make_user_tuple(data)
            configure.user_provider:create(tuple)

        elseif entity == configure.PROJECT then
            local tuple = configure.make_project_tuple(data)
            configure.project_provider:create(tuple)

        elseif entity == configure.ORGANIZATION then
            local tuple = configure.make_org_tuple(data)
            configure.org_provider:create(tuple)

        else
            return -1
        end

        return 0
    end

    function configure.get_entity(entity, id, tracker)

        if entity == configure.TASK then
            return configure.task_provider:get_by_tracker(id, tracker)

        elseif entity == configure.USER then
            return configure.user_provider:get_by_tracker(id, tracker)

        elseif entity == configure.PROJECT then
            return entity == configure.project_provider:get_by_tracker(id, tracker)

        elseif entity == configure.ORGANIZATION then
            return configure.org_provider:get_by_tracker(id, tracker)

        else
            return -1
        end


        return 0
    end

    return configure
end


return db