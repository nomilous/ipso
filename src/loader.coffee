{parallel} = require 'also'

lastInstance          = undefined
module.exports._test  = -> lastInstance
module.exports.create = (config = {}) ->

    lastInstance = local = 

        dir: config.dir

        loadModules: (spectate, fnArgsArray) ->

            parallel( for nodule in fnArgsArray

                do (nodule) -> -> spectate require nodule

            )

    return api = 

        loadModules: local.loadModules
