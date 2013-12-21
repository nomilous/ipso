{util, deferred, parallel}  = require 'also'
{AssertionError} = require 'assert'
facto   = require 'facto'
Loader  = require './loader'
Does    = require 'does'
does    = Does does: mode: 'spec'
should  = require 'should'
{readdirSync, readFileSync} = require 'fs'
{join}        = require 'path'

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

                    does.reset().then -> done error
                    return

                if arg1 isnt 'done' and arg1 isnt 'facto' 

                    #
                    # * test did not "request" done or facto (ie. synchronous)
                    #   but this test wrapper got a done from mocha, it needs
                    #   to be called.
                    #

                    try if promise.then? and @test.type is 'test'
                        return does.reset().then -> 
                            done new Error 'Synchronous test returned promise. Inject test resolver (done or facto).'
                            

                    testResolver()
                    return

                #
                # * redirect AssertionError being raised in a promise chain
                #   back into mocha's test resolver
                #

                try if promise.then? then promise.then (->), (error) -> 

                    does.reset().then -> done error


            #
            # * loader rejection into done() - error loading module
            #
                
            (error) -> 

                does.reset().then -> done error
                

        )


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

        with: (list) -> 

            object[key] = list[key] for key of list
            return object

    #
    # TODO: tagged?
    #

    return does.spectateSync name: name, tagged: true, object


ipso.Mock = (name) -> 

    #
    # Mock() (with capital M) mocks a class definition.
    # 
    # !!EXPERIMENT!!, pending a properly implemented method 
    #                 that stubs the prototype
    # 
    # 

    #
    # * create the mock for injection into subsequent hooks and
    #   tests where .does() can be called upon to create future 
    #   instanceMethod expectations.
    #

    mockObject = ipso.mock name

    return klass = class

        #
        # * with() as class method to configure the base set 
        #   of function and property stubs for each future
        #   instance of the class
        #

        @with = -> 

            mockObject.with.apply @, arguments
            return klass

        #
        # assemble instance from current stub set
        # ---------------------------------------
        # 
        # * will contain stubs (properties and functions) as set 
        #   up in the mock().with()
        # 
        # * will also includes further ammendments created with 
        #   .does() in subsequent hooks (or in the test itself)
        # 

        constructor: -> 

            stubs = does.getSync(name).object

            #
            # * run the special case constructor spy if present
            #

            if typeof stubs.$constructor is 'function'

                stubs.$constructor.apply @, arguments

            #
            # * create the object properties and function from 
            #   the current contents of the mock stub set.
            #

            for stub of stubs

                continue if stub is '$constructor'
                @[stub] = stubs[stub]



ipso.tag = deferred (action, list) ->

    #
    # not necessary to carry the promise, this is a synchronous call
    # but remains potentially async for future use
    #

    parallel( for tag of list

        do (tag) -> -> does.spectateSync

            name: tag
            tagged: true
            list[tag]

    ).then action.resolve, action.reject, action.notify


ipso.define = require './define'


ipso.components = -> 

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

ipso.does = does


module.exports.once = (fn) -> do (done = false) -> ->
    
    return if done
    done = true
    fn.apply @, arguments
    

