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
# * All ipso tests are asynchronous - done is called in the background on the nextTick
#   if the testFunction signature itself did not contain 'done' at argument1
# 

module.exports = ipso = (actualTestFunction) -> 

    return testFunctionForMocha = (done) -> 

        fnArgsArray = util.argsOf actualTestFunction

        argsToInjectIntoTest = []

        unless done?

            #
            # ### Injecting into describe() or context()
            #

            if fnArgsArray[0] is 'done' or fnArgsArray[0] is 'facto' 

                console.log 'ipso cannot inject done into describe() or context()'.red
                return

            does.activate context: @, mode: 'spec', spec: null, resolver: null
            argsToInjectIntoTest.push Module for Module in loadModulesSync( fnArgsArray, does )
            actualTestFunction.apply @, argsToInjectIntoTest
            return




        #
        # ### Injecting into hook or it()
        #

        does.activate context: @, mode: 'spec', spec: @test, resolver: done


        #
        # * testResolver wraps mocha's done into a proxy that call it via 
        #   does.asset(... for function expectations that mocha is not aware of.
        #

        testResolver = (metadata) -> 

            does.assert( done ).then( 

                (result) -> 

                    #
                    # * does.assert(... does not call done if nothing failed
                    #

                    if fnArgsArray[0] is 'facto' then facto metadata
                    done()


                (error) -> 

                    #
                    # * does.assert(... already called done - to fail the mocha test
                    #

                    if fnArgsArray[0] is 'facto' then facto metadata

                (notify) -> 

                    #
                    # * later... 
                    #

            )

        #
        # * testResolver is only injected if arg1 is done or facto
        #

        if fnArgsArray[0] is 'done' or fnArgsArray[0] is 'facto' 

            argsToInjectIntoTest.push testResolver
            arg1 = fnArgsArray.shift()

        loadModules( fnArgsArray, does ).then(

            #
            # * loader resolved with list of Modules refs to inject
            #

            (Modules) => 

                argsToInjectIntoTest.push Module for Module in Modules

                try promise = actualTestFunction.apply @, argsToInjectIntoTest
                catch error

                    does.reset()
                    done error
                    return

                if arg1 isnt 'done' and arg1 isnt 'facto' 

                    #
                    # * test did not "request" done or facto (ie. synchronous)
                    #   but this test wrapper got a done from mocha, it needs
                    #   to be called.
                    #

                    testResolver()

                #
                # * redirect AssertionError being raised in a promise chain
                #   back into mocha's test resolver
                #

                if promise.then? then promise.then (->), done

            #
            # * loader rejection into done() - error loading module
            #
                
            done

        )


ipso.modules = (list) -> 

    for tag of list 
        unless list[tag].require?
            throw new Error 'ipso.module expects { tagName: { require: "path/or/name" } }'
        config.modules[tag] = list[tag]
    return ipso

#
# convenience {ipso, mock, tag} = require 'ipso'
#

ipso.ipso = ipso
ipso.mock = (name) -> 

    object = 
        title: name
        is: (mock) -> 
            if typeof mock is 'object' then return object.should.equal mock
            name.should.equal mock

        #
        # experiment - may become property expetations
        #

        has: (list) -> 

            object[key] = list[key] for key of list
            return object

    #
    # TODO: tagged?
    #

    return does.spectateSync name: name, tagged: true, object
        

    

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
    

