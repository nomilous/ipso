{util, deferred, parallel}  = require 'also'
{AssertionError} = require 'assert'
facto   = require 'facto'
Loader  = require './loader'
colors  = require 'colors'
Does    = require 'does'
does    = Does does: mode: 'spec'
should  = require 'should'

config = 

    #
    # **ipso should be run in repo root**
    #

    dir: process.cwd()
    modules: {}

{loadModules, loadModulesSync} = Loader.create config

#
# `ipso( testFunction )` - Decorates a test function
# --------------------------------------------------
# 

module.exports = ipso = (testFunction) -> 
    
    fnArgsArray = util.argsOf testFunction

    inject = []

    if fnArgsArray.length == 0 

        #
        # ### No args passed to the test function
        # 
        # * Return a function to mocha that calls the test function when called
        # 

        return -> testFunction.call @

    else if fnArgsArray[0] isnt 'done' and fnArgsArray[0] isnt 'facto' 

        #
        # ### Test function has arguments but not done or facto
        # 
        # * All args are assumed to be injection tags
        # 

        return (done) -> 

            unless @test?

                #
                # Injecting into describe() or context()
                # 
                # * Inject synchronously
                #

                does.activate context: @, mode: 'spec', spec: null, resolver: null
                inject.push Module for Module in loadModulesSync( fnArgsArray, does )
                testFunction.apply @, inject
                return

            #
            # * Injecting into it() or "hook"()
            #

            does.activate context: @, mode: 'spec', spec: @test, resolver: done

            loadModules( fnArgsArray, does ).then(

                (Modules) => 

                    inject.push argN = Module for Module in Modules
                    testFunction.apply @, inject
                    done() 

                done

            ).then( 

                -> does.assert( done )
                (error) -> done error

            )

        #
        # TODO: consider making a loadModules that is not async so
        #       that ipso can be used to inject into describe() and
        #       context()   [ NOT POSSIBLE, ipso injector is async, context and describe are not ]
        #

    return (done) -> 

        does.activate context: @, mode: 'spec', spec: @test, resolver: done
            

        #
        # ### Test function has arguments
        #
        # * Return this function for mocha to run as the test
        #
        # * When mocha calls this function 'to run the test', this function 
        #   calls the original test function
        #
        # * Tests created with 'done' or 'facto' at arg1 receive spectatable modules
        # 
        #
        #      eg.
        #           it 'does something', ipso (facto, something) -> 
        #               something.does 
        #                   functionStub: -> 
        #                       # replaces original (optionally return mock)
        #                   _functionSpy: -> 
        #                       # called ahead of original
        # 
        # 

        if fnArgsArray[0] is 'done' or fnArgsArray[0] is 'facto' 

            fnArgsArray.shift()

            inject.push arg1 = (metadata) -> 

                does.assert( done ).then( 

                    (result) -> 

                        #
                        # * assert does not call done if nothing failed
                        #

                        if fnArgsArray[0] is 'facto' then facto metadata
                        
                        done()

                    (error) -> 

                        #
                        # * assert already called done - to fail the mocha test
                        #

                        if fnArgsArray[0] is 'facto' then facto metadata

                    (notify) -> 

                )

        loadModules( fnArgsArray, does ).then(

            #
            # * loader resolved with list of Modules refs to inject
            #

            (Modules) => 

                inject.push argN = Module for Module in Modules
                testFunction.apply @, inject

            #
            # * loader rejection into done() - error loading module
            #
                
            done

        ).then (->), done


ipso.modules = (list) -> 

    for tag of list 
        unless list[tag].require?
            throw new Error 'ipso.module expects { tagName: { require: "path/or/name" } }'
        config.modules[tag] = list[tag]
    return ipso


ipso.ipso = ipso
ipso.mock = (name) -> 

    object = 
        title: name
        is: (mock) -> 
            if typeof mock is 'object' then return object.should.equal mock
            name.should.equal mock

    #
    # TODO: tagged?
    #

    return does.spectateSync name: name, object
        

    

ipso.tag = deferred (action, list) ->

    parallel( for tag of list

        do (tag) -> -> does.spectate

            name: tag
            tagged: true
            list[tag]

    ).then action.resolve, action.reject, action.notify



module.exports.once = (fn) -> do (done = false) -> ->
    
    return if done
    done = true
    fn.apply @, arguments
    

