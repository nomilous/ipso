{deferred}     = require 'also'
{watcher}      = require './watcher'
{environment}  = require './environment'
{readFileSync, readdirSync, lstatSync} = require 'fs'
{normalize}    = require 'path'
{spawn}        = require 'child_process'
{sep}          = require 'path'
{compile}      = require 'coffee-script'
colors         = require 'colors'
program        = require 'commander'
keypress       = require 'keypress'
keypress process.stdin

program.version JSON.parse( 
    readFileSync __dirname + '/../package.json'
    'utf8'
).version

# program.option '-i, --inspector',           'Start node-inspector.'
# program.option '-w, --web-port [webPort]',  'Node inspector @ alternate port.'
program.option '-w, --no-watch',         'Dont watch spec and src dirs.'
program.option '-e, --env',              'Loads .env.user'
program.option '-a, --alt-env [name]',   'Loads .env.name'
program.option '    --spec    [dir]',    'Specify alternate spec dir.',       'spec'
program.option '    --src     [dir]',    'Specify alternate src dir.',        'src'
program.option '    --lib     [dir]',    'Specify alternate compile target.', 'lib'


{env, altEnv, watch, spec, src, lib, env} = program.parse process.argv


kids = []

# if inspector

#     bin = normalize __dirname + '/../node_modules/.bin/node-inspector'
#     kids.push kid = spawn bin, [
#         "--web-port=#{ (try parseInt webPort) || 8080}"
#     ]

#     kid.stdout.on 'data', (chunk) -> refresh chunk.toString()
#     kid.stderr.on 'data', (chunk) -> refresh chunk.toString(), 'stderr'


test = deferred ({resolve}, file) -> 
    
    bin    = normalize __dirname + '/../node_modules/.bin/mocha'
    args   = [ '--colors','--compilers', 'coffee:coffee-script', file ]
    console.log '\nipso: ' + "node_modules/.bin/mocha #{args.join ' '}".grey
    running = spawn bin, args, stdio: 'inherit'
    # running.stdout.on 'data', (chunk) -> refresh chunk.toString()
    # running.stderr.on 'data', (chunk) -> refresh chunk.toString(), 'stderr'
    running.on 'exit', resolve

compile = deferred ({resolve}) ->

    #
    # TODO: optional compile per file, (and not spawned)
    #

    bin    = normalize __dirname + '/../node_modules/.bin/coffee'
    args   = [ '-c', '-b', '-o', lib, src ]
    console.log '\nipso: ' + "node_modules/.bin/coffee #{args.join ' '}".grey
    running = spawn bin, args, stdio: 'inherit'
    # running.stdout.on 'data', (chunk) -> refresh chunk.toString()
    # running.stderr.on 'data', (chunk) -> refresh chunk.toString(), 'stderr'
    running.on 'exit', resolve


if env? or typeof altEnv is 'string' then environment altEnv

if watch

    watcher 
        path: program.spec || 'spec'
        handler: 
            change: (file, stats) -> 
                test( file ).then -> refresh()
    
    watcher 
        path: program.src || 'src'
        handler: 
            change: (file, stats) -> 
                return unless file.match /\.coffee/
                compile().then ->
                    refresh()
                    specFile = file.replace /\.coffee$/, '_spec.coffee' 
                    specFile = specFile.replace process.cwd() + sep + src, spec
                    test specFile
                .then -> refresh()
            

prompt    = '> '
input     = ''
argsHint  = ''

actions = 

    'node-debug':   
        args: ' [<port>] <script>'
        secondary: 'pathWalker'

    'coffee-debug': 
        args: ' [<port>] <script>'
        secondary: 'pathWalker'

primaryTabComplete = ->

    #
    # produce list of actions according to partial input without whitespace
    #

    matches = []
    for action of actions
        matches.push action if action.match new RegExp "^#{input}"
    if matches.length == 0

        #
        # no matches, reset and recurse for whole action list
        #

        input = ''
        return primaryTabComplete()

    return matches


secondaryTabComplete = (act) ->

    #
    # partial input has white space (ie command is present)
    #

    try secondaryType = actions[act].secondary
    return [] unless secondaryType

    if secondaryType == 'pathWalker'

        #
        # pathWalker - secondary tab completion walks the file tree (up or down)
        #

        try all  = input.split(' ').pop() # whitespace in path not supported in path...
        parts    = all.split sep
        last     = parts.pop()
        path     = process.cwd() + sep + parts.join( sep ) + sep
        files    = readdirSync path
        select   = files.filter (file) -> file.match new RegExp "^#{last}"
        
        if select.length == 1 

            input += select[0][last.length..]
            file = input.split(' ').pop()
            stat = lstatSync process.cwd() + sep + file
            if stat.isDirectory() then input += sep
            

        else 

            console.log()
            for part in select
                stat = lstatSync path + part
                if stat.isDirectory() then console.log part + sep
                else console.log part

        return []



refresh = (output, stream) ->

    #
    # write stream chunks to console but preserve prompt and partial input
    # stderr in red
    #

    if output?
        switch stream
            when 'stderr' then process.stdout.write output.red
            else process.stdout.write output

    process.stdout.clearLine()
    process.stdout.cursorTo 0
    process.stdout.write prompt + input + argsHint
    process.stdout.cursorTo (prompt + input).length


shutdown = (code) -> 

    kid.kill() for kid in kids
    process.exit code

doAction = -> 
    
    return if input == ''
    [act, args...] = input.split ' '
    trimmed = args.filter (arg) -> arg isnt ''
    console.log action: act, args: trimmed if act?
    input = ''

run = -> 

    stdin  = process.openStdin()
    process.stdin.setRawMode true
    refresh()
    process.stdin.on 'keypress', (chunk, key) -> 

        argsHint = ''

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

            try [m,act] = input.match /^(.*?)\s/

            if act?
                matches = secondaryTabComplete act
            else
                matches = primaryTabComplete()
                
            if matches.length == 1
                input = matches[0]
                argsHint  = ' ' + actions[matches[0]].args.grey
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
