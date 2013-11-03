Mocha = require 'mocha'

module.exports = class MochaRunner

    constructor: (reporter) -> 

        @mocha = new Mocha reporter: reporter

    run: (files, callback) -> 

        @mocha.addFile file for file in files
        @mocha.run callback

