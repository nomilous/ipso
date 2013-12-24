require('../lib/ipso').components (emitter) -> 

    #
    # components (and node_modules) are injected per the function argument names
    #

    e = new emitter
    e.on   'eventname', (payload) -> console.log received: payload
    e.emit 'eventname', 'DATA'

