{normalize}    = require 'path'
{spawn}        = require 'child_process'
colors         = require 'colors'

module.exports.inspector = (opts, kids, refresh) -> 

    [arg1, arg2, arg3] = opts.args

    if arg3?

        webPort   = arg1
        debugPort = arg2
        script    = arg3
        
    else if arg2?

        webPort   = arg1
        debugPort = 5858
        script    = arg2
        
    else

        webPort   = 8080
        debugPort = 5858
        script    = arg1


    bin = normalize __dirname + '/../node_modules/.bin/node-inspector'
    kids.push kid1 = spawn bin, [
        "--web-port=#{ webPort || 8080}"
    ]

    
    kid1.stderr.on 'data', (chunk) -> refresh chunk.toString(), 'stderr'
    kid1.stdout.on 'data', (chunk) -> 

        str = chunk.toString()
        str = str.replace /5858/, debugPort
        refresh str

    bin = normalize __dirname + '/../node_modules/.bin/node-dev'
    kids.push kid2 = spawn bin, [
        "--debug=#{debugPort}"
        script
    ]

    kid2.stderr.on 'data', (chunk) -> refresh chunk.toString(), 'stderr'
    kid2.stdout.on 'data', (chunk) -> refresh chunk.toString()


