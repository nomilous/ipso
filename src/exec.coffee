{readFileSync} = require 'fs'
{normalize}    = require 'path'
{spawn}        = require 'child_process'
colors         = require 'colors'
program        = require 'commander'
keypress       = require 'keypress'
keypress process.stdin

program.version JSON.parse( 
    readFileSync __dirname + '/../package.json'
    'utf8'
).version

program.option '-i, --inspector',           'Start node-inspector.'
program.option '-w, --web-port [webPort]',  'Node inspector @ alternate port.'



{inspector, webPort} = program.parse process.argv

kids = []

if inspector

    bin = normalize __dirname + '/../node_modules/.bin/node-inspector'
    kids.push kid = spawn bin, [

        "--web-port=#{ (try parseInt webPort) || 8080}"

    ]

    kid.stdout.on 'data', (chunk) -> refresh chunk.toString()
    kid.stderr.on 'data', (chunk) -> refresh chunk.toString(), 'stderr'




prompt = '> '
input  = ''

refresh = (output, stream) ->

    if output?
        switch stream
            when 'stderr' then process.stdout.write output.red
            else process.stdout.write output

    process.stdout.clearLine()
    process.stdout.cursorTo(0)
    process.stdout.write prompt + input


shutdown = (code) -> 

    kid.kill() for kid in kids
    process.exit code

action = -> 
    
    console.log action: input unless input is ''
    input = ''

run = -> 

    stdin  = process.openStdin()
    process.stdin.setRawMode true
    refresh()
    process.stdin.on 'keypress', (chunk, key) -> 

        try {name, ctrl, meta, shift, sequence} = key

        return shutdown 0 if ctrl and name is 'c'

        if name is 'backspace' 
            input = input[0..-2]
            return refresh()

        if name is 'return'
            process.stdout.write '\n'
            action()
            process.stdout.write prompt + input
            return

        return unless chunk
        input += chunk.toString()
        refresh()

run()
