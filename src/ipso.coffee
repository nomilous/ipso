{util} = require 'also'

module.exports = (fn) -> 
    
    fnArgs = util.argsOf fn

    if fnArgs.length == 0 then return -> fn.call @
    
    (done) -> fn.call @, done






# module.exports.facto = require './facto'
