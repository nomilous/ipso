{util, deferred, parallel}  = require 'also'
{sep} = require 'path'
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



#
# HAC
# ===
# 
#  ipso.def 'module-name': ->
#  --------------------------
# 
#  creates capacity to successfully require 'module-name'
#  even tho module-name does not exist
# 
#  Achieved by tailoring the behaviours of fs{readFileSync, statSync, lstatSync}
#  such that when they are called from require('module-name') (module.js) they
#  return faked responses that create the appearence of the module being installed.
#


override = {}    # override require
lstatOverride = {} # paths that fake exist

#
# TODO: only replace these if def is called
#       an then only once
#

fs = require 'fs'
readFileSync = fs.readFileSync
fs.readFileSync = (path, encoding) ->

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

        switch file

            when 'package.json'

                lstatOverride[modulesPath] = 1
                lstatOverride[modulePath] = 1
                lstatOverride[scriptPath] = 1

                return JSON.stringify override[mod]['package.json']


            when 'STUBBED.js'

                if typeof override[mod]['STUBBED.js'] is 'function'

                    return """

                    // console.log('loading stubbed module "#{mod}"');
                    
                    ipso = require('ipso');

                    /* stubbed module scope contains get() for access to pre-defined mock objects */

                    get = function(tag) {
                        try { 
                            return ipso.does.getSync(tag).object
                        } catch (error) {
                            console.log('ipso: missing mock "%s"', tag);
                        }
                    }; 

                    module.exports = #{

                        override[mod]['STUBBED.js'].toString()

                    }
                    """

                else 

                    console.log """
                    ipso.def(list) requires list of functions to be exported as modules,
                    does not (yet?) support define for modules that export objects
                    """.red


        

    readFileSync path, encoding

statSync = fs.statSync
fs.statSync = (path) -> 

    if path.match /STUBBED.js/ then return {
        isDirectory: -> false
    }

    statSync path


lstatSync = fs.lstatSync
fs.lstatSync = (path) -> 

    if lstatOverride[path]? then return {
        isSymbolicLink: -> false
    }

    lstatSync path


ipso.define = (list) -> 

    for moduleName of list

        override[moduleName] =

            'package.json':
                name: moduleName
                version: '0.0.0'
                main: 'STUBBED.js'
                dependencies: {}

            'STUBBED.js':
                list[moduleName]


ipso.does = does


module.exports.once = (fn) -> do (done = false) -> ->
    
    return if done
    done = true
    fn.apply @, arguments
    

