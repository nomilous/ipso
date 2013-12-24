require('../lib/ipso').components (emitter) -> 

    e = new emitter
    e.on   'eventname', (payload) -> console.log received: payload
    e.emit 'eventname', 'DATA'

