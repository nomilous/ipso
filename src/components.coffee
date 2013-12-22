{readdirSync, readFileSync} = require 'fs'
{join} = require 'path'

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

module.exports = (ipso) -> (opts) -> 

    #
    # loads components for serverside use
    # -----------------------------------
    # 
    # * assumes (for now) that cwd is the directory containing the components subdirectory
    #

    compomnentsRoot = join process.cwd(), 'components'

    try 

        #
        # * assemble list of modules to be defined, and their component alias path
        #

        list    = {}
        aliases = {}

        for componentDir in readdirSync compomnentsRoot

            componentFile = join compomnentsRoot, componentDir, 'component.json'
            
            try 

                #
                # * TODO: enable require 'username/componentname' to handle name collisions
                #                (this could prove to be very !!TRICKY!!)
                #

                component = JSON.parse readFileSync componentFile

                list[ component.name ] = -> 
                aliases[ component.name ] = join compomnentsRoot, componentDir, component.main

            catch error

                console.log "ipso: error loading component: #{componentFile}"

    catch err

        switch err.errno

            when 3  then console.log "ipso: could not access directory: #{compomnentsRoot}"
            when 34 then console.log "ipso: expected directory: #{compomnentsRoot}"
            else         console.log "ipso: unexpected error reading directory: #{compomnentsRoot}" 

    ipso.define list, aliases
    return ipso

