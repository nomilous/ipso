{normalize}    = require 'path'
{spawn}        = require 'child_process'

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

    console.log 

        webPort: webPort
        debugPort: debugPort
        script: script


    bin = normalize __dirname + '/../node_modules/.bin/node-inspector'
    kids.push kid = spawn bin, [
        "--web-port=#{ (try parseInt webPort) || 8080}"
    ]

    
    kid.stderr.on 'data', (chunk) -> refresh chunk.toString(), 'stderr'
    kid.stdout.on 'data', (chunk) -> 

        str = chunk.toString()
        str = str.replace /5858/, debugPort
        refresh str

