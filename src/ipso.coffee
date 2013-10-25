{util} = require 'also'

module.exports = (fn) -> 
    
    fnArgs = util.argsOf fn
    if fnArgs.length == 0 

        #
        # * no args defined on test function signature
        # * return a function that calls the test function
        # * preseve existing self (context)
        #

        return -> fn.call @
    
    (done) -> 

        promise = fn.call @, done
        if promise? and promise.then? then promise.then (->), done

