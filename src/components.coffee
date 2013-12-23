fs   = require 'fs'
path = require 'path'

#
# TODO:
# 
# * set does mode to something other than spec to disable and remove .does mocker
# 
#       * other things may need tailoring too, can't recall
#
# * opts can define alternative components location
# 
# * hitchike injection tag / alias config via component.json
# 
#       * perhaps a bit presumptious to hitchhike additional configuration 
#         keys onto component.json
# 
#       * AWESOME that it's possible tho... :)
# 
#       * see inject.alias below
# 
# * handle whatever challenges are presented re injection tag 
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
    # loads components for serverside use
    # -----------------------------------
    # 
    # * assumes (for now) that cwd is the directory containing the components subdirectory
    #

    lastarg = arg for arg in args

    ipso.does.mode 'bridge'

    compomnentsRoot = path.join process.cwd(), 'components'

    #
    # * assemble list of modules to be defined, and their component alias path
    #

    list    = {}
    aliases = {}
    injects = {}

    try 

        for componentDir in fs.readdirSync compomnentsRoot

            componentFile = path.join compomnentsRoot, componentDir, 'component.json'
            
            try 

                # console.log order: componentDir

                #
                # * TODO: enable require 'username/componentname' to handle name collisions
                #                (this could prove to be very !!TRICKY!!)
                #

                component = JSON.parse fs.readFileSync componentFile

                list[ component.name ] = -> 
                aliases[ component.name ] = path.join compomnentsRoot, componentDir, component.main || 'index.js'

                #
                # inject.alias
                # ------------
                # 
                # * extended component config can define inject.alias
                # * it creates an injection tag reference for cases where module names 
                #   are not injection friendly
                #

                if component.inject? and component.inject.alias?

                    #
                    # * TODO: warn on / handle injection alias name collision
                    #

                    injects[ component.inject.alias ] = component.name

            catch error

                console.log "ipso: error loading component: #{componentFile}"

    catch err

        switch err.errno

            when 3  then console.log "ipso: could not access directory: #{compomnentsRoot}"
            when 34 then console.log "ipso: expected directory: #{compomnentsRoot}"
            else         console.log "ipso: unexpected error reading directory: #{compomnentsRoot}" 


    # console.log ALIASES: aliases

    ipso.define list, aliases: aliases

    #
    # * ipso.tag where defined
    #

    tags = {}
    for tag of injects
        moduleName = injects[tag]
        tags[tag] = require aliases[ moduleName ]

    ipso.tag tags

    

    lastarg() if typeof lastarg is 'function'

    return ipso

