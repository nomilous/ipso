#
# PRE-RELEASE - ALPHA - CLI
# =========================
# 
# ipso -h
# 
# * Expect no consistency between versions (worst case)
# * Care **has already been taken** to minimize changes
# 


{deferred}     = require 'also'
{watcher}      = require './watcher'
{environment}  = require './environment'
{inspector}    = require './inspector'
{readFileSync, readdirSync, lstatSync} = require 'fs'
{normalize}    = require 'path'
{spawn}        = require 'child_process'
{sep}          = require 'path'
{compile}      = require 'coffee-script'
colors         = require 'colors'
program        = require 'commander'
# MochaRunner    = require './mocha_runner'
keypress       = require 'keypress'
keypress process.stdin

program.version JSON.parse( 
    readFileSync __dirname + '/../package.json'
    'utf8'
).version

program.option '-w, --no-watch',         'Dont watch spec and src dirs.'
program.option '-n, --no-env',           'Dont load .env.test'
program.option '-m, --mocha',            'Use mocha.'
program.option '-e, --alt-env [name]',   'Loads .env.name'
program.option '    --spec    [dir]',    'Specify alternate spec dir.',       'spec'
program.option '    --src     [dir]',    'Specify alternate src dir.',        'src'
program.option '    --lib     [dir]',    'Specify alternate compile target.', 'lib'


{env, altEnv, mocha, watch, spec, src, lib, env} = program.parse process.argv


kids = []

# if mocha then testRunner = MochaRunner.create reporter: 'Dot'
# MochaRunner.on 'spec_event', (payload) -> console.log payload

test = deferred ({resolve}, file) -> 
    
    unless file.split('.').pop().match /^js$|coffee$/
        console.log '\nipso: ' + "ignored #{file}".grey
        resolve()
        return

    unless mocha 
        console.log '\nipso: ' + "Unspecified spec scaffold.".red, "ipso --mocha"
        resolve()
        return

        #
        # mocha is not the default
        # there is no default yet
        #

    # console.log run: file
    # testRunner.run [file], resolve 


    
    ipsoPath = normalize __dirname + '/ipso'
    bin      = normalize __dirname + '/../node_modules/.bin/mocha'
    args     = [ 
        '--colors'
        '--compilers', 'coffee:coffee-script'
        '--require',   'should'
        file 
    ]

    #
    # * TODO: consider posibilities behind spec report to facto
    #       * related notes below
    # 

    console.log '\nipso: ' + "node_modules/.bin/mocha #{args.join ' '}".grey
    process.env.IPSO_SRC = src
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

    #
    # TODO: consider posibilities behind source diffs to facto
    #       * team's view of each developer progress / attempt
    #       * others can observe / assist a stuck team member
    #       * detecting stuck
    #

    console.log '\nipso: ' + "node_modules/.bin/coffee #{args.join ' '}".grey
    running = spawn bin, args, stdio: 'inherit'
    # running.stdout.on 'data', (chunk) -> refresh chunk.toString()
    # running.stderr.on 'data', (chunk) -> refresh chunk.toString(), 'stderr'
    running.on 'exit', resolve


if env or typeof altEnv is 'string' then environment altEnv

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
    'inspect': 
        args: '  [<web-port>, <debug-port>] <script>'
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
        # ----------------------------------------------------------------------
        # 
        # * TODO: find furtherest common match on tab
        #      
        #   ie. all files start with 'ser', tab on 's' should populate input to '**/ser'
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

    input = input.replace '  ', ' '
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
    input = ''

    switch act 
        when 'inspect'
            inspector args: args, kids, refresh
        else console.log action: act, args: trimmed if act?


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
            if act? then matches = secondaryTabComplete act
            else matches = primaryTabComplete()
                
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
