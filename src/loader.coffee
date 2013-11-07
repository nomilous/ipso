{parallel}  = require 'also'
{normalize, sep, dirname} = require 'path'
{underscore} = require 'inflection'
{readdirSync,lstatSync} = require 'fs'
require 'colors'

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

        loadModule: (name, does) -> 

            if path = (try local.modules[name].require)
                if path[0] is '.' then path = normalize local.dir + sep + path
                return require path

            return require name unless local.upperCase name
            return require path if path = local.find name
            console.log 'ipso: ' + "warning: missing module #{name}".yellow
            return {

                $ipso: 
                    PENDING: true
                    module: name
                    save: (path) -> console.log """

                        #
                        #   NonExistantModule.$ipso.save(templateTag, pa/th) 
                        #   ------------------------------------------------
                        #   
                        #   Not yet implemented.
                        # 
                        #   * (for never having to write anything twice)
                        #   * for cases where ipso detects the injection of a not yet existing module
                        #   * can save the newly written stub to ./src/path/ as the ""first draft"" 
                        #   * templates from ~/.ipso/templates
                        #   * pending `does` to expose access to expectations for a list of functions to create
                        #                                                         -----------------------------
                        # 
                        #   
                        #             perhaps there's an even slicker way to do it?
                        #  

                    """.green

            }


        loadModules: (fnArgsArray, does) ->

            return promise = parallel( for Module in fnArgsArray

                do (Module) -> -> 
                    does.spectate 
                        name: Module
                        tagged: false
                        local.loadModule( Module, does )

            )

    return api = 

        loadModules: local.loadModules
