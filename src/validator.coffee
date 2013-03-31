module.exports = class Validator

    configure: (scaffold, opts) -> 

        console.log 'Validator.configure', arguments

    edge: (placeholder, nodes) -> 

        console.log 'Validator.edge', arguments

    hup: ->

    handles: []

    matches: []

