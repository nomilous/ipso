Mocha = require 'mocha'

module.exports = class MochaRunner

    constructor: (reporter) -> 

        @mocha = new Mocha
        reporter()

