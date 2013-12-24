# require('ipso').components()
require('../lib/ipso').components()

#
# components then become requirable by name
#

Emitter = require 'emitter'
emitter = new Emitter

emitter.on   'eventname', (payload) -> console.log received: payload
emitter.emit 'eventname', 'DATA'
