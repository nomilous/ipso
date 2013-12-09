

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

module.exports = (list) -> 

    module.exports.activate() unless activated

    for moduleName of list

        if moduleName.match /^\$/

            type = 'function'
            name = moduleName[1..]

        else 

            type = 'literal'
            name = moduleName

        override[name] =

            type: type

            'package.json':
                name: name
                version: '0.0.0'
                main: 'STUBBED.js'
                dependencies: {}

            'STUBBED.js': 
                list[moduleName]



override = {}      # override list
lstatOverride = {} # paths that 'fake exist'
activated = false

module.exports.activate = ->

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

                        return """

                        ipso = require('ipso');
                        mock = ipso.mock;
                        get  = function(tag) {

                            try { return ipso.does.getSync(tag).object }
                            catch (error) { console.log('ipso: missing mock "%s"', tag); }

                        }; 

                        module.exports = #{

                            switch type

                                when 'function' 

                                    override[mod]['STUBBED.js'].toString()
                                
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
