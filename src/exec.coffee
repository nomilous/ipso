keypress = require 'keypress'
keypress process.stdin

#rompt = 'ipso://'
prompt = '> '
input  = ''

refresh = ->
    process.stdout.clearLine()
    process.stdout.cursorTo(0)
    process.stdout.write prompt + input

shutdown = (code) -> 
    
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
