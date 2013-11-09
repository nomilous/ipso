{deferred, parallel, pipeline}  = require 'also'
{normalize, sep, dirname} = require 'path'
{underscore} = require 'inflection'
{readdirSync,lstatSync} = require 'fs'
require 'colors'

lastInstance          = undefined
module.exports._test  = -> lastInstance
module.exports.create = (config) ->

    lastInstance = local = 

        #
        # `loadModules( arrayOfName, doesInstance )`
        # -----------------------------------------
        # 
        # * Asynchronously load the list of modules.
        # * Used by `it()`'s and `before()`'s and `after()`'s in mocha (they're async)
        # * Can load special case ipso.tag(ged) objects
        # * Objects are assigned spectateability. (  `objct.does(...`   )
        #

        loadModules: (arrayOfName, doesInstance) ->

            return promise = parallel( for moduleName in arrayOfName

                #
                # https://github.com/nomilous/knowledge/blob/master/spec/promise/loops.coffee#L81
                #

                do (moduleName) -> -> return nestedPromise = pipeline [

                    (      ) -> local.loadModule moduleName, doesInstance
                    (module) -> doesInstance.spectate name: moduleName, tagged: false, module

                ]
            )


        #
        # `loadModulesSync( arrayOfName, doesInstance )`
        # ----------------------------------------------
        # 
        # * Synchronously load the list of modules.
        # * Used by `describe()`'s and `context()`'s in mocha (they're sync)
        # * VERY IMPORTANT
        #     * does not load tagged objects
        # 

        loadModulesSync: (arrayOfName, doesInstance) -> 

            for moduleName in arrayOfName

                local.loadModuleSync moduleName, doesInstance









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

        loadModule: deferred (action, name, does) -> 

            #
            # loadModule is async (promise)
            # -----------------------------
            # 
            # * enables ipso to involve network/db for does.tag(ged) object injection
            # * first attempts to load a tagged object from does.tagged
            # * falls back to local (synchronously loaded) modules
            # 

            does.get query: tag: name, (error, spectated) -> 

                #
                # * does.get() returns error on not found tag or bad args
                #       * for now those errors can be safely ignored 
                #           * not found is valid reason to fall through to local injection below 
                #           * bad args will not occur becase no pathway exists that leads through 
                #             here to a call to does.get with bad args.
                #      

                #
                # * does.get() returns the entire spectated entity, including expectections,
                #   only resolve with the object itself for injection
                #

                return action.resolve spectated.object if spectated?
                # return action.reject error if # TODO: network/db errors later

                if path = (try local.modules[name].require)
                    if path[0] is '.' then path = normalize local.dir + sep + path
                    return action.resolve require path

                return action.resolve require name unless local.upperCase name
                return action.resolve require path if path = local.find name
                console.log 'ipso: ' + "warning: missing module #{name}".yellow
                return action.resolve {

                    $ipso: 
                        PENDING: true
                        module: name
                        save: (path) -> console.log """

                            #
                            #   #{name}.$ipso.save(templateTag, pa/th) 
                            #   -------------------------------------------------------------------
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


        loadModuleSync: (name, does) -> 

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
                        #   #{name}.$ipso.save(templateTag, pa/th) 
                        #   --------------------------------------------------------------
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



    return api = 

        loadModules: local.loadModules
        loadModulesSync: local.loadModulesSync
