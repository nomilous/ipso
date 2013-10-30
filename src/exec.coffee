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
hint   = ''

actions = 

    'node-debug':   args: '<port> <script>'
    'coffee-debug': args: '<port> <script>'


refresh = (output, stream) ->

    if output?
        switch stream
            when 'stderr' then process.stdout.write output.red
            else process.stdout.write output

    process.stdout.clearLine()
    process.stdout.cursorTo 0
    process.stdout.write prompt + input + hint
    process.stdout.cursorTo (prompt + input).length


shutdown = (code) -> 

    kid.kill() for kid in kids
    process.exit code

doAction = -> 
    
    [act, args...] = input.split ' '
    console.log action: act, args: args unless input is ''
    input = ''

run = -> 

    stdin  = process.openStdin()
    process.stdin.setRawMode true
    refresh()
    process.stdin.on 'keypress', (chunk, key) -> 

        hint = ''

        try {name, ctrl, meta, shift, sequence} = key
        if ctrl 
            switch name
                when 'd' then shutdown 0
                when 'c' 
                    input = ''
                    refresh()

            return

        if name is 'backspace' 
            input = input[0..-2]
            return refresh()

        if name is 'tab'
            matches = []
            for action of actions
                matches.push action if action.match new RegExp "^#{input}"
            if matches.length == 1
                input = matches[0]
                hint  = ' ' + actions[matches[0]].args.grey
                return refresh()
            else
                console.log()
                console.log action, actions[action].args.grey for action in matches
                return refresh()


        if name is 'return'
            process.stdout.write '\n'
            doAction()
            process.stdout.write prompt + input
            return

        return unless chunk
        input += chunk.toString()
        refresh()

run()
