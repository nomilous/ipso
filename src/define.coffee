

#
# HAC
# ===
# 
# ipso.define(list)
# -----------------
# 
# creates capacity to return mock module using require
# 
# Achieved by tailoring the behaviours of fs{readFileSync, statSync, lstatSync}
# such that when they are called from require('module-name') (module.js) they
# return faked responses that create the appearence of the module being installed.
# 
# 

fs    = require 'fs'
{sep} = require 'path'

module.exports = (list, opts = {}) -> 

    module.exports.activate()

    type = 'literal'
    if opts.aliases? then type = 'aliased'

    for moduleName of list
        
        name  = moduleName
        alias = try opts.aliases[moduleName]

        # console.log aliasing: [name, alias]

        override[name] =

            type: type

            aliasPath: alias

            'package.json':
                name: name
                version: '0.0.0'
                main: 'STUBBED.js'
                dependencies: {}

            'STUBBED.js': 
                list[moduleName]

        #
        # immediately do the first require to create the mock 
        # subclasses ""as mocks""
        # 
        # this alleviates the problem of the first injection of 
        # the mock being perfomed ahead of the require, leading 
        # to the submodules being created as ""PENDING modules""
        # instead of mocks (ie. define $save)
        #

        if type is 'literal' then require name



override = {}      # override list
lstatOverride = {} # paths that 'fake exist'
activated = false

Object.defineProperty module.exports, 'activate', enumarable: 'false', get: -> 

    if activated then return -> 
    return ->

        activated = true
        readFileSync = fs.readFileSync
        fs.readFileSync = (path, encoding) ->

            ### MODIFIED BY ipso.define ###

            [mod, file] = path.split( sep )[-2..]
            parts       = path.split( sep )[0..-3]

            modulesPath = parts.join sep
            modulePath  = parts.concat([mod]).join sep
            scriptPath  = parts.concat([mod, 'STUBBED.js']).join sep

            #
            # dodge modules with names that are properties of Object
            #

            # ignore = [
            #     'should'
            # ]

            if override.hasOwnProperty(mod) # and ignore.indexOf( mod ) < 0

                type = override[mod].type

                switch file

                    when 'package.json'

                        lstatOverride[modulesPath] = 1
                        lstatOverride[modulePath] = 1
                        lstatOverride[scriptPath] = 1

                        return JSON.stringify override[mod]['package.json']


                    when 'STUBBED.js'

                        if typeof override[mod]['STUBBED.js'] is 'function'

                            if override[mod].type is 'aliased'

                                # console.log 
                                #     aliased: mod
                                #     path: override[mod].aliasPath


                                return """
                                module.exports = require('#{override[mod].aliasPath}');
                                """

                            if override[mod].scriptPath?

                                #
                                # Same module has already been required and 
                                # a different path was resolved, 
                                # 
                                # Proxy require to the original path to preserve 
                                # require cache.
                                #

                                return """
                                module.exports = require('#{override[mod].scriptPath}');
                                """

                            else

                                override[mod].scriptPath = scriptPath

                            return """

                            ipso = require('ipso'); // testing catch 22
                            mock = ipso.mock;
                            Mock = ipso.Mock;
                            get  = function(tag) {

                                try { return ipso.does.getSync(tag).object }
                                catch (error) { console.log('ipso: missing mock "%s"', tag); }

                            }; 

                            module.exports = #{

                                switch type

                                    when 'literal' 

                                        "(#{override[mod]['STUBBED.js'].toString()}).call(this);"

                            }
                            """

                        else 

                            console.log """
                            ipso.define(list) requires list of functions to be exported as modules,
                            or used as module factories.
                            """.red


                

            readFileSync path, encoding

        statSync = fs.statSync
        fs.statSync = (path) -> 

            ### MODIFIED BY ipso.define ###

            if path.match /STUBBED.js/ then return {
                isDirectory: -> false
            }

            statSync path


        lstatSync = fs.lstatSync
        fs.lstatSync = (path) -> 

            ### MODIFIED BY ipso.define ###

            if lstatOverride[path]? then return {
                isSymbolicLink: -> false
            }

            lstatSync path
