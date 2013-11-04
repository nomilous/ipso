hound  = require 'hound'
colors = require 'colors' 
{sep}  = require 'path'

module.exports.watcher = (opts) -> 

    return unless opts.path? and opts.handler?
    watchdir = process.cwd() + sep + opts.path
    
    try 
        emitter = hound.watch watchdir
        emitter.on 'change', opts.handler.change
        console.log 'ipso:' + " watching directory: .#{sep}#{opts.path}".grey

    catch error
        if error.errno == 34 
            console.log 'ipso:' + " expected directory: .#{sep}#{opts.path}".red
        else 
            console.log 'ipso:' + " exception #{error}".red

