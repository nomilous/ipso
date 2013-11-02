{util, parallel}   = require 'also'
facto              = require 'facto'
does               = require 'does'
{spectate, assert} = does does: mode: 'spec'

module.exports = (fn) -> 
    
    fnArgs = util.argsOf fn
    if fnArgs.length == 0 

        #
        # * no args defined on test function signature (ie. synchronous test)
        # * return a function to mocha's it()
        # * when mocha calls this function,, this function calls the original test function
        # * and preserves the context (@)
        # 

        return -> fn.call @

    #
    # * got args on the test function
    # * return a function to it() that accepts the test resolver
    # 
    
    (done) -> 

        #
        # * when mocha calls this function 'to run the test', this function 
        #   calls the original test function
        #

        inject  = []

        if fnArgs[0] is 'done' 

            inject.push done
            fnArgs.shift()


        else 

            #
            # * test has not ""asked"" for 'done'
            # * call it here  on the nextTick, but only if not facto at arg1
            # 

            done() if done? unless fnArgs[0] is 'facto'


        if fnArgs[0] is 'facto' 

            #
            # Tests created with facto at arg1 receive spectatable modules
            # ------------------------------------------------------------
            #
            # eg
            # 
            #     it 'does something', ipso (facto, something) -> 
            #  
            #         something.does ...
            # 
            # 

            fnArgs.shift()

            #
            # * first injected argument is the test resolver
            # 

            inject.push (metadata) -> 

                #
                # TODO: consider posibilities of assert output also being
                #       directed into facto()
                #

                #
                # * hand the mocha test resolver into does.assert to perform 
                #   any necessary raisins
                #

                assert done

                #
                # TODO: async facto().then  #?# -> done()
                # COMPLEXITY: test timeout (if it needs to wait)
                #

                facto metadata

                #
                # call original done (mocha)
                #

                done()
            

            promise = parallel( for nodule in fnArgs

                do (nodule) -> -> spectate require nodule

            ).then(

                (nodules) => 

                    inject.push nodule for nodule in nodules
                    fn.apply @, inject
                    

                done

            )

            if promise? and promise.then? then promise.then (->), done
            return


        else 

            inject.push require nodule for nodule in fnArgs
            promise = fn.apply @, inject


        #
        # * if the test returned a promise, chain to catch possible 
        #   failure in the promise rejection handler
        # 
        # * noop the resolution handler to let the test call done()
        #   without the "multiple done()'s were called" error
        #

        if promise? and promise.then? then promise.then (->), done

