{readdirSync, readFileSync} = require 'fs'
{join}        = require 'path'

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

