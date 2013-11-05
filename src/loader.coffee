{parallel}  = require 'also'
{normalize, sep, dirname} = require 'path'
{underscore} = require 'inflection'
{readdirSync,lstatSync} = require 'fs'

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

        recurse: (name, path, matches) -> 

            for fd in readdirSync path
                file = path + sep + fd
                stat = lstatSync file
                if stat.isDirectory()
                    local.recurse name, file, matches
                    continue
                if fd.match new RegExp "^#{name}.[js|coffee]"
                    matches.push dirname(file) + sep + name

        find: (name) -> 

            matches = []
            try local.recurse underscore(name), local.dir + sep + 'lib', matches
            try local.recurse underscore(name), local.dir + sep + 'app', matches
            if matches.length > 1 then throw new Error "ipso: found multiple matches for #{name}, use ipso.modules"
            return matches[0]

        loadModule: (name) -> 

            if path = (try local.modules[name].require)
                if path[0] is '.' then path = normalize local.dir + sep + path
                return require path

            return require name unless local.upperCase name
            return require path if path = local.find name 


        loadModules: (fnArgsArray, spectate) ->

            return promise = parallel( for Module in fnArgsArray

                do (Module) -> -> spectate local.loadModule Module

            )

    return api = 

        loadModules: local.loadModules
