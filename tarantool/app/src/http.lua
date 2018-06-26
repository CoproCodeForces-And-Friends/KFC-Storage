local server = require('http.server')
local json = require('json')

local srv = {}

function srv.init(config)
    box.cfg {
        log = config.server.LOG_FILE,
        log_level = config.server.LOG_LEVEL,
        memtx_memory = config.server.MEMTX_MEMORY,
        listen = config.server.CFG_PORT
    }

    local httpd = server.new(config.server.HOST, config.server.PORT)

    httpd:route({path = config.routes.GET_ALL, method = 'GET'}, 'entityController#get_all')
    httpd:route({path = config.routes.GET_ENTITY_ALL, method = 'GET'}, 'entityController#get_entity_all')

    httpd:route({path = config.routes.MANIPULATE_SINGLE_ENTITY, method = 'GET'}, 'entityController#get_entity')
    httpd:route({path = config.routes.MANIPULATE_SINGLE_ENTITY, method = 'POST'}, 'entityController#add_entity')
    httpd:route({path = config.routes.MANIPULATE_SINGLE_ENTITY, method = 'PUT'}, 'entityController#update_entity')
    httpd:route({path = config.routes.MANIPULATE_SINGLE_ENTITY, method = 'PATCH'}, 'entityController#update_entity_part')

    httpd:route({path = config.routes.GET_DICTIONARY, method = 'GET'}, 'entityController#get_main_info')
    httpd:route({path = config.routes.POST_SEARCH, method = 'POST'}, 'entityController#get_tasks_by_pattern')

    return httpd
end

return srv