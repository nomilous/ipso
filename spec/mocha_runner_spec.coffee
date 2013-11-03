should      = require 'should'
ipso        = require '../lib/ipso'
MochaRunner = require '../lib/mocha_runner'

describe 'MochaRunner', -> 

    it 'runs mocha tests', ipso (facto) -> 

        mocha = new MochaRunner (runner) -> 

            runner.on 'start', -> facto()

        mocha.run [], ->
