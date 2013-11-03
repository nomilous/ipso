should      = require 'should'
ipso        = require '../lib/ipso'
MochaRunner = require '../lib/mocha_runner'

describe 'MochaRunner', -> 

    it 'runs mocha tests', ipso (facto) -> 

        new MochaRunner (runner) -> facto()

