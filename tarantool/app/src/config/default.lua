
return {

    spaces = {
        task = {
            name = 'task',
        },
        user = {
            name = 'user',
        },
        organization = {
            name = 'organization',
        },
        project = {
            name = 'project'
        }
    },
    server = {
        HOST = 'localhost',
        PORT = 8008,
        LOG_LEVEL = 5,
        MEMTX_MEMORY = 268435456,
        LOG_FILE = 'tarantool.log',
        CFG_PORT = 3301
    },
    routes = {
        GET_ALL = '/storage/all',
        GET_ENTITY_ALL = '/storage/:tracker/:entity/all',
        MANIPULATE_SINGLE_ENTITY = '/storage/:tracker/:entity/:id',
        GET_DICTIONARY = '/storage/organization/dictionary',
        POST_SEARCH = '/storage/task/search'
    }
}