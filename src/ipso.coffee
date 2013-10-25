{util} = require 'also'
facto  = require 'facto'

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
        #   calls the original test function, passing in the done 
        #

        if fnArgs[0] is 'facto' then promise = fn.call @, -> console.log facto done()
        else promise = fn.call @, done

        #
        # * if the test returned a promise, chain to catch possible 
        #   failure in the promise rejection handler
        # 
        # * noop the resolution handler to let the test call done()
        #   without the "multiple done()'s were called" error
        #

        if promise? and promise.then? then promise.then (->), done

