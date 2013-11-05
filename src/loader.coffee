{parallel} = require 'also'

module.exports = (spectate, fnArgsArray) ->

    parallel( for nodule in fnArgsArray

        do (nodule) -> -> spectate require nodule

    )
