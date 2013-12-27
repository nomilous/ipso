fs     = require 'fs'
path   = require 'path'
{util} = require 'also'

#
# TODO:
# 
# * enable warning on name stomping existing node module
#
# * opts can define alternative components location
# 
# * consider that the require bridge and possibly even the injection functionality
#   may belong upstream, inside component's compendium of goodness
# 
#       * reasons againt
#
#           * it is admittedly somewhat of a hac:
#             
#               monkey-patching readFileSync and co. to `simulate` 
#               a node_module being installed
# 
#           * it steps on the toes of the npm empire
# 
#           * name collision problems
#
# 
#       * reasons for
# 
#           * it opens the doors a little wider on async just-in-time module 
#             installs, making ""deployment"" that much less of a thing.
# 
#           * relatedly, it's an interesting middleground on the ole' commonjs 
#             vs. requirejs debate 
# 


module.exports = (ipso) -> (args...) -> 

    #
    # function at last argument is injection target
    # ---------------------------------------------
    # 
    # * If it is present, it will be called immediately.
    # * The argument signature is used to determine which node_modules, 
    #   components or local ./lib or ./app modules should be injected
    #
    
    fn = arg for arg in args


    #
    # mode is set to 'bridge' in does
    # -------------------------------
    # 
    # * does in an injection filter
    # * each component or module being injected is passed through the filter
    # * in `spec` mode it attaches .does() to each for mocking.
    # * in `bridge` mode it does nothing ##undecided
    #

    ipso.does.config mode: 'bridge'


    #
    # load components for require-ability
    # -----------------------------------
    # 
    # * hardcoded below are certain pending configurables
    # * there will be name collisions, nothing has been done about it here
    # 

    compomnentsRoot = path.join process.cwd(), 'components'

    #
    # * assemble list of modules to be defined, and their component alias path
    #

    list    = {}
    aliases = {}

    try 

        for componentDir in fs.readdirSync compomnentsRoot

            componentFile = path.join compomnentsRoot, componentDir, 'component.json'
            
            try 

                component = JSON.parse fs.readFileSync componentFile

                list[ component.name ] = ->
                aliases[ component.name ] = path.join compomnentsRoot, componentDir, component.main || 'index.js'

                #
                # inject.alias
                # ------------
                # 
                # * extended component config can define inject.alias
                # * it creates an additional ""name"" that can be used with require to access the component
                # 

                if component.inject? and component.inject.alias?

                    list[ component.inject.alias ] = -> 
                    aliases[ component.inject.alias ] = path.join compomnentsRoot, componentDir, component.main || 'index.js'


            catch error

                console.log "ipso: error loading component: #{componentFile}"

    catch err

        switch err.errno

            when 3  then console.log "ipso: could not access directory: #{compomnentsRoot}"
            when 34 then console.log "ipso: expected directory: #{compomnentsRoot}"
            else         console.log "ipso: unexpected error reading directory: #{compomnentsRoot}" 


    #
    # * create module name aliases for require
    #

    ipso.define list, aliases: aliases


    #
    # * ipso injects into fn(*) if present
    #

    if typeof fn is 'function'

        decoratedFn = ipso fn
        decoratedFn resolver = (result) -> 

            console.log result if result?

    return ipso

