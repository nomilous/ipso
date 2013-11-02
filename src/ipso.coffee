{util, parallel} = require 'also'
facto            = require 'facto'
does             = require 'does'
{spectate}       = does mode: 'spec'

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

            #inject.push (meta) -> facto done, meta
            inject.push (meta) -> facto done(), meta
            fnArgs.shift()

            return parallel( for nodule in fnArgs

                do (nodule) -> -> spectate require nodule

            ).then(

                (nodules) => 

                    inject.push nodule for nodule in nodules
                    promise = fn.apply @, inject
                    if promise? and promise.then? then promise.then (->), done

                done

            )


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

