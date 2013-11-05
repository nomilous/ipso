{parallel}  = require 'also'
{normalize, sep} = require 'path'

lastInstance          = undefined
module.exports._test  = -> lastInstance
module.exports.create = (config) ->

    lastInstance = local = 

        dir: config.dir
        modules: config.modules

        upperCase: (string) -> 

            try char = string[0].charCodeAt 0
            catch error
                return false
            return true if char > 64 and char < 91
            return false


        loadModule: (name) -> 

            if path = (try local.modules[name].require)
                if path[0] is '.' then path = normalize local.dir + sep + path
                return require path

            return require name unless local.upperCase name


        loadModules: (fnArgsArray, spectate) ->

            return promise = parallel( for Module in fnArgsArray

                do (Module) -> -> spectate local.loadModule Module

            )

    return api = 

        loadModules: local.loadModules
