{util}             = require 'also'
facto              = require 'facto'
loader             = require './loader'
does               = require 'does'
{spectate, assert} = does does: mode: 'spec'

# #
# # spec events into does()
# # -----------------------
# # 
# require('./mocha_runner').on 'spec_event', (payload) ->   # subscribe
#     #
#     # is mocha spawning children?
#     # ---------------------------
#     # 
#     # ## THIS IN A RUNNING TEST 
#     # 
#     console.log HUH: payload


module.exports = ipso = (fn) -> 
    
    fnArgsArray = util.argsOf fn
    if fnArgsArray.length == 0 

        #
        # No args passed to the test function
        # -----------------------------------
        #

        return -> fn.call @
    

    return (done) -> 

        #
        # Test function has arguments
        # ---------------------------
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

        inject  = []

        if fnArgsArray[0] is 'done' or fnArgsArray[0] is 'facto' 

            fnArgsArray.shift()

            inject.push arg1 = (metadata) -> 

                assert( done ).then( 

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


            
            return loader( spectate, fnArgsArray ).then(

                #
                # * loader resolved with list of Modules refs to inject
                #

                (Modules) => 

                    inject.push argN = Module for Module in Modules
                    fn.apply @, inject

                #
                # * loader rejection into done() - error loading module
                #
                    
                done

            ).then (->), done
 

        else 

            #
            # not (done,...) or (facto,...)
            # -----------------------------
            # 
            # * Injected modules do not define `.does()` 
            #

            inject.push require nodule for nodule in fnArgsArray
            promise = fn.apply @, inject

            #
            # * Test has not ""asked"" for 'done' but mocha has injected because
            #   arguments (modules to be injected) are present - call it on next
            #   tick to mimick synchronous test
            #

            process.nextTick -> done() if done?
            try promise.then (->), done


module.exports.once = (fn) -> do (done = false) -> ->
    
    return if done
    done = true
    fn.apply @, arguments
    

