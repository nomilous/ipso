{parallel} = require 'also'

lastInstance          = undefined
module.exports._test  = -> lastInstance
module.exports.create = (config = {}) ->

    lastInstance = local = 

        dir: config.dir

        upperCase: (string) -> 

            try char = string[0].charCodeAt 0
            catch error
                return false
            return true if char > 64 and char < 91
            return false


        loadModule: (name) -> 

            return require name unless local.upperCase name[0]


        loadModules: (fnArgsArray, spectate) ->

            return promise = parallel( for Module in fnArgsArray

                do (Module) -> -> spectate local.loadModule Module

            )

    return api = 

        loadModules: local.loadModules
